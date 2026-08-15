import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/session_logout_controller.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/users/application/avatar_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/profile_cover_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';

part 'me_avatar_editor.dart';
part 'me_profile_cover_editor.dart';
part 'me_profile_editor.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) return const _GuestMePage();
    return const _AuthenticatedMePage();
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
  const _AuthenticatedMePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meProfileControllerProvider);
    final notifier = ref.read(meProfileControllerProvider.notifier);
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
        MeProfilePhase.ready => RefreshIndicator(
          onRefresh: state.isSubmitting ? () async {} : notifier.load,
          child: _MePageList(children: [_MeDashboard(profile: state.profile!)]),
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
          child: _MePageList(children: [_MeProfileContent(state: state)]),
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
    final horizontal = width <= 400 ? tokens.space12 : tokens.space24;
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

class _MeDashboard extends ConsumerWidget {
  const _MeDashboard({required this.profile});

  final MeProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final stickersEnabled = ref.watch(stickersEnabledProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileOverview(profile: profile),
        SizedBox(height: tokens.space12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('me-open-edit-profile'),
                onPressed: () => context.pushNamed('me-edit'),
                icon: const WenyouIcon(WenyouIconIds.actionEdit),
                label: const Text('编辑资料'),
              ),
            ),
            SizedBox(width: tokens.space12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('me-open-public-profile'),
                onPressed: () => context.pushNamed(
                  'user-profile',
                  pathParameters: {'userId': profile.id},
                  queryParameters: const {'mode': 'preview'},
                ),
                icon: const WenyouIcon(WenyouIconIds.actionShow),
                label: const Text('预览公开主页'),
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.space12),
        WenyouPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                key: const Key('me-open-moments'),
                leading: const WenyouIcon(WenyouIconIds.navigationMoments),
                title: const Text('我的动态'),
                subtitle: const Text('查看已发布的公开动态'),
                trailing: const WenyouIcon(WenyouIconIds.navigationNext),
                onTap: () => context.pushNamed(
                  'user-moments',
                  pathParameters: {'userId': profile.id},
                ),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('me-open-bookmarks'),
                leading: const WenyouIcon(WenyouIconIds.actionBookmark),
                title: const Text('我的收藏'),
                subtitle: const Text('主题帖与动态收藏'),
                trailing: const WenyouIcon(WenyouIconIds.navigationNext),
                onTap: () => context.pushNamed('me-bookmarks'),
              ),
              if (stickersEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  key: const Key('me-open-stickers'),
                  leading: const WenyouIcon(WenyouIconIds.actionAddReaction),
                  title: const Text('表情包'),
                  subtitle: const Text('添加、排序和移除表情'),
                  trailing: const WenyouIcon(WenyouIconIds.navigationNext),
                  onTap: () => context.pushNamed('me-stickers'),
                ),
              ],
              const Divider(height: 1),
              ListTile(
                key: const Key('me-open-settings-tile'),
                leading: const WenyouIcon(WenyouIconIds.actionSettings),
                title: const Text('账号设置'),
                subtitle: const Text('邮箱、密码、终端、黑名单与退出'),
                trailing: const WenyouIcon(WenyouIconIds.navigationNext),
                onTap: () => context.pushNamed('me-settings'),
              ),
            ],
          ),
        ),
      ],
    );
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
        UserProfileStatItem(
          key: const Key('me-open-wallet'),
          label: '温油',
          value: '${profile.receivedTipTotal}L',
          onTap: () => context.pushNamed('wallet'),
        ),
      ],
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  const _PrivacySwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _SubmissionFailure extends StatelessWidget {
  const _SubmissionFailure({required this.failure});

  final ApiFailure failure;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: failure.businessCode == 40900
          ? '该用户名已被使用，请换一个。'
          : failure.userMessage,
      detail: failure.requestId == null ? null : '请求 ID：${failure.requestId}',
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

String? _validateUsername(String? value) {
  final username = value?.trim() ?? '';
  if (username.length < 2 || username.length > 24) {
    return '用户名需要 2–24 个字符';
  }
  if (!RegExp(r'^[A-Za-z0-9\u4E00-\u9FFF]+$').hasMatch(username)) {
    return '用户名只能包含字母、数字和中文';
  }
  return null;
}

String? _validateBio(String? value, String? currentBio) {
  final bio = value?.trim() ?? '';
  if (bio.length > 255) return '简介最多 255 个字符';
  if (bio.isEmpty && (currentBio?.isNotEmpty ?? false)) {
    return '当前接口暂不支持清空已有简介，请保留至少 1 个字符';
  }
  return null;
}

String _maskEmail(String email) {
  final separator = email.indexOf('@');
  if (separator <= 0 || separator == email.length - 1) return email;
  return '${email[0]}***${email.substring(separator)}';
}
