import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_actions.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_content.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class PublicUserPage extends ConsumerWidget {
  const PublicUserPage({
    required this.userId,
    this.previewOnly = false,
    super.key,
  });

  final String userId;
  final bool previewOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = publicUserControllerProvider(userId);
    final state = ref.watch(provider);
    final session = ref.watch(sessionControllerProvider);
    final meState = session.isAuthenticated
        ? ref.watch(meProfileControllerProvider)
        : null;
    final canTip =
        state.phase == PublicUserPhase.ready &&
        !state.profile!.isDeactivated &&
        (!session.isAuthenticated ||
            (meState?.phase == MeProfilePhase.ready &&
                meState!.profile!.id != state.profile!.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(previewOnly ? '预览公开主页' : '用户主页'),
        actions: [
          if (canTip)
            WenyouTipButton(
              key: const Key('public-user-tip'),
              target: TipTarget.user(id: state.profile!.id),
              recipientName: state.profile!.username,
              returnTo: '/users/${state.profile!.id}',
              iconOnly: true,
              onSuccess: (_) => ref.read(provider.notifier).load(),
            ),
          if (canTip)
            WenyouReportButton(
              key: const Key('public-user-report'),
              target: ReportTarget.user(state.profile!.id),
              targetLabel: '这个用户',
              returnTo: '/users/${state.profile!.id}',
              iconOnly: true,
            ),
        ],
      ),
      body: switch (state.phase) {
        PublicUserPhase.loading => const _UserLoadingState(),
        PublicUserPhase.failed => _UserFailureState(
          notFound: state.failure?.httpStatus == 404,
          message: state.failure?.userMessage,
          requestId: state.failure?.requestId,
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        PublicUserPhase.ready => RefreshIndicator(
          onRefresh: () => ref.read(provider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: _pagePadding(context),
            children: [
              WenyouConstrainedWidth(
                child: state.profile!.isDeactivated
                    ? const WenyouPanel(
                        child: WenyouEmptyState(
                          icon: WenyouIconIds.statusUserUnavailable,
                          title: '已注销用户',
                          message: '该账号已经注销，公开资料不再展示。',
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _UserProfileContent(
                            profile: state.profile!,
                            relationTarget: _relationTarget(
                              state.profile!,
                              meState,
                            ),
                            isCurrentUser:
                                meState?.phase == MeProfilePhase.ready &&
                                meState!.profile!.id == state.profile!.id,
                            previewOnly: previewOnly,
                          ),
                          SizedBox(height: context.wenyouTokens.space12),
                          _UserActivitySummaryPanel(
                            state: state,
                            onRetry: () => ref
                                .read(provider.notifier)
                                .retryActivitySummary(),
                          ),
                          SizedBox(height: context.wenyouTokens.space12),
                          PublicUserContentArea(
                            key: const Key('public-user-content-area'),
                            userId: userId,
                            state: state,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      },
    );
  }

  UserRelationTarget? _relationTarget(
    PublicUserProfileModel profile,
    MeProfileState? meState,
  ) {
    if (meState?.phase != MeProfilePhase.ready ||
        meState!.profile!.id == profile.id) {
      return null;
    }
    return UserRelationTarget(
      userId: profile.id,
      username: profile.username,
      isFollowing: profile.isFollowing,
      isBlocked: profile.isBlocked,
      isBlockedBy: profile.isBlockedBy,
      followerCount: profile.followerCount,
    );
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return EdgeInsets.fromLTRB(
      horizontal,
      tokens.space16,
      horizontal,
      tokens.space32,
    );
  }
}

class _UserProfileContent extends ConsumerWidget {
  const _UserProfileContent({
    required this.profile,
    required this.isCurrentUser,
    required this.previewOnly,
    this.relationTarget,
  });

  final PublicUserProfileModel profile;
  final bool isCurrentUser;
  final bool previewOnly;
  final UserRelationTarget? relationTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final relationState = relationTarget == null
        ? null
        : ref.watch(userRelationControllerProvider(relationTarget!));
    final isFollowing = relationState?.isFollowing ?? profile.isFollowing;
    final isBlocked = relationState?.isBlocked ?? profile.isBlocked;
    final isBlockedBy = relationState?.isBlockedBy ?? profile.isBlockedBy;
    final directMessagesEnabled = ref.watch(
      appCapabilitiesProvider.select(
        (capabilities) => capabilities.directMessages,
      ),
    );
    final hasLeadingAction =
        (isCurrentUser && !previewOnly) ||
        (directMessagesEnabled && relationTarget != null);
    final statuses = <UserProfileStatusItem>[
      if (isFollowing)
        const UserProfileStatusItem(
          icon: WenyouIconIds.statusSuccess,
          label: '已关注',
        ),
      if (profile.isFollowedBy)
        const UserProfileStatusItem(
          icon: WenyouIconIds.identityMembers,
          label: '关注了你',
        ),
      if (isBlocked)
        const UserProfileStatusItem(
          icon: WenyouIconIds.actionBlock,
          label: '已拉黑',
        ),
      if (isBlockedBy)
        const UserProfileStatusItem(
          icon: WenyouIconIds.actionHide,
          label: '互动受限',
        ),
    ];
    return UserProfileHeader(
      key: const Key('public-user-profile-header'),
      username: profile.username,
      avatarUrl: profile.avatarUrl,
      profileCover: profile.profileCover,
      level: profile.level,
      bio: profile.bio?.trim().isNotEmpty == true ? profile.bio : '这个人还没有填写简介。',
      metadata: profile.createdAt == null
          ? null
          : '${DateFormat('yyyy-MM-dd').format(profile.createdAt!)} 加入温油站',
      statuses: statuses,
      stats: [
        UserProfileStatItem(
          label: '关注',
          value: '${profile.followingCount}',
          onTap: () => context.pushNamed(
            isCurrentUser ? 'me-following' : 'user-following',
            pathParameters: isCurrentUser ? const {} : {'userId': profile.id},
          ),
        ),
        UserProfileStatItem(
          label: '粉丝',
          value: '${relationState?.followerCount ?? profile.followerCount}',
          onTap: () => context.pushNamed(
            isCurrentUser ? 'me-followers' : 'user-followers',
            pathParameters: isCurrentUser ? const {} : {'userId': profile.id},
          ),
        ),
        UserProfileStatItem(
          label: '收到加油',
          value: '${WenyouAmount.format(profile.receivedTipTotal)}L',
        ),
      ],
      actions: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (relationTarget != null) ...[
            UserRelationActions(target: relationTarget!),
            SizedBox(height: tokens.space12),
          ],
          Row(
            children: [
              if (isCurrentUser && !previewOnly)
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('public-user-edit-profile'),
                    onPressed: () => context.pushNamed('me-edit'),
                    icon: const WenyouIcon(WenyouIconIds.actionEdit),
                    label: const Text('编辑资料'),
                  ),
                )
              else if (directMessagesEnabled && relationTarget != null)
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('public-user-open-direct-message'),
                    onPressed: () => context.pushNamed(
                      'direct-message-new',
                      pathParameters: {'userId': profile.id},
                    ),
                    icon: const WenyouIcon(WenyouIconIds.contentThread),
                    label: const Text('发私聊'),
                  ),
                ),
              if (hasLeadingAction) SizedBox(width: tokens.space12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('public-user-open-moments'),
                  onPressed: () => context.pushNamed(
                    'user-moments',
                    pathParameters: {'userId': profile.id},
                  ),
                  icon: const WenyouIcon(WenyouIconIds.navigationMoments),
                  label: const Text('查看动态'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserActivitySummaryPanel extends StatelessWidget {
  const _UserActivitySummaryPanel({required this.state, required this.onRetry});

  final PublicUserState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      key: const Key('public-user-activity-summary'),
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(title: '创作活动', subtitle: '按你当前可见的公开范围统计'),
          SizedBox(height: tokens.space12),
          switch (state.activityPhase) {
            PublicUserActivityPhase.idle ||
            PublicUserActivityPhase.loading => const LinearProgressIndicator(),
            PublicUserActivityPhase.failed => WenyouStatusBanner(
              key: const Key('public-user-activity-failure'),
              tone: WenyouStatusTone.error,
              message: state.activityFailure?.userMessage ?? '创作活动汇总没有加载完成。',
              detail: state.activityFailure?.requestId == null
                  ? null
                  : '请求 ID：${state.activityFailure!.requestId}',
              action: TextButton(
                key: const Key('public-user-activity-retry'),
                onPressed: onRetry,
                child: const Text('重试'),
              ),
            ),
            PublicUserActivityPhase.ready => _ActivitySummaryGrid(
              summary: state.activitySummary!,
            ),
          },
        ],
      ),
    );
  }
}

class _ActivitySummaryGrid extends StatelessWidget {
  const _ActivitySummaryGrid({required this.summary});

  final PublicUserActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - tokens.space8) / 2;
        return Wrap(
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            _ActivitySummaryItem(
              width: itemWidth,
              label: '动态数',
              value: '${summary.momentCount}',
            ),
            _ActivitySummaryItem(
              width: itemWidth,
              label: '自建主题',
              value: '${summary.createdThreadCount}',
            ),
            _ActivitySummaryItem(
              width: itemWidth,
              label: '玩家主题',
              value: summary.playedThreadCount?.toString() ?? '未公开',
            ),
            _ActivitySummaryItem(
              width: itemWidth,
              label: '公开回复数',
              value: summary.replyCount?.toString() ?? '未公开',
            ),
          ],
        );
      },
    );
  }
}

class _ActivitySummaryItem extends StatelessWidget {
  const _ActivitySummaryItem({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.softPanel,
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space12),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: tokens.space4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserLoadingState extends StatelessWidget {
  const _UserLoadingState();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space24),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _UserFailureState extends StatelessWidget {
  const _UserFailureState({
    required this.notFound,
    required this.message,
    required this.requestId,
    required this.onRetry,
  });

  final bool notFound;
  final String? message;
  final String? requestId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 600,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: notFound
              ? WenyouIconIds.statusUserUnavailable
              : WenyouIconIds.statusOffline,
          title: notFound ? '用户不存在' : '用户资料没有加载完成',
          message: notFound ? '该用户可能已经注销，或账号不存在。' : (message ?? '请稍后重试。'),
          detail: requestId == null ? null : '请求 ID：$requestId',
          action: OutlinedButton.icon(
            key: const Key('public-user-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
