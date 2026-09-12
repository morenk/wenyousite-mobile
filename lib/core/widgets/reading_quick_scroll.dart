import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_controller.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_overlay.dart';

export 'reading_quick_scroll_controller.dart';

class ReadingQuickScrollAction extends StatelessWidget {
  const ReadingQuickScrollAction({required this.controller, super.key});

  final ReadingQuickScrollController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Semantics(
      button: true,
      enabled: controller.enabled,
      toggled: controller.isOpen,
      label: '快翻',
      excludeSemantics: true,
      onTap: controller.enabled ? controller.toggle : null,
      child: IconButton(
        key: const Key('reading-quick-scroll-toggle'),
        tooltip: '快翻',
        style: IconButton.styleFrom(
          minimumSize: Size.square(context.wenyouTokens.minimumTouchTarget),
        ),
        onPressed: controller.enabled ? controller.toggle : null,
        icon: const WenyouIcon(WenyouIconIds.actionReadingQuickScroll),
      ),
    ),
  );
}

/// 默认进度提示不接管触摸；主动打开时仅滑块与操作卡接收局部手势。
class ReadingProgressViewport extends StatelessWidget {
  const ReadingProgressViewport({
    required this.controller,
    required this.child,
    this.hasMore = false,
    this.loading = false,
    this.loadFailed = false,
    this.onRetry,
    this.bottomObstructionKey,
    super.key,
  });

  final ReadingQuickScrollController controller;
  final Widget child;
  final bool hasMore;
  final bool loading;
  final bool loadFailed;
  final VoidCallback? onRetry;
  final GlobalKey? bottomObstructionKey;

  @override
  Widget build(BuildContext context) => ReadingQuickScrollOverlay(
    controller: controller,
    hasMore: hasMore,
    loading: loading,
    loadFailed: loadFailed,
    onRetry: onRetry,
    bottomObstructionKey: bottomObstructionKey,
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
        child: ListenableBuilder(
          listenable: controller,
          child: child,
          builder: (context, content) => RawScrollbar(
            key: const Key('reading-progress-indicator'),
            controller: controller.scrollController,
            interactive: false,
            thickness: 2,
            crossAxisMargin: 2,
            radius: Radius.circular(context.wenyouTokens.radiusPill),
            thumbColor: controller.isOpen
                ? Colors.transparent
                : context.wenyouTokens.brandForeground,
            timeToFade: const Duration(milliseconds: 1500),
            fadeDuration: const Duration(milliseconds: 180),
            notificationPredicate: (notification) =>
                notification.depth == 0 &&
                notification.metrics.axis == Axis.vertical,
            child: content!,
          ),
        ),
      ),
    ),
  );
}
