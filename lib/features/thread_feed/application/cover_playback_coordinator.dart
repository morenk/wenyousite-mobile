import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';

const coverPlaybackMinimumVisibleFraction = 0.5;

enum CoverPlaybackPhase { idle, playing }

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
    final bounds = (visibleBounds ?? viewport).intersect(viewport);
    if (cover.isEmpty || bounds.isEmpty || !cover.overlaps(bounds)) return 0;
    final intersection = cover.intersect(bounds);
    return intersection.width *
        intersection.height /
        (cover.width * cover.height);
  }
}

/// 半可见时激活，完全离屏才停止；每帧合并测量，持续可见项保持自己的播放器。
class CoverPlaybackCoordinator extends ChangeNotifier {
  CoverPlaybackCoordinator({this.source});
  final CoverAnimationSource? source;
  final _candidates = <Object, CoverPlaybackGeometry? Function()>{};
  final _active = <Object>{};
  bool _reviewPending = false;
  int _reviewEpoch = 0;
  bool _allowed = true;
  bool _disposed = false;

  Set<Object> get activeTokens => Set.unmodifiable(_active);
  bool isActive(Object token) => _active.contains(token);

  void register(Object token, CoverPlaybackGeometry? Function() measure) {
    _candidates[token] = measure;
    remeasure();
  }

  void unregister(Object token) {
    _candidates.remove(token);
    if (_active.remove(token) && !_disposed) notifyListeners();
  }

  void setAllowed(bool allowed) {
    if (_allowed == allowed) return;
    _allowed = allowed;
    if (!allowed) {
      interrupt();
    } else {
      remeasure();
    }
  }

  void interrupt() {
    _reviewPending = false;
    _reviewEpoch++;
    if (_active.isEmpty || _disposed) return;
    _active.clear();
    notifyListeners();
  }

  void remeasure() {
    if (!_allowed || _disposed || _reviewPending) return;
    _reviewPending = true;
    final epoch = _reviewEpoch;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_disposed || epoch != _reviewEpoch) return;
      _reviewPending = false;
      _refresh();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _refresh() {
    if (!_allowed || _disposed) return;
    final next = <Object>{};
    for (final entry in _candidates.entries) {
      final fraction = entry.value()?.visibleFraction ?? 0;
      if (_active.contains(entry.key)
          ? fraction > 0
          : fraction >= coverPlaybackMinimumVisibleFraction) {
        next.add(entry.key);
      }
    }
    if (setEquals(next, _active)) return;
    _active
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _reviewEpoch++;
    _active.clear();
    _candidates.clear();
    source?.releaseMemory();
    super.dispose();
  }
}
