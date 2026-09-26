import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_nested_scroll.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_actions.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_content_dashboard.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_content.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class PublicUserPage extends ConsumerStatefulWidget {
  const PublicUserPage({required this.userId, this.userMoments, super.key});

  final MeUserMomentsIntegration? userMoments;

  final String userId;

  @override
  ConsumerState<PublicUserPage> createState() => _PublicUserPageState();
}

class _PublicUserPageState extends ConsumerState<PublicUserPage> {
  bool _showMoments = false;

  @override
  Widget build(BuildContext context) {
    final provider = publicUserControllerProvider(widget.userId);
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
          if (canTip)
            _ProfileMoreActions(userId: widget.userId, target: relationTarget),
        ],
      ),
      body: switch (state.phase) {
        PublicUserPhase.loading => const _UserLoadingState(),
        PublicUserPhase.failed => _UserFailureState(
          notFound: state.failure?.httpStatus == 404,
          message: state.failure?.userMessage,
          detail: wenyouFailureDetail(state.failure),
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        PublicUserPhase.ready => RefreshIndicator(
          onRefresh: () async {
            await ref.read(provider.notifier).load();
            if (_showMoments) await widget.userMoments?.refresh(widget.userId);
          },
          child: NestedScrollView(
            key: PageStorageKey('public-user-${widget.userId}'),
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: WenyouConstrainedWidth(
                  child: state.profile!.isDeactivated
                      ? const WenyouEmptyState(
                          icon: WenyouIconIds.statusUserUnavailable,
                          title: '已注销用户',
                        )
                      : _UserProfileContent(
                          profile: state.profile!,
                          canTip: canTip,
                          relationTarget: relationTarget,
                          isCurrentUser:
                              meState?.phase == MeProfilePhase.ready &&
                              meState!.profile!.id == state.profile!.id,
                        ),
                ),
              ),
              if (!state.profile!.isDeactivated)
                WenyouPinnedHeader(
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: WenyouContentTabs<String>(
                      key: const Key('public-user-content-tabs'),
                      keyPrefix: 'public-user',
                      semanticsLabel: '用户公开内容',
                      placement: WenyouTabPlacement.page,
                      options: [
                        const WenyouFilterOption(
                          value: 'created',
                          label: '主题',
                          keyValue: 'created-tab',
                        ),
                        const WenyouFilterOption(
                          value: 'moments',
                          label: '动态',
                          keyValue: 'moments-tab',
                        ),
                        for (final tab in state.availableTabs.where(
                          (tab) => tab != PublicUserContentTab.created,
                        ))
                          WenyouFilterOption(
                            value: tab.name,
                            label: tab.label,
                            keyValue: '${tab.name}-tab',
                          ),
                      ],
                      selected: _showMoments ? 'moments' : state.activeTab.name,
                      onSelected: (value) {
                        setState(() => _showMoments = value == 'moments');
                        if (!_showMoments) {
                          unawaited(
                            ref
                                .read(provider.notifier)
                                .selectTab(
                                  PublicUserContentTab.values.byName(value),
                                ),
                          );
                        }
                      },
                    ),
                  ),
                ),
            ],
            body: state.profile!.isDeactivated
                ? const SizedBox.shrink()
                : _showMoments
                ? widget.userMoments?.builder(widget.userId) ??
                      Center(
                        child: TextButton(
                          onPressed: () => context.pushNamed(
                            'user-moments',
                            pathParameters: {'userId': widget.userId},
                          ),
                          child: const Text('查看动态'),
                        ),
                      )
                : CustomScrollView(
                    key: PageStorageKey(
                      'public-user-${widget.userId}-${state.activeTab.name}',
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const WenyouNestedScrollInset(),
                      SliverPadding(
                        padding: _pagePadding(context),
                        sliver: PublicUserContentSectionSliver(
                          tab: state.activeTab,
                          state: state,
                          onRetry: ref.read(provider.notifier).retryActive,
                          onLoadMore: ref
                              .read(provider.notifier)
                              .loadMoreActive,
                        ),
                      ),
                    ],
                  ),
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
    ];
    final statuses = <UserProfileStatusItem>[
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
      bio: profile.bio,
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
      identityAction: isCurrentUser
          ? UserProfileEditButton(
              key: const Key('public-user-edit-profile'),
              onPressed: () => context.pushNamed('me-edit'),
            )
          : null,
      actions: relationTarget == null
          ? destinationActions.isEmpty
                ? null
                : WenyouIconLabelActionBar(actions: destinationActions)
          : UserRelationActions(
              target: relationTarget!,
              showBlockAction: false,
              prominentFollow: true,
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
    required this.detail,
    required this.onRetry,
  });

  final bool notFound;
  final String? message;
  final String? detail;
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
          detail: detail,
          action: OutlinedButton.icon(
            key: const Key('public-user-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重试'),
          ),
        ),
      ),
    );
  }
}

class _ProfileMoreActions extends ConsumerWidget {
  const _ProfileMoreActions({required this.userId, required this.target});
  final String userId;
  final UserRelationTarget? target;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = target == null
        ? null
        : ref.watch(userRelationControllerProvider(target!));
    return WenyouAnchoredActionBubble<String>(
      placement: WenyouPopoverPlacement.below,
      alignment: WenyouPopoverAlignment.end,
      semanticLabel: '用户操作',
      actions: [
        if (state != null)
          WenyouPopoverAction(
            key: const Key('user-relation-block'),
            value: 'block',
            icon: state.isBlocked
                ? WenyouIconIds.actionUnlock
                : WenyouIconIds.actionBlock,
            label: state.isBlocked ? '取消拉黑' : '拉黑',
            enabled: !state.isPending,
            loading: state.pendingAction == UserRelationAction.block,
            tone: WenyouPopoverActionTone.destructive,
          ),
        const WenyouPopoverAction(
          key: Key('public-user-report'),
          value: 'report',
          icon: WenyouIconIds.actionReport,
          label: '举报',
        ),
      ],
      onSelected: (action) {
        if (action == 'block') {
          unawaited(
            showWenyouUserBlockFlow(
              context,
              ref.read(userRelationControllerProvider(target!).notifier),
              target!,
              state!.isBlocked,
            ),
          );
        } else {
          unawaited(
            showWenyouReportFlow(
              context: context,
              ref: ref,
              target: ReportTarget.user(userId),
              targetLabel: '这个用户',
              returnTo: '/users/$userId',
            ),
          );
        }
      },
      anchorBuilder: (context, handle) => IconButton(
        key: const Key('public-user-more'),
        tooltip: '更多用户操作',
        onPressed: handle.toggle,
        icon: const WenyouIcon(WenyouIconIds.actionMore),
      ),
    );
  }
}
