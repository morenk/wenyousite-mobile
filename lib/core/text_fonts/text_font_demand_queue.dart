import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_integrity.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_snapshot.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_progress.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';

/// 只消费已验证的资源描述，不读取尚未发布的策略字段。
/// 订阅者描述当前有效需求；整个进程共用此队列、窗口和注册快照。
class TextFontDemandQueue extends ChangeNotifier {
  TextFontDemandQueue({
    required this.cache,
    required this.download,
    required this.register,
    required this.snapshot,
    required this.window,
    this.cancelDownload,
    TextFontRetryLedger? retries,
    Duration Function()? elapsed,
  }) : retries = retries ?? TextFontRetryLedger(),
       _elapsed = elapsed ?? (Stopwatch()..start()).elapsedDuration;

  final TextFontCache cache;
  final Future<Uint8List> Function(TextFontAsset) download;
  final Future<void> Function(String, Uint8List) register;
  final void Function(TextFontAsset)? cancelDownload;
  final TextFontNativeSnapshot snapshot;
  final TextFontDownloadWindow window;
  final TextFontRetryLedger retries;
  final progress = TextFontProgressLedger();
  final Duration Function() _elapsed;
  final _demands = <Object, Map<String, String>>{};
  final _pending = <String, _FontWork>{};
  final _notices = <String>{};
  final _registering = <String>{};
  TextFontManifest? _manifest;
  bool _onlineSource = false;
  bool _foreground = true;
  bool _online = true;
  bool _disposed = false;
  bool _dirty = false;
  bool _metadataPaused = false;
  int _sourceEpoch = 0;
  Future<void>? _draining;
  Timer? _timer;
  TextFontAsset? _activeDownload;
  int requests = 0;
  int attemptedDownloadBytes = 0;
  int verifiedDownloadBytes = 0;

  int get pendingCount => _pending.length;
  bool get hasTimer => _timer?.isActive ?? false;

  void reportReceived(String path, int bytes) {
    final asset = _activeDownload;
    if (asset != null &&
        (path == asset.path || path.endsWith('/${asset.path}'))) {
      progress.received(asset, bytes);
    }
  }

  TextFontLoadProgress progressFor(
    String id,
    String text,
    Set<String> tracked,
  ) {
    final font = _manifest?.fonts[id];
    if (font == null) {
      return const TextFontLoadProgress(phase: TextFontProgressPhase.preparing);
    }
    final runes = text.runes.toSet();
    final needed = font.shards
        .where((shard) => runes.any(shard.contains))
        .toList();
    if (!font.ready ||
        font.notices.any(
          (n) => retries.isTerminal(n.hash) || n.bytes > window.maximumBytes,
        ) ||
        needed.any(
          (s) =>
              snapshot.loadedFamily(s) == null &&
              ((!snapshot.canAttempt(s) && !_registering.contains(s.family)) ||
                  s.asset.bytes > window.maximumBytes ||
                  retries.isTerminal(s.asset.hash)),
        )) {
      return const TextFontLoadProgress(phase: TextFontProgressPhase.failed);
    }
    tracked.retainAll(needed.map((s) => s.asset.hash));
    for (final shard in needed) {
      if (snapshot.loadedFamily(shard) == null) tracked.add(shard.asset.hash);
    }
    return progress.summarize(
      needed.where((s) => tracked.contains(s.asset.hash)).map((s) => s.asset),
      applicable: needed.every((s) => snapshot.loadedFamily(s) != null),
    );
  }

  void updateSource(TextFontManifest? manifest, {required bool downloadable}) {
    _sourceEpoch++;
    _manifest = manifest;
    _onlineSource = downloadable;
    _reconcile();
    wake();
    notifyListeners();
  }

  void setForeground(bool value) {
    _foreground = value;
    if (!value) {
      _timer?.cancel();
      if (_activeDownload case final asset?) cancelDownload?.call(asset);
    } else {
      wake();
    }
  }

  void setOnline(bool value) {
    _online = value;
    if (!value) {
      _timer?.cancel();
      if (_activeDownload case final asset?) cancelDownload?.call(asset);
    } else {
      wake();
    }
  }

  void setDemand(Object owner, Map<String, String> texts) {
    if (_disposed) return;
    if (mapEquals(_demands[owner], texts)) return;
    _demands[owner] = Map.of(texts);
    _reconcile();
    wake();
  }

  void release(Object owner) {
    _demands.remove(owner);
    _reconcile();
    wake();
  }

  void _reconcile() {
    final wanted = <String, _FontWork>{};
    for (final texts in _demands.values) {
      for (final entry in texts.entries) {
        final font = _manifest?.fonts[entry.key];
        if (font == null || !font.ready) continue;
        final runes = entry.value.runes.toSet();
        for (final shard in font.shards) {
          if (!snapshot.canAttempt(shard) ||
              shard.asset.bytes > window.maximumBytes ||
              font.notices.any(
                (notice) => notice.bytes > window.maximumBytes,
              ) ||
              !runes.any(shard.contains)) {
            continue;
          }
          for (final notice in font.notices) {
            if (!_notices.contains(notice.hash)) {
              wanted[notice.hash] = _FontWork(notice);
            }
          }
          final work = wanted.putIfAbsent(
            shard.asset.hash,
            () => _FontWork(shard.asset),
          );
          work.shards[shard.family] = shard;
          work.notices.addAll(font.notices.map((n) => n.hash));
        }
      }
    }
    _pending.removeWhere((key, work) {
      if (wanted.containsKey(key)) return false;
      if (!work.shards.values.any((s) => snapshot.loadedFamily(s) != null)) {
        progress.forget(key);
      }
      return true;
    });
    for (final entry in wanted.entries) {
      _pending[entry.key] = entry.value;
    }
    if (_activeDownload case final asset?) {
      if (!_pending.containsKey(asset.hash)) cancelDownload?.call(asset);
    }
    if (_pending.isEmpty) _timer?.cancel();
  }

  /// 网络/前台事件仅唤醒检查，不能重置退避或跳过Retry-After。
  void wake() {
    if (_disposed || !_foreground || _metadataPaused || _pending.isEmpty) {
      return;
    }
    if (_draining != null) {
      _dirty = true;
      return;
    }
    _timer?.cancel();
    final done = Completer<void>();
    _draining = done.future;
    unawaited(
      _drain().whenComplete(() {
        _draining = null;
        done.complete();
        if (_dirty) {
          _dirty = false;
          wake();
        }
      }),
    );
  }

  Future<void> settle() async {
    while (_draining != null) {
      await _draining;
    }
  }

  /// 元数据和样张排队等待当前传输结束，不取消仍持续接收正文的下载。
  Future<void> pauseForMetadata() async {
    _metadataPaused = true;
    _timer?.cancel();
    await settle();
  }

  void resumeAfterMetadata() {
    _metadataPaused = false;
    wake();
  }

  Future<void> _drain() async {
    // 只探测本轮正文需要的分片，不预取字库。先核验缓存，下载第一片时
    // 即可报告完整且扣除缓存的总量；不会因后续分片尚未开始而缺失分母。
    for (final work in _pending.values.toList()) {
      if (_disposed || !_foreground || _metadataPaused) return;
      if (work.shards.isEmpty || progress.knows(work.asset.hash)) continue;
      Uint8List? cached;
      try {
        cached = await cache.read(work.asset);
      } on FileSystemException {
        cached = null;
      }
      if (_disposed || !_pending.containsKey(work.asset.hash)) continue;
      if (cached == null) {
        progress.waiting(work.asset);
      } else {
        progress.cached(work.asset);
      }
    }
    Duration? next;
    int? earlierBytes;
    void defer(Duration due) {
      if (next == null || due < next!) next = due;
    }

    for (final work in _pending.values.toList()) {
      if (_disposed || !_foreground || _metadataPaused) break;
      final asset = work.asset;
      final sourceEpoch = _sourceEpoch;
      if (!_pending.containsKey(asset.hash) || retries.isTerminal(asset.hash)) {
        continue;
      }
      if (work.notices.any((hash) => !_notices.contains(hash))) continue;
      final now = _elapsed();
      if (retries.availableAt(asset.hash) > now) {
        defer(retries.availableAt(asset.hash));
        continue;
      }
      Uint8List? bytes;
      try {
        try {
          bytes = await cache.read(asset);
        } on FileSystemException {
          bytes = null;
        }
        if (!_pending.containsKey(asset.hash) || !_foreground || _disposed) {
          continue;
        }
        if (work.shards.isNotEmpty) {
          if (bytes == null) {
            progress.waiting(asset);
          } else {
            progress.cached(asset);
          }
        }
        if (bytes == null) {
          if (!_onlineSource || !_online) {
            // 目录恢复由服务层负责；离线时仍先尝试合法缓存。
            continue;
          }
          final ready = window.availableAt(asset.bytes, _elapsed());
          if (!window.reserve(
            asset.bytes,
            _elapsed(),
            reservedForEarlier: earlierBytes,
          )) {
            earlierBytes ??= asset.bytes;
            defer(
              ready > now
                  ? ready
                  : window.availableAt(earlierBytes, _elapsed()),
            );
            continue;
          }
          requests++;
          attemptedDownloadBytes += asset.bytes;
          _activeDownload = asset;
          if (work.shards.isNotEmpty) progress.start(asset);
          try {
            // 传输层按非空字节续idle并保留不可续期的总上限。
            bytes = await download(asset);
          } finally {
            _activeDownload = null;
          }
          if (!await verifyTextFontAsset(asset, bytes)) {
            throw const FormatException('字体资源校验失败');
          }
          if (work.shards.isNotEmpty) progress.applying(asset, bytes.length);
          verifiedDownloadBytes += bytes.length;
          try {
            await cache.write(asset, bytes);
          } on FileSystemException {
            // 缓存实现不可写时仍消费本次已验证输入，不重新下载。
          }
        }
        retries.success(asset.hash);
      } on Object catch (error) {
        if (_disposed) break;
        if (error is FormatException ||
            error is TextFontTransferFailure &&
                error.kind == TextFontTransferFailureKind.quarantined) {
          retries.quarantine(asset.hash);
          progress.failed(asset);
        } else if (error is! TextFontTransferFailure ||
            error.kind != TextFontTransferFailureKind.cancelled) {
          retries.transientFailure(
            asset.hash,
            _elapsed(),
            retryAfter: error is TextFontTransferFailure
                ? error.retryAfter
                : null,
          );
          defer(retries.availableAt(asset.hash));
          if (work.shards.isNotEmpty) progress.waiting(asset);
        } else if (work.shards.isNotEmpty) {
          progress.waiting(asset);
        }
        continue;
      }
      if (_disposed ||
          !_foreground ||
          sourceEpoch != _sourceEpoch ||
          !_pending.containsKey(asset.hash)) {
        continue;
      }
      if (work.shards.isEmpty) {
        _notices.add(asset.hash);
        cache.pinned.add(asset.hash);
      } else {
        // 同一SHA只取一次输入，每个family独立登记。原生失败只隔离该键。
        for (final shard in work.shards.values) {
          if (!snapshot.beginNativeAttempt(shard)) continue;
          _registering.add(shard.family);
          try {
            await register(shard.family, bytes);
            snapshot.completeNativeAttempt(shard);
          } on Object {
            // attempted已保留占用，不能退款或再次调用该键。
            progress.failed(asset);
          } finally {
            _registering.remove(shard.family);
          }
        }
        if (work.shards.values.every((s) => snapshot.loadedFamily(s) != null)) {
          progress.complete(asset);
        }
      }
      _pending.remove(asset.hash);
      _reconcile();
      if (_pending.isNotEmpty && next == null) _dirty = true;
      if (!_disposed) notifyListeners();
    }
    if (!_disposed && _foreground && _pending.isNotEmpty && next != null) {
      final delay = next! - _elapsed();
      _timer = Timer(
        delay > Duration.zero ? delay : const Duration(milliseconds: 1),
        wake,
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    if (_activeDownload case final asset?) cancelDownload?.call(asset);
    _demands.clear();
    _pending.clear();
    progress.dispose();
    super.dispose();
  }
}

class _FontWork {
  _FontWork(this.asset);
  final TextFontAsset asset;
  final shards = <String, TextFontShard>{};
  final notices = <String>{};
}

extension on Stopwatch {
  Duration elapsedDuration() => elapsed;
}
