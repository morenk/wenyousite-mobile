import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_member_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

class ThreadMemberManagementPage extends ConsumerWidget {
  const ThreadMemberManagementPage({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('成员管理')),
      body: ThreadMemberManagementContent(threadId: threadId),
    );
  }
}

class ThreadMemberManagementContent extends ConsumerWidget {
  const ThreadMemberManagementContent({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = threadMemberManagementControllerProvider(threadId);
    final state = ref.watch(provider);
    return switch (state.phase) {
      ThreadMemberManagementPhase.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      ThreadMemberManagementPhase.failed => _MembersFatalState(
        failure: state.failure,
        onRetry: () => ref.read(provider.notifier).load(),
      ),
      ThreadMemberManagementPhase.ready => _MembersReadyState(
        threadId: threadId,
        state: state,
      ),
    };
  }
}

class _MembersReadyState extends ConsumerWidget {
  const _MembersReadyState({required this.threadId, required this.state});

  final String threadId;
  final ThreadMemberManagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final bootstrap = state.bootstrap!;
    return WenyouPageBody(
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failure != null) ...[
            WenyouStatusBanner(
              key: const Key('thread-members-action-failure'),
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: state.failure!.requestId == null
                  ? null
                  : '问题编号：${state.failure!.requestId}',
              action: TextButton(
                key: const Key('thread-members-dismiss-failure'),
                onPressed: state.isUpdating
                    ? null
                    : () => ref
                          .read(
                            threadMemberManagementControllerProvider(
                              threadId,
                            ).notifier,
                          )
                          .clearFailure(),
                child: const Text('知道了'),
              ),
            ),
          ],
          if (state.actionOutcome != null) ...[
            if (state.failure != null) SizedBox(height: tokens.space12),
            WenyouWriteOutcomeBanner(
              key: const Key('thread-members-write-outcome'),
              status: state.actionOutcome!,
              confirmingMessage: '正在确认成员设置…',
              indeterminateMessage: '成员设置结果暂时无法确定，请稍后刷新查看。',
              requestId: state.actionRequestId,
              onRefresh: () => ref
                  .read(
                    threadMemberManagementControllerProvider(threadId).notifier,
                  )
                  .load(),
              refreshKey: const Key('thread-members-refresh-result'),
            ),
          ],
          if (state.failure != null || state.actionOutcome != null)
            SizedBox(height: tokens.space12),
          if (bootstrap.members.isEmpty)
            const WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.statusGroupUnavailable,
                title: '还没有参与人',
              ),
            )
          else
            for (var index = 0; index < bootstrap.members.length; index++) ...[
              _MemberRow(
                threadId: threadId,
                member: bootstrap.members[index],
                actorIsOwner: bootstrap.actorIsOwner,
                state: state,
              ),
              if (index < bootstrap.members.length - 1)
                Divider(height: 1, color: tokens.border),
            ],
        ],
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({
    required this.threadId,
    required this.member,
    required this.actorIsOwner,
    required this.state,
  });

  final String threadId;
  final ThreadMemberManagementMember member;
  final bool actorIsOwner;
  final ThreadMemberManagementState state;

  bool get _actionable =>
      member.role != ThreadMemberManagementRole.owner &&
      member.role != ThreadMemberManagementRole.unknown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final pending = state.pendingUserId == member.userId;
    final notifier = ref.read(
      threadMemberManagementControllerProvider(threadId).notifier,
    );
    final playerPending =
        pending && state.pendingAction == ThreadMemberManagementAction.player;
    final rolePending =
        pending && state.pendingAction == ThreadMemberManagementAction.role;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('thread-member-profile-${member.userId}'),
              onTap: () => context.push(AppRouteLocations.user(member.userId)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Row(
                  children: [
                    _MemberAvatar(member: member),
                    SizedBox(width: tokens.space12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: tokens.space4),
                          Text(
                            'Lv.${member.level} · ${member.role.label} · '
                            '${member.playerMarked ? '玩家' : '非玩家'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_actionable) ...[
            IconButton.filled(
              key: ValueKey('thread-member-player-${member.userId}'),
              tooltip: member.playerMarked ? '收回玩家标记' : '标记为玩家',
              style: IconButton.styleFrom(
                backgroundColor: tokens.actionSurface,
                foregroundColor: tokens.onActionSurface,
                disabledBackgroundColor: tokens.border,
                disabledForegroundColor: tokens.mutedText,
              ),
              onPressed: state.isUpdating
                  ? null
                  : () async {
                      final succeeded = await notifier.togglePlayer(member);
                      if (!context.mounted || !succeeded) return;
                      showWenyouSnackBar(
                        context,
                        member.playerMarked
                            ? '已收回 ${member.username} 的玩家标记。'
                            : '已将 ${member.username} 标记为玩家。',
                      );
                    },
              icon: playerPending
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tokens.onActionSurface,
                      ),
                    )
                  : const WenyouIcon(WenyouIconIds.contentRoleplay),
            ),
            if (actorIsOwner)
              IconButton.filled(
                key: ValueKey('thread-member-collaborator-${member.userId}'),
                tooltip: member.role == ThreadMemberManagementRole.collaborator
                    ? '移除协作者'
                    : '设为协作者',
                style: IconButton.styleFrom(
                  backgroundColor: tokens.info,
                  foregroundColor: tokens.panel,
                  disabledBackgroundColor: tokens.border,
                  disabledForegroundColor: tokens.mutedText,
                ),
                onPressed: state.isUpdating
                    ? null
                    : () => _confirmRoleChange(context, notifier),
                icon: rolePending
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tokens.panel,
                        ),
                      )
                    : const WenyouIcon(WenyouIconIds.statusShield),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRoleChange(
    BuildContext context,
    ThreadMemberManagementController notifier,
  ) async {
    final promoting = member.role != ThreadMemberManagementRole.collaborator;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(promoting ? '设为协作者？' : '移除协作者身份？'),
        content: Text(
          promoting
              ? '${member.username} 将可以编辑主题内容并管理玩家标记。'
              : '${member.username} 将降为普通参与人，不再拥有主题管理权限。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: ValueKey('thread-member-role-confirm-${member.userId}'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(promoting ? '确认任命' : '确认移除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final succeeded = await notifier.toggleCollaborator(member);
    if (!context.mounted || !succeeded) return;
    showWenyouSnackBar(
      context,
      promoting ? '已任命 ${member.username} 为协作者。' : '已移除协作者身份。',
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final ThreadMemberManagementMember member;

  @override
  Widget build(BuildContext context) {
    return WenyouAvatar(
      username: member.username,
      avatarUrl: member.avatarUrl,
      size: 40,
    );
  }
}

class _MembersFatalState extends StatelessWidget {
  const _MembersFatalState({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.statusGroupUnavailable,
          title: '成员列表加载失败',
          message: failure?.userMessage ?? '请检查网络或管理权限后重试。',
          detail: failure?.requestId == null
              ? null
              : '问题编号：${failure!.requestId}',
          action: OutlinedButton.icon(
            key: const Key('thread-members-load-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
