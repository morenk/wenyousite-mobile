import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

/// 只根据当前窗口的真实阅读位置补相邻页；按住滑块时冻结窗口边界。
class DiscussionWindowPrefetch {
  DiscussionWindowPrefetch({
    required this.reading,
    required this.isMounted,
    this.canMutate,
    this.clock,
  }) {
    _watch.start();
    reading.addListener(_onReading);
  }

  final ReadingQuickScrollController reading;
  final bool Function() isMounted;
  final bool Function()? canMutate;
  final Duration Function()? clock;
  final _watch = Stopwatch();
  Duration get _now => clock?.call() ?? _watch.elapsed;
  List<String> _ids = const [];
  bool _ready = false;
  bool _hasBefore = false;
  bool _hasAfter = false;
  bool _scheduled = false;
  bool _busy = false;
  bool _disposed = false;
  bool? _pendingBefore;
  bool _reversed = false;
  int _direction = 0;
  double _speed = 0;
  double _latencySeconds = .2;
  double? _lastPixels;
  Duration? _lastSample;
  Object? _lastRequestPosition;
  Future<void> Function(bool before)? _load;

  void update({
    required List<String> ids,
    required bool ready,
    required bool hasBefore,
    required bool hasAfter,
    required Future<void> Function(bool before) load,
  }) {
    if ((_ids.firstOrNull, _ids.lastOrNull) !=
        (ids.firstOrNull, ids.lastOrNull)) {
      // 窗口前插和裁剪的像素补偿不作为阅读速度。
      _lastPixels = null;
      _lastSample = null;
      _speed = 0;
      _lastRequestPosition = null;
    }
    _ids = ids;
    _ready = ready;
    _hasBefore = hasBefore;
    _hasAfter = hasAfter;
    _load = load;
    _schedule();
  }

  bool get canApply =>
      !_disposed &&
      !_reversed &&
      isMounted() &&
      !reading.isDragging &&
      canMutate?.call() != false;

  void resume() => _schedule();

  void _onReading() {
    _sample();
    _schedule();
  }

  void _sample() {
    final scroll = reading.scrollController;
    if (!scroll.hasClients) return;
    final now = _now;
    final pixels = scroll.position.pixels;
    final previous = _lastPixels;
    final elapsed = _lastSample == null
        ? 0
        : (now - _lastSample!).inMicroseconds;
    if (previous != null && (pixels - previous).abs() >= 1) {
      final delta = pixels - previous;
      _direction = delta < 0 ? -1 : 1;
      if (elapsed > 0) _speed = delta.abs() * 1000000 / elapsed;
      if (_busy && _pendingBefore != (_direction < 0)) _reversed = true;
    }
    _lastPixels = pixels;
    _lastSample = now;
  }

  void _schedule() {
    if (_disposed || _scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!canApply || !_ready || _busy || _ids.isEmpty) return;
      final scroll = reading.scrollController;
      if (!scroll.hasClients || !scroll.position.hasContentDimensions) return;
      if (_lastPixels == null) _sample();
      final position = scroll.position;
      final viewport = position.viewportDimension;
      final active =
          _lastSample != null &&
          _now - _lastSample! < const Duration(milliseconds: 500);
      // 常规响应按速度提前，但最多四屏；持续慢响应退回基础两屏。
      final extra = active && _latencySeconds < 2 && viewport > 0
          ? _speed * math.min(_latencySeconds, .8) / viewport
          : 0.0;
      final lead = viewport * (2 + extra).clamp(2, 4);
      final index = _ids.indexOf(reading.visibleBookmark?.id ?? '');
      final before =
          _hasBefore &&
          ((index >= 0 && index < 5) ||
              (_direction < 0 && position.extentBefore <= lead));
      final after =
          _hasAfter &&
          ((index >= 0 && index >= _ids.length - 5) ||
              position.extentAfter <= lead);
      if (!before && !after) {
        _lastRequestPosition = null;
        return;
      }
      final preferBefore =
          before &&
          (!after ||
              _direction < 0 ||
              (_direction == 0 &&
                  position.extentBefore < position.extentAfter));
      unawaited(_request(preferBefore));
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _request(bool before) async {
    final position = (
      before,
      _ids.firstOrNull,
      _ids.lastOrNull,
      reading.visibleBookmark?.id,
    );
    // 可见条目保护阻止裁剪时，等待读者移动；不能重复请求同一页。
    if (_lastRequestPosition == position) return;
    _lastRequestPosition = position;
    _busy = true;
    _pendingBefore = before;
    _reversed = false;
    final started = _now;
    try {
      await _load?.call(before);
    } finally {
      final elapsed = (_now - started).inMicroseconds / 1000000;
      if (elapsed > 0) _latencySeconds = elapsed;
      final rejected = !canApply;
      _busy = false;
      _pendingBefore = null;
      _reversed = false;
      if (rejected) _lastRequestPosition = null;
      if (!_disposed) _schedule();
    }
  }

  void dispose() {
    _disposed = true;
    _watch.stop();
    reading.removeListener(_onReading);
  }
}
