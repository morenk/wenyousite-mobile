import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_published_floor_navigation.dart';

/// 发布后的阅读始终可操作；只对齐已读取窗口，不等待图片或字体稳定。
class ThreadPublishedFloorReading extends StatefulWidget {
  const ThreadPublishedFloorReading({
    required this.navigation,
    required this.targetKey,
    required this.itemListKey,
    required this.scrollController,
    required this.targetIndex,
    required this.itemCount,
    required this.onRetry,
    required this.onUserScroll,
    required this.child,
    super.key,
  });

  final ThreadPublishedFloorNavigation navigation;
  final GlobalKey targetKey;
  final GlobalKey itemListKey;
  final ScrollController scrollController;
  final int targetIndex;
  final int itemCount;
  final VoidCallback onRetry;
  final VoidCallback onUserScroll;
  final Widget child;

  @override
  State<ThreadPublishedFloorReading> createState() =>
      _ThreadPublishedFloorReadingState();
}

class _ThreadPublishedFloorReadingState
    extends State<ThreadPublishedFloorReading> {
  final _reveal = DiscussionTargetRevealCoordinator();

  @override
  Widget build(BuildContext context) {
    final navigation = widget.navigation;
    final post = navigation.post;
    if (post != null && navigation.ready && !navigation.aligned) {
      _reveal.schedule(
        targetId: post.id,
        scopeSignature: '${post.id}:${navigation.revision}',
        contentSignature: '${post.id}:${navigation.revision}',
        targetIndex: widget.targetIndex,
        itemCount: widget.itemCount,
        ready: true,
        targetKey: widget.targetKey,
        itemListKey: widget.itemListKey,
        scrollController: widget.scrollController,
        isMounted: () => mounted && navigation.ready && !navigation.aligned,
        requestRebuild: () => setState(() {}),
        onAligned: navigation.didAlign,
      );
    }
    return Column(
      children: [
        if (post != null && !navigation.ready && !navigation.aligned)
          WenyouStatusBanner(
            key: const Key('thread-published-floor-status'),
            message: navigation.loading
                ? '已发布，正在定位新楼层…'
                : navigation.failure != null
                ? '已发布，定位失败。'
                : navigation.clearedAuthor
                ? '已显示全部发言者，正在定位新楼层…'
                : '已发布。',
            action: navigation.loading
                ? null
                : TextButton(
                    key: const Key('thread-published-floor-retry'),
                    onPressed: navigation.ready ? null : widget.onRetry,
                    child: Text(navigation.failure == null ? '查看新楼层' : '重试定位'),
                  ),
          ),
        Expanded(
          child: NotificationListener<ScrollStartNotification>(
            onNotification: (notification) {
              if (notification.depth == 0 && notification.dragDetails != null) {
                _reveal.releaseForUserNavigation();
                widget.onUserScroll();
              }
              return false;
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
