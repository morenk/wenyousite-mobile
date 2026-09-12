import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 页面持有，滚动控制器的生命周期仍归页面；不保存跨页面阅读进度。
class ReadingQuickScrollController extends ChangeNotifier {
  ReadingQuickScrollController({
    required this.scrollController,
    required this.onUserNavigation,
    this.pinnedHeaderKey,
  }) {
    scrollController.addListener(_onScroll);
  }

  final ScrollController scrollController;
  final VoidCallback onUserNavigation;
  final GlobalKey? pinnedHeaderKey;
  final _anchors = <RenderBox, String>{};
  Object? _scope;
  Object? _contentRevision;
  double? _measuredMax;
  bool _disposed = false;
  bool _snapshotScheduled = false;
  bool _moveScheduled = false;
  bool _open = false;
  bool _enabled = false;
  bool _dragging = false;
  bool _followingEnd = false;
  double _fraction = 0;
  double _dragMin = 0;
  double _dragMax = 0;
  double? _pendingOffset;
  int _epoch = 0;
  String _location = '阅读位置';
  bool? _failedEdge;

  bool get isOpen => _open;
  bool get enabled => _enabled;
  bool get isDragging => _dragging;
  bool get isFollowingEnd => _dragging && _followingEnd;
  double get fraction => _fraction;
  String get location => _location;
  bool get edgeFailed => _failedEdge != null;
  bool get canScroll =>
      scrollController.hasClients &&
      scrollController.position.hasContentDimensions &&
      scrollController.position.maxScrollExtent >
          scrollController.position.minScrollExtent;

  /// 在页面 build 中同步，子控件随该次 build 更新，不能在此发通知。
  void synchronize({
    required Object scope,
    required bool enabled,
    Object? contentRevision,
  }) {
    if (_scope != scope || !enabled) {
      _cancelMovement();
      _open = false;
      _location = '阅读位置';
      _fraction = 0;
      _measuredMax = null;
    }
    if (_contentRevision != contentRevision) _measuredMax = null;
    _contentRevision = contentRevision;
    _scope = scope;
    _enabled = enabled;
    scheduleSnapshot();
  }

  void toggle() {
    if (!_enabled) return;
    // 显式导航后解除旧目标的自动对齐，悬浮控件不改变阅读视口。
    onUserNavigation();
    _cancelMovement();
    _open = !_open;
    notifyListeners();
    scheduleSnapshot();
  }

  void close() {
    _cancelMovement();
    if (!_open) return;
    _open = false;
    notifyListeners();
  }

  void _cancelMovement() {
    _epoch++;
    _pendingOffset = null;
    _dragging = false;
    _followingEnd = false;
    _failedEdge = null;
  }

  void beginDrag(double value) {
    if (!_enabled || !_open || !canScroll) return;
    _cancelMovement();
    onUserNavigation();
    final p = scrollController.position;
    _dragMin = p.minScrollExtent;
    _dragMax = _readingMax(p);
    _dragging = true;
    updateDrag(value);
  }

  void updateDrag(double value) {
    if (!_dragging) beginDrag(value);
    if (!_dragging) return;
    if (_followingEnd) {
      // 离开末端时以刚抵达的范围继续微调，避免退回开始拖动时的旧范围。
      final p = scrollController.position;
      _dragMin = p.minScrollExtent;
      _dragMax = p.maxScrollExtent;
    }
    _fraction = value.clamp(0, 1);
    _followingEnd = _fraction == 1;
    _queueMove(
      _followingEnd
          ? scrollController.position.maxScrollExtent
          : _dragMin + (_dragMax - _dragMin) * _fraction,
    );
  }

  void _queueMove(double offset) {
    _pendingOffset = offset;
    if (_moveScheduled) return;
    _moveScheduled = true;
    WidgetsBinding.instance.scheduleFrameCallback((_) {
      _moveScheduled = false;
      if (_disposed) return;
      final offset = _pendingOffset;
      _pendingOffset = null;
      if (offset != null && scrollController.hasClients) {
        final p = scrollController.position;
        scrollController.jumpTo(
          offset.clamp(p.minScrollExtent, p.maxScrollExtent),
        );
      }
      scheduleSnapshot();
    });
  }

  double? _adjustForMeasuredRange(ScrollMetrics metrics) {
    if (!_dragging ||
        _followingEnd ||
        metrics.maxScrollExtent >= _dragMax ||
        metrics.maxScrollExtent < metrics.minScrollExtent) {
      return null;
    }
    // 首次懒布局可能把长楼层高度外推到整份列表；收缩后的旧映射会
    // 使滑杆尚在中间、正文已经到底。只收紧估算，在布局内校正，
    // 避免先绘制底部再在下一帧跳回。分页增长仍保持当前拖动范围。
    _dragMin = metrics.minScrollExtent;
    _dragMax = metrics.maxScrollExtent;
    _measuredMax = _dragMax;
    return _dragMin + (_dragMax - _dragMin) * _fraction;
  }

  double _readingMax(ScrollPosition position) =>
      (_measuredMax ?? position.maxScrollExtent).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );

  void _invalidateMeasuredRange() {
    if (_measuredMax == null) return;
    _measuredMax = null;
    scheduleSnapshot();
  }

  void endDrag(double value) {
    if (!_dragging) return;
    updateDrag(value);
    _dragging = false;
    _followingEnd = false;
    // 最后一个手指位置仍在下一帧应用，不启动惯性或后续自动跟随。
    scheduleSnapshot();
  }

  void step(double value) {
    beginDrag(value);
    endDrag(value);
  }

  /// 触摸取消不应用尚未绘制的输入，也不能遗留末端跟随。
  void cancelDrag() {
    if (_disposed || !_dragging) return;
    _cancelMovement();
    scheduleSnapshot();
  }

  void stepByViewport(int direction) {
    if (!canScroll || !_enabled || !_open) return;
    final position = scrollController.position;
    final range = _readingMax(position) - position.minScrollExtent;
    if (range <= 0) return;
    step(
      (_fraction + direction * position.viewportDimension / range).clamp(0, 1),
    );
  }

  void seekEdge(bool end) {
    if (!_enabled || !_open || !scrollController.hasClients) return;
    _cancelMovement();
    onUserNavigation();
    final epoch = _epoch;
    var attempts = 0;
    var stable = 0;
    void correct(Duration _) {
      if (_disposed || epoch != _epoch || !scrollController.hasClients) return;
      final p = scrollController.position;
      final target = end ? p.maxScrollExtent : p.minScrollExtent;
      if ((p.pixels - target).abs() <= 1) {
        stable++;
      } else {
        stable = 0;
        scrollController.jumpTo(target);
      }
      if (stable >= 2) {
        if (end) _measuredMax = p.maxScrollExtent;
        scheduleSnapshot();
        return;
      }
      if (++attempts >= 12) {
        _failedEdge = end;
        scheduleSnapshot();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback(correct);
      WidgetsBinding.instance.ensureVisualUpdate();
    }

    WidgetsBinding.instance.addPostFrameCallback(correct);
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void retryEdge() {
    final edge = _failedEdge;
    if (edge != null) seekEdge(edge);
  }

  bool handleScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _cancelMovement();
    }
    return false;
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        _measuredMax != null &&
        scrollController.position.pixels > _measuredMax! + 1) {
      _measuredMax = null;
    }
    scheduleSnapshot();
  }

  void registerAnchor(RenderBox box, String label) {
    _anchors[box] = label;
    scheduleSnapshot();
  }

  void unregisterAnchor(RenderBox box) => _anchors.remove(box);

  void scheduleSnapshot() {
    if (_disposed || _snapshotScheduled) return;
    _snapshotScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _snapshotScheduled = false;
      if (_disposed) return;
      if (scrollController.hasClients) {
        final p = scrollController.position;
        if (p.hasContentDimensions && isFollowingEnd) {
          _dragMin = p.minScrollExtent;
          _dragMax = p.maxScrollExtent;
          // 只在仍按住末端且布局边界改变时继续推进；静止等待分页不空转。
          if ((p.pixels - p.maxScrollExtent).abs() > 1) {
            _queueMove(p.maxScrollExtent);
          } else {
            _measuredMax = p.maxScrollExtent;
          }
        }
        if (p.hasContentDimensions && !_dragging && _pendingOffset == null) {
          final range = _readingMax(p) - p.minScrollExtent;
          _fraction = range <= 0
              ? 0
              : ((p.pixels - p.minScrollExtent) / range).clamp(0, 1);
        }
        _location = _visibleLocation();
      }
      notifyListeners();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  String _visibleLocation() {
    final view = scrollController.position.context.notificationContext
        ?.findRenderObject();
    if (view is! RenderBox || !view.hasSize) return '阅读位置';
    var top = view.localToGlobal(Offset.zero).dy;
    final bottom = top + view.size.height;
    final header = pinnedHeaderKey?.currentContext?.findRenderObject();
    if (header is RenderBox && header.hasSize && header.attached) {
      final headerTop = header.localToGlobal(Offset.zero).dy;
      if ((headerTop - top).abs() <= 1) top += header.size.height;
    }
    var nearest = double.infinity;
    var label = '阅读位置';
    for (final entry in _anchors.entries) {
      final box = entry.key;
      if (!box.attached || !box.hasSize || !hasLiveScrollGeometry(box)) {
        continue;
      }
      final y = box.localToGlobal(Offset.zero).dy;
      if (!y.isFinite || y + box.size.height <= top || y >= bottom) continue;
      final distance = y <= top ? 0.0 : y - top;
      if (distance < nearest) {
        nearest = distance;
        label = entry.value;
      }
    }
    return label;
  }

  static bool hasLiveScrollGeometry(RenderObject target) {
    RenderObject child = target;
    while (child.parent != null) {
      final parent = child.parent!;
      if (parent is RenderSliver && parent.childScrollOffset(child) == null) {
        return false;
      }
      if (parent is RenderAbstractViewport) return true;
      child = parent;
    }
    return false;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelMovement();
    _anchors.clear();
    scrollController.removeListener(_onScroll);
    super.dispose();
  }
}

/// 仅接到页面主阅读列表，保留原滚动、回弹及下拉刷新规则。
class ReadingQuickScrollPhysics extends ScrollPhysics {
  const ReadingQuickScrollPhysics({required this.controller, super.parent});

  final ReadingQuickScrollController controller;

  @override
  ReadingQuickScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      ReadingQuickScrollPhysics(
        controller: controller,
        parent: buildParent(ancestor),
      );

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) =>
      controller._adjustForMeasuredRange(newPosition) ??
      super.adjustPositionForNewDimensions(
        oldPosition: oldPosition,
        newPosition: newPosition,
        isScrolling: isScrolling,
        velocity: velocity,
      );
}

/// 只登记已布局的正文，不为了定位创建屏幕外 Markdown 或图片。
class ReadingPositionAnchor extends SingleChildRenderObjectWidget {
  const ReadingPositionAnchor({
    required this.controller,
    required this.label,
    required super.child,
    super.key,
  });

  final ReadingQuickScrollController controller;
  final String label;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ReadingAnchor(controller, label);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderProxyBox renderObject,
  ) {
    (renderObject as _ReadingAnchor).update(controller, label);
  }
}

class _ReadingAnchor extends RenderProxyBox {
  _ReadingAnchor(this.controller, this.label);

  ReadingQuickScrollController controller;
  String label;
  Size? _lastSize;

  @override
  void performLayout() {
    super.performLayout();
    if (_lastSize != null && _lastSize != size) {
      controller._invalidateMeasuredRange();
    }
    _lastSize = size;
  }

  void update(ReadingQuickScrollController next, String text) {
    controller.unregisterAnchor(this);
    controller = next;
    label = text;
    if (attached) controller.registerAnchor(this, label);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    controller.registerAnchor(this, label);
  }

  @override
  void detach() {
    controller.unregisterAnchor(this);
    super.detach();
  }
}
