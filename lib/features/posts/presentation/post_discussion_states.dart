import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_states.dart';

/// 正常分页由页面自动调度；只有失败时才需要用户在阅读位置重试。
class PostDiscussionPaginationStatus extends StatelessWidget {
  const PostDiscussionPaginationStatus({
    required this.state,
    required this.onRetry,
    super.key,
  });

  final PostDiscussionState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = state.transientFailure;
    if (failure != null &&
        state.retryAction == PostDiscussionRetryAction.loadMore) {
      return WenyouLoadMoreControl(
        hasMore: state.hasMore,
        isLoading: state.isLoadingMore,
        failure: failure,
        onLoadMore: onRetry,
        retryKey: const Key('post-replies-retry'),
        showEndLabel: false,
      );
    }
    if (!state.hasMore || state.isRefreshing || failure != null) {
      return const SizedBox.shrink();
    }
    return WenyouLoadMoreControl(
      key: const Key('post-replies-loading'),
      hasMore: true,
      isLoading: true,
      onLoadMore: onRetry,
      loadingLabel: '正在加载回复',
      showEndLabel: false,
    );
  }
}

class PostDiscussionFailure extends StatelessWidget {
  const PostDiscussionFailure({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.metricReplies,
          title: failure?.httpStatus == 404 ? '楼层暂时不可见' : '楼中楼讨论加载失败',
          message: failure?.userMessage ?? '请稍后重试。',
          detail: wenyouFailureDetail(failure),
          action: onRetry == null
              ? null
              : FilledButton(onPressed: onRetry, child: const Text('重试')),
        ),
      ),
    );
  }
}

class PostRouteMismatch extends StatelessWidget {
  const PostRouteMismatch({super.key});

  @override
  Widget build(BuildContext context) {
    return const WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.actionUnlink,
          title: '楼层不属于当前主题',
          message: '请返回主题详情后重新打开。',
        ),
      ),
    );
  }
}
