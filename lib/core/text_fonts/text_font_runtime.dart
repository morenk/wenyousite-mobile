import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

typedef TextFontDownload = Future<Uint8List> Function(TextFontAsset asset);
typedef TextFontRegister = Future<void> Function(String family, Uint8List data);

/// 与进程同寿命。Flutter 没有卸载字体 API，页面销毁绝不能重置计数。
class TextFontRuntime extends ChangeNotifier {
  TextFontRuntime({
    required this.cache,
    required this.download,
    TextFontRegister? register,
  }) : register = register ?? _register;
  final TextFontCache cache;
  final TextFontDownload download;
  final TextFontRegister register;
  TextFontManifest? manifest;
  bool assetsAvailable = false;
  int requests = 0;
  int downloadedBytes = 0;
  int registeredBytes = 0;
  final families = <String>{};
  final _registered = <String>{};
  final _failed = <String>{};
  final _notices = <String>{};
  Future<void> _queue = Future<void>.value();

  int get registeredFaces => _registered.length;

  void updateManifest(TextFontManifest? value) {
    manifest = value;
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
      if (_registered.contains(shard.family) &&
          !_unavailableFaces.contains(shard.family))
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
    final cached = await cache.read(descriptor);
    if (cached != null) return cached;
    if (!assetsAvailable ||
        requests >= 64 ||
        downloadedBytes + descriptor.bytes > 24 * 1024 * 1024) {
      throw const TextFontUnavailable();
    }
    requests++;
    downloadedBytes += descriptor.bytes;
    // 串行队列使下载并发保持 1（契约上限 2），损坏缓存只下载一次。
    final bytes = await download(
      descriptor,
    ).timeout(const Duration(seconds: 15));
    if (!descriptor.verifies(bytes)) throw const FormatException('字体资源校验失败');
    await cache.write(descriptor, bytes);
    return bytes;
  }

  Future<void> ensure(String id, String text) {
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
      if (_registered.length >= 32 ||
          registeredBytes + shard.asset.bytes > 24 * 1024 * 1024) {
        break;
      }
      final bytes = await asset(shard.asset);
      // 原生注册失败也不能假定内存已释放，先保守消耗预算。
      registeredBytes += bytes.length;
      _registered.add(shard.family);
      try {
        await register(shard.family, bytes);
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
