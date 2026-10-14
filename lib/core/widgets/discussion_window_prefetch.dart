import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

/// 只根据当前窗口的真实阅读位置补相邻页；按住滑块时冻结窗口边界。
class DiscussionWindowPrefetch {
  DiscussionWindowPrefetch({
    required this.reading,
    required this.isMounted,
    this.canMutate,
  }) {
    reading.addListener(_schedule);
  }

  final ReadingQuickScrollController reading;
  final bool Function() isMounted;
  final bool Function()? canMutate;
  List<String> _ids = const [];
  bool _ready = false;
  bool _hasBefore = false;
  bool _hasAfter = false;
  bool _scheduled = false;
  bool _busy = false;
  bool _disposed = false;
  Object? _lastRequestPosition;
  Future<void> Function(bool before)? _load;

  void update({
    required List<String> ids,
    required bool ready,
    required bool hasBefore,
    required bool hasAfter,
    required Future<void> Function(bool before) load,
  }) {
    _ids = ids;
    _ready = ready;
    _hasBefore = hasBefore;
    _hasAfter = hasAfter;
    _load = load;
    _schedule();
  }

  bool get canApply =>
      !_disposed &&
      isMounted() &&
      !reading.isDragging &&
      canMutate?.call() != false;

  void resume() => _schedule();

  void _schedule() {
    if (_disposed || _scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!canApply || !_ready || _busy) return;
      final scroll = reading.scrollController;
      if (!scroll.hasClients || !scroll.position.hasContentDimensions) return;
      final index = _ids.indexOf(reading.visibleBookmark?.id ?? '');
      final before = _hasBefore && index >= 0 && index < 5;
      final after =
          _hasAfter &&
          ((index >= 0 && index >= _ids.length - 5) ||
              scroll.position.extentAfter <=
                  scroll.position.viewportDimension * 2);
      if (before || after) unawaited(_request(before));
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _request(bool before) async {
    final position = (
      before,
      _ids.firstOrNull,
      _ids.lastOrNull,
      reading.visibleBookmark?.id,
      reading.scrollController.position.pixels,
    );
    // 可见条目保护阻止裁剪时，等待读者移动；不能重复请求同一页。
    if (_lastRequestPosition == position) return;
    _lastRequestPosition = position;
    _busy = true;
    try {
      await _load?.call(before);
    } finally {
      _busy = false;
      if (!canApply) _lastRequestPosition = null;
    }
  }

  void dispose() {
    _disposed = true;
    reading.removeListener(_schedule);
  }
}
