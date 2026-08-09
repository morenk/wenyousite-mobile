import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';

class ThreadInteractionActions extends ConsumerWidget {
  const ThreadInteractionActions({
    required this.target,
    required this.onRequireAuthentication,
    super.key,
  });

  final ThreadInteractionTarget target;
  final VoidCallback onRequireAuthentication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    final provider = threadInteractionControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final tokens = context.wenyouTokens;
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
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
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
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
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

  Widget _actionIcon({required bool pending, required IconData fallback}) {
    return pending
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(fallback);
  }

  Future<void> _toggleLike(
    BuildContext context,
    ThreadInteractionController notifier,
  ) async {
    final succeeded = await notifier.toggleLike();
    if (!context.mounted || !succeeded) return;
    _showSuccess(context, notifier);
  }

  Future<void> _toggleBookmark(
    BuildContext context,
    ThreadInteractionController notifier,
  ) async {
    final succeeded = await notifier.toggleBookmark();
    if (!context.mounted || !succeeded) return;
    _showSuccess(context, notifier);
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
