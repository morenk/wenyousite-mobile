import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/application/avatar_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/profile_cover_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_profile_media_editor.dart';

class MeProfileEditDraft extends ChangeNotifier {
  MeProfileEditDraft() {
    bioController.addListener(_handleBioChanged);
  }

  final TextEditingController bioController = TextEditingController();
  MeProfileModel? _baseline;
  var _showRecentReplies = false;
  var _showPlayedThreads = false;
  var _showBookmarks = false;
  var _synchronizing = false;

  bool get showRecentReplies => _showRecentReplies;
  bool get showPlayedThreads => _showPlayedThreads;
  bool get showBookmarks => _showBookmarks;

  bool get isDirty {
    final baseline = _baseline;
    if (baseline == null) return false;
    return bioController.text.trim() != (baseline.bio ?? '') ||
        _showRecentReplies != baseline.showRecentReplies ||
        _showPlayedThreads != baseline.showPlayedThreads ||
        _showBookmarks != baseline.showBookmarks;
  }

  String? get currentBio => _baseline?.bio;

  void bind(MeProfileModel profile) {
    final baseline = _baseline;
    if (baseline == null || baseline.id != profile.id) {
      _replaceWith(profile, notify: false);
      return;
    }
    final bioWasDirty = bioController.text.trim() != (baseline.bio ?? '');
    final repliesWereDirty = _showRecentReplies != baseline.showRecentReplies;
    final playedWereDirty = _showPlayedThreads != baseline.showPlayedThreads;
    final bookmarksWereDirty = _showBookmarks != baseline.showBookmarks;
    _baseline = profile;
    _synchronizing = true;
    if (!bioWasDirty) bioController.text = profile.bio ?? '';
    if (!repliesWereDirty) _showRecentReplies = profile.showRecentReplies;
    if (!playedWereDirty) _showPlayedThreads = profile.showPlayedThreads;
    if (!bookmarksWereDirty) _showBookmarks = profile.showBookmarks;
    _synchronizing = false;
  }

  void commit(MeProfileModel profile) => _replaceWith(profile, notify: true);

  void setShowRecentReplies(bool value) {
    if (_showRecentReplies == value) return;
    _showRecentReplies = value;
    notifyListeners();
  }

  void setShowPlayedThreads(bool value) {
    if (_showPlayedThreads == value) return;
    _showPlayedThreads = value;
    notifyListeners();
  }

  void setShowBookmarks(bool value) {
    if (_showBookmarks == value) return;
    _showBookmarks = value;
    notifyListeners();
  }

  void _replaceWith(MeProfileModel profile, {required bool notify}) {
    _baseline = profile;
    _synchronizing = true;
    bioController.text = profile.bio ?? '';
    _showRecentReplies = profile.showRecentReplies;
    _showPlayedThreads = profile.showPlayedThreads;
    _showBookmarks = profile.showBookmarks;
    _synchronizing = false;
    if (notify) notifyListeners();
  }

  void _handleBioChanged() {
    if (!_synchronizing) notifyListeners();
  }

  @override
  void dispose() {
    bioController
      ..removeListener(_handleBioChanged)
      ..dispose();
    super.dispose();
  }
}

class MeProfileEditor extends ConsumerWidget {
  const MeProfileEditor({
    required this.state,
    required this.draft,
    required this.formKey,
    super.key,
  });

  final MeProfileState state;
  final MeProfileEditDraft draft;
  final GlobalKey<FormState> formKey;

  MeProfileModel get _profile => state.profile!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final avatarState = ref.watch(avatarControllerProvider);
    final coverState = ref.watch(profileCoverControllerProvider);
    final mediaBusy = avatarState.isBusy || coverState.isBusy;
    final mutationBusy = state.isSubmitting || mediaBusy;
    final settingsFailure = state.failedAction == MeProfileAction.settings
        ? state.submissionFailure
        : null;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MeProfileMediaEditor(
            profile: _profile,
            mutationsDisabled: state.isSubmitting,
          ),
          SizedBox(height: tokens.space8),
          _UsernameRow(
            username: _profile.username,
            enabled: !mutationBusy,
            onTap: () => _openUsernameEditor(context, ref, _profile.username),
          ),
          SizedBox(height: tokens.space24),
          Text('个人简介', style: Theme.of(context).textTheme.wenyouSectionTitle),
          SizedBox(height: tokens.space8),
          TextFormField(
            key: const Key('me-bio-field'),
            controller: draft.bioController,
            enabled: !state.isSubmitting,
            minLines: 3,
            maxLines: 5,
            maxLength: 255,
            decoration: const InputDecoration(
              hintText: '介绍一下自己',
              alignLabelWithHint: true,
            ),
            validator: (value) => _validateBio(value, draft.currentBio),
            onChanged: (_) => _clearFeedback(ref),
          ),
          SizedBox(height: tokens.space16),
          const WenyouSectionHeader(
            title: '主页公开内容',
            subtitle: '选择其他人能在你的主页看到的内容。',
          ),
          SizedBox(height: tokens.space4),
          _PrivacySwitch(
            key: const Key('me-privacy-replies'),
            title: '最近回复',
            value: draft.showRecentReplies,
            enabled: !state.isSubmitting,
            onChanged: (value) {
              _clearFeedback(ref);
              draft.setShowRecentReplies(value);
            },
          ),
          const Divider(height: 1),
          _PrivacySwitch(
            key: const Key('me-privacy-played'),
            title: '参与的主题',
            value: draft.showPlayedThreads,
            enabled: !state.isSubmitting,
            onChanged: (value) {
              _clearFeedback(ref);
              draft.setShowPlayedThreads(value);
            },
          ),
          const Divider(height: 1),
          _PrivacySwitch(
            key: const Key('me-privacy-bookmarks'),
            title: '收藏的主题',
            value: draft.showBookmarks,
            enabled: !state.isSubmitting,
            onChanged: (value) {
              _clearFeedback(ref);
              draft.setShowBookmarks(value);
            },
          ),
          if (settingsFailure != null) ...[
            SizedBox(height: tokens.space12),
            _SubmissionFailure(
              key: const Key('me-settings-failure'),
              failure: settingsFailure,
            ),
          ],
        ],
      ),
    );
  }

  void _clearFeedback(WidgetRef ref) {
    ref.read(meProfileControllerProvider.notifier).clearFeedback();
  }
}

class _UsernameRow extends StatelessWidget {
  const _UsernameRow({
    required this.username,
    required this.enabled,
    required this.onTap,
  });

  final String username;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return ListTile(
      key: const Key('me-username-edit'),
      contentPadding: EdgeInsets.zero,
      minTileHeight: 64,
      enabled: enabled,
      titleTextStyle: Theme.of(context).textTheme.wenyouRowTitle,
      title: const Text('用户名'),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .55,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
              ),
            ),
            SizedBox(width: tokens.space4),
            WenyouIcon(
              WenyouIconIds.navigationNext,
              size: 18,
              color: tokens.mutedText,
            ),
          ],
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  const _PrivacySwitch({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String title;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.wenyouRowTitle),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _SubmissionFailure extends StatefulWidget {
  const _SubmissionFailure({required this.failure, super.key});

  final ApiFailure failure;

  @override
  State<_SubmissionFailure> createState() => _SubmissionFailureState();
}

class _SubmissionFailureState extends State<_SubmissionFailure> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: .85,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: widget.failure.userMessage,
      detail: wenyouFailureDetail(widget.failure, treatAsWrite: true),
    );
  }
}

Future<void> _openUsernameEditor(
  BuildContext context,
  WidgetRef ref,
  String username,
) async {
  final updated = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => _UsernameEditorSheet(username: username),
  );
  ref.read(meProfileControllerProvider.notifier).clearFeedback();
  if (updated == true && context.mounted) {
    showWenyouSnackBar(context, '用户名已更新。', tone: WenyouSnackBarTone.success);
  }
}

class _UsernameEditorSheet extends ConsumerStatefulWidget {
  const _UsernameEditorSheet({required this.username});

  final String username;

  @override
  ConsumerState<_UsernameEditorSheet> createState() =>
      _UsernameEditorSheetState();
}

class _UsernameEditorSheetState extends ConsumerState<_UsernameEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(meProfileControllerProvider);
    final submitting = state.submitting == MeProfileAction.username;
    final failure = state.failedAction == MeProfileAction.username
        ? state.submissionFailure
        : null;
    return PopScope(
      canPop: !submitting,
      child: AnimatedPadding(
        duration: tokens.feedbackDuration,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            0,
            tokens.space16,
            tokens.space16,
          ),
          child: WenyouConstrainedWidth(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '修改用户名',
                          style: Theme.of(context).textTheme.wenyouOverlayTitle,
                        ),
                      ),
                      IconButton(
                        tooltip: '关闭',
                        onPressed: submitting
                            ? null
                            : () => Navigator.pop(context),
                        icon: const WenyouIcon(WenyouIconIds.actionClose),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.space8),
                  TextFormField(
                    key: const Key('me-username-field'),
                    controller: _controller,
                    enabled: !submitting,
                    autofocus: true,
                    maxLength: 24,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: '用户名',
                      errorText: failure == null
                          ? null
                          : failure.businessCode == 40900
                          ? '这个用户名已被使用'
                          : failure.userMessage,
                    ),
                    validator: _validateUsername,
                    onChanged: (_) => ref
                        .read(meProfileControllerProvider.notifier)
                        .clearFeedback(),
                    onFieldSubmitted: (_) => _save(),
                  ),
                  Text(
                    '2–24 个字符，仅支持中文、字母和数字；修改后 7 天内不能再次修改。',
                    style: Theme.of(
                      context,
                    ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
                  ),
                  SizedBox(height: tokens.space16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        key: const Key('me-username-cancel'),
                        onPressed: submitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      SizedBox(width: tokens.space8),
                      FilledButton(
                        key: const Key('me-username-save'),
                        onPressed: submitting ? null : _save,
                        child: submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final next = _controller.text.trim();
    if (next == widget.username) {
      Navigator.pop(context, false);
      return;
    }
    final succeeded = await ref
        .read(meProfileControllerProvider.notifier)
        .saveUsername(next);
    if (succeeded && mounted) Navigator.pop(context, true);
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
    return '请至少保留 1 个字符';
  }
  return null;
}
