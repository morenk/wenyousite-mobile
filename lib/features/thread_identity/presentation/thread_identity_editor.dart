import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_feedback.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart'
    show showWenyouSnackBar;
import 'package:wenyousite_mobile/features/media/application/avatar_image_policy.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/avatar_crop.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_profile.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_editor_content.dart';

Future<ThreadIdentityState?> showThreadIdentityEditor(
  BuildContext context,
  String threadId, {
  String? identityId,
  ThreadIdentityEditorDraft? draft,
}) => showWenyouSheet<ThreadIdentityState>(
  context: context,
  dismissible: false,
  builder: (_) => _ThreadIdentityEditor(
    threadId: threadId,
    identityId: identityId,
    draft: draft,
  ),
);

class _ThreadIdentityEditor extends ConsumerStatefulWidget {
  const _ThreadIdentityEditor({
    required this.threadId,
    this.identityId,
    this.draft,
  });
  final String threadId;
  final String? identityId;
  final ThreadIdentityEditorDraft? draft;
  @override
  ConsumerState<_ThreadIdentityEditor> createState() =>
      _ThreadIdentityEditorState();
}

class _ThreadIdentityEditorState extends ConsumerState<_ThreadIdentityEditor> {
  final _nickname = TextEditingController();
  final _profileLink = TextEditingController();
  String _initialProfileLink = '';
  String? _profileLinkError;
  final _uploadKey = Object();
  ThreadIdentityState? _identity;
  String? _avatarMediaId;
  String? _avatarUrl;
  String? _error;
  bool _busy = false;
  bool _loaded = false;
  bool _uncertain = false;
  bool _retainDraft = false;
  bool _versionChanged = false;
  bool _atLimit = false;
  bool _allowPop = false;
  bool _confirmingClose = false;
  bool _saveInFlight = false;
  late final Object _session;

  @override
  void initState() {
    super.initState();
    _session = ref.read(sessionScopeProvider);
    unawaited(_load());
  }

  bool get _active => mounted && ref.read(sessionScopeProvider) == _session;
  bool get _dirty =>
      _loaded &&
      (_nickname.text.trim() != (_identity?.nickname ?? '') ||
          _avatarMediaId != _identity?.avatarMediaId ||
          _profileLink.text.trim() != _initialProfileLink);

  Future<void> _requestClose() async {
    if (!_active || _confirmingClose || _allowPop) return;
    if (_busy ||
        ref.read(mediaUploadTaskControllerProvider(_uploadKey)).isBusy) {
      showWenyouSnackBar(context, '资料正在处理，请稍候。');
      return;
    }
    if (_dirty) {
      _confirmingClose = true;
      final discard = await showWenyouConfirmationDialog(
        context: context,
        title: '放弃未保存的修改？',
        message: '身份资料尚未保存。',
        confirmLabel: '放弃修改',
        cancelLabel: '继续编辑',
        confirmKey: const Key('thread-identity-discard'),
        tone: WenyouConfirmationTone.destructive,
      );
      _confirmingClose = false;
      if (!discard || !_active) return;
    }
    await _finish();
  }

  Future<void> _finish([ThreadIdentityState? result]) async {
    if (!_active || _allowPop) return;
    final route = ModalRoute.of(context);
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted && _active && route?.isCurrent == true) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(threadIdentityRepositoryProvider);
      final collection = widget.identityId == null
          ? await repo.list(widget.threadId)
          : null;
      final value =
          collection?.account ??
          await repo.find(widget.threadId, widget.identityId!);
      _atLimit =
          collection != null &&
          collection.identities.length >= collection.limit;
      if (!_active) return;
      setState(() {
        _identity = value;
        if (!_loaded) {
          _nickname.text = widget.draft?.nickname ?? value.nickname ?? '';
          _initialProfileLink = value.editableProfilePostId == null
              ? ''
              : identityProfilePostLink(
                  widget.threadId,
                  value.editableProfilePostId!,
                );
          _profileLink.text = widget.draft?.profileLink ?? _initialProfileLink;
          _avatarMediaId = widget.draft?.avatarMediaId ?? value.avatarMediaId;
          _avatarUrl = widget.draft?.avatarUrl ?? value.displayAvatarUrl;
          _uncertain = widget.draft?.uncertain ?? false;
          _loaded = true;
        }
        _error = null;
      });
    } on Object catch (error) {
      if (_active) {
        setState(
          () => _error = wenyouFailureMessage(
            mapApplicationFailure(error, '帖内身份加载失败，请重试。'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!_retainDraft) widget.draft?.clear();
    if (_retainDraft && widget.draft != null) {
      final draft = widget.draft!;
      draft.nickname = _nickname.text.trim();
      draft.profileLink = _profileLink.text.trim();
      draft.avatarMediaId = _avatarMediaId;
      draft.avatarUrl = _avatarUrl;
      draft.uncertain = _uncertain;
    }
    _nickname.dispose();
    _profileLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (_, next) {
      if (next == _session) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isActive) {
        Navigator.of(context).removeRoute(route);
      }
    });
    if (!_active) return const SizedBox.shrink();
    final upload = ref.watch(mediaUploadTaskControllerProvider(_uploadKey));
    final identity = _identity;
    return PopScope<ThreadIdentityState>(
      canPop: _allowPop || (!_dirty && !_busy && !upload.isBusy),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestClose());
      },
      child: WenyouSheetBody(
        title: '设置帖内身份',
        onClose: _requestClose,
        closeEnabled: !_busy && !upload.isBusy,
        slivers: [
          SliverToBoxAdapter(
            child: identity == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_error == null)
                        const CircularProgressIndicator()
                      else ...[
                        Text(_error!),
                        TextButton(onPressed: _load, child: const Text('重试')),
                      ],
                    ],
                  )
                : ThreadIdentityEditorContent(
                    nicknameController: _nickname,
                    profileLinkController:
                        ref
                            .watch(appCapabilitiesProvider)
                            .rpIdentityProfileSupported
                        ? _profileLink
                        : null,
                    profileLinkError: _profileLinkError,
                    onProfileLinkChanged: (_) =>
                        setState(() => _profileLinkError = null),
                    previewName: _nickname.text.trim().isEmpty
                        ? identity.accountName
                        : _nickname.text.trim(),
                    previewAvatarUrl: _avatarMediaId == null
                        ? identity.accountAvatarUrl
                        : _avatarUrl,
                    canEdit: identity.canEdit && _active && !_atLimit,
                    isBusy: _busy || upload.isBusy,
                    hasCustomAvatar: _avatarMediaId != null,
                    hasSavedIdentity: identity.canDelete,
                    maxNicknameLength: 24,
                    progressLabel: upload.isBusy ? upload.progressLabel : null,
                    errorMessage: _atLimit
                        ? '已满 10 个身份'
                        : _error ?? upload.failure?.userMessage,
                    onReviewIdentities: _uncertain
                        ? () {
                            _retainDraft = true;
                            unawaited(_finish());
                          }
                        : null,
                    onNicknameChanged: (_) => setState(() {}),
                    onSelectAvatar: _pickAvatar,
                    onClearAvatar: () => setState(() {
                      _avatarMediaId = null;
                      _avatarUrl = null;
                    }),
                    onSave: () => _save(clear: false),
                    onClear: () => _save(clear: true),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    if (_busy || !_active) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final selected = await ref
          .read(avatarImagePickerPortProvider)
          .pickAvatarFromGallery();
      if (!mounted || !_active || selected == null) return;
      final input = validateAvatarImageInput(selected);
      final cropped = await showAvatarCropDialog(
        context,
        input: input,
        processor: ref.read(imageCropProcessorPortProvider),
      );
      if (!_active || cropped == null) return;
      final image = await ref
          .read(mediaUploadTaskControllerProvider(_uploadKey).notifier)
          .uploadInput(validateAvatarImageInput(cropped));
      if (!_active || image == null) return;
      setState(() {
        _avatarMediaId = image.mediaId;
        _avatarUrl = image.url;
      });
    } on Object catch (error) {
      if (_active) {
        setState(
          () => _error = wenyouFailureMessage(
            mapApplicationFailure(error, '头像准备失败，请重试。'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save({required bool clear}) async {
    if (_saveInFlight) return;
    _saveInFlight = true;
    try {
      await _performSave(clear: clear);
    } finally {
      _saveInFlight = false;
    }
  }

  Future<void> _performSave({required bool clear}) async {
    final identity = _identity;
    if (_busy || !_active || identity == null) return;
    if (!clear) {
      final error = validateThreadIdentityNickname(_nickname.text);
      if (error != null) {
        setState(() => _error = error);
        return;
      }
    }
    if (!clear &&
        widget.identityId == null &&
        _nickname.text.trim().isEmpty &&
        _avatarMediaId == null) {
      setState(() => _error = '请设置昵称或头像');
      return;
    }
    if ((_uncertain || _versionChanged) &&
        !await showWenyouConfirmationDialog(
          context: context,
          title: _uncertain ? '再次新建身份？' : '保存你的修改？',
          message: _uncertain
              ? '上次操作可能已成功。再次新建会占用一个名额，请先确认身份列表。'
              : '这份身份已在其他地方修改，继续将覆盖对应资料。',
          confirmLabel: _uncertain ? '再次新建' : '保存',
          cancelLabel: '返回',
        )) {
      return;
    }
    if (!mounted || !_active) return;
    if (clear &&
        !await showWenyouConfirmationDialog(
          context: context,
          title: '删除这个身份？',
          message: '已有发言保留当时的身份。',
          confirmLabel: '删除',
        )) {
      return;
    }
    if (!_active) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final profileChanged =
        !clear &&
        ref.read(appCapabilitiesProvider).rpIdentityProfileSupported &&
        _profileLink.text.trim() != _initialProfileLink;
    String? profilePostId;
    if (profileChanged && _profileLink.text.trim().isNotEmpty) {
      try {
        profilePostId = parseIdentityProfilePostLink(
          _profileLink.text,
          threadId: widget.threadId,
        );
        final target = await ref.read(identityProfilePostLookupProvider)(
          profilePostId,
        );
        if (!_active) return;
        if (target == null || target.id != profilePostId) {
          throw const DomainValidationException('资料暂不可用');
        }
        if (target.threadId != widget.threadId) {
          throw const DomainValidationException('请选择本主题内的楼层');
        }
      } on Object catch (error) {
        if (_active) {
          final failure = mapApplicationFailure(error, '资料读取失败，请重试');
          setState(() {
            _busy = false;
            _profileLinkError = error is DomainValidationException
                ? error.message
                : const {401, 403, 404, 410}.contains(failure.httpStatus)
                ? '资料暂不可用'
                : '资料读取失败，请重试';
          });
        }
        return;
      }
    }
    try {
      final repo = ref.read(threadIdentityRepositoryProvider);
      final input = ThreadIdentityUpdate(
        nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
        clearNickname: _nickname.text.trim().isEmpty,
        avatarMediaId: _avatarMediaId,
        clearAvatar: _avatarMediaId == null,
        version: identity.version,
        profilePostId: profileChanged ? profilePostId : null,
        clearProfilePost: profileChanged && profilePostId == null,
      );
      final value = clear
          ? await repo.remove(
              widget.threadId,
              widget.identityId!,
              identity.version!,
            )
          : widget.identityId == null
          ? await repo.create(widget.threadId, input)
          : await repo.updateRole(widget.threadId, widget.identityId!, input);
      if (!mounted || !_active) return;
      ref.read(visibilityCacheInvalidatorProvider)();
      _uncertain = false;
      _nickname.clear();
      _profileLink.clear();
      _avatarMediaId = null;
      _avatarUrl = null;
      widget.draft?.clear();
      await _finish(value);
    } on Object catch (error) {
      if (!_active) return;
      final failure = mapApplicationFailure(error, '帖内资料保存失败，已保留你的输入。');
      _versionChanged = failure.businessCode == 40002;
      if (widget.identityId == null &&
          (failure.httpStatus == null ||
              failure.httpStatus! >= 500 ||
              failure.httpStatus == 429)) {
        _uncertain = true;
      }
      // 刷新资格与集合，同时保留输入；下次写入需明确确认版本或未知新建。
      await _load();
      if (_active) {
        if (profileChanged && failure.businessCode == 40403) {
          setState(() => _profileLinkError = '资料暂不可用');
          return;
        }
        setState(
          () => _error = failure.businessCode == 40013
              ? '已满 10 个身份'
              : _uncertain
              ? '保存失败，请先查看身份列表。'
              : wenyouFailureMessage(failure, treatAsWrite: true),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
