import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

enum TextFontProgressPhase {
  preparing,
  downloading,
  waiting,
  applying,
  complete,
  failed,
}

@immutable
class TextFontLoadProgress {
  const TextFontLoadProgress({
    required this.phase,
    this.receivedBytes = 0,
    this.totalBytes,
    this.usedNetwork = false,
  });
  final TextFontProgressPhase phase;
  final int receivedBytes;
  final int? totalBytes;
  final bool usedNetwork;
  double? get fraction {
    if (phase == TextFontProgressPhase.complete) return 1;
    final total = totalBytes;
    // 字节收齐不等于校验、原生注册已完成，不伪造 99% 或提前显示 100%。
    if (phase != TextFontProgressPhase.downloading ||
        total == null ||
        total == 0 ||
        receivedBytes >= total) {
      return null;
    }
    return receivedBytes / total;
  }
}

class _AssetProgress {
  _AssetProgress(this.phase, {this.network = false, this.cached = false});
  TextFontProgressPhase phase;
  int received = 0;
  bool network, cached;
}

/// 独立于字体可用性通知，分块进度最多每 100ms 更新一次订阅者。
class TextFontProgressLedger extends ChangeNotifier {
  final _assets = <String, _AssetProgress>{};
  Timer? _notification;
  bool _disposed = false;
  bool knows(String hash) => _assets.containsKey(hash);

  void cached(TextFontAsset asset) {
    _assets[asset.hash] = _AssetProgress(
      TextFontProgressPhase.applying,
      cached: true,
    );
    _changed();
  }

  void waiting(TextFontAsset asset) {
    final state = _assets.putIfAbsent(
      asset.hash,
      () => _AssetProgress(TextFontProgressPhase.waiting),
    );
    state.phase = TextFontProgressPhase.waiting;
    _changed();
  }

  void start(TextFontAsset asset) {
    _assets[asset.hash] = _AssetProgress(
      TextFontProgressPhase.downloading,
      network: true,
    );
    _changed();
  }

  void received(TextFontAsset asset, int bytes) {
    final state = _assets[asset.hash];
    if (state == null ||
        state.phase != TextFontProgressPhase.downloading ||
        bytes < state.received ||
        bytes > asset.bytes) {
      return;
    }
    state.received = bytes;
    if (!_disposed) {
      _notification ??= Timer(const Duration(milliseconds: 100), _changed);
    }
  }

  void applying(TextFontAsset asset, int bytes) {
    final state = _assets[asset.hash];
    if (state == null) return;
    state.received = bytes;
    state.phase = TextFontProgressPhase.applying;
    _changed();
  }

  void failed(TextFontAsset asset) {
    _assets[asset.hash]?.phase = TextFontProgressPhase.failed;
    // 必需声明文件不计入字体字节总量，但其终态也必须唤醒作者进度。
    _changed();
  }

  void complete(TextFontAsset asset) {
    _assets[asset.hash]?.phase = TextFontProgressPhase.complete;
    _changed();
  }

  void forget(String hash) {
    if (_assets.remove(hash) != null) _changed();
  }

  TextFontLoadProgress summarize(
    Iterable<TextFontAsset> requiredAssets, {
    required bool applicable,
  }) {
    final assets = {for (final asset in requiredAssets) asset.hash: asset};
    var received = 0, total = 0;
    var known = true,
        network = false,
        failed = false,
        waiting = false,
        downloading = false;
    for (final asset in assets.values) {
      final state = _assets[asset.hash];
      if (state == null) {
        known = false;
        continue;
      }
      if (state.cached) continue;
      total += asset.bytes;
      received += state.received;
      network |= state.network;
      failed |= state.phase == TextFontProgressPhase.failed;
      waiting |= state.phase == TextFontProgressPhase.waiting;
      downloading |= state.phase == TextFontProgressPhase.downloading;
    }
    return TextFontLoadProgress(
      phase: applicable
          ? TextFontProgressPhase.complete
          : failed
          ? TextFontProgressPhase.failed
          : !known
          ? TextFontProgressPhase.preparing
          : downloading && received < total
          ? TextFontProgressPhase.downloading
          : waiting
          ? TextFontProgressPhase.waiting
          : TextFontProgressPhase.applying,
      receivedBytes: received,
      totalBytes: known ? total : null,
      usedNetwork: network,
    );
  }

  void _changed() {
    _notification?.cancel();
    _notification = null;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _notification?.cancel();
    super.dispose();
  }
}
