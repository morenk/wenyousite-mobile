import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_demand_queue.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_integrity.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_snapshot.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime_policy.dart';

typedef TextFontDownload = Future<Uint8List> Function(TextFontAsset asset);
typedef TextFontRegister = Future<void> Function(String family, Uint8List data);

/// 与进程同寿命。Flutter 没有卸载字体 API，页面销毁绝不能重置计数。
class TextFontRuntime extends ChangeNotifier {
  TextFontRuntime({
    required this.cache,
    required this.download,
    TextFontRegister? register,
    TextFontNativeLedger? ledger,
  }) : register = register ?? _register,
       ledger = ledger ?? TextFontNativeLedger();
  final TextFontNativeLedger ledger;
  final TextFontCache cache;
  final TextFontDownload download;
  final TextFontRegister register;
  TextFontManifest? manifest;
  bool requiresRuntimePolicy = false;
  bool assetsAvailable = false;
  bool Function(String font)? fontUnavailable;
  int requests = 0;
  int downloadedBytes = 0;
  int registeredBytes = 0;
  // 普通 24 MiB 与原件额度独立累计；失败不能归还或挪用。
  int _originalReservedBytes = 0;
  int _originalDownloadedBytes = 0;
  int _originalRegisteredBytes = 0;
  final families = <String>{};
  final _registered = <String>{};
  final _failed = <String>{};
  final _notices = <String>{};
  Future<void> _queue = Future<void>.value();
  TextFontDemandQueue? demandQueue;
  final _demands = <Object, Map<String, String>>{};

  void enableContinuous(
    TextFontRuntimePolicy policy,
    TextFontDownloadWindow window,
    Duration Function() elapsed,
    void Function(TextFontAsset) cancel,
  ) {
    if (demandQueue != null || manifest == null) return;
    final snapshot = policy.freeze(manifest!);
    // 旧端点先加载的字体也属于同一引擎，协商v2不能重复注册。
    for (final shard in manifest!.fonts.values.expand((f) => f.shards)) {
      if (_registered.contains(shard.family)) {
        snapshot.beginNativeAttempt(shard);
        if (!_unavailableFaces.contains(shard.family)) {
          snapshot.completeNativeAttempt(shard);
        }
      }
    }
    snapshot.attachLedger(ledger);
    final queue = demandQueue = TextFontDemandQueue(
      cache: cache,
      download: download,
      register: register,
      snapshot: snapshot,
      window: window,
      elapsed: elapsed,
      cancelDownload: cancel,
    );
    queue.addListener(notifyListeners);
    queue.updateSource(manifest, downloadable: assetsAvailable);
    for (final entry in _demands.entries) {
      queue.setDemand(entry.key, entry.value);
    }
  }

  void enableDynamic(
    TextFontDownloadWindow window,
    Duration Function() elapsed,
    void Function(TextFontAsset) cancel,
  ) {
    if (demandQueue case final queue?) {
      queue.snapshot.attachLedger(ledger, dynamicVersions: true);
      return;
    }
    final queue = demandQueue = TextFontDemandQueue(
      cache: cache,
      download: download,
      register: register,
      snapshot: TextFontNativeSnapshot.dynamic(ledger),
      window: window,
      elapsed: elapsed,
      cancelDownload: cancel,
    );
    queue.addListener(notifyListeners);
    queue.updateSource(manifest, downloadable: assetsAvailable);
    for (final entry in _demands.entries) {
      queue.setDemand(entry.key, entry.value);
    }
  }

  void setDemand(Object owner, Map<String, String> texts) {
    _demands[owner] = Map.of(texts);
    if (demandQueue case final queue?) {
      queue.setDemand(owner, texts);
    } else {
      if (requiresRuntimePolicy) return;
      for (final entry in texts.entries) {
        unawaited(ensure(entry.key, entry.value));
      }
    }
  }

  void release(Object owner) {
    _demands.remove(owner);
    demandQueue?.release(owner);
  }

  int get registeredFaces => _registered.length;
  int get originalReservedBytes => _originalReservedBytes;
  int get originalDownloadedBytes => _originalDownloadedBytes;
  int get originalRegisteredBytes => _originalRegisteredBytes;

  void updateManifest(TextFontManifest? value) {
    manifest = value;
    demandQueue?.updateSource(value, downloadable: assetsAvailable);
    notifyListeners();
  }

  /// 目录重试也进入同一队列，避免与字体/声明下载争用缓存写入。
  Future<T> schedule<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        result.complete(await action());
      } on Object catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  static Future<void> _register(String family, Uint8List data) async {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(data)));
    await loader.load();
  }

  List<String> loadedFamilies(String id) => [
    for (final shard in manifest?.fonts[id]?.shards ?? <TextFontShard>[])
      if (demandQueue != null
          ? demandQueue!.snapshot.loadedFamily(shard) != null
          : ledger.loaded(hash: shard.asset.hash, family: shard.family))
        shard.family,
  ];

  TextStyle style(String id, TextStyle base) {
    final loaded = loadedFamilies(id);
    return loaded.isEmpty
        ? base
        : base.copyWith(
            fontFamily: loaded.first,
            fontFamilyFallback: [
              ...loaded.skip(1),
              if (base.fontFamily != null) base.fontFamily!,
              ...?base.fontFamilyFallback,
            ],
          );
  }

  Future<Uint8List> asset(TextFontAsset descriptor) async {
    // 原件只能经家族/分片/许可检查后一次性预留，不能借公共资源入口重试。
    if (descriptor.isOriginal) throw const TextFontUnavailable();
    return _asset(descriptor);
  }

  Future<Uint8List> _asset(TextFontAsset descriptor) async {
    final cached = await cache.read(descriptor);
    if (cached != null) return cached;
    if (!assetsAvailable ||
        requests >= 64 ||
        (!descriptor.isOriginal &&
            downloadedBytes + descriptor.bytes > 24 * 1024 * 1024)) {
      throw const TextFontUnavailable();
    }
    requests++;
    if (descriptor.isOriginal) {
      _originalDownloadedBytes += descriptor.bytes;
    } else {
      downloadedBytes += descriptor.bytes;
    }
    // 串行队列使下载并发保持 1（契约上限 2），损坏缓存只下载一次。
    final bytes = await download(
      descriptor,
    ).timeout(const Duration(seconds: 15));
    if (!await verifyTextFontAsset(descriptor, bytes)) {
      throw const FormatException('字体资源校验失败');
    }
    await cache.write(descriptor, bytes);
    return bytes;
  }

  Future<void> ensure(String id, String text) {
    if (demandQueue case final queue?) {
      final owner = Object();
      queue.setDemand(owner, {id: text});
      return queue.settle().whenComplete(() => queue.release(owner));
    }
    if (requiresRuntimePolicy) return Future<void>.value();
    final completer = Completer<void>();
    _queue = _queue.then((_) async {
      try {
        await _ensure(id, text);
      } on Object {
        // 资源与原生字体失败不改变正文；本进程固定回退，避免滚动重试。
        _failed.add(id);
      } finally {
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> _ensure(String id, String text) async {
    if (!MarkdownTextFont.ids.contains(id)) return;
    final font = manifest?.fonts[id];
    if (font == null || !font.ready || _failed.contains(id)) return;
    if (!families.contains(id) && families.length >= 8) return;
    final runes = text.runes.toSet();
    final needed = font.shards
        .where((s) => runes.any(s.contains) && !_registered.contains(s.family))
        .toList();
    if (needed.isEmpty) return;
    families.add(id);
    for (final notice in font.notices) {
      if (!_notices.contains(notice.hash)) {
        await asset(notice);
        cache.pinned.add(notice.hash);
        _notices.add(notice.hash);
      }
    }
    for (final shard in needed) {
      if (!ledger.canAttempt(
        hash: shard.asset.hash,
        family: shard.family,
        inputBytes: shard.asset.bytes,
      )) {
        continue;
      }
      final original = shard.asset.isOriginal;
      if (_registered.length >= 32 ||
          (original
              ? _originalReservedBytes != 0
              : registeredBytes + shard.asset.bytes > 24 * 1024 * 1024)) {
        break;
      }
      if (original) {
        // 下载或缓存首次注册之前预留，失败/超时也永久消耗本进程额度。
        _originalReservedBytes = TextFontOriginal.bytes;
      }
      final bytes = await _asset(shard.asset);
      if (!ledger.beginNativeAttempt(
        hash: shard.asset.hash,
        family: shard.family,
        inputBytes: bytes.length,
      )) {
        continue;
      }
      // 原生注册失败也不能假定内存已释放，先保守消耗预算。
      if (original) {
        _originalRegisteredBytes += bytes.length;
      } else {
        registeredBytes += bytes.length;
      }
      _registered.add(shard.family);
      try {
        await register(shard.family, bytes);
        ledger.completeNativeAttempt(
          hash: shard.asset.hash,
          family: shard.family,
        );
      } on Object {
        _unavailableFaces.add(shard.family);
        rethrow;
      }
      cache.pinned.add(shard.asset.hash);
      notifyListeners();
    }
  }

  final _unavailableFaces = <String>{};
}

class TextFontUnavailable implements Exception {
  const TextFontUnavailable();
}
