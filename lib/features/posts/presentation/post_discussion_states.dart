import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
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
      return WenyouStatusBanner(
        message: failure.userMessage,
        detail: wenyouFailureDetail(failure),
        tone: WenyouStatusTone.error,
        action: TextButton(
          key: const Key('post-replies-retry'),
          onPressed: onRetry,
          child: const Text('重试'),
        ),
      );
    }
    if (!state.hasMore || state.isRefreshing || failure != null) {
      return const SizedBox.shrink();
    }
    return Semantics(
      key: const Key('post-replies-loading'),
      liveRegion: true,
      excludeSemantics: true,
      label: '正在加载回复',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: context.wenyouTokens.space8),
          const Text('正在加载回复'),
        ],
      ),
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
