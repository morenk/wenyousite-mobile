import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

class UserRelationActions extends ConsumerWidget {
  const UserRelationActions({
    required this.target,
    this.additionalActions = const [],
    this.showBlockAction = true,
    super.key,
  });

  final UserRelationTarget target;
  final List<WenyouIconLabelAction> additionalActions;
  final bool showBlockAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = userRelationControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WenyouIconLabelActionBar(
          actions: [
            WenyouIconLabelAction(
              key: const Key('user-relation-follow'),
              icon: state.isFollowing
                  ? WenyouIconIds.actionUnfollow
                  : WenyouIconIds.actionFollow,
              label: state.isFollowing ? '已关注' : '关注',
              semanticsLabel: state.isFollowing ? '已关注，点按取消关注' : '关注',
              selected: state.isFollowing,
              loading: state.pendingAction == UserRelationAction.follow,
              onPressed: state.isPending
                  ? null
                  : () => _toggleFollow(context, notifier),
            ),
            if (showBlockAction)
              WenyouIconLabelAction(
                key: const Key('user-relation-block'),
                icon: state.isBlocked
                    ? WenyouIconIds.actionUnlock
                    : WenyouIconIds.actionBlock,
                label: state.isBlocked ? '取消拉黑' : '拉黑',
                semanticsLabel: state.isBlocked ? '取消拉黑' : '拉黑',
                selected: state.isBlocked,
                loading: state.pendingAction == UserRelationAction.block,
                foregroundColor: Theme.of(context).colorScheme.error,
                onPressed: state.isPending
                    ? null
                    : () => _toggleUserBlock(
                        context,
                        notifier,
                        target,
                        state.isBlocked,
                      ),
              ),
            ...additionalActions,
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

  Future<void> _toggleFollow(
    BuildContext context,
    UserRelationController notifier,
  ) async {
    final succeeded = await notifier.toggleFollow();
    if (!context.mounted || !succeeded) return;
    _showUserRelationSuccess(context, notifier);
  }
}

class UserRelationBlockIconButton extends ConsumerWidget {
  const UserRelationBlockIconButton({required this.target, super.key});

  final UserRelationTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = userRelationControllerProvider(target);
    final state = ref.watch(provider);
    final isLoading = state.pendingAction == UserRelationAction.block;
    final color = Theme.of(context).colorScheme.error;
    return IconButton(
      key: const Key('user-relation-block'),
      tooltip: state.isBlocked ? '取消拉黑' : '拉黑',
      color: color,
      onPressed: state.isPending
          ? null
          : () => _toggleUserBlock(
              context,
              ref.read(provider.notifier),
              target,
              state.isBlocked,
            ),
      icon: isLoading
          ? SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : WenyouIcon(
              state.isBlocked
                  ? WenyouIconIds.actionUnlock
                  : WenyouIconIds.actionBlock,
            ),
    );
  }
}

Future<void> _toggleUserBlock(
  BuildContext context,
  UserRelationController notifier,
  UserRelationTarget target,
  bool isBlocked,
) async {
  if (!isBlocked) {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '拉黑用户？',
      message: '拉黑 ${target.username} 后，将屏蔽对方的回复与通知；已有私聊记录保留，但不能继续发送。',
      confirmLabel: '确认拉黑',
      confirmKey: const Key('user-relation-block-confirm'),
      tone: WenyouConfirmationTone.destructive,
    );
    if (!confirmed) return;
  }
  final succeeded = await notifier.toggleBlock();
  if (!context.mounted || !succeeded) return;
  _showUserRelationSuccess(context, notifier);
}

void _showUserRelationSuccess(
  BuildContext context,
  UserRelationController notifier,
) {
  final message = notifier.takeSuccessMessage();
  if (message == null) return;
  showWenyouSnackBar(context, message);
}
