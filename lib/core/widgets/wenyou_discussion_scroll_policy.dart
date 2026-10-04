import 'package:flutter/rendering.dart'
    show
        RenderAbstractViewport,
        RenderObject,
        RenderSliver,
        RenderSliverMultiBoxAdaptor,
        SliverMultiBoxAdaptorParentData,
        ScrollCacheExtent;
import 'package:flutter/widgets.dart';

/// 只预布局可见区域两侧各两屏；离屏行正常释放，选字等临时状态由子组件保留。
const discussionScrollCacheExtent = ScrollCacheExtent.viewport(2.0);

/// Starts one discussion text prefetch task after the current frame is
/// delivered, without scheduling duplicates during intervening rebuilds.
class DiscussionPrefetchScheduler {
  var _scheduled = false;

  void schedule({
    required bool shouldPrefetch,
    required bool Function() isMounted,
    required VoidCallback prefetch,
  }) {
    if (_scheduled || !shouldPrefetch) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (isMounted()) prefetch();
    });
  }
}

/// Reveals a discussion target that may not have been materialized by its
/// lazy sliver yet. The target owns automatic movement until the first user
/// drag, and can be reset when route or filter context changes.
class DiscussionTargetRevealCoordinator {
  String? _lastContentSignature;
  String? _scopeSignature;
  String? _attemptTargetId;
  String? _seekContentSignature;
  final _visitedSeeks = <String>{};
  var _scheduled = false;
  var _releasedByUser = false;

  void reset() {
    _lastContentSignature = null;
    _scopeSignature = null;
    _attemptTargetId = null;
    _seekContentSignature = null;
    _visitedSeeks.clear();
    _scheduled = false;
    _releasedByUser = false;
  }

  void schedule({
    required String targetId,
    required String scopeSignature,
    required String contentSignature,
    required int targetIndex,
    required int itemCount,
    required bool ready,
    required GlobalKey targetKey,
    required GlobalKey itemListKey,
    required ScrollController scrollController,
    required bool Function() isMounted,
    required VoidCallback requestRebuild,
    double? targetOffset,
    VoidCallback? onAligned,
  }) {
    if (_scopeSignature != scopeSignature) {
      reset();
      _scopeSignature = scopeSignature;
    }
    if (!ready ||
        targetIndex < 0 ||
        targetIndex >= itemCount ||
        _releasedByUser ||
        _scheduled ||
        _lastContentSignature == contentSignature) {
      return;
    }
    if (_attemptTargetId != targetId ||
        _seekContentSignature != contentSignature) {
      _attemptTargetId = targetId;
      _seekContentSignature = contentSignature;
      _visitedSeeks.clear();
    }
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!isMounted() ||
          _releasedByUser ||
          _scopeSignature != scopeSignature) {
        return;
      }
      final targetContext = targetKey.currentContext;
      if (targetContext != null && _canReveal(targetContext)) {
        alignDiscussionTarget(
          targetContext,
          scrollController,
          offset: targetOffset,
        );
        _lastContentSignature = contentSignature;
        _attemptTargetId = null;
        _visitedSeeks.clear();
        onAligned?.call();
        return;
      }
      if (!scrollController.hasClients) {
        return;
      }
      final list = itemListKey.currentContext?.findRenderObject();
      if (list is! RenderSliverMultiBoxAdaptor || !list.attached) return;
      final viewport = RenderAbstractViewport.maybeOf(list);
      if (viewport == null) return;
      final position = scrollController.position;
      final first = list.firstChild;
      final last = list.lastChild;
      double destination;
      if (first == null || last == null) {
        destination = viewport.getOffsetToReveal(list, 0).offset;
      } else if (targetIndex > list.indexOf(last)) {
        // 沿已完成布局的行边界前进，不能用平均行高估算长短混排的目标。
        destination =
            viewport.getOffsetToReveal(last, 0).offset + last.size.height;
      } else if (targetIndex < list.indexOf(first)) {
        destination =
            viewport.getOffsetToReveal(first, 0).offset -
            position.viewportDimension;
      } else {
        var row = first;
        while (list.indexOf(row) < targetIndex) {
          row = list.childAfter(row)!;
        }
        destination = viewport.getOffsetToReveal(row, 0).offset;
      }
      destination = destination.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      // 几何尚未推进时停止重排；内容更新会重新尝试，不限制目标距离。
      final seek =
          '$contentSignature:${first == null ? null : list.indexOf(first)}:'
          '${last == null ? null : list.indexOf(last)}:${position.pixels}:$destination';
      if (!destination.isFinite ||
          (destination - position.pixels).abs() < 0.5 ||
          !_visitedSeeks.add(seek)) {
        return;
      }
      scrollController.jumpTo(destination);
      if (isMounted()) requestRebuild();
    });
  }

  static bool _canReveal(BuildContext context) {
    // Kept-alive sliver children retain context after losing layout geometry.
    final target = context.findRenderObject();
    if (target == null || !target.attached) return false;
    RenderObject child = target;
    while (child.parent != null) {
      final parent = child.parent!;
      final parentData = child.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData &&
          parentData.keptAlive) {
        return false;
      }
      if (parent is RenderSliver && parent.childScrollOffset(child) == null) {
        return false;
      }
      if (parent is RenderAbstractViewport) return true;
      child = parent;
    }
    return false;
  }

  bool handleLayoutChange({
    required bool Function() isMounted,
    required VoidCallback requestRebuild,
  }) {
    if (_scopeSignature == null ||
        _lastContentSignature == null ||
        _releasedByUser) {
      return false;
    }
    _lastContentSignature = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isMounted()) requestRebuild();
    });
    return false;
  }

  bool handleUserScroll(ScrollNotification notification) {
    final startsUserScroll =
        notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical &&
        notification is ScrollStartNotification &&
        notification.dragDetails != null &&
        _scopeSignature != null;
    if (startsUserScroll) _releasedByUser = true;
    return false;
  }

  /// 滑杆和首尾按钮发起的是程序滚动，也必须结束深链的自动对齐。
  void releaseForUserNavigation() => _releasedByUser = true;
}

/// 返回使用实际视口坐标，避免把吸顶目录高度重复加入条目内偏移。
void alignDiscussionTarget(
  BuildContext context,
  ScrollController scroll, {
  double? offset,
}) {
  if (offset == null) {
    Scrollable.ensureVisible(context, duration: Duration.zero, alignment: 0);
    return;
  }
  final target = context.findRenderObject();
  if (target == null || !target.attached || !scroll.hasClients) return;
  final viewport = RenderAbstractViewport.of(target);
  final revealed = viewport.getOffsetToReveal(target, 0);
  final position = scroll.position;
  scroll.jumpTo(
    (revealed.offset + revealed.rect.top + offset).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ),
  );
}
