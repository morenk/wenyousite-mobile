import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';

/// 只观察主阅读列表的实际几何，不以预布局到的评论或页脚触发请求。
class MomentCommentPagination extends ConsumerStatefulWidget {
  const MomentCommentPagination({
    required this.momentId,
    required this.scrollController,
    required this.enabled,
    required this.onScroll,
    required this.child,
    super.key,
  });

  final String momentId;
  final ScrollController scrollController;
  final bool enabled;
  final ValueChanged<ScrollNotification> onScroll;
  final Widget child;

  @override
  ConsumerState<MomentCommentPagination> createState() =>
      _MomentCommentPaginationState();
}

class _MomentCommentPaginationState
    extends ConsumerState<MomentCommentPagination> {
  final _scheduler = DiscussionPrefetchScheduler();

  void _schedule() {
    _scheduler.schedule(
      shouldPrefetch: widget.enabled,
      isMounted: () => mounted,
      prefetch: () {
        if (!widget.enabled || !widget.scrollController.hasClients) return;
        final position = widget.scrollController.position;
        if (!position.hasContentDimensions ||
            position.outOfRange ||
            !wenyouShouldPrefetch(position)) {
          return;
        }
        unawaited(
          ref
              .read(momentDetailControllerProvider(widget.momentId).notifier)
              .loadMoreComments(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(momentDetailControllerProvider(widget.momentId));
    // 首屏和追加结果不足一屏时也继续补足；控制器阻止并发及失败重试。
    _schedule();
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        widget.onScroll(notification);
        if (notification.depth == 0 &&
            notification.metrics.axis == Axis.vertical &&
            (notification is ScrollUpdateNotification ||
                notification is OverscrollNotification)) {
          _schedule();
        }
        return false;
      },
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.axis == Axis.vertical) {
            _schedule();
          }
          return false;
        },
        child: widget.child,
      ),
    );
  }
}
