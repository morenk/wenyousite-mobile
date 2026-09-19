import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

bool wenyouShouldPrefetch(ScrollMetrics metrics, {double threshold = 480}) {
  return metrics.axis == Axis.vertical && metrics.extentAfter < threshold;
}

class WenyouPaginationFooter extends StatelessWidget {
  const WenyouPaginationFooter({
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
    this.failure,
    this.loadMoreLabel = '加载更多',
    this.loadingLabel = '正在加载更多',
    this.endLabel = '已经到底了',
    this.showEndLabel = true,
    this.retryLabel = '重试',
    this.loadMoreKey,
    this.retryKey,
    super.key,
  });

  final bool hasMore;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final ApiFailure? failure;
  final String loadMoreLabel;
  final String loadingLabel;
  final String endLabel;
  final bool showEndLabel;
  final String retryLabel;
  final Key? loadMoreKey;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
    if (!showEndLabel && !hasMore && !isLoading && failure == null) {
      return const SizedBox.shrink();
    }
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space16),
      child: Center(
        child: WenyouLoadMoreControl(
          hasMore: hasMore,
          isLoading: isLoading,
          onLoadMore: onLoadMore,
          failure: failure,
          loadMoreLabel: loadMoreLabel,
          loadingLabel: loadingLabel,
          endLabel: endLabel,
          showEndLabel: showEndLabel,
          retryLabel: retryLabel,
          loadMoreKey: loadMoreKey,
          retryKey: retryKey,
        ),
      ),
    );
  }
}

class WenyouLoadMoreControl extends StatelessWidget {
  const WenyouLoadMoreControl({
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
    this.failure,
    this.loadMoreLabel = '加载更多',
    this.loadingLabel = '正在加载更多',
    this.endLabel = '已经到底了',
    this.showEndLabel = true,
    this.retryLabel = '重试',
    this.loadMoreKey,
    this.retryKey,
    super.key,
  });

  final bool hasMore;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final ApiFailure? failure;
  final String loadMoreLabel;
  final String loadingLabel;
  final String endLabel;
  final bool showEndLabel;
  final String retryLabel;
  final Key? loadMoreKey;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final Widget child;
    if (failure case final currentFailure?) {
      child = WenyouFailureBanner(
        failure: currentFailure,
        action: TextButton(
          key: retryKey,
          onPressed: isLoading ? null : onLoadMore,
          child: Text(retryLabel),
        ),
      );
    } else if (isLoading) {
      child = Semantics(
        liveRegion: true,
        label: loadingLabel,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: tokens.space8),
            Flexible(child: Text(loadingLabel)),
          ],
        ),
      );
    } else if (hasMore) {
      child = OutlinedButton(
        key: loadMoreKey,
        onPressed: onLoadMore,
        child: Text(loadMoreLabel),
      );
    } else if (showEndLabel) {
      child = Text(
        endLabel,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
      );
    } else {
      child = const SizedBox.shrink();
    }
    return child;
  }
}
