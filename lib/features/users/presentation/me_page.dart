import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/auth/application/logout_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

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
            icon: Icons.person_outline_rounded,
            title: '当前以游客身份浏览',
            message: '登录后可查看和管理本人资料、公开范围与账号会话。',
            action: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/auth/login?returnTo=/me'),
                icon: const Icon(Icons.login_rounded),
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
      appBar: AppBar(title: const Text('我的')),
      body: switch (state.phase) {
        MeProfilePhase.loading => _MePageList(
          children: const [
            WenyouPanel(
              child: WenyouEmptyState(
                icon: Icons.person_outline_rounded,
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
                icon: Icons.cloud_off_outlined,
                title: '本人资料没有加载完成',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: state.failure?.requestId == null
                    ? null
                    : '请求 ID：${state.failure!.requestId}',
                action: OutlinedButton.icon(
                  key: const Key('me-profile-retry'),
                  onPressed: notifier.load,
                  icon: const Icon(Icons.refresh_rounded),
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
              _MeProfileContent(state: state),
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: children[index],
            ),
          ),
        ],
      ],
    );
  }
}

class _MeProfileContent extends ConsumerStatefulWidget {
  const _MeProfileContent({required this.state});

  final MeProfileState state;

  @override
  ConsumerState<_MeProfileContent> createState() => _MeProfileContentState();
}

class _MeProfileContentState extends ConsumerState<_MeProfileContent> {
  final _usernameFormKey = GlobalKey<FormState>();
  final _settingsFormKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late bool _showRecentReplies;
  late bool _showPlayedThreads;
  late bool _showBookmarks;
  var _editingUsername = false;

  MeProfileModel get _profile => widget.state.profile!;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: _profile.username);
    _bioController = TextEditingController(text: _profile.bio ?? '');
    _showRecentReplies = _profile.showRecentReplies;
    _showPlayedThreads = _profile.showPlayedThreads;
    _showBookmarks = _profile.showBookmarks;
  }

  @override
  void didUpdateWidget(covariant _MeProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.state.profile!;
    final next = _profile;
    if (previous.updatedAt == next.updatedAt &&
        previous.username == next.username &&
        previous.bio == next.bio &&
        previous.showRecentReplies == next.showRecentReplies &&
        previous.showPlayedThreads == next.showPlayedThreads &&
        previous.showBookmarks == next.showBookmarks) {
      return;
    }
    _usernameController.text = next.username;
    _bioController.text = next.bio ?? '';
    _showRecentReplies = next.showRecentReplies;
    _showPlayedThreads = next.showPlayedThreads;
    _showBookmarks = next.showBookmarks;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        _ProfileOverview(profile: _profile),
        SizedBox(height: tokens.space12),
        _buildUsernamePanel(context),
        SizedBox(height: tokens.space12),
        _buildSettingsPanel(context),
        SizedBox(height: tokens.space12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('me-open-public-profile'),
            onPressed: widget.state.isSubmitting
                ? null
                : () => context.pushNamed(
                    'user-profile',
                    pathParameters: {'userId': _profile.id},
                  ),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('查看我的公开主页'),
          ),
        ),
        SizedBox(height: tokens.space12),
        _AccountContentPanel(disabled: widget.state.isSubmitting),
      ],
    );
  }

  Widget _buildUsernamePanel(BuildContext context) {
    final tokens = context.wenyouTokens;
    final failure = widget.state.failedAction == MeProfileAction.username
        ? widget.state.submissionFailure
        : null;
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Form(
        key: _usernameFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WenyouSectionHeader(
              title: '用户名',
              subtitle: '2–24 位字母、数字或中文；修改后 7 天内不可再次修改。',
            ),
            SizedBox(height: tokens.space16),
            if (_editingUsername) ...[
              TextFormField(
                key: const Key('me-username-field'),
                controller: _usernameController,
                enabled: !widget.state.isSubmitting,
                autofocus: true,
                maxLength: 24,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '新用户名',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: _validateUsername,
                onChanged: (_) => _clearFeedback(),
                onFieldSubmitted: (_) => _saveUsername(),
              ),
              if (failure != null) ...[
                SizedBox(height: tokens.space8),
                _SubmissionFailure(failure: failure),
              ],
              SizedBox(height: tokens.space12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.state.isSubmitting
                          ? null
                          : _cancelUsernameEdit,
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: tokens.space12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('me-username-save'),
                      onPressed:
                          widget.state.submitting == MeProfileAction.username
                          ? null
                          : _saveUsername,
                      icon: widget.state.submitting == MeProfileAction.username
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        widget.state.submitting == MeProfileAction.username
                            ? '保存中'
                            : '保存用户名',
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _profile.username,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(width: tokens.space12),
                  OutlinedButton.icon(
                    key: const Key('me-username-edit'),
                    onPressed: widget.state.isSubmitting
                        ? null
                        : () {
                            _clearFeedback();
                            setState(() {
                              _usernameController.text = _profile.username;
                              _editingUsername = true;
                            });
                          },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('修改'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(BuildContext context) {
    final tokens = context.wenyouTokens;
    final failure = widget.state.failedAction == MeProfileAction.settings
        ? widget.state.submissionFailure
        : null;
    return Form(
      key: _settingsFormKey,
      child: Column(
        children: [
          WenyouPanel(
            padding: EdgeInsets.all(tokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WenyouSectionHeader(
                  title: '基本信息',
                  subtitle: '头像上传将在图片能力切片接入；这里先管理文字资料。',
                ),
                SizedBox(height: tokens.space16),
                TextFormField(
                  key: const Key('me-bio-field'),
                  controller: _bioController,
                  enabled: !widget.state.isSubmitting,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: '个人简介',
                    hintText: '介绍一下自己（可选）',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => _validateBio(value, _profile.bio),
                  onChanged: (_) => _clearFeedback(),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space12),
          WenyouPanel(
            padding: EdgeInsets.all(tokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WenyouSectionHeader(
                  title: '公开范围',
                  subtitle: '关闭后，其他人不会在你的公开主页看到对应入口。',
                ),
                SizedBox(height: tokens.space8),
                _PrivacySwitch(
                  key: const Key('me-privacy-replies'),
                  title: '公开最近回复',
                  subtitle: '允许他人在你的主页查看最近 10 条回复',
                  value: _showRecentReplies,
                  enabled: !widget.state.isSubmitting,
                  onChanged: (value) {
                    _clearFeedback();
                    setState(() => _showRecentReplies = value);
                  },
                ),
                _PrivacySwitch(
                  key: const Key('me-privacy-played'),
                  title: '公开参与主题',
                  subtitle: '允许他人在你的主页查看玩家参与记录',
                  value: _showPlayedThreads,
                  enabled: !widget.state.isSubmitting,
                  onChanged: (value) {
                    _clearFeedback();
                    setState(() => _showPlayedThreads = value);
                  },
                ),
                _PrivacySwitch(
                  key: const Key('me-privacy-bookmarks'),
                  title: '公开收藏',
                  subtitle: '允许他人在你的主页查看收藏主题',
                  value: _showBookmarks,
                  enabled: !widget.state.isSubmitting,
                  onChanged: (value) {
                    _clearFeedback();
                    setState(() => _showBookmarks = value);
                  },
                ),
              ],
            ),
          ),
          if (failure != null) ...[
            SizedBox(height: tokens.space12),
            _SubmissionFailure(failure: failure),
          ],
          SizedBox(height: tokens.space12),
          WenyouAsyncPrimaryButton(
            key: const Key('me-settings-save'),
            label: '保存资料设置',
            loadingLabel: '正在保存资料设置',
            icon: Icons.save_outlined,
            isLoading: widget.state.submitting == MeProfileAction.settings,
            onPressed: widget.state.isSubmitting ? null : _saveSettings,
          ),
        ],
      ),
    );
  }

  void _cancelUsernameEdit() {
    _clearFeedback();
    setState(() {
      _usernameController.text = _profile.username;
      _editingUsername = false;
    });
  }

  Future<void> _saveUsername() async {
    if (!(_usernameFormKey.currentState?.validate() ?? false)) return;
    final succeeded = await ref
        .read(meProfileControllerProvider.notifier)
        .saveUsername(_usernameController.text);
    if (!mounted || !succeeded) return;
    setState(() => _editingUsername = false);
    _showSuccess();
  }

  Future<void> _saveSettings() async {
    if (!(_settingsFormKey.currentState?.validate() ?? false)) return;
    final succeeded = await ref
        .read(meProfileControllerProvider.notifier)
        .saveSettings(
          bio: _bioController.text,
          showRecentReplies: _showRecentReplies,
          showPlayedThreads: _showPlayedThreads,
          showBookmarks: _showBookmarks,
        );
    if (!mounted || !succeeded) return;
    _showSuccess();
  }

  void _showSuccess() {
    final message = ref.read(meProfileControllerProvider).successMessage;
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    ref.read(meProfileControllerProvider.notifier).clearFeedback();
  }

  void _clearFeedback() {
    ref.read(meProfileControllerProvider.notifier).clearFeedback();
  }
}

class _AccountContentPanel extends StatelessWidget {
  const _AccountContentPanel({required this.disabled});

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return WenyouPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            key: const Key('me-open-bookmarks'),
            enabled: !disabled,
            leading: const Icon(Icons.bookmarks_outlined),
            title: const Text('我的收藏'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: disabled ? null : () => context.pushNamed('me-bookmarks'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-following'),
            enabled: !disabled,
            leading: const Icon(Icons.person_add_alt_1_outlined),
            title: const Text('我关注的人'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: disabled ? null : () => context.pushNamed('me-following'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-followers'),
            enabled: !disabled,
            leading: const Icon(Icons.people_outline_rounded),
            title: const Text('我的粉丝'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: disabled ? null : () => context.pushNamed('me-followers'),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('me-open-blocks'),
            enabled: !disabled,
            leading: const Icon(Icons.block_outlined),
            title: const Text('管理黑名单'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: disabled ? null : () => context.pushNamed('me-blocks'),
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
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        WenyouPanel(
          child: Column(
            children: [
              _MeAvatar(profile: profile),
              SizedBox(height: tokens.space12),
              Text(
                profile.username,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: tokens.space4),
              Text(
                _maskEmail(profile.email),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: tokens.space8),
              _InfoPill(
                icon: profile.emailVerified
                    ? Icons.verified_outlined
                    : Icons.warning_amber_rounded,
                label: profile.emailVerified ? '邮箱已验证' : '邮箱待验证',
              ),
              SizedBox(height: tokens.space12),
              Text(
                '${DateFormat('yyyy-MM-dd').format(profile.createdAt)} 加入温油站',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space12),
        WenyouPanel(
          padding: EdgeInsets.all(tokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WenyouSectionHeader(
                title: 'Lv.${profile.level} 成长进度',
                subtitle: profile.nextLevelExperience == null
                    ? '已达到当前最高等级'
                    : '${profile.experience} / ${profile.nextLevelExperience} 经验',
              ),
              SizedBox(height: tokens.space12),
              Semantics(
                label: '等级进度 ${(profile.levelProgress * 100).round()}%',
                child: LinearProgressIndicator(value: profile.levelProgress),
              ),
              SizedBox(height: tokens.space16),
              Wrap(
                spacing: tokens.space16,
                runSpacing: tokens.space8,
                children: [
                  Text('关注 ${profile.followingCount}'),
                  Text('粉丝 ${profile.followerCount}'),
                  Text(
                    '收到 ${profile.receivedTipTotal}L · ${profile.receivedTipCount} 次',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeAvatar extends StatelessWidget {
  const _MeAvatar({required this.profile});

  final MeProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, size: 42, color: tokens.mutedText),
    );
    return Semantics(
      image: true,
      label: '${profile.username} 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: 84,
          child: profile.avatarUrl == null
              ? fallback
              : CachedNetworkImage(
                  imageUrl: profile.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.accentedBackground,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: tokens.focus),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
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
              : const Icon(Icons.logout_rounded),
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
