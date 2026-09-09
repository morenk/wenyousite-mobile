import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';

const coverPlaybackSettleDelay = Duration(milliseconds: 300);
const coverPlaybackMinimumVisibleFraction = 0.5;

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
  Object? _selected;
  Object? _previous;
  bool _allowed = true;
  bool _scrolling = false;
  bool _disposed = false;

  Object? get selected => _selected;

  void register(Object token, CoverPlaybackGeometry? Function() measure) {
    _candidates[token] = measure;
    settle();
  }

  void unregister(Object token) {
    if (_candidates.remove(token) == null) return;
    if (_selected == token) _select(null);
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
    if (_selected != null) _previous = _selected;
    _select(null);
  }

  void settle() {
    _settle?.cancel();
    if (!_allowed || _scrolling || _disposed) return;
    _settle = Timer(coverPlaybackSettleDelay, _choose);
  }

  void _choose() {
    if (!_allowed || _scrolling || _disposed) return;
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
          (distance == bestDistance && entry.key == (_selected ?? _previous))) {
        best = entry.key;
        bestDistance = distance;
      }
    }
    _select(best);
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
    _candidates.clear();
    source?.releaseMemory();
    super.dispose();
  }
}
