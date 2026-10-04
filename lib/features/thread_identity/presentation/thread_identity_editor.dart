import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_feedback.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_policy.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/avatar_crop.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_editor_content.dart';

Future<ThreadIdentityState?> showThreadIdentityEditor(
  BuildContext context,
  String threadId,
) => showWenyouSheet<ThreadIdentityState>(
  context: context,
  builder: (_) => _ThreadIdentityEditor(threadId: threadId),
);

class _ThreadIdentityEditor extends ConsumerStatefulWidget {
  const _ThreadIdentityEditor({required this.threadId});
  final String threadId;
  @override
  ConsumerState<_ThreadIdentityEditor> createState() =>
      _ThreadIdentityEditorState();
}

class _ThreadIdentityEditorState extends ConsumerState<_ThreadIdentityEditor> {
  final _nickname = TextEditingController();
  final _uploadKey = Object();
  ThreadIdentityState? _identity;
  String? _avatarMediaId;
  String? _avatarUrl;
  String? _error;
  bool _busy = false;
  bool _loaded = false;
  late final Object _session;

  @override
  void initState() {
    super.initState();
    _session = ref.read(sessionScopeProvider);
    unawaited(_load());
  }

  bool get _active => mounted && ref.read(sessionScopeProvider) == _session;

  Future<void> _load() async {
    try {
      final value = await ref
          .read(threadIdentityRepositoryProvider)
          .mine(widget.threadId);
      if (!_active) return;
      setState(() {
        _identity = value;
        if (!_loaded) {
          _nickname.text = value.nickname ?? '';
          _avatarMediaId = value.avatarMediaId;
          _avatarUrl = value.displayAvatarUrl;
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
    _nickname.dispose();
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
    return WenyouSheetBody(
      title: '设置帖内身份',
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
                  accountName: identity.accountName,
                  previewName: _nickname.text.trim().isEmpty
                      ? identity.accountName
                      : _nickname.text.trim(),
                  previewAvatarUrl: _avatarMediaId == null
                      ? identity.accountAvatarUrl
                      : _avatarUrl,
                  canEdit: identity.canEdit && _active,
                  isBusy: _busy || upload.isBusy,
                  hasCustomAvatar: _avatarMediaId != null,
                  hasSavedIdentity:
                      identity.nickname != null ||
                      identity.avatarMediaId != null,
                  maxNicknameLength: 24,
                  progressLabel: upload.isBusy ? upload.progressLabel : null,
                  errorMessage: _error ?? upload.failure?.userMessage,
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
    final identity = _identity;
    if (_busy || !_active || identity == null) return;
    if (!clear) {
      final error = validateThreadIdentityNickname(_nickname.text);
      if (error != null) {
        setState(() => _error = error);
        return;
      }
    }
    if (clear &&
        !await showWenyouConfirmationDialog(
          context: context,
          title: '清除帖内资料？',
          message: '之后的发言将沿用站内资料，已有发言保留当时的身份。',
          confirmLabel: '清除',
        )) {
      return;
    }
    if (!_active) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(threadIdentityRepositoryProvider);
      final value = clear
          ? await repo.clear(widget.threadId)
          : await repo.update(
              widget.threadId,
              ThreadIdentityUpdate(
                nickname: _nickname.text.trim().isEmpty
                    ? null
                    : _nickname.text.trim(),
                clearNickname: _nickname.text.trim().isEmpty,
                avatarMediaId: _avatarMediaId,
                clearAvatar: _avatarMediaId == null,
                version: identity.version,
              ),
            );
      if (!mounted || !_active) return;
      ref.read(visibilityCacheInvalidatorProvider)();
      Navigator.of(context).pop(value);
    } on Object catch (error) {
      if (!_active) return;
      final failure = mapApplicationFailure(error, '帖内资料保存失败，已保留你的输入。');
      // 刷新资格和版本，同时保持用户尚未提交的头像与昵称输入。
      await _load();
      if (_active) {
        setState(
          () => _error = wenyouFailureMessage(failure, treatAsWrite: true),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
