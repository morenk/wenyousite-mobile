import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/profile_cover_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

class MeProfileCoverEditor extends ConsumerWidget {
  const MeProfileCoverEditor({
    required this.profile,
    required this.profileWriteDisabled,
    super.key,
  });

  final MeProfileModel profile;
  final bool profileWriteDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(profileCoverControllerProvider);
    final disabled = profileWriteDisabled || state.isBusy;
    final cover = profile.profileCover;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileCoverPreview(cover: cover),
        SizedBox(height: tokens.space12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            OutlinedButton.icon(
              key: const Key('me-profile-cover-change'),
              onPressed: disabled ? null : () => _chooseAndSet(context, ref),
              icon: const WenyouIcon(WenyouIconIds.contentGallery),
              label: Text(cover == null ? '选择背景图' : '更换背景图'),
            ),
            if (cover != null)
              TextButton.icon(
                key: const Key('me-profile-cover-remove'),
                onPressed: disabled ? null : () => _confirmRemove(context, ref),
                icon: const WenyouIcon(WenyouIconIds.actionDelete),
                label: const Text('移除背景图'),
              ),
          ],
        ),
        SizedBox(height: tokens.space4),
        Text(
          '支持 JPG、PNG、WebP，最大 10MB；上传前可分别调整电脑端 3:1 与移动端 2:1 取景。',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        if (state.isBusy) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            key: const Key('me-profile-cover-progress'),
            tone: WenyouStatusTone.accent,
            message: _progressMessage(state),
            action:
                state.phase == ProfileCoverPhase.uploadingWeb ||
                    state.phase == ProfileCoverPhase.uploadingMobile
                ? TextButton(
                    key: const Key('me-profile-cover-cancel-upload'),
                    onPressed: ref
                        .read(profileCoverControllerProvider.notifier)
                        .cancelUpload,
                    child: const Text('取消上传'),
                  )
                : null,
          ),
          if (state.progress?.fraction case final fraction?) ...[
            SizedBox(height: tokens.space8),
            Semantics(
              label: '背景图上传进度 ${(fraction * 100).round()}%',
              child: LinearProgressIndicator(value: fraction),
            ),
          ],
        ],
        if (state.failure != null) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            key: const Key('me-profile-cover-failure'),
            tone: WenyouStatusTone.error,
            message: state.failure!.userMessage,
            detail: state.failure!.requestId == null
                ? null
                : '请求 ID：${state.failure!.requestId}',
            action: TextButton(
              key: const Key('me-profile-cover-retry'),
              onPressed: () => _retry(context, ref),
              child: Text(
                state.failedOperation == ProfileCoverOperation.remove
                    ? '重试移除'
                    : state.pendingWebMediaId != null &&
                          state.pendingMobileMediaId != null
                    ? '重试设置'
                    : '重试上传',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _chooseAndSet(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(profileCoverControllerProvider.notifier);
    final input = await controller.pickImage();
    if (!context.mounted || input == null) return;
    final selection = await showProfileCoverCropDialog(
      context,
      input: input,
      processor: ref.read(imageCropProcessorPortProvider),
    );
    if (!context.mounted || selection == null) return;
    final result = await controller.setSelection(selection);
    if (!context.mounted || result == null) return;
    _applyResult(context, ref, result, '主页背景已更新。');
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除当前主页背景？'),
        content: const Text('电脑端与移动端背景会同时移除，之后仍可重新上传。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('me-profile-cover-remove-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref
        .read(profileCoverControllerProvider.notifier)
        .remove();
    if (!context.mounted || result == null) return;
    _applyResult(context, ref, result, '主页背景已移除。');
  }

  Future<void> _retry(BuildContext context, WidgetRef ref) async {
    final state = ref.read(profileCoverControllerProvider);
    final removing = state.failedOperation == ProfileCoverOperation.remove;
    if (!removing &&
        !state.hasPendingSelection &&
        (state.pendingWebMediaId == null ||
            state.pendingMobileMediaId == null)) {
      return _chooseAndSet(context, ref);
    }
    final result = await ref
        .read(profileCoverControllerProvider.notifier)
        .retry();
    if (!context.mounted || result == null) return;
    _applyResult(context, ref, result, removing ? '主页背景已移除。' : '主页背景已更新。');
  }

  void _applyResult(
    BuildContext context,
    WidgetRef ref,
    ProfileCoverUpdateResult result,
    String message,
  ) {
    final oldUrls =
        profile.profileCover?.cachedUrls.toList() ?? const <String>[];
    ref
        .read(meProfileControllerProvider.notifier)
        .applyProfileCoverUpdate(result);
    for (final url in oldUrls) {
      unawaited(WenyouCachedImage.evictFromCache(url));
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _progressMessage(ProfileCoverState state) {
    return switch (state.phase) {
      ProfileCoverPhase.picking => '正在打开系统相册…',
      ProfileCoverPhase.uploadingWeb => _uploadMessage(
        '正在上传电脑端背景',
        state.progress,
      ),
      ProfileCoverPhase.uploadingMobile => _uploadMessage(
        '正在上传移动端背景',
        state.progress,
      ),
      ProfileCoverPhase.setting => '双画幅已上传，正在原子更新主页背景…',
      ProfileCoverPhase.removing => '正在移除电脑端与移动端背景…',
      ProfileCoverPhase.idle || ProfileCoverPhase.failed => '',
    };
  }

  String _uploadMessage(String fallback, MediaUploadProgress? progress) {
    return switch (progress?.stage) {
      MediaUploadStage.preparing => '$fallback：准备中…',
      MediaUploadStage.uploading =>
        progress?.fraction == null
            ? '$fallback…'
            : '$fallback ${(progress!.fraction! * 100).round()}%',
      MediaUploadStage.confirming => '$fallback：确认中…',
      MediaUploadStage.processing => '$fallback：安全处理中…',
      null => '$fallback…',
    };
  }
}

class _ProfileCoverPreview extends StatelessWidget {
  const _ProfileCoverPreview({required this.cover});

  final ProfileCoverModel? cover;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final variant = cover?.preferredForMobile;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Center(
        child: WenyouIcon(
          WenyouIconIds.contentGallery,
          size: 32,
          color: tokens.mutedText,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: AspectRatio(
        aspectRatio: 2,
        child: variant == null
            ? fallback
            : WenyouCachedImage(
                imageUrl: variant.url,
                fit: BoxFit.cover,
                cacheWidth: 1200,
                cacheHeight: 600,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
