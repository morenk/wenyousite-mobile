import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';

class ThreadInteractionActions extends ConsumerWidget {
  const ThreadInteractionActions({
    required this.target,
    required this.onRequireAuthentication,
    this.compact = false,
    super.key,
  });

  final ThreadInteractionTarget target;
  final VoidCallback onRequireAuthentication;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    final provider = threadInteractionControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final tokens = context.wenyouTokens;
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: state.isLiked
                ? '取消喜欢，当前 ${state.likeCount} 个喜欢'
                : '喜欢，当前 ${state.likeCount} 个喜欢',
            excludeSemantics: true,
            child: TextButton(
              key: const Key('thread-interaction-like'),
              onPressed: state.isPending
                  ? null
                  : authenticated
                  ? () => _toggleLike(context, notifier, compact: true)
                  : onRequireAuthentication,
              style: TextButton.styleFrom(
                minimumSize: Size(
                  tokens.minimumTouchTarget,
                  tokens.minimumTouchTarget,
                ),
                padding: EdgeInsets.symmetric(horizontal: tokens.space4),
                foregroundColor: state.isLiked
                    ? tokens.brand
                    : tokens.mutedText,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionIcon(
                    pending:
                        state.pendingAction == ThreadInteractionAction.like,
                    fallback: state.isLiked
                        ? WenyouIconIds.actionLike
                        : WenyouIconIds.actionLike,
                  ),
                  SizedBox(width: tokens.space4),
                  Text(
                    '${state.likeCount}',
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (authenticated)
            IconButton(
              key: const Key('thread-interaction-bookmark'),
              onPressed: state.isPending
                  ? null
                  : () => _toggleBookmark(context, notifier, compact: true),
              tooltip: state.isBookmarked ? '取消收藏' : '收藏主题',
              color: state.isBookmarked ? tokens.brand : tokens.mutedText,
              icon: _actionIcon(
                pending:
                    state.pendingAction == ThreadInteractionAction.bookmark,
                fallback: state.isBookmarked
                    ? WenyouIconIds.actionBookmark
                    : WenyouIconIds.actionBookmark,
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            OutlinedButton.icon(
              key: const Key('thread-interaction-like'),
              onPressed: state.isPending
                  ? null
                  : authenticated
                  ? () => _toggleLike(context, notifier)
                  : onRequireAuthentication,
              icon: _actionIcon(
                pending: state.pendingAction == ThreadInteractionAction.like,
                fallback: state.isLiked
                    ? WenyouIconIds.actionLike
                    : WenyouIconIds.actionLike,
              ),
              label: Text(
                state.isLiked
                    ? '已喜欢 ${state.likeCount}'
                    : '喜欢 ${state.likeCount}',
              ),
            ),
            if (authenticated)
              OutlinedButton.icon(
                key: const Key('thread-interaction-bookmark'),
                onPressed: state.isPending
                    ? null
                    : () => _toggleBookmark(context, notifier),
                icon: _actionIcon(
                  pending:
                      state.pendingAction == ThreadInteractionAction.bookmark,
                  fallback: state.isBookmarked
                      ? WenyouIconIds.actionBookmark
                      : WenyouIconIds.actionBookmark,
                ),
                label: Text(state.isBookmarked ? '已收藏' : '收藏'),
              ),
          ],
        ),
        if (state.failure != null) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            tone: WenyouStatusTone.error,
            message: state.failure!.userMessage,
            detail: state.failure!.requestId == null
                ? null
                : '请求 ID：${state.failure!.requestId}',
          ),
        ],
      ],
    );
  }

  Widget _actionIcon({required bool pending, required String fallback}) {
    return pending
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : WenyouIcon(fallback);
  }

  Future<void> _toggleLike(
    BuildContext context,
    ThreadInteractionController notifier, {
    bool compact = false,
  }) async {
    final succeeded = await notifier.toggleLike();
    if (!context.mounted) return;
    if (!succeeded) {
      if (compact) _showFailure(context, notifier);
      return;
    }
    _showSuccess(context, notifier);
  }

  Future<void> _toggleBookmark(
    BuildContext context,
    ThreadInteractionController notifier, {
    bool compact = false,
  }) async {
    final succeeded = await notifier.toggleBookmark();
    if (!context.mounted) return;
    if (!succeeded) {
      if (compact) _showFailure(context, notifier);
      return;
    }
    _showSuccess(context, notifier);
  }

  void _showFailure(
    BuildContext context,
    ThreadInteractionController notifier,
  ) {
    final failure = notifier.takeFailure();
    if (failure == null) return;
    final requestId = failure.requestId;
    final message = requestId == null
        ? failure.userMessage
        : '${failure.userMessage}（请求 ID：$requestId）';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(
    BuildContext context,
    ThreadInteractionController notifier,
  ) {
    final message = notifier.takeSuccessMessage();
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
