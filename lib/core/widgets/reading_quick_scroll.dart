import 'package:flutter/widgets.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_controller.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_overlay.dart';

export 'reading_quick_scroll_controller.dart';

/// 三个阅读页共用的入口；只有展开滑块接管局部触摸。
class ReadingProgressViewport extends StatelessWidget {
  const ReadingProgressViewport({
    required this.controller,
    required this.child,
    this.hasMore = false,
    this.loading = false,
    this.loadFailed = false,
    this.bottomObstructionKey,
    super.key,
  });

  final ReadingQuickScrollController controller;
  final Widget child;
  final bool hasMore;
  final bool loading;
  final bool loadFailed;
  final GlobalKey? bottomObstructionKey;

  @override
  Widget build(BuildContext context) => ReadingQuickScrollOverlay(
    controller: controller,
    hasMore: hasMore,
    loading: loading,
    loadFailed: loadFailed,
    bottomObstructionKey: bottomObstructionKey,
    child: Listener(
      onPointerCancel: (_) => controller.close(),
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.axis == Axis.vertical) {
            controller.scheduleSnapshot();
          }
          return false;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: controller.handleScroll,
          child: child,
        ),
      ),
    ),
  );
}
