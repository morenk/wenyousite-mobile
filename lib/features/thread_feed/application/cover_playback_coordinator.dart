import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';

const coverPlaybackSettleDelay = Duration(milliseconds: 120);
const coverPlaybackMinimumVisibleFraction = 0.5;

enum CoverPlaybackPhase { idle, preparing, playing }

class CoverPlaybackGeometry {
  const CoverPlaybackGeometry({
    required this.cover,
    required this.viewport,
    this.visibleBounds,
  });

  final Rect cover;
  final Rect viewport;
  final Rect? visibleBounds;

  double get visibleFraction {
    final bounds = visibleBounds ?? viewport;
    if (cover.isEmpty || bounds.isEmpty || !cover.overlaps(bounds)) {
      return 0;
    }
    final intersection = cover.intersect(bounds);
    return intersection.width *
        intersection.height /
        (cover.width * cover.height);
  }

  double get distance => (cover.center - viewport.center).distanceSquared;
}

/// 一个应用作用域内只有一个动画租约；失效时同步通知播放器释放解码器。
class CoverPlaybackCoordinator extends ChangeNotifier {
  CoverPlaybackCoordinator({this.source});
  final CoverAnimationSource? source;
  final _candidates = <Object, CoverPlaybackGeometry? Function()>{};
  Timer? _settle;
  bool _reviewPending = false;
  int _reviewEpoch = 0;
  Object? _preparing;
  Object? _selected;
  Object? _previous;
  bool _allowed = true;
  bool _scrolling = false;
  bool _disposed = false;

  Object? get selected => _selected;
  Object? get preparing => _preparing;

  void register(Object token, CoverPlaybackGeometry? Function() measure) {
    _candidates[token] = measure;
    settle();
  }

  void unregister(Object token) {
    if (_candidates.remove(token) == null) return;
    if (_preparing == token) interrupt();
    if (_previous == token) _previous = null;
    settle();
  }

  void setAllowed(bool allowed) {
    if (_allowed == allowed) return;
    _allowed = allowed;
    interrupt();
    if (allowed) settle();
  }

  void scrollStarted() {
    _scrolling = true;
    interrupt();
  }

  void scrollEnded() {
    _scrolling = false;
    settle();
  }

  void interrupt() {
    _settle?.cancel();
    _settle = null;
    _reviewPending = false;
    _reviewEpoch++;
    if (_selected != null) _previous = _selected;
    if (_selected != null || _preparing != null) {
      _selected = null;
      _preparing = null;
      notifyListeners();
    }
  }

  void settle() {
    if (!_allowed || _scrolling || _disposed) return;
    // 同帧的 poster 注册只测量一次，不重置已有中心候选的确认计时。
    if (_reviewPending) return;
    _reviewPending = true;
    final epoch = _reviewEpoch;
    scheduleMicrotask(() {
      if (epoch != _reviewEpoch || _disposed) return;
      _reviewPending = false;
      _prepare();
    });
  }

  void _prepare() {
    if (!_allowed || _scrolling || _disposed) return;
    final best = _best();
    if (best == _preparing) return;
    // 先通知全部旧播放器释放，再授予新准备租约，避免监听顺序造成双解码。
    interrupt();
    if (best == null) return;
    _preparing = best;
    notifyListeners();
    _settle = Timer(coverPlaybackSettleDelay, () {
      _settle = null;
      if (!_allowed || _scrolling || _disposed) return;
      if (_best() != _preparing) {
        _prepare();
      } else {
        _select(_preparing);
      }
    });
  }

  Object? _best() {
    Object? best;
    var bestDistance = double.infinity;
    for (final entry in _candidates.entries) {
      final geometry = entry.value();
      if (geometry == null ||
          geometry.visibleFraction < coverPlaybackMinimumVisibleFraction) {
        continue;
      }
      final distance = geometry.distance;
      if (distance < bestDistance ||
          (distance == bestDistance &&
              entry.key == (_preparing ?? _previous))) {
        best = entry.key;
        bestDistance = distance;
      }
    }
    return best;
  }

  void _select(Object? token) {
    if (_selected == token || _disposed) return;
    _selected = token;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _settle?.cancel();
    _reviewEpoch++;
    _candidates.clear();
    source?.releaseMemory();
    super.dispose();
  }
}
