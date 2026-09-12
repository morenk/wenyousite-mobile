import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_controller.dart';

class ReadingQuickScrollCard extends StatelessWidget {
  const ReadingQuickScrollCard({
    required this.controller,
    required this.status,
    required this.hasMore,
    required this.loadFailed,
    required this.onRetry,
    required this.onDismiss,
    super.key,
  });
  final ReadingQuickScrollController controller;
  final String? status;
  final bool hasMore;
  final bool loadFailed;
  final VoidCallback? onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Material(
      key: const Key('reading-quick-scroll-card'),
      color: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius20),
        side: BorderSide(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              controller.location,
              style: Theme.of(context).textTheme.wenyouCaption,
            ),
            if (status != null)
              Padding(
                padding: EdgeInsets.only(top: tokens.space8),
                child: Text(
                  status!,
                  style: Theme.of(context).textTheme.wenyouCaption,
                ),
              ),
            if (controller.edgeFailed) const Text('跳转失败，请重试。'),
            Wrap(
              spacing: tokens.space4,
              children: [
                TextButton(
                  key: const Key('reading-quick-scroll-start'),
                  onPressed: controller.canScroll
                      ? () {
                          onDismiss();
                          controller.seekEdge(false);
                        }
                      : null,
                  child: const Text('开头'),
                ),
                TextButton(
                  key: const Key('reading-quick-scroll-end'),
                  onPressed: controller.canScroll
                      ? () {
                          onDismiss();
                          controller.seekEdge(true);
                        }
                      : null,
                  child: Text(hasMore ? '已加载末尾' : '末尾'),
                ),
                if (loadFailed)
                  TextButton(
                    key: const Key('reading-quick-scroll-retry-load'),
                    onPressed: onRetry,
                    child: const Text('重试加载'),
                  ),
                if (controller.edgeFailed)
                  TextButton(
                    key: const Key('reading-quick-scroll-retry-edge'),
                    onPressed: controller.retryEdge,
                    child: const Text('重试跳转'),
                  ),
                TextButton(
                  key: const Key('reading-quick-scroll-close'),
                  onPressed: controller.close,
                  child: const Text('收起'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
