import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_widgets.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';
import 'package:wenyousite_mobile/features/media/presentation/image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/users/application/avatar_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/profile_cover_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

class MeProfileMediaEditor extends ConsumerWidget {
  const MeProfileMediaEditor({
    required this.profile,
    required this.mutationsDisabled,
    super.key,
  });

  final MeProfileModel profile;
  final bool mutationsDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final avatarState = ref.watch(avatarControllerProvider);
    final coverState = ref.watch(profileCoverControllerProvider);
    final mediaBusy = avatarState.isBusy || coverState.isBusy;
    final targetsDisabled = mutationsDisabled || mediaBusy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const avatarSize = 72.0;
            const avatarOverlap = avatarSize / 2;
            final coverHeight = constraints.maxWidth / 2;
            return SizedBox(
              key: const Key('me-profile-media-stage'),
              height: coverHeight + avatarOverlap + tokens.space8,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    bottom: avatarOverlap + tokens.space8,
                    child: _CoverEditTarget(
                      profile: profile,
                      previewBytes: coverState.previewBytes,
                      busy:
                          coverState.isBusy && coverState.previewBytes != null,
                      failed:
                          coverState.failure != null &&
                          coverState.previewBytes != null,
                      onFailureTap: () =>
                          _showCoverFailure(context, ref, coverState),
                      enabled: !targetsDisabled,
                      onTap: () => _handleCoverTap(context, ref),
                    ),
                  ),
                  Positioned(
                    left: tokens.space16,
                    top: coverHeight - avatarOverlap,
                    child: _AvatarEditTarget(
                      profile: profile,
                      previewBytes: avatarState.previewBytes,
                      busy:
                          avatarState.isBusy &&
                          avatarState.previewBytes != null,
                      failed:
                          avatarState.failure != null &&
                          avatarState.previewBytes != null,
                      onFailureTap: () =>
                          _showAvatarFailure(context, ref, avatarState),
                      enabled: !targetsDisabled,
                      onTap: () => _handleAvatarTap(context, ref),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if ((avatarState.isBusy || avatarState.failure != null) &&
            avatarState.previewBytes == null) ...[
          SizedBox(height: tokens.space8),
          _AvatarTaskFeedback(
            state: avatarState,
            onCancel: ref.read(avatarControllerProvider.notifier).cancelUpload,
            onRetry: () => _retryAvatar(context, ref),
          ),
        ] else if ((coverState.isBusy || coverState.failure != null) &&
            coverState.previewBytes == null) ...[
          SizedBox(height: tokens.space8),
          _CoverTaskFeedback(
            state: coverState,
            onCancel: ref
                .read(profileCoverControllerProvider.notifier)
                .cancelUpload,
            onRetry: () => _retryCover(context, ref),
          ),
        ],
      ],
    );
  }

  Future<void> _showAvatarFailure(
    BuildContext context,
    WidgetRef ref,
    AvatarState state,
  ) async {
    final delayed =
        state.uploadFailure?.failure.source == FailureSource.expected &&
        state.uploadFailure?.failure.reason == FailureReason.timeout;
    final action = await showPendingImageActions(
      context,
      title: delayed ? '图片准备较久' : '头像未完成',
      retryLabel: delayed ? '继续等待' : '重试',
      removeLabel: '放弃本次更换',
      detail: state.failure?.userMessage,
      canRetry: state.uploadFailure?.canRetry != false,
    );
    if (!context.mounted) return;
    if (action == PendingImageAction.retry) {
      await _retryAvatar(context, ref);
    } else if (action == PendingImageAction.remove) {
      ref.read(avatarControllerProvider.notifier).clearFailure();
    }
  }

  Future<void> _showCoverFailure(
    BuildContext context,
    WidgetRef ref,
    ProfileCoverState state,
  ) async {
    final delayed =
        state.uploadFailure?.failure.source == FailureSource.expected &&
        state.uploadFailure?.failure.reason == FailureReason.timeout;
    final action = await showPendingImageActions(
      context,
      title: delayed ? '图片准备较久' : '主页背景未完成',
      retryLabel: delayed ? '继续等待' : '重试',
      removeLabel: '放弃本次更换',
      detail: state.failure?.userMessage,
      canRetry: state.uploadFailure?.canRetry != false,
    );
    if (!context.mounted) return;
    if (action == PendingImageAction.retry) {
      await _retryCover(context, ref);
    } else if (action == PendingImageAction.remove) {
      ref.read(profileCoverControllerProvider.notifier).clearFailure();
    }
  }

  Future<void> _handleAvatarTap(BuildContext context, WidgetRef ref) async {
    if (profile.avatarUrl == null) return _chooseAvatar(context, ref);
    final action = await _showMediaActionSheet<_AvatarAction>(
      context: context,
      title: '头像',
      actions: const [
        _MediaSheetAction(
          value: _AvatarAction.change,
          key: Key('me-avatar-sheet-change'),
          icon: WenyouIconIds.contentGallery,
          label: '更换头像',
        ),
        _MediaSheetAction(
          value: _AvatarAction.remove,
          key: Key('me-avatar-remove'),
          icon: WenyouIconIds.actionDelete,
          label: '移除头像',
          destructive: true,
        ),
      ],
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case _AvatarAction.change:
        await _chooseAvatar(context, ref);
      case _AvatarAction.remove:
        await _confirmRemoveAvatar(context, ref);
    }
  }

  Future<void> _handleCoverTap(BuildContext context, WidgetRef ref) async {
    if (profile.profileCover == null) return _chooseCover(context, ref);
    final action = await _showMediaActionSheet<_CoverAction>(
      context: context,
      title: '主页背景',
      actions: const [
        _MediaSheetAction(
          value: _CoverAction.change,
          key: Key('me-profile-cover-sheet-change'),
          icon: WenyouIconIds.contentGallery,
          label: '更换主页背景',
        ),
        _MediaSheetAction(
          value: _CoverAction.remove,
          key: Key('me-profile-cover-remove'),
          icon: WenyouIconIds.actionDelete,
          label: '移除主页背景',
          destructive: true,
        ),
      ],
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case _CoverAction.change:
        await _chooseCover(context, ref);
      case _CoverAction.remove:
        await _confirmRemoveCover(context, ref);
    }
  }

  Future<void> _chooseAvatar(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final container = ProviderScope.containerOf(context, listen: false);
    final controller = ref.read(avatarControllerProvider.notifier);
    final processor = ref.read(imageCropProcessorPortProvider);
    final input = await controller.pickImage();
    if (!navigator.mounted || input == null) return;
    final cropped = await showAvatarCropDialog(
      navigator.context,
      input: input,
      processor: processor,
    );
    if (cropped == null) return;
    final result = await controller.setImage(cropped);
    if (result == null) return;
    _applyAvatarResult(container, result);
  }

  Future<void> _chooseCover(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final container = ProviderScope.containerOf(context, listen: false);
    final controller = ref.read(profileCoverControllerProvider.notifier);
    final processor = ref.read(imageCropProcessorPortProvider);
    final input = await controller.pickImage();
    if (!navigator.mounted || input == null) return;
    final selection = await showProfileCoverCropDialog(
      navigator.context,
      input: input,
      processor: processor,
    );
    if (selection == null) return;
    final result = await controller.setSelection(selection);
    if (result == null) return;
    _applyCoverResult(container, result);
  }

  Future<void> _confirmRemoveAvatar(BuildContext context, WidgetRef ref) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '移除头像？',
      message: '移除后将显示默认头像。',
      confirmLabel: '移除',
      confirmKey: const Key('me-avatar-remove-confirm'),
      tone: WenyouConfirmationTone.destructive,
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref.read(avatarControllerProvider.notifier).remove();
    if (!context.mounted || result == null) return;
    _applyAvatarResult(
      ProviderScope.containerOf(context, listen: false),
      result,
    );
  }

  Future<void> _confirmRemoveCover(BuildContext context, WidgetRef ref) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '移除主页背景？',
      message: '移除后主页将不再显示背景图。',
      confirmLabel: '移除',
      confirmKey: const Key('me-profile-cover-remove-confirm'),
      tone: WenyouConfirmationTone.destructive,
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref
        .read(profileCoverControllerProvider.notifier)
        .remove();
    if (!context.mounted || result == null) return;
    _applyCoverResult(
      ProviderScope.containerOf(context, listen: false),
      result,
    );
  }

  Future<void> _retryAvatar(BuildContext context, WidgetRef ref) async {
    final state = ref.read(avatarControllerProvider);
    final operation = state.failedOperation;
    if (operation == AvatarOperation.set &&
        state.pendingMediaId == null &&
        !state.hasPendingInput) {
      return _chooseAvatar(context, ref);
    }
    final result = await ref.read(avatarControllerProvider.notifier).retry();
    if (!context.mounted || result == null) return;
    _applyAvatarResult(
      ProviderScope.containerOf(context, listen: false),
      result,
    );
  }

  Future<void> _retryCover(BuildContext context, WidgetRef ref) async {
    final state = ref.read(profileCoverControllerProvider);
    final removing = state.failedOperation == ProfileCoverOperation.remove;
    if (!removing &&
        !state.hasPendingSelection &&
        (state.pendingWebMediaId == null ||
            state.pendingMobileMediaId == null)) {
      return _chooseCover(context, ref);
    }
    final result = await ref
        .read(profileCoverControllerProvider.notifier)
        .retry();
    if (!context.mounted || result == null) return;
    _applyCoverResult(
      ProviderScope.containerOf(context, listen: false),
      result,
    );
  }

  void _applyAvatarResult(
    ProviderContainer container,
    AvatarUpdateResult result,
  ) {
    final previousUrl = container
        .read(meProfileControllerProvider)
        .profile
        ?.avatarUrl;
    container
        .read(meProfileControllerProvider.notifier)
        .applyAvatarUpdate(result);
    if (previousUrl != null) {
      unawaited(WenyouCachedImage.evictFromCache(previousUrl));
    }
  }

  void _applyCoverResult(
    ProviderContainer container,
    ProfileCoverUpdateResult result,
  ) {
    final oldUrls =
        container
            .read(meProfileControllerProvider)
            .profile
            ?.profileCover
            ?.cachedUrls
            .toList() ??
        const <String>[];
    container
        .read(meProfileControllerProvider.notifier)
        .applyProfileCoverUpdate(result);
    for (final url in oldUrls) {
      unawaited(WenyouCachedImage.evictFromCache(url));
    }
  }
}

enum _AvatarAction { change, remove }

enum _CoverAction { change, remove }

class _CoverEditTarget extends StatelessWidget {
  const _CoverEditTarget({
    required this.profile,
    required this.previewBytes,
    required this.busy,
    required this.failed,
    required this.onFailureTap,
    required this.enabled,
    required this.onTap,
  });

  final MeProfileModel profile;
  final Uint8List? previewBytes;
  final bool busy;
  final bool failed;
  final VoidCallback onFailureTap;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final cover = profile.profileCover;
    final variant = cover?.preferredForMobile;
    final hasCover = previewBytes != null || variant != null;
    final fallback = ColoredBox(
      color: tokens.panel,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WenyouIcon(
                WenyouIconIds.actionAddImage,
                size: 28,
                color: tokens.brandForeground,
              ),
              SizedBox(height: tokens.space8),
              Text('添加主页背景', style: Theme.of(context).textTheme.wenyouRowTitle),
            ],
          ),
        ),
      ),
    );
    final image = previewBytes != null
        ? Image.memory(
            previewBytes!,
            key: const Key('me-profile-cover-local-preview'),
            fit: BoxFit.cover,
            cacheWidth: 1200,
            cacheHeight: 600,
            gaplessPlayback: true,
          )
        : variant == null
        ? fallback
        : WenyouCachedImage(
            imageUrl: variant.url,
            fit: BoxFit.cover,
            cacheWidth: 1200,
            cacheHeight: 600,
            placeholder: (_, _) => fallback,
            errorWidget: (_, _, _) => fallback,
          );
    final label = cover == null ? '添加主页背景' : '更换主页背景';
    return Semantics(
      button: true,
      enabled: enabled,
      label: failed
          ? '$label，图片未完成，点按选择操作'
          : busy
          ? '$label，图片准备中'
          : label,
      excludeSemantics: true,
      child: Material(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusCompact),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('me-profile-cover-change'),
          onTap: enabled ? (failed ? onFailureTap : onTap) : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PendingImageOverlay(
                active: busy,
                failed: failed,
                onFailureTap: onFailureTap,
                child: image,
              ),
              if (hasCover)
                Positioned(
                  top: tokens.space8,
                  right: tokens.space8,
                  child: const _MediaEditBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarEditTarget extends StatelessWidget {
  const _AvatarEditTarget({
    required this.profile,
    required this.previewBytes,
    required this.busy,
    required this.failed,
    required this.onFailureTap,
    required this.enabled,
    required this.onTap,
  });

  final MeProfileModel profile;
  final Uint8List? previewBytes;
  final bool busy;
  final bool failed;
  final VoidCallback onFailureTap;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final preview = previewBytes;
    final avatar = preview == null
        ? WenyouAvatar(
            username: profile.username,
            avatarUrl: profile.avatarUrl,
            size: 66,
          )
        : Semantics(
            image: true,
            label: '新头像预览',
            child: ClipOval(
              child: Image.memory(
                preview,
                key: const Key('me-avatar-local-preview'),
                width: 66,
                height: 66,
                fit: BoxFit.cover,
                cacheWidth: 198,
                cacheHeight: 198,
                gaplessPlayback: true,
              ),
            ),
          );
    final label = profile.avatarUrl == null ? '添加头像' : '更换头像';
    return Semantics(
      button: true,
      enabled: enabled,
      label: failed
          ? '$label，图片未完成，点按选择操作'
          : busy
          ? '$label，图片准备中'
          : label,
      excludeSemantics: true,
      child: Material(
        key: const Key('me-avatar-change'),
        color: tokens.panel,
        shape: CircleBorder(side: BorderSide(color: tokens.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? (failed ? onFailureTap : onTap) : null,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 72,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: ClipOval(
                    child: PendingImageOverlay(
                      active: busy,
                      failed: failed,
                      onFailureTap: onFailureTap,
                      child: avatar,
                    ),
                  ),
                ),
                const Positioned(right: 0, bottom: 0, child: _MediaEditBadge()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaEditBadge extends StatelessWidget {
  const _MediaEditBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.panel,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.border),
      ),
      child: const SizedBox.square(
        dimension: 28,
        child: Center(child: WenyouIcon(WenyouIconIds.actionEdit, size: 16)),
      ),
    );
  }
}

class _AvatarTaskFeedback extends StatelessWidget {
  const _AvatarTaskFeedback({
    required this.state,
    required this.onCancel,
    required this.onRetry,
  });

  final AvatarState state;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.failure case final failure?) {
      return _MediaFailureNotice(
        key: const Key('me-avatar-failure'),
        failure: failure,
        uploadFailure: state.uploadFailure,
        message: _avatarFailureMessage(state, failure),
        retryKey: const Key('me-avatar-retry'),
        retryLabel: _avatarRetryLabel(state),
        onRetry: onRetry,
      );
    }
    final fraction = state.progress?.fraction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WenyouStatusBanner(
          key: const Key('me-avatar-progress'),
          tone: WenyouStatusTone.accent,
          message: _avatarProgressMessage(state),
          action: state.phase == AvatarPhase.uploading
              ? TextButton(
                  key: const Key('me-avatar-cancel-upload'),
                  onPressed: onCancel,
                  child: const Text('取消上传'),
                )
              : null,
        ),
        if (fraction != null) ...[
          SizedBox(height: context.wenyouTokens.space8),
          Semantics(
            label: '头像更新进度 ${(fraction * 100).round()}%',
            child: LinearProgressIndicator(value: fraction),
          ),
        ],
      ],
    );
  }
}

class _CoverTaskFeedback extends StatelessWidget {
  const _CoverTaskFeedback({
    required this.state,
    required this.onCancel,
    required this.onRetry,
  });

  final ProfileCoverState state;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.failure case final failure?) {
      return _MediaFailureNotice(
        key: const Key('me-profile-cover-failure'),
        failure: failure,
        uploadFailure: state.uploadFailure,
        message: _coverFailureMessage(state, failure),
        retryKey: const Key('me-profile-cover-retry'),
        retryLabel: _coverRetryLabel(state),
        onRetry: onRetry,
      );
    }
    final fraction = state.progress?.fraction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WenyouStatusBanner(
          key: const Key('me-profile-cover-progress'),
          tone: WenyouStatusTone.accent,
          message: _coverProgressMessage(state),
          action:
              state.phase == ProfileCoverPhase.uploadingWeb ||
                  state.phase == ProfileCoverPhase.uploadingMobile
              ? TextButton(
                  key: const Key('me-profile-cover-cancel-upload'),
                  onPressed: onCancel,
                  child: const Text('取消上传'),
                )
              : null,
        ),
        if (fraction != null) ...[
          SizedBox(height: context.wenyouTokens.space8),
          Semantics(
            label: '主页背景更新进度 ${(fraction * 100).round()}%',
            child: LinearProgressIndicator(value: fraction),
          ),
        ],
      ],
    );
  }
}

class _MediaFailureNotice extends StatefulWidget {
  const _MediaFailureNotice({
    required this.failure,
    this.uploadFailure,
    required this.message,
    required this.retryKey,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final ApiFailure failure;
  final MediaUploadFailure? uploadFailure;
  final String message;
  final Key retryKey;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  State<_MediaFailureNotice> createState() => _MediaFailureNoticeState();
}

class _MediaFailureNoticeState extends State<_MediaFailureNotice> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: .8,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: widget.uploadFailure?.presentation.message ?? widget.message,
      detail:
          widget.uploadFailure?.presentation.problemDetail ??
          wenyouFailureDetail(widget.failure, treatAsWrite: true),
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.uploadFailure case final upload?)
            CopyDiagnosticButton(diagnosticId: upload.diagnosticId),
          if (widget.uploadFailure?.canRetry ?? true)
            TextButton(
              key: widget.retryKey,
              onPressed: widget.onRetry,
              child: Text(widget.retryLabel),
            ),
        ],
      ),
    );
  }
}

class _MediaSheetAction<T> {
  const _MediaSheetAction({
    required this.value,
    required this.key,
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final T value;
  final Key key;
  final String icon;
  final String label;
  final bool destructive;
}

Future<T?> _showMediaActionSheet<T>({
  required BuildContext context,
  required String title,
  required List<_MediaSheetAction<T>> actions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final tokens = sheetContext.wenyouTokens;
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: tokens.space16),
        children: [
          Padding(
            padding: EdgeInsets.only(left: tokens.space16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.wenyouOverlayTitle,
                  ),
                ),
                IconButton(
                  tooltip: '关闭',
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const WenyouIcon(WenyouIconIds.actionClose),
                ),
              ],
            ),
          ),
          for (var index = 0; index < actions.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            Builder(
              builder: (context) {
                final action = actions[index];
                final color = action.destructive
                    ? Theme.of(sheetContext).colorScheme.error
                    : null;
                return ListTile(
                  key: action.key,
                  leading: WenyouIcon(action.icon, color: color),
                  title: Text(
                    action.label,
                    style: Theme.of(
                      sheetContext,
                    ).textTheme.wenyouRowTitle.copyWith(color: color),
                  ),
                  onTap: () => Navigator.pop(sheetContext, action.value),
                );
              },
            ),
          ],
        ],
      );
    },
  );
}

String _avatarProgressMessage(AvatarState state) {
  if (state.phase == AvatarPhase.removing) return '正在移除头像…';
  final fraction = state.progress?.fraction;
  return fraction == null ? '正在更新头像…' : '正在更新头像 ${(fraction * 100).round()}%';
}

String _coverProgressMessage(ProfileCoverState state) {
  if (state.phase == ProfileCoverPhase.removing) return '正在移除主页背景…';
  final fraction = state.progress?.fraction;
  return fraction == null
      ? '正在更新主页背景…'
      : '正在更新主页背景 ${(fraction * 100).round()}%';
}

String _avatarFailureMessage(AvatarState state, ApiFailure failure) {
  if (state.failedOperation == AvatarOperation.remove) {
    return '头像移除失败，请重试。';
  }
  final message = failure.userMessage;
  return message.startsWith('头像没有') ? '头像更新失败，请重试。' : message;
}

String _coverFailureMessage(ProfileCoverState state, ApiFailure failure) {
  if (state.failedOperation == ProfileCoverOperation.remove) {
    return '主页背景移除失败，请重试。';
  }
  final message = failure.userMessage;
  return message.startsWith('背景图没有') ? '主页背景更新失败，请重试。' : message;
}

String _avatarRetryLabel(AvatarState state) {
  if (state.failedOperation == AvatarOperation.remove) return '重试移除';
  if (state.pendingMediaId != null) return '重试设置';
  return state.hasPendingInput ? '重试上传' : '重新选择';
}

String _coverRetryLabel(ProfileCoverState state) {
  if (state.failedOperation == ProfileCoverOperation.remove) return '重试移除';
  if (state.pendingWebMediaId != null && state.pendingMobileMediaId != null) {
    return '重试设置';
  }
  return state.hasPendingSelection ? '重试上传' : '重新选择';
}
