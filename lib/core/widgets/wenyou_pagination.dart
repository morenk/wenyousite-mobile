import 'package:flutter/material.dart';
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
  final Key? loadMoreKey;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
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
          child: const Text('重试'),
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
            Text(loadingLabel),
          ],
        ),
      );
    } else if (hasMore) {
      child = OutlinedButton(
        key: loadMoreKey,
        onPressed: onLoadMore,
        child: Text(loadMoreLabel),
      );
    } else {
      child = Text(
        endLabel,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
      );
    }
    return child;
  }
}
