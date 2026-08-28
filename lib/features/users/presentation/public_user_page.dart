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
import 'package:wenyousite_mobile/features/users/presentation/user_activity_summary_panel.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class PublicUserPage extends ConsumerWidget {
  const PublicUserPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = publicUserControllerProvider(userId);
    final state = ref.watch(provider);
    final session = ref.watch(sessionControllerProvider);
    final meState = session.isAuthenticated
        ? ref.watch(meProfileControllerProvider)
        : null;
    final profile = state.phase == PublicUserPhase.ready ? state.profile : null;
    final relationTarget = profile == null
        ? null
        : _relationTarget(profile, meState);
    final canTip =
        state.phase == PublicUserPhase.ready &&
        !state.profile!.isDeactivated &&
        (!session.isAuthenticated ||
            (meState?.phase == MeProfilePhase.ready &&
                meState!.profile!.id != state.profile!.id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户主页'),
        actions: [
          if (relationTarget != null)
            UserRelationBlockIconButton(target: relationTarget),
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
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _UserProfileContent(
                            profile: state.profile!,
                            canTip: canTip,
                            relationTarget: relationTarget,
                            isCurrentUser:
                                meState?.phase == MeProfilePhase.ready &&
                                meState!.profile!.id == state.profile!.id,
                          ),
                          SizedBox(height: context.wenyouTokens.space12),
                          UserActivitySummaryPanel(
                            key: const Key('public-user-activity-summary'),
                            keyPrefix: 'public-user-activity',
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
    final horizontal = wenyouHorizontalPagePadding(context);
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
    required this.canTip,
    this.relationTarget,
  });

  final PublicUserProfileModel profile;
  final bool isCurrentUser;
  final bool canTip;
  final UserRelationTarget? relationTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final destinationActions = <WenyouIconLabelAction>[
      if (canTip)
        WenyouIconLabelAction(
          key: const Key('public-user-tip'),
          onPressed: () => showWenyouTipFlow(
            context: context,
            ref: ref,
            target: TipTarget.user(id: profile.id),
            recipientName: profile.username,
            returnTo: '/users/${profile.id}',
            onSuccess: (_) => ref
                .read(publicUserControllerProvider(profile.id).notifier)
                .load(),
          ),
          icon: WenyouIconIds.actionTip,
          label: '加油',
        ),
      if (directMessagesEnabled && relationTarget != null)
        WenyouIconLabelAction(
          key: const Key('public-user-open-direct-message'),
          onPressed: () => context.pushNamed(
            'direct-message-new',
            pathParameters: {'userId': profile.id},
          ),
          icon: WenyouIconIds.contentThread,
          label: '私聊',
          semanticsLabel: '发私聊',
        ),
      WenyouIconLabelAction(
        key: const Key('public-user-open-moments'),
        onPressed: () => context.pushNamed(
          'user-moments',
          pathParameters: {'userId': profile.id},
        ),
        icon: WenyouIconIds.navigationMoments,
        label: '动态',
        semanticsLabel: '查看动态',
      ),
    ];
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
          value: formatWenyouCompactCount(profile.followingCount),
          semanticValue: '${profile.followingCount}',
          onTap: () => context.pushNamed(
            isCurrentUser ? 'me-following' : 'user-following',
            pathParameters: isCurrentUser ? const {} : {'userId': profile.id},
          ),
        ),
        UserProfileStatItem(
          label: '粉丝',
          value: formatWenyouCompactCount(
            relationState?.followerCount ?? profile.followerCount,
          ),
          semanticValue:
              '${relationState?.followerCount ?? profile.followerCount}',
          onTap: () => context.pushNamed(
            isCurrentUser ? 'me-followers' : 'user-followers',
            pathParameters: isCurrentUser ? const {} : {'userId': profile.id},
          ),
        ),
        UserProfileStatItem(
          label: '收到加油',
          value: '${WenyouAmount.format(profile.receivedTipTotal)} 升',
        ),
      ],
      actions: relationTarget == null
          ? WenyouIconLabelActionBar(
              actions: [
                if (isCurrentUser)
                  WenyouIconLabelAction(
                    key: const Key('public-user-edit-profile'),
                    onPressed: () => context.pushNamed('me-edit'),
                    icon: WenyouIconIds.actionEdit,
                    label: '编辑资料',
                  ),
                ...destinationActions,
              ],
            )
          : UserRelationActions(
              target: relationTarget!,
              showBlockAction: false,
              additionalActions: destinationActions,
            ),
    );
  }
}

class _UserLoadingState extends StatelessWidget {
  const _UserLoadingState();

  @override
  Widget build(BuildContext context) {
    return const WenyouPageBody(
      maxWidth: 600,
      child: WenyouDetailSkeleton(label: '正在加载个人资料'),
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
          title: notFound ? '用户不存在' : '用户资料加载失败',
          message: notFound ? '该用户可能已经注销，或账号不存在。' : (message ?? '请稍后重试。'),
          detail: requestId == null ? null : '问题编号：$requestId',
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
