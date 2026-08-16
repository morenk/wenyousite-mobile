import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/session_logout_controller.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
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

class MePage extends ConsumerWidget {
  const MePage({
    this.userMomentsBuilder,
    this.momentBookmarksBuilder,
    super.key,
  });

  final MeUserMomentsBuilder? userMomentsBuilder;
  final MeMomentBookmarksBuilder? momentBookmarksBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) return const _GuestMePage();
    return _AuthenticatedMePage(
      userMomentsBuilder: userMomentsBuilder,
      momentBookmarksBuilder: momentBookmarksBuilder,
    );
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
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: WenyouIconIds.identityMember,
            title: '当前以游客身份浏览',
            message: '登录后可查看和管理本人资料、公开范围与账号会话。',
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
      ),
    );
  }
}

class _AuthenticatedMePage extends ConsumerWidget {
  const _AuthenticatedMePage({
    required this.userMomentsBuilder,
    required this.momentBookmarksBuilder,
  });

  final MeUserMomentsBuilder? userMomentsBuilder;
  final MeMomentBookmarksBuilder? momentBookmarksBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meProfileControllerProvider);
    final notifier = ref.read(meProfileControllerProvider.notifier);
    final stickersEnabled = ref.watch(stickersEnabledProvider);
    final profile = state.profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          if (profile != null)
            IconButton(
              key: const Key('me-open-public-profile'),
              tooltip: '预览公开主页',
              onPressed: () => context.pushNamed(
                'user-profile',
                pathParameters: {'userId': profile.id},
                queryParameters: const {'mode': 'preview'},
              ),
              icon: const WenyouIcon(WenyouIconIds.actionShow),
            ),
          if (profile != null && stickersEnabled)
            IconButton(
              key: const Key('me-open-stickers'),
              tooltip: '管理表情包',
              onPressed: () => context.pushNamed('me-stickers'),
              icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
            ),
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
                title: '已恢复登录会话',
                message: '正在读取本人资料…',
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
                title: '本人资料没有加载完成',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: state.failure?.requestId == null
                    ? null
                    : '请求 ID：${state.failure!.requestId}',
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
          userMomentsBuilder: userMomentsBuilder,
          momentBookmarksBuilder: momentBookmarksBuilder,
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
          children: [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.identityMember,
                title: '正在读取资料',
                message: '头像、简介与公开范围马上就好。',
                action: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
        MeProfilePhase.failed => _MePageList(
          children: [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.statusOffline,
                title: '资料没有加载完成',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: state.failure?.requestId == null
                    ? null
                    : '请求 ID：${state.failure!.requestId}',
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

class MeSettingsPage extends ConsumerWidget {
  const MeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meProfileControllerProvider);
    final notifier = ref.read(meProfileControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('账号设置')),
      body: switch (state.phase) {
        MeProfilePhase.loading => const _MePageList(
          children: [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.actionSettings,
                title: '正在读取账号状态',
                message: '正在确认邮箱和安全设置…',
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
                title: '账号状态没有加载完成',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: state.failure?.requestId == null
                    ? null
                    : '请求 ID：${state.failure!.requestId}',
                action: OutlinedButton.icon(
                  key: const Key('me-settings-retry'),
                  onPressed: notifier.load,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
              ),
            ),
            const _LogoutPanel(),
          ],
        ),
        MeProfilePhase.ready => RefreshIndicator(
          onRefresh: state.isSubmitting ? () async {} : notifier.load,
          child: _MePageList(
            children: [
              _AccountSecurityPanel(disabled: state.isSubmitting),
              const _LogoutPanel(),
            ],
          ),
        ),
      },
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
  const _MeDashboard({
    required this.profile,
    required this.userMomentsBuilder,
    required this.momentBookmarksBuilder,
  });

  final MeProfileModel profile;
  final MeUserMomentsBuilder? userMomentsBuilder;
  final MeMomentBookmarksBuilder? momentBookmarksBuilder;

  @override
  ConsumerState<_MeDashboard> createState() => _MeDashboardState();
}

class _MeDashboardState extends ConsumerState<_MeDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: MeContentTab.values.length,
      vsync: this,
    )..addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    final index = _tabController.index;
    if (_visitedTabs.add(index)) setState(() {});
    final tab = MeContentTab.values[index].publicUserTab;
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
    final horizontal = wenyouHorizontalPagePadding(context);
    return NestedScrollView(
      key: const PageStorageKey('me-dashboard-scroll'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileOverview(profile: widget.profile),
                  SizedBox(height: tokens.space12),
                  _WalletBalanceStrip(state: walletState),
                  SizedBox(height: tokens.space20),
                  const WenyouSectionHeader(
                    title: '我的内容',
                    subtitle: '创建的主题会直接显示在这里，无需进入公开主页预览。',
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: WenyouConstrainedWidth(
                child: TabBar(
                  key: const Key('me-content-tabs'),
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    for (final tab in MeContentTab.values)
                      Tab(
                        key: Key('me-content-${tab.name}-tab'),
                        text: tab.label,
                        height: tokens.minimumTouchTarget,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          for (var index = 0; index < MeContentTab.values.length; index++)
            _visitedTabs.contains(index)
                ? MeContentTabBody(
                    key: PageStorageKey('me-content-tab-$index'),
                    tab: MeContentTab.values[index],
                    userId: widget.profile.id,
                    onRefreshChrome: _refreshChrome,
                    userMomentsBuilder: widget.userMomentsBuilder,
                    momentBookmarksBuilder: widget.momentBookmarksBuilder,
                  )
                : const SizedBox.expand(),
        ],
      ),
    );
  }

  Future<void> _refreshChrome() {
    final walletProvider = walletControllerProvider(walletSessionKey(ref));
    return Future.wait([
      ref.read(meProfileControllerProvider.notifier).load(),
      ref.read(walletProvider.notifier).refresh(),
    ]);
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
            subtitle: const Text('查看并退出其他活跃终端'),
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
            leading: const WenyouIcon(WenyouIconIds.actionMention),
            title: const Text('更换邮箱'),
            subtitle: const Text('使用当前密码和新邮箱验证码确认'),
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
  const _ProfileOverview({required this.profile});

  final MeProfileModel profile;

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
      actions: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const Key('me-open-edit-profile'),
          onPressed: () => context.pushNamed('me-edit'),
          icon: const WenyouIcon(WenyouIconIds.actionEdit),
          label: const Text('编辑资料'),
        ),
      ),
      stats: [
        UserProfileStatItem(
          key: const Key('me-open-following'),
          label: '关注',
          value: '${profile.followingCount}',
          onTap: () => context.pushNamed('me-following'),
        ),
        UserProfileStatItem(
          key: const Key('me-open-followers'),
          label: '粉丝',
          value: '${profile.followerCount}',
          onTap: () => context.pushNamed('me-followers'),
        ),
      ],
    );
  }
}

class _WalletBalanceStrip extends StatelessWidget {
  const _WalletBalanceStrip({required this.state});

  final WalletState state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final balance = state.summary?.balance;
    final formatted = balance == null
        ? '—'
        : '${WenyouAmount.format(balance)} L';
    final subtitle = state.summaryFailure != null
        ? '余额暂未同步，点按进入钱包重试'
        : state.isLoadingSummary
        ? '正在同步钱包余额…'
        : '与钱包详情使用同一份实时余额';
    return Semantics(
      button: true,
      label: '打开我的温油，当前余额 $formatted',
      child: WenyouPanel(
        key: const Key('me-open-wallet'),
        onTap: () => context.pushNamed('wallet'),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space16,
          vertical: tokens.space12,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.accentedBackground,
                borderRadius: BorderRadius.circular(tokens.radius12),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.space12),
                child: const WenyouIcon(WenyouIconIds.economyTransaction),
              ),
            ),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('钱包余额'),
                  SizedBox(height: tokens.space4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.space12),
            Text(
              formatted,
              key: const Key('me-wallet-balance'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(width: tokens.space4),
            const WenyouIcon(WenyouIconIds.navigationNext, size: 18),
          ],
        ),
      ),
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
          const WenyouSectionHeader(
            title: '当前会话',
            subtitle: '退出会撤销当前移动端会话并清除本机登录信息。',
          ),
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
                : '请求 ID：${logout.failure!.requestId}',
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
            child: const Text('仅清除本机登录'),
          ),
      ],
    );
  }

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出当前账号？'),
        content: const Text('将撤销当前移动端会话，并清除本机保存的登录信息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('logout-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final succeeded = await ref
        .read(logoutControllerProvider.notifier)
        .submit();
    if (succeeded && context.mounted) {
      context.go(AppRouteLocations.me);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已安全退出当前账号。')));
    }
  }

  Future<void> _confirmLocalLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('仅清除本机登录？'),
        content: const Text('服务器暂未确认撤销此会话。请稍后重新登录并在终端管理中检查。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('返回重试'),
          ),
          FilledButton(
            key: const Key('logout-local-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('清除本机登录'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(logoutControllerProvider.notifier).forceLocalLogout();
    if (context.mounted) {
      context.go(AppRouteLocations.me);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('本机登录信息已清除。')));
    }
  }
}

String _maskEmail(String email) {
  final separator = email.indexOf('@');
  if (separator <= 0 || separator == email.length - 1) return email;
  return '${email[0]}***${email.substring(separator)}';
}
