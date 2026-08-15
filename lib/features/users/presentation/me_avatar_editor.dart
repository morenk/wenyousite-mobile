part of 'me_page.dart';

class _AvatarEditor extends ConsumerWidget {
  const _AvatarEditor({
    required this.profile,
    required this.profileWriteDisabled,
  });

  final MeProfileModel profile;
  final bool profileWriteDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(avatarControllerProvider);
    final disabled = profileWriteDisabled || state.isBusy;
    return Column(
      children: [
        _MeAvatar(profile: profile),
        SizedBox(height: tokens.space12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            OutlinedButton.icon(
              key: const Key('me-avatar-change'),
              onPressed: disabled ? null : () => _chooseAndSet(context, ref),
              icon: const WenyouIcon(WenyouIconIds.contentGallery),
              label: Text(profile.avatarUrl == null ? '选择头像' : '更换头像'),
            ),
            if (profile.avatarUrl != null)
              TextButton.icon(
                key: const Key('me-avatar-remove'),
                onPressed: disabled ? null : () => _confirmRemove(context, ref),
                icon: const WenyouIcon(WenyouIconIds.actionDelete),
                label: const Text('移除头像'),
              ),
          ],
        ),
        SizedBox(height: tokens.space4),
        Text(
          '支持 JPG、PNG、WebP，最大 10MB',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        if (state.isBusy) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            key: const Key('me-avatar-progress'),
            tone: WenyouStatusTone.accent,
            message: _progressMessage(state),
            action: state.phase == AvatarPhase.uploading
                ? TextButton(
                    key: const Key('me-avatar-cancel-upload'),
                    onPressed: ref
                        .read(avatarControllerProvider.notifier)
                        .cancelUpload,
                    child: const Text('取消上传'),
                  )
                : null,
          ),
          if (state.progress?.fraction case final fraction?) ...[
            SizedBox(height: tokens.space8),
            Semantics(
              label: '头像上传进度 ${(fraction * 100).round()}%',
              child: LinearProgressIndicator(value: fraction),
            ),
          ],
        ],
        if (state.failure != null) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            key: const Key('me-avatar-failure'),
            tone: WenyouStatusTone.error,
            message: state.failure!.userMessage,
            detail: state.failure!.requestId == null
                ? null
                : '请求 ID：${state.failure!.requestId}',
            action: state.failure!.businessCode == 40107
                ? TextButton(
                    key: const Key('me-avatar-verify-email'),
                    onPressed: () => _verifyAndRetry(context, ref),
                    child: const Text('先验证邮箱'),
                  )
                : TextButton(
                    key: const Key('me-avatar-retry'),
                    onPressed: () => _retry(context, ref),
                    child: Text(
                      state.pendingMediaId == null
                          ? state.failedOperation == AvatarOperation.remove
                                ? '重试移除'
                                : '重新选择'
                          : '重试设置',
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Future<void> _chooseAndSet(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(avatarControllerProvider.notifier)
        .chooseAndSet();
    if (!context.mounted || result == null) return;
    _applyResult(context, ref, result, '头像已更新。');
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除当前头像？'),
        content: const Text('移除后将使用默认头像占位，之后仍可重新上传。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('me-avatar-remove-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref.read(avatarControllerProvider.notifier).remove();
    if (!context.mounted || result == null) return;
    _applyResult(context, ref, result, '头像已移除。');
  }

  Future<void> _retry(BuildContext context, WidgetRef ref) async {
    final operation = ref.read(avatarControllerProvider).failedOperation;
    final result = await ref.read(avatarControllerProvider.notifier).retry();
    if (!context.mounted || result == null) return;
    _applyResult(
      context,
      ref,
      result,
      operation == AvatarOperation.remove ? '头像已移除。' : '头像已更新。',
    );
  }

  Future<void> _verifyAndRetry(BuildContext context, WidgetRef ref) async {
    final verified = await context.push<bool>(
      Uri(
        path: '/me/security/verify-email',
        queryParameters: const {'returnTo': '/me'},
      ).toString(),
    );
    if (verified == true && context.mounted) {
      await _retry(context, ref);
    }
  }

  void _applyResult(
    BuildContext context,
    WidgetRef ref,
    AvatarUpdateResult result,
    String message,
  ) {
    final previousUrl = profile.avatarUrl;
    ref.read(meProfileControllerProvider.notifier).applyAvatarUpdate(result);
    if (previousUrl != null) {
      unawaited(WenyouCachedImage.evictFromCache(previousUrl));
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _progressMessage(AvatarState state) {
    return switch (state.phase) {
      AvatarPhase.picking => '正在打开系统相册…',
      AvatarPhase.setting => '图片已上传，正在设置头像…',
      AvatarPhase.removing => '正在移除头像…',
      AvatarPhase.uploading => switch (state.progress?.stage) {
        MediaUploadStage.preparing => '正在准备头像上传…',
        MediaUploadStage.uploading =>
          state.progress?.fraction == null
              ? '正在上传头像…'
              : '正在上传头像 ${(state.progress!.fraction! * 100).round()}%',
        MediaUploadStage.confirming => '正在确认头像上传…',
        MediaUploadStage.processing => '头像正在安全处理中…',
        null => '正在上传头像…',
      },
      AvatarPhase.idle || AvatarPhase.failed => '',
    };
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
      child: WenyouIcon(
        WenyouIconIds.identityMember,
        size: 42,
        color: tokens.mutedText,
      ),
    );
    return Semantics(
      image: true,
      label: '${profile.username} 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: 84,
          child: profile.avatarUrl == null
              ? fallback
              : WenyouCachedImage(
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
