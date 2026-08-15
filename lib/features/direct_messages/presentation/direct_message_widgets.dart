import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

class DirectMessageAvatar extends StatelessWidget {
  const DirectMessageAvatar({required this.user, this.size = 44, super.key});

  final DirectMessageUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: WenyouIcon(
        user.isDeactivated
            ? WenyouIconIds.statusUserUnavailable
            : WenyouIconIds.identityMember,
        color: tokens.mutedText,
        size: size * 0.5,
      ),
    );
    return Semantics(
      image: true,
      label: '${user.username} 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: user.avatarUrl == null
              ? fallback
              : WenyouCachedImage(
                  imageUrl: user.avatarUrl!,
                  fit: BoxFit.cover,
                  cacheWidth: size.ceil(),
                  cacheHeight: size.ceil(),
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class DirectMessageComposer extends ConsumerStatefulWidget {
  const DirectMessageComposer({
    required this.onSend,
    this.disabled = false,
    this.submitLabel = '发送',
    this.placeholder = '输入消息…',
    this.requestHint,
    this.failure,
    this.failedDraft,
    this.onAbandonFailedDraft,
    this.optimistic = false,
    super.key,
  });

  final Future<bool> Function({
    String? content,
    String? mediaId,
    String? stickerAssetId,
  })
  onSend;
  final bool disabled;
  final String submitLabel;
  final String placeholder;
  final String? requestHint;
  final ApiFailure? failure;
  final DirectMessageDraft? failedDraft;
  final VoidCallback? onAbandonFailedDraft;
  final bool optimistic;

  @override
  ConsumerState<DirectMessageComposer> createState() =>
      _DirectMessageComposerState();
}

class _DirectMessageComposerState extends ConsumerState<DirectMessageComposer> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final Object _uploadTaskId = Object();
  UploadedEditorImage? _uploadedImage;
  ApiFailure? _localFailure;
  var _busy = false;

  bool get _disabled => widget.disabled || _busy;
  bool get _hasPayload =>
      normalizeDirectMessageContent(_controller.text).isNotEmpty ||
      _uploadedImage != null;
  bool get _showCharacterCount =>
      _controller.text.length >= (directMessageMaxLength * 0.9).floor();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.failedDraft?.content ?? '',
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    final failure = _localFailure ?? widget.failure;
    final uploadLocked = uploadState.isBusy || uploadState.failure != null;
    final supporting = <Widget>[
      if (widget.requestHint != null) ...[
        _ComposerStatusLine(
          icon: WenyouIconIds.statusInfo,
          message: widget.requestHint!,
        ),
        SizedBox(height: tokens.space8),
      ],
      if (_uploadedImage != null) ...[
        _ImagePreview(
          image: _uploadedImage!,
          onRemove: _disabled ? null : _removeImage,
        ),
        SizedBox(height: tokens.space8),
      ],
      if (uploadState.isBusy) ...[
        _UploadProgress(
          state: uploadState,
          onCancel: () => ref
              .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
              .cancel(),
        ),
        SizedBox(height: tokens.space8),
      ],
      if (uploadState.failure case final uploadFailure?) ...[
        _ComposerStatusLine(
          key: const Key('direct-message-composer-upload-failure'),
          icon: WenyouIconIds.statusError,
          message: uploadFailure.requestId == null
              ? uploadFailure.userMessage
              : '${uploadFailure.userMessage} · 请求 ID：${uploadFailure.requestId}',
          error: true,
          onRetry: uploadFailure.canRetry ? _retryImageUpload : null,
          onDismiss: _abandonImageUpload,
          retryKey: const Key('direct-message-composer-retry-upload'),
          dismissKey: const Key('direct-message-composer-abandon-upload'),
        ),
        SizedBox(height: tokens.space8),
      ],
      if (failure != null) ...[
        _ComposerStatusLine(
          key: const Key('direct-message-composer-failure'),
          icon: WenyouIconIds.statusError,
          message: failure.userMessage,
          error: true,
          onRetry: widget.failedDraft == null || _busy
              ? null
              : _retryFailedDraft,
          onDismiss: widget.failedDraft == null
              ? () => setState(() => _localFailure = null)
              : _abandonFailedDraft,
          retryKey: const Key('direct-message-composer-retry'),
          dismissKey: const Key('direct-message-composer-abandon'),
        ),
        SizedBox(height: tokens.space8),
      ],
    ];
    return WenyouInlineComposerDock(
      controller: _controller,
      focusNode: _focusNode,
      fieldKey: const Key('direct-message-composer-field'),
      dockKey: const Key('direct-message-composer-dock'),
      placeholder: widget.placeholder,
      maxLength: directMessageMaxLength,
      enabled: !widget.disabled,
      onChanged: (_) {
        if (_localFailure != null) _localFailure = null;
        setState(() {});
      },
      supporting: supporting,
      leadingActions: [
        IconButton(
          key: const Key('direct-message-composer-image'),
          onPressed: _disabled || _uploadedImage != null || uploadState.isBusy
              ? null
              : _pickImage,
          tooltip: '添加图片',
          icon: const WenyouIcon(WenyouIconIds.actionAddImage),
        ),
      ],
      trailingActions: [
        if (ref.watch(stickersEnabledProvider))
          IconButton(
            key: const Key('direct-message-composer-sticker'),
            onPressed: _disabled ? null : _pickSticker,
            tooltip: '表情',
            icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
          ),
      ],
      submitAction: IconButton.filled(
        key: const Key('direct-message-composer-submit'),
        onPressed: _disabled || uploadLocked || !_hasPayload ? null : _submit,
        tooltip: _submitLabel(uploadState),
        icon: _busy
            ? Semantics(
                liveRegion: true,
                label: '消息处理中',
                child: const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const WenyouIcon(WenyouIconIds.actionSend),
      ),
      characterCountText: _showCharacterCount
          ? '${directMessageMaxLength - _controller.text.length}'
          : null,
      characterCountKey: const Key('direct-message-composer-character-count'),
    );
  }

  String _submitLabel(MediaUploadTaskState uploadState) {
    final progress = uploadState.progress;
    if (uploadState.phase == MediaUploadTaskPhase.uploading &&
        progress?.fraction != null) {
      return '上传 ${(progress!.fraction! * 100).round()}%';
    }
    if (uploadState.isBusy) return '图片处理中';
    return _busy ? '处理中' : widget.submitLabel;
  }

  Future<void> _pickImage() async {
    await _runImageUpload(retry: false);
  }

  Future<void> _retryImageUpload() async {
    await _runImageUpload(retry: true);
  }

  Future<void> _runImageUpload({required bool retry}) async {
    final shouldRestoreFocus = _focusNode.hasFocus;
    final selection = _controller.selection;
    final controller = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    final image = retry
        ? await controller.retryUpload()
        : await controller.pickAndUpload();
    if (!mounted) return;
    if (image != null) {
      setState(() {
        _uploadedImage = image;
        _localFailure = null;
      });
    }
    if (shouldRestoreFocus) {
      _restoreFocus(selection);
    }
  }

  void _removeImage() {
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    setState(() {
      _uploadedImage = null;
      _localFailure = null;
    });
  }

  void _abandonImageUpload() {
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
  }

  Future<void> _submit() async {
    if (_busy || widget.disabled) return;
    final normalized = normalizeDirectMessageContent(_controller.text);
    final selection = _controller.selection;
    final shouldRestoreFocus = _focusNode.hasFocus;
    final validation = validateDirectMessagePayload(
      content: normalized,
      mediaId: _uploadedImage?.mediaId,
      stickerAssetId: null,
    );
    if (validation != null) {
      setState(() => _localFailure = ApiFailure(userMessage: validation));
      return;
    }
    if (widget.optimistic) {
      final mediaId = _uploadedImage?.mediaId;
      _controller.clear();
      setState(() {
        _uploadedImage = null;
        _localFailure = null;
      });
      ref
          .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
          .reset();
      _focusNode.requestFocus();
      unawaited(
        _dispatchOptimistic(
          content: normalized.isEmpty ? null : normalized,
          mediaId: mediaId,
          selection: selection,
          shouldRestoreFocus: shouldRestoreFocus,
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _localFailure = null;
    });
    try {
      final content = normalized.isEmpty ? null : normalized;
      final succeeded = await widget.onSend(
        content: content,
        mediaId: _uploadedImage?.mediaId,
      );
      if (!mounted) return;
      if (succeeded) {
        _controller.clear();
        _uploadedImage = null;
        ref
            .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
            .reset();
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _localFailure = _asFailure(error, '消息发送失败，请重试。'));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _dispatchOptimistic({
    required String? content,
    required String? mediaId,
    required TextSelection selection,
    required bool shouldRestoreFocus,
  }) async {
    try {
      await widget.onSend(content: content, mediaId: mediaId);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _localFailure = _asFailure(error, '消息发送失败，请重试。');
        _restoreOptimisticText(content, selection);
      });
      if (shouldRestoreFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _restoreFocus(_restoredSelection(selection, content));
        });
      }
    }
  }

  void _restoreOptimisticText(String? content, TextSelection selection) {
    final failedText = content ?? '';
    if (failedText.isEmpty) return;
    final currentText = _controller.text;
    if (currentText.isEmpty) {
      _controller.text = failedText;
      _controller.selection = _restoredSelection(selection, content);
      return;
    }
    if (currentText != failedText) {
      _controller.text = '$failedText\n$currentText';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  TextSelection _restoredSelection(
    TextSelection selection,
    String? restoredContent,
  ) {
    final length = restoredContent?.length ?? 0;
    return TextSelection(
      baseOffset: selection.baseOffset.clamp(0, length),
      extentOffset: selection.extentOffset.clamp(0, length),
      affinity: selection.affinity,
      isDirectional: selection.isDirectional,
    );
  }

  Future<void> _pickSticker() async {
    final shouldRestoreFocus = _focusNode.hasFocus;
    final selection = _controller.selection;
    final sticker = await showStickerPicker(context);
    if (!mounted) return;
    if (sticker == null) {
      if (shouldRestoreFocus) _restoreFocus(selection);
      return;
    }
    if (widget.optimistic) {
      unawaited(
        widget
            .onSend(stickerAssetId: sticker.asset.id)
            .then((succeeded) async {
              if (succeeded) {
                await ref
                    .read(stickerCollectionControllerProvider.notifier)
                    .load();
              }
            })
            .catchError((_) {}),
      );
      if (shouldRestoreFocus) _restoreFocus(selection);
      return;
    }
    setState(() {
      _busy = true;
      _localFailure = null;
    });
    try {
      final succeeded = await widget.onSend(stickerAssetId: sticker.asset.id);
      if (succeeded) {
        await ref.read(stickerCollectionControllerProvider.notifier).load();
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _localFailure = _asFailure(error, '表情发送失败，请重试。'));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        if (shouldRestoreFocus) _restoreFocus(selection);
      }
    }
  }

  Future<void> _retryFailedDraft() async {
    final draft = widget.failedDraft;
    if (_busy || widget.disabled || draft == null) return;
    setState(() {
      _busy = true;
      _localFailure = null;
    });
    try {
      await widget.onSend(
        content: draft.content,
        mediaId: draft.mediaId,
        stickerAssetId: draft.stickerAssetId,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _restoreFocus(TextSelection selection) {
    final offset = selection.end.clamp(0, _controller.text.length);
    _controller.selection = TextSelection.collapsed(offset: offset);
    _focusNode.requestFocus();
  }

  void _abandonFailedDraft() {
    widget.onAbandonFailedDraft?.call();
    setState(() {
      _localFailure = null;
    });
  }
}

class _ComposerStatusLine extends StatelessWidget {
  const _ComposerStatusLine({
    required this.icon,
    required this.message,
    this.error = false,
    this.onRetry,
    this.onDismiss,
    this.retryKey,
    this.dismissKey,
    super.key,
  });

  final String icon;
  final String message;
  final bool error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Key? retryKey;
  final Key? dismissKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = error
        ? Theme.of(context).colorScheme.error
        : tokens.mutedText;
    return Row(
      children: [
        WenyouIcon(icon, size: 16, color: color),
        SizedBox(width: tokens.space4),
        Expanded(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
        if (onRetry != null)
          IconButton(
            key: retryKey,
            onPressed: onRetry,
            tooltip: '重试',
            visualDensity: VisualDensity.compact,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
          ),
        if (onDismiss != null)
          IconButton(
            key: dismissKey,
            onPressed: onDismiss,
            tooltip: '关闭',
            visualDensity: VisualDensity.compact,
            icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
          ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, this.onRemove});

  final UploadedEditorImage image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      key: const Key('direct-message-composer-attachment'),
      decoration: BoxDecoration(
        color: tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radius12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: WenyouCachedImage(
              imageUrl: image.url,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: tokens.space8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              '[图片]',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            key: const Key('direct-message-composer-remove-image'),
            onPressed: onRemove,
            tooltip: '移除图片',
            icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
          ),
        ],
      ),
    );
  }
}

class _UploadProgress extends StatelessWidget {
  const _UploadProgress({required this.state, required this.onCancel});

  final MediaUploadTaskState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      children: [
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: state.progress?.fraction,
          ),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          child: Text(
            switch (state.phase) {
              MediaUploadTaskPhase.picking => '正在打开相册…',
              MediaUploadTaskPhase.preparing => '正在准备图片…',
              MediaUploadTaskPhase.uploading
                  when state.progress?.fraction != null =>
                '正在上传 ${(state.progress!.fraction! * 100).round()}%',
              MediaUploadTaskPhase.uploading => '正在上传图片…',
              MediaUploadTaskPhase.confirming => '正在确认图片…',
              MediaUploadTaskPhase.processing => '正在处理图片…',
              MediaUploadTaskPhase.idle || MediaUploadTaskPhase.failed => '',
            },
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          key: const Key('direct-message-composer-cancel-upload'),
          onPressed: onCancel,
          tooltip: '取消上传',
          visualDensity: VisualDensity.compact,
          icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
        ),
      ],
    );
  }
}

class DirectMessageBubble extends ConsumerStatefulWidget {
  const DirectMessageBubble({
    required this.message,
    required this.mine,
    required this.canRecall,
    required this.onRecall,
    this.hideIncomingRequestImage = false,
    this.isRecalling = false,
    this.isGroupEnd = true,
    this.failure,
    this.onRetry,
    this.onAbandon,
    this.onVerifyEmail,
    super.key,
  });

  final DirectMessage message;
  final bool mine;
  final bool hideIncomingRequestImage;
  final bool canRecall;
  final bool isRecalling;
  final bool isGroupEnd;
  final ApiFailure? failure;
  final VoidCallback onRecall;
  final VoidCallback? onRetry;
  final VoidCallback? onAbandon;
  final VoidCallback? onVerifyEmail;

  @override
  ConsumerState<DirectMessageBubble> createState() =>
      _DirectMessageBubbleState();
}

class _DirectMessageBubbleState extends ConsumerState<DirectMessageBubble> {
  late bool _imageRevealed;

  @override
  void initState() {
    super.initState();
    _imageRevealed = !widget.hideIncomingRequestImage;
  }

  @override
  void didUpdateWidget(covariant DirectMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hideIncomingRequestImage &&
        !widget.hideIncomingRequestImage) {
      _imageRevealed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final media = widget.message.media;
    final stickersEnabled = ref.watch(stickersEnabledProvider);
    final stickerBusy = media == null || !stickersEnabled
        ? false
        : ref.watch(
            stickerCollectionControllerProvider.select((state) => state.isBusy),
          );
    final pureSticker =
        media?.isSticker == true && widget.message.content == null;
    final sending =
        widget.message.deliveryState == DirectMessageDeliveryState.sending;
    final failed =
        widget.message.deliveryState == DirectMessageDeliveryState.failed;
    final canSaveSticker = stickersEnabled && media != null && _imageRevealed;
    final actions = <CustomSemanticsAction, VoidCallback>{
      if (!widget.message.isRecalled && widget.message.content != null)
        const CustomSemanticsAction(label: '复制消息'): _copyMessage,
      if (!widget.message.isRecalled && canSaveSticker && !stickerBusy)
        const CustomSemanticsAction(label: '收藏表情'): _saveSticker,
      if (!widget.message.isRecalled && widget.canRecall && !widget.isRecalling)
        const CustomSemanticsAction(label: '撤回消息'): widget.onRecall,
      if (failed && widget.onRetry != null)
        const CustomSemanticsAction(label: '重试发送'): widget.onRetry!,
      if (failed && widget.onAbandon != null)
        const CustomSemanticsAction(label: '删除失败消息'): widget.onAbandon!,
      if (failed &&
          widget.failure?.businessCode == 40107 &&
          widget.onVerifyEmail != null)
        const CustomSemanticsAction(label: '验证邮箱'): widget.onVerifyEmail!,
    };
    final maxWidth = MediaQuery.sizeOf(context).width >= 600
        ? 420.0
        : widget.mine && (sending || failed)
        ? MediaQuery.sizeOf(context).width * 0.68
        : MediaQuery.sizeOf(context).width * 0.8;
    return Semantics(
      onLongPress: actions.isEmpty ? null : _showActions,
      onLongPressHint: actions.isEmpty ? null : '打开消息操作',
      customSemanticsActions: actions,
      child: Align(
        alignment: widget.mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.mine && (sending || failed)) ...[
              if (sending)
                Semantics(
                  label: '消息发送中',
                  liveRegion: true,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 6, bottom: 8),
                    child: SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                )
              else
                IconButton(
                  key: ValueKey(
                    'direct-message-delivery-failed-${widget.message.id}',
                  ),
                  onPressed: _showActions,
                  tooltip: widget.failure?.userMessage ?? '发送失败，点按处理',
                  visualDensity: VisualDensity.compact,
                  icon: WenyouIcon(
                    WenyouIconIds.statusError,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                ),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: GestureDetector(
                key: ValueKey('direct-message-actions-${widget.message.id}'),
                behavior: HitTestBehavior.opaque,
                onLongPress: actions.isEmpty ? null : _showActions,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pureSticker
                        ? Colors.transparent
                        : widget.mine
                        ? tokens.brand
                        : tokens.softPanel,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(tokens.radius16),
                      topRight: Radius.circular(tokens.radius16),
                      bottomLeft: Radius.circular(
                        !widget.isGroupEnd || widget.mine
                            ? tokens.radius16
                            : tokens.space4,
                      ),
                      bottomRight: Radius.circular(
                        !widget.isGroupEnd || !widget.mine
                            ? tokens.radius16
                            : tokens.space4,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: pureSticker
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(
                            horizontal: tokens.space12,
                            vertical: tokens.space8,
                          ),
                    child: widget.message.isRecalled
                        ? Text(
                            widget.mine ? '你撤回了一条消息' : '对方撤回了一条消息',
                            style: TextStyle(
                              color: widget.mine
                                  ? tokens.onBrand.withValues(alpha: 0.82)
                                  : tokens.mutedText,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.message.content != null)
                                Text(
                                  widget.message.content!,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: widget.mine
                                            ? tokens.onBrand
                                            : tokens.text,
                                      ),
                                ),
                              if (media != null) ...[
                                if (widget.message.content != null)
                                  SizedBox(height: tokens.space8),
                                if (!_imageRevealed)
                                  OutlinedButton.icon(
                                    key: ValueKey(
                                      'direct-message-reveal-${widget.message.id}',
                                    ),
                                    onPressed: () =>
                                        setState(() => _imageRevealed = true),
                                    icon: const WenyouIcon(
                                      WenyouIconIds.actionImage,
                                    ),
                                    label: const Text('点击查看陌生人图片'),
                                  )
                                else
                                  _MessageImage(media: media),
                              ],
                              if (media == null &&
                                  widget.message.content == null &&
                                  widget.message.localDraft != null)
                                _OptimisticMediaPlaceholder(
                                  isSticker:
                                      widget
                                          .message
                                          .localDraft!
                                          .stickerAssetId !=
                                      null,
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showActions() async {
    final media = widget.message.media;
    final stickersEnabled = ref.read(stickersEnabledProvider);
    final canSaveSticker = stickersEnabled && media != null && _imageRevealed;
    final stickerBusy = canSaveSticker
        ? ref.read(stickerCollectionControllerProvider).isBusy
        : false;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: context.wenyouTokens.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message.content != null)
              ListTile(
                key: ValueKey('direct-message-copy-${widget.message.id}'),
                leading: const WenyouIcon(WenyouIconIds.actionCopy),
                title: const Text('复制'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _copyMessage();
                },
              ),
            if (canSaveSticker)
              ListTile(
                key: ValueKey(
                  'direct-message-save-sticker-${widget.message.id}',
                ),
                leading: const WenyouIcon(WenyouIconIds.actionAddReaction),
                title: Text(stickerBusy ? '处理中…' : '收藏表情'),
                onTap: stickerBusy
                    ? null
                    : () {
                        Navigator.pop(sheetContext);
                        _saveSticker();
                      },
              ),
            if (widget.canRecall)
              ListTile(
                key: ValueKey('direct-message-recall-${widget.message.id}'),
                leading: const WenyouIcon(WenyouIconIds.actionUndo),
                title: Text(widget.isRecalling ? '撤回中…' : '撤回'),
                onTap: widget.isRecalling
                    ? null
                    : () {
                        Navigator.pop(sheetContext);
                        widget.onRecall();
                      },
              ),
            if (widget.message.deliveryState ==
                    DirectMessageDeliveryState.failed &&
                widget.failure?.businessCode == 40107 &&
                widget.onVerifyEmail != null)
              ListTile(
                key: ValueKey(
                  'direct-message-verify-email-${widget.message.id}',
                ),
                leading: const WenyouIcon(WenyouIconIds.actionMarkRead),
                title: const Text('验证邮箱'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  widget.onVerifyEmail!();
                },
              ),
            if (widget.message.deliveryState ==
                    DirectMessageDeliveryState.failed &&
                widget.onRetry != null)
              ListTile(
                key: ValueKey('direct-message-retry-${widget.message.id}'),
                leading: const WenyouIcon(WenyouIconIds.actionRefresh),
                title: const Text('重新发送'),
                subtitle: widget.failure == null
                    ? null
                    : Text(
                        widget.failure!.userMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  widget.onRetry!();
                },
              ),
            if (widget.message.deliveryState ==
                    DirectMessageDeliveryState.failed &&
                widget.onAbandon != null)
              ListTile(
                key: ValueKey('direct-message-abandon-${widget.message.id}'),
                leading: const WenyouIcon(WenyouIconIds.actionDelete),
                title: const Text('删除失败消息'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  widget.onAbandon!();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyMessage() async {
    final content = widget.message.content;
    if (content == null) return;
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制')));
  }

  Future<void> _saveSticker() async {
    final result = await ref
        .read(stickerCollectionControllerProvider.notifier)
        .importDirectMessage(widget.message.id);
    if (!mounted) return;
    final state = ref.read(stickerCollectionControllerProvider);
    final message = result == null
        ? state.transientFailure?.userMessage ?? '收藏表情失败，请稍后重试。'
        : switch (result.status) {
            StickerImportStatus.processing => '图片正在处理，完成后会出现在收藏中。',
            StickerImportStatus.completed when result.alreadySaved =>
              '已经收藏过这个表情。',
            StickerImportStatus.completed => '已添加到表情收藏。',
            StickerImportStatus.failed => '表情处理失败，请换一张图片。',
          };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OptimisticMediaPlaceholder extends StatelessWidget {
  const _OptimisticMediaPlaceholder({required this.isSticker});

  final bool isSticker;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox.square(
      dimension: 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.onBrand.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: WenyouIcon(
          isSticker
              ? WenyouIconIds.actionAddReaction
              : WenyouIconIds.actionImage,
          color: tokens.onBrand.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _MessageImage extends StatelessWidget {
  const _MessageImage({required this.media});

  final DirectMessageMedia media;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final maxDimension = media.isSticker ? 160.0 : 280.0;
    return Semantics(
      button: true,
      image: true,
      label: media.isSticker ? '私聊表情，点按查看大图' : '私聊图片，点按查看大图',
      child: InkWell(
        onTap: () => _showImage(context),
        borderRadius: BorderRadius.circular(tokens.radius12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDimension,
              maxHeight: maxDimension,
            ),
            child: WenyouCachedImage(
              imageUrl: media.displayUrl,
              fit: BoxFit.contain,
              cacheWidth: maxDimension.ceil(),
              cacheHeight: maxDimension.ceil(),
              placeholder: (_, _) => SizedBox.square(
                dimension: 96,
                child: ColoredBox(
                  color: tokens.softPanel,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
              errorWidget: (_, _, _) => SizedBox.square(
                dimension: 96,
                child: ColoredBox(
                  color: tokens.softPanel,
                  child: WenyouIcon(
                    WenyouIconIds.statusImageUnavailable,
                    color: tokens.mutedText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImage(BuildContext context) {
    return showDialog<void>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.92),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: WenyouCachedImage(
                    imageUrl: media.url,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) => const WenyouIcon(
                      WenyouIconIds.statusImageUnavailable,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.pop(dialogContext),
                  tooltip: '关闭大图',
                  icon: const WenyouIcon(WenyouIconIds.actionClose),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ApiFailure _asFailure(Object error, String fallback) {
  return error is ApiFailure
      ? error
      : ApiFailure(userMessage: fallback, cause: error);
}
