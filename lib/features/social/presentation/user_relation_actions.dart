import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

class UserRelationActions extends ConsumerWidget {
  const UserRelationActions({required this.target, super.key});

  final UserRelationTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = userRelationControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: state.isFollowing
                  ? OutlinedButton.icon(
                      key: const Key('user-relation-follow'),
                      onPressed: state.isPending
                          ? null
                          : () => _toggleFollow(context, notifier),
                      icon: _actionIcon(
                        pending:
                            state.pendingAction == UserRelationAction.follow,
                        fallback: WenyouIconIds.actionUnfollow,
                      ),
                      label: const Text('已关注'),
                    )
                  : FilledButton.icon(
                      key: const Key('user-relation-follow'),
                      onPressed: state.isPending
                          ? null
                          : () => _toggleFollow(context, notifier),
                      icon: _actionIcon(
                        pending:
                            state.pendingAction == UserRelationAction.follow,
                        fallback: WenyouIconIds.actionFollow,
                      ),
                      label: const Text('关注'),
                    ),
            ),
            SizedBox(width: tokens.space8),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('user-relation-block'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: state.isPending
                    ? null
                    : () => _toggleBlock(context, notifier, state.isBlocked),
                icon: _actionIcon(
                  pending: state.pendingAction == UserRelationAction.block,
                  fallback: state.isBlocked
                      ? WenyouIconIds.actionUnlock
                      : WenyouIconIds.actionBlock,
                ),
                label: Text(state.isBlocked ? '取消拉黑' : '拉黑'),
              ),
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
                : '问题编号：${state.failure!.requestId}',
          ),
        ],
        if (state.outcomeStatus != null) ...[
          SizedBox(height: tokens.space12),
          WenyouWriteOutcomeBanner(
            key: const Key('user-relation-write-outcome'),
            status: state.outcomeStatus!,
            confirmingMessage: '正在确认关系状态…',
            indeterminateMessage: '关系操作结果暂时无法确定，请稍后刷新查看。',
            requestId: state.outcomeRequestId,
            onRefresh: notifier.refresh,
            refreshKey: const Key('user-relation-refresh-result'),
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

  Future<void> _toggleFollow(
    BuildContext context,
    UserRelationController notifier,
  ) async {
    final succeeded = await notifier.toggleFollow();
    if (!context.mounted || !succeeded) return;
    _showSuccess(context, notifier);
  }

  Future<void> _toggleBlock(
    BuildContext context,
    UserRelationController notifier,
    bool isBlocked,
  ) async {
    if (!isBlocked) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('拉黑用户？'),
          content: Text(
            '拉黑 ${target.username} 后，将屏蔽对方的回复与通知；已有私聊记录保留，但不能继续发送。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const Key('user-relation-block-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('确认拉黑'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    final succeeded = await notifier.toggleBlock();
    if (!context.mounted || !succeeded) return;
    _showSuccess(context, notifier);
  }

  void _showSuccess(BuildContext context, UserRelationController notifier) {
    final message = notifier.takeSuccessMessage();
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
