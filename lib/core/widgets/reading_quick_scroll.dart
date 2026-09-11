import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_controller.dart';

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

/// 仅提供视觉进度；不在正文边缘注册拖拽或点击手势。
class ReadingProgressViewport extends StatelessWidget {
  const ReadingProgressViewport({
    required this.controller,
    required this.child,
    super.key,
  });

  final ReadingQuickScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.axis == Axis.vertical) {
            controller.scheduleSnapshot();
          }
          return false;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: controller.handleScroll,
          child: RawScrollbar(
            key: const Key('reading-progress-indicator'),
            controller: controller.scrollController,
            interactive: false,
            thickness: 2,
            crossAxisMargin: 2,
            radius: Radius.circular(context.wenyouTokens.radiusPill),
            thumbColor: context.wenyouTokens.brandForeground,
            timeToFade: const Duration(milliseconds: 1500),
            fadeDuration: const Duration(milliseconds: 180),
            notificationPredicate: (notification) =>
                notification.depth == 0 &&
                notification.metrics.axis == Axis.vertical,
            child: child,
          ),
        ),
      );
}

/// 放在 Scaffold 的 bottomNavigationBar 内，改变视口而不盖住正文。
class ReadingQuickScrollBar extends StatelessWidget {
  const ReadingQuickScrollBar({
    required this.controller,
    required this.hasMore,
    required this.loading,
    required this.loadFailed,
    required this.onRetry,
    this.bottomSafeArea = false,
    super.key,
  });

  final ReadingQuickScrollController controller;
  final bool hasMore;
  final bool loading;
  final bool loadFailed;
  final VoidCallback onRetry;
  final bool bottomSafeArea;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      if (!controller.isOpen) return const SizedBox.shrink();
      final tokens = context.wenyouTokens;
      return Material(
        key: const Key('reading-quick-scroll-bar'),
        color: tokens.panel,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: tokens.border)),
          ),
          child: SafeArea(
            top: false,
            bottom: bottomSafeArea,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.location,
                          style: Theme.of(context).textTheme.wenyouCaption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        key: const Key('reading-quick-scroll-close'),
                        onPressed: controller.close,
                        child: const Text('收起'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        key: const Key('reading-quick-scroll-start'),
                        onPressed: controller.canScroll
                            ? () => controller.seekEdge(false)
                            : null,
                        child: const Text('开头'),
                      ),
                      Expanded(
                        child: Semantics(
                          label: '快翻阅读位置',
                          child: Slider(
                            key: const Key('reading-quick-scroll-slider'),
                            value: controller.fraction,
                            semanticFormatterCallback: (_) =>
                                controller.location,
                            onChangeStart: controller.canScroll
                                ? controller.beginDrag
                                : null,
                            onChanged: !controller.canScroll
                                ? null
                                : (value) {
                                    if (controller.isDragging) {
                                      controller.updateDrag(value);
                                    } else {
                                      controller.step(value);
                                    }
                                  },
                            onChangeEnd: controller.canScroll
                                ? controller.endDrag
                                : null,
                          ),
                        ),
                      ),
                      TextButton(
                        key: const Key('reading-quick-scroll-end'),
                        onPressed: controller.canScroll
                            ? () => controller.seekEdge(true)
                            : null,
                        child: Text(
                          hasMore ? '已加载\n末尾' : '末尾',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (hasMore)
                    _StatusLine(
                      text: loadFailed
                          ? '更多内容加载失败，当前可快翻已加载内容'
                          : controller.isFollowingEnd
                          ? loading
                                ? '正在加载更多，按住末端继续快翻'
                                : '按住末端继续快翻，松手即可停下'
                          : loading
                          ? '正在加载更多，当前可快翻已加载内容'
                          : '当前可快翻已加载内容',
                      onRetry: loadFailed ? onRetry : null,
                    ),
                  if (controller.edgeFailed)
                    _StatusLine(
                      text: '跳转失败，请重试。',
                      onRetry: controller.retryEdge,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.wenyouTokens.space8),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.wenyouCaption),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('重试')),
      ],
    ),
  );
}
