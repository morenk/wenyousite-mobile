part of 'me_page.dart';

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
    final avatarState = ref.watch(avatarControllerProvider);
    final profileWriteDisabled =
        widget.state.isSubmitting || avatarState.isBusy;
    return Column(
      children: [
        WenyouPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WenyouSectionHeader(title: '头像'),
              SizedBox(height: tokens.space16),
              _AvatarEditor(
                profile: _profile,
                profileWriteDisabled: widget.state.isSubmitting,
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space12),
        _buildUsernamePanel(context, profileWriteDisabled),
        SizedBox(height: tokens.space12),
        _buildSettingsPanel(context, profileWriteDisabled),
      ],
    );
  }

  Widget _buildUsernamePanel(BuildContext context, bool disabled) {
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
                enabled: !disabled,
                autofocus: true,
                maxLength: 24,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '新用户名',
                  prefixIcon: WenyouIcon(WenyouIconIds.identityLevel),
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
                      onPressed: disabled ? null : _cancelUsernameEdit,
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: tokens.space12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('me-username-save'),
                      onPressed: disabled ? null : _saveUsername,
                      icon: widget.state.submitting == MeProfileAction.username
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(WenyouIconIds.actionConfirm),
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
                    onPressed: disabled
                        ? null
                        : () {
                            _clearFeedback();
                            setState(() {
                              _usernameController.text = _profile.username;
                              _editingUsername = true;
                            });
                          },
                    icon: const WenyouIcon(WenyouIconIds.actionEdit),
                    label: const Text('修改'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(BuildContext context, bool disabled) {
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
                  subtitle: '头像在上方独立管理；这里保存公开文字资料。',
                ),
                SizedBox(height: tokens.space16),
                TextFormField(
                  key: const Key('me-bio-field'),
                  controller: _bioController,
                  enabled: !disabled,
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
                  enabled: !disabled,
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
                  enabled: !disabled,
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
                  enabled: !disabled,
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
            icon: WenyouIconIds.actionSave,
            isLoading: widget.state.submitting == MeProfileAction.settings,
            onPressed: disabled ? null : _saveSettings,
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
