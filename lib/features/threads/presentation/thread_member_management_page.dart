import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_member_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

class ThreadMemberManagementPage extends ConsumerWidget {
  const ThreadMemberManagementPage({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = threadMemberManagementControllerProvider(threadId);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('成员管理'),
        actions: [
          IconButton(
            key: const Key('thread-members-refresh'),
            tooltip: '刷新成员',
            onPressed:
                state.phase == ThreadMemberManagementPhase.loading ||
                    state.isUpdating
                ? null
                : () => ref.read(provider.notifier).load(),
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          ),
        ],
      ),
      body: switch (state.phase) {
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
      },
    );
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
          WenyouPanel(
            child: WenyouSectionHeader(
              title: bootstrap.threadTitle,
              subtitle:
                  '${bootstrap.members.length} 位参与人。回复后会自动进入候选池；玩家标记与协作者身份由管理者维护。',
            ),
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('thread-members-action-failure'),
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: state.failure!.requestId == null
                  ? null
                  : '请求 ID：${state.failure!.requestId}',
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
          SizedBox(height: tokens.space12),
          if (bootstrap.members.isEmpty)
            const WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.statusGroupUnavailable,
                title: '还没有参与人',
                message: '用户回复主题后，会自动进入这里的候选池。',
              ),
            )
          else
            for (var index = 0; index < bootstrap.members.length; index++) ...[
              _MemberCard(
                threadId: threadId,
                member: bootstrap.members[index],
                actorIsOwner: bootstrap.actorIsOwner,
                state: state,
              ),
              if (index < bootstrap.members.length - 1)
                SizedBox(height: tokens.space12),
            ],
        ],
      ),
    );
  }
}

class _MemberCard extends ConsumerWidget {
  const _MemberCard({
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
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: ValueKey('thread-member-profile-${member.userId}'),
            borderRadius: BorderRadius.circular(tokens.radius12),
            onTap: () => context.push(AppRouteLocations.user(member.userId)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.space4),
              child: Row(
                children: [
                  _MemberAvatar(member: member),
                  SizedBox(width: tokens.space12),
                  Expanded(
                    child: Column(
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
                          'Lv.${member.level}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.mutedText),
                        ),
                      ],
                    ),
                  ),
                  const WenyouIcon(WenyouIconIds.navigationNext),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.space12),
          Wrap(
            spacing: tokens.space8,
            runSpacing: tokens.space8,
            children: [
              _MemberBadge(
                label: member.role.label,
                icon: switch (member.role) {
                  ThreadMemberManagementRole.owner =>
                    WenyouIconIds.statusPremium,
                  ThreadMemberManagementRole.collaborator =>
                    WenyouIconIds.statusShield,
                  ThreadMemberManagementRole.participant =>
                    WenyouIconIds.identityMember,
                  ThreadMemberManagementRole.unknown =>
                    WenyouIconIds.statusHelp,
                },
                accent:
                    member.role == ThreadMemberManagementRole.owner ||
                    member.role == ThreadMemberManagementRole.collaborator,
              ),
              if (member.playerMarked)
                const _MemberBadge(
                  label: '玩家',
                  icon: WenyouIconIds.contentRoleplay,
                  accent: true,
                ),
            ],
          ),
          if (_actionable) ...[
            SizedBox(height: tokens.space12),
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: [
                OutlinedButton.icon(
                  key: ValueKey('thread-member-player-${member.userId}'),
                  onPressed: state.isUpdating
                      ? null
                      : () async {
                          final succeeded = await notifier.togglePlayer(member);
                          if (!context.mounted || !succeeded) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                member.playerMarked
                                    ? '已收回 ${member.username} 的玩家标记。'
                                    : '已将 ${member.username} 标记为玩家。',
                              ),
                            ),
                          );
                        },
                  icon:
                      pending &&
                          state.pendingAction ==
                              ThreadMemberManagementAction.player
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : WenyouIcon(
                          member.playerMarked
                              ? WenyouIconIds.actionUnfollow
                              : WenyouIconIds.actionFollow,
                        ),
                  label: Text(member.playerMarked ? '收回玩家' : '标记玩家'),
                ),
                if (actorIsOwner)
                  OutlinedButton.icon(
                    key: ValueKey(
                      'thread-member-collaborator-${member.userId}',
                    ),
                    onPressed: state.isUpdating
                        ? null
                        : () => _confirmRoleChange(context, notifier),
                    icon:
                        pending &&
                            state.pendingAction ==
                                ThreadMemberManagementAction.role
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : WenyouIcon(
                            member.role ==
                                    ThreadMemberManagementRole.collaborator
                                ? WenyouIconIds.statusShield
                                : WenyouIconIds.statusShield,
                          ),
                    label: Text(
                      member.role == ThreadMemberManagementRole.collaborator
                          ? '移除协作者'
                          : '设为协作者',
                    ),
                  ),
              ],
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(promoting ? '已任命 ${member.username} 为协作者。' : '已移除协作者身份。'),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final ThreadMemberManagementMember member;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final initial = member.username.trim().isEmpty
        ? '?'
        : member.username.characters.first;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Center(child: Text(initial)),
    );
    final uri = Uri.tryParse(member.avatarUrl ?? '');
    final validAvatar =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    return ClipOval(
      child: SizedBox.square(
        dimension: 44,
        child: !validAvatar
            ? fallback
            : WenyouCachedImage(
                imageUrl: member.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge({
    required this.label,
    required this.icon,
    this.accent = false,
  });

  final String label;
  final String icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? tokens.accentedBackground : tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radius12),
        border: Border.all(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouIcon(icon, size: 16),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
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
          title: '成员列表没有加载完成',
          message: failure?.userMessage ?? '请检查网络或管理权限后重试。',
          detail: failure?.requestId == null
              ? null
              : '请求 ID：${failure!.requestId}',
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
