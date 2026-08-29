import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/application/session_logout_controller.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/users/application/avatar_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/profile_cover_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_content_dashboard.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_profile_editor.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

void _showRefreshFailure(BuildContext context, ApiFailure failure) {
  final requestId = failure.requestId;
  final message = requestId == null
      ? failure.userMessage
      : '${failure.userMessage}（问题编号：$requestId）';
  showWenyouSnackBar(context, message, pacing: WenyouSnackBarPacing.extended);
}

class MePage extends ConsumerWidget {
  const MePage({this.userMoments, super.key});

  final MeUserMomentsIntegration? userMoments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) return const _GuestMePage();
    return _AuthenticatedMePage(userMoments: userMoments);
  }
}

class _GuestMePage extends StatelessWidget {
  const _GuestMePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: WenyouPageBody(
        maxWidth: 600,
        bottomPadding: 112,
        child: Column(
          children: [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.identityMember,
                title: '当前以游客身份浏览',
                action: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      AppRouteLocations.login(returnTo: AppRouteLocations.me),
                    ),
                    icon: const WenyouIcon(WenyouIconIds.actionLogin),
                    label: const Text('登录'),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.wenyouTokens.space12),
            const _AppearanceSettingsPanel(),
          ],
        ),
      ),
    );
  }
}

class _AuthenticatedMePage extends ConsumerWidget {
  const _AuthenticatedMePage({required this.userMoments});

  final MeUserMomentsIntegration? userMoments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meProfileControllerProvider);
    final notifier = ref.read(meProfileControllerProvider.notifier);
    ref.listen(
      meProfileControllerProvider.select((value) => value.refreshFailure),
      (previous, next) {
        if (next != null && next != previous) {
          _showRefreshFailure(context, next);
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            key: const Key('me-open-settings'),
            tooltip: '账号设置',
            onPressed: () => context.pushNamed('me-settings'),
            icon: const WenyouIcon(WenyouIconIds.actionSettings),
          ),
        ],
      ),
      body: switch (state.phase) {
        MeProfilePhase.loading => _MePageList(
          children: const [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.identityMember,
                title: '正在读取本人资料',
                action: CircularProgressIndicator(),
              ),
            ),
            _LogoutPanel(),
          ],
        ),
        MeProfilePhase.failed => _MePageList(
          children: [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.statusOffline,
                title: '本人资料加载失败',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: state.failure?.requestId == null
                    ? null
                    : '问题编号：${state.failure!.requestId}',
                action: OutlinedButton.icon(
                  key: const Key('me-profile-retry'),
                  onPressed: notifier.load,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
              ),
            ),
            const _LogoutPanel(),
          ],
        ),
        MeProfilePhase.ready => _MeDashboard(
          profile: state.profile!,
          userMoments: userMoments,
        ),
      },
    );
  }
}

class MeEditPage extends ConsumerWidget {
  const MeEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meProfileControllerProvider);
    final avatarState = ref.watch(avatarControllerProvider);
    final profileCoverState = ref.watch(profileCoverControllerProvider);
    final notifier = ref.read(meProfileControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('编辑资料')),
      body: switch (state.phase) {
        MeProfilePhase.loading => const _MePageList(
          children: [WenyouDetailSkeleton(label: '正在读取资料')],
        ),
        MeProfilePhase.failed => _MePageList(
          children: [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.statusOffline,
                title: '资料加载失败',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: state.failure?.requestId == null
                    ? null
                    : '问题编号：${state.failure!.requestId}',
                action: OutlinedButton.icon(
                  key: const Key('me-edit-retry'),
                  onPressed: notifier.load,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
              ),
            ),
          ],
        ),
        MeProfilePhase.ready => RefreshIndicator(
          onRefresh:
              state.isSubmitting ||
                  avatarState.isBusy ||
                  profileCoverState.isBusy
              ? () async {}
              : notifier.load,
          child: _MePageList(children: [MeProfileEditor(state: state)]),
        ),
      },
    );
  }
}

class MeSettingsPage extends StatelessWidget {
  const MeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账号设置')),
      body: const _MePageList(
        children: [
          _AppearanceSettingsPanel(),
          _AccountSecurityPanel(disabled: false),
          _LogoutPanel(),
        ],
      ),
    );
  }
}

class _AppearanceSettingsPanel extends ConsumerWidget {
  const _AppearanceSettingsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(
      appearancePreferenceControllerProvider.select(
        (state) => state.preference,
      ),
    );
    return WenyouPanel(
      padding: EdgeInsets.zero,
      child: ListTile(
        key: const Key('open-appearance-settings'),
        leading: WenyouIcon(preference.icon),
        title: const Text('外观'),
        subtitle: Text(preference.label),
        trailing: const WenyouIcon(WenyouIconIds.navigationNext),
        onTap: () => context.pushNamed(AppRouteNames.appearance),
      ),
    );
  }
}

class _MePageList extends StatelessWidget {
  const _MePageList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = wenyouHorizontalPagePadding(
      context,
      availableWidth: width,
    );
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontal, tokens.space16, horizontal, 112),
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.space12),
          WenyouConstrainedWidth(child: children[index]),
        ],
      ],
    );
  }
}

class _MeDashboard extends ConsumerStatefulWidget {
  const _MeDashboard({required this.profile, required this.userMoments});

  final MeProfileModel profile;
  final MeUserMomentsIntegration? userMoments;

  @override
  ConsumerState<_MeDashboard> createState() => _MeDashboardState();
}

class _MeDashboardState extends ConsumerState<_MeDashboard> {
  final Set<int> _visitedTabs = {0};
  final ScrollController _outerScrollController = ScrollController();
  var _activeIndex = 0;
  var _refreshGestureEligible = false;

  @override
  void dispose() {
    _outerScrollController.dispose();
    super.dispose();
  }

  void _selectTab(MeContentTab selected) {
    if (_activeIndex == selected.index &&
        _visitedTabs.contains(selected.index)) {
      return;
    }
    setState(() {
      _activeIndex = selected.index;
      _visitedTabs.add(selected.index);
    });
    final tab = selected.publicUserTab;
    if (tab != null) {
      unawaited(
        ref
            .read(meUserContentControllerProvider(widget.profile.id).notifier)
            .selectTab(tab),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final walletProvider = walletControllerProvider(walletSessionKey(ref));
    final walletState = ref.watch(walletProvider);
    final stickersEnabled = ref.watch(stickersEnabledProvider);
    final horizontal = wenyouHorizontalPagePadding(context);
    ref.listen(
      meUserContentControllerProvider(
        widget.profile.id,
      ).select((value) => value.transientFailure),
      (previous, next) {
        if (next != null && next != previous) {
          _showRefreshFailure(context, next);
        }
      },
    );
    return RefreshIndicator(
      key: const Key('me-dashboard-refresh'),
      semanticsLabel: '刷新我的主页',
      notificationPredicate: _refreshNotificationPredicate,
      onRefresh: _refreshDashboard,
      child: NestedScrollView(
        key: const PageStorageKey('me-dashboard-scroll'),
        controller: _outerScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                tokens.space16,
                horizontal,
                tokens.space12,
              ),
              child: WenyouConstrainedWidth(
                child: _ProfileOverview(
                  profile: widget.profile,
                  walletState: walletState,
                  stickersEnabled: stickersEnabled,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: WenyouContentTabs<MeContentTab>(
              key: const Key('me-content-tabs'),
              keyPrefix: 'me-content',
              semanticsLabel: '我的主页内容',
              placement: WenyouTabPlacement.page,
              options: [
                for (final tab in MeContentTab.values)
                  WenyouFilterOption(value: tab, label: tab.label),
              ],
              selected: MeContentTab.values[_activeIndex],
              onSelected: _selectTab,
            ),
          ),
        ],
        body: IndexedStack(
          index: _activeIndex,
          children: [
            for (var index = 0; index < MeContentTab.values.length; index++)
              _visitedTabs.contains(index)
                  ? MeContentTabBody(
                      key: PageStorageKey('me-content-tab-$index'),
                      tab: MeContentTab.values[index],
                      userId: widget.profile.id,
                      userMomentsBuilder: widget.userMoments?.builder,
                      onSelectTab: _selectTab,
                    )
                  : const SizedBox.expand(),
          ],
        ),
      ),
    );
  }

  bool _refreshNotificationPredicate(ScrollNotification notification) {
    if (notification.depth != 1 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _refreshGestureEligible =
          !_outerScrollController.hasClients ||
          _outerScrollController.position.pixels <=
              _outerScrollController.position.minScrollExtent;
      return _refreshGestureEligible;
    }
    final eligible = _refreshGestureEligible;
    if (notification is ScrollEndNotification) {
      _refreshGestureEligible = false;
    }
    return eligible;
  }

  Future<void> _refreshDashboard() async {
    final activeTab = MeContentTab.values[_activeIndex];
    final walletProvider = walletControllerProvider(walletSessionKey(ref));
    await Future.wait([
      ref.read(meProfileControllerProvider.notifier).refresh(),
      _refreshWallet(walletProvider),
      switch (activeTab) {
        MeContentTab.overview =>
          ref
              .read(meUserContentControllerProvider(widget.profile.id).notifier)
              .refreshOverview(),
        MeContentTab.moments =>
          widget.userMoments?.refresh(widget.profile.id) ?? Future.value(),
        MeContentTab.createdThreads || MeContentTab.playedThreads =>
          ref
              .read(meUserContentControllerProvider(widget.profile.id).notifier)
              .refreshActive(),
      },
    ]);
  }

  Future<void> _refreshWallet(
    AutoDisposeStateNotifierProvider<WalletController, WalletState> provider,
  ) async {
    await ref.read(provider.notifier).retrySummary();
    if (!mounted) return;
    final failure = ref.read(provider).summaryFailure;
    if (failure != null) _showRefreshFailure(context, failure);
  }
}

class _AccountSecurityPanel extends StatelessWidget {
  const _AccountSecurityPanel({required this.disabled});

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return WenyouPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            key: const Key('me-open-blocks'),
            enabled: !disabled,
            leading: const WenyouIcon(WenyouIconIds.actionBlock),
            title: const Text('管理黑名单'),
            trailing: const WenyouIcon(WenyouIconIds.navigationNext),
            onTap: disabled ? null : () => context.pushNamed('me-blocks'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-login-sessions'),
            enabled: !disabled,
            leading: const WenyouIcon(WenyouIconIds.actionDevices),
            title: const Text('登录终端'),
            trailing: const WenyouIcon(WenyouIconIds.navigationNext),
            onTap: disabled ? null : () => context.pushNamed('login-sessions'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-change-password'),
            enabled: !disabled,
            leading: const WenyouIcon(WenyouIconIds.securityPassword),
            title: const Text('修改密码'),
            subtitle: const Text('修改后所有终端需要重新登录'),
            trailing: const WenyouIcon(WenyouIconIds.navigationNext),
            onTap: disabled ? null : () => context.pushNamed('change-password'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-change-email'),
            enabled: !disabled,
            leading: const WenyouIcon(WenyouIconIds.statusMail),
            title: const Text('更换邮箱'),
            trailing: const WenyouIcon(WenyouIconIds.navigationNext),
            onTap: disabled ? null : () => context.pushNamed('change-email'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-moderation-appeals'),
            enabled: !disabled,
            leading: const WenyouIcon(WenyouIconIds.moderationDecision),
            title: const Text('治理决定与申诉'),
            subtitle: const Text('查看近 30 天决定与申诉进度'),
            trailing: const WenyouIcon(WenyouIconIds.navigationNext),
            onTap: disabled
                ? null
                : () => context.pushNamed('moderation-appeals'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-delete-account'),
            enabled: !disabled,
            leading: WenyouIcon(
              WenyouIconIds.actionDelete,
              color: scheme.error,
            ),
            title: Text('注销账号', style: TextStyle(color: scheme.error)),
            subtitle: const Text('不可恢复；已发布内容会匿名保留'),
            trailing: WenyouIcon(
              WenyouIconIds.navigationNext,
              color: scheme.error,
            ),
            onTap: disabled ? null : () => context.pushNamed('delete-account'),
          ),
        ],
      ),
    );
  }
}

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({
    required this.profile,
    required this.walletState,
    required this.stickersEnabled,
  });

  final MeProfileModel profile;
  final WalletState walletState;
  final bool stickersEnabled;

  @override
  Widget build(BuildContext context) {
    return UserProfileHeader(
      key: const Key('me-profile-header'),
      username: profile.username,
      avatarUrl: profile.avatarUrl,
      profileCover: profile.profileCover,
      level: profile.level,
      bio: profile.bio?.trim().isNotEmpty == true ? profile.bio : '还没有填写个人简介。',
      metadata:
          '${DateFormat('yyyy-MM-dd').format(profile.createdAt)} 加入温油站 · ${_maskEmail(profile.email)}',
      levelProgress: profile.levelProgress,
      levelProgressLabel: profile.nextLevelExperience == null
          ? '已达到当前最高等级'
          : '${profile.experience} / ${profile.nextLevelExperience} 经验',
      actions: WenyouIconLabelActionBar(
        actions: [
          WenyouIconLabelAction(
            key: const Key('me-open-edit-profile'),
            onPressed: () => context.pushNamed('me-edit'),
            icon: WenyouIconIds.actionEdit,
            label: '编辑资料',
          ),
          WenyouIconLabelAction(
            key: const Key('me-open-bookmarks'),
            onPressed: () => context.pushNamed('me-bookmarks'),
            icon: WenyouIconIds.actionBookmark,
            label: '收藏',
          ),
          if (stickersEnabled)
            WenyouIconLabelAction(
              key: const Key('me-open-stickers'),
              onPressed: () => context.pushNamed('me-stickers'),
              icon: WenyouIconIds.actionAddReaction,
              label: '表情包',
            ),
        ],
      ),
      stats: [
        UserProfileStatItem(
          key: const Key('me-open-following'),
          label: '关注',
          value: formatWenyouCompactCount(profile.followingCount),
          semanticValue: '${profile.followingCount}',
          onTap: () => context.pushNamed('me-following'),
        ),
        UserProfileStatItem(
          key: const Key('me-open-followers'),
          label: '粉丝',
          value: formatWenyouCompactCount(profile.followerCount),
          semanticValue: '${profile.followerCount}',
          onTap: () => context.pushNamed('me-followers'),
        ),
        UserProfileStatItem(
          key: const Key('me-open-wallet'),
          label: '温油',
          value: walletState.summary == null
              ? '—'
              : '${WenyouAmount.format(walletState.summary!.balance)} 升',
          onTap: () => context.pushNamed('wallet'),
        ),
      ],
    );
  }
}

class _LogoutPanel extends StatelessWidget {
  const _LogoutPanel();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(title: '当前会话'),
          SizedBox(height: tokens.space16),
          const _LogoutAction(),
        ],
      ),
    );
  }
}

class _LogoutAction extends ConsumerWidget {
  const _LogoutAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logout = ref.watch(logoutControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (logout.failure != null) ...[
          WenyouStatusBanner(
            message: logout.failure!.userMessage,
            detail: logout.failure!.requestId == null
                ? null
                : '问题编号：${logout.failure!.requestId}',
            tone: WenyouStatusTone.error,
          ),
          SizedBox(height: context.wenyouTokens.space8),
        ],
        OutlinedButton.icon(
          key: const Key('logout-submit'),
          onPressed: logout.isSubmitting
              ? null
              : () => _confirmAndLogout(context, ref),
          icon: logout.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const WenyouIcon(WenyouIconIds.actionLogout),
          label: Text(logout.failure == null ? '退出当前账号' : '重试安全退出'),
        ),
        if (logout.failure != null)
          TextButton(
            key: const Key('logout-local-only'),
            onPressed: logout.isSubmitting
                ? null
                : () => _confirmLocalLogout(context, ref),
            child: const Text('仅清除这台设备的登录'),
          ),
      ],
    );
  }

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '退出当前账号？',
      confirmLabel: '确认退出',
      confirmKey: const Key('logout-confirm'),
    );
    if (!confirmed) return;
    final succeeded = await ref
        .read(logoutControllerProvider.notifier)
        .submit();
    if (succeeded && context.mounted) {
      context.go(AppRouteLocations.me);
      showWenyouSnackBar(context, '已安全退出当前账号。');
    }
  }

  Future<void> _confirmLocalLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '仅清除这台设备的登录？',
      message: '账号安全退出失败。清除这台设备的登录后，请稍后重新登录并在终端管理中检查。',
      cancelLabel: '返回重试',
      confirmLabel: '清除这台设备的登录',
      confirmKey: const Key('logout-local-confirm'),
      tone: WenyouConfirmationTone.destructive,
    );
    if (!confirmed) return;
    await ref.read(logoutControllerProvider.notifier).forceLocalLogout();
    if (context.mounted) {
      context.go(AppRouteLocations.me);
      showWenyouSnackBar(context, '这台设备的登录信息已清除。');
    }
  }
}

String _maskEmail(String email) {
  final separator = email.indexOf('@');
  if (separator <= 0 || separator == email.length - 1) return email;
  return '${email[0]}***${email.substring(separator)}';
}
