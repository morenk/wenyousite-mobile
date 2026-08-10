import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
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
      child: Icon(
        user.isDeactivated ? Icons.person_off_rounded : Icons.person_rounded,
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
              : CachedNetworkImage(
                  imageUrl: user.avatarUrl!,
                  fit: BoxFit.cover,
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

  @override
  ConsumerState<DirectMessageComposer> createState() =>
      _DirectMessageComposerState();
}

class _DirectMessageComposerState extends ConsumerState<DirectMessageComposer> {
  late final TextEditingController _controller;
  MediaUploadInput? _selectedImage;
  UploadedEditorImage? _uploadedImage;
  MediaUploadProgress? _uploadProgress;
  CancelToken? _uploadCancelToken;
  ApiFailure? _localFailure;
  var _busy = false;

  bool get _lockedByFailedSend => widget.failedDraft != null;
  bool get _disabled => widget.disabled || _busy || _lockedByFailedSend;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.failedDraft?.content ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant DirectMessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.failedDraft == null && widget.failedDraft != null) {
      _controller.text = widget.failedDraft?.content ?? _controller.text;
    }
  }

  @override
  void dispose() {
    _uploadCancelToken?.cancel('composer disposed');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final failure = _localFailure ?? widget.failure;
    return Material(
      color: tokens.softPanel,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space12,
            tokens.space12,
            tokens.space12,
            tokens.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.requestHint != null) ...[
                Text(
                  widget.requestHint!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: tokens.space8),
              ],
              if (_selectedImage != null) ...[
                _ImagePreview(
                  input: _selectedImage!,
                  onRemove: _disabled ? null : _removeImage,
                ),
                SizedBox(height: tokens.space8),
              ],
              TextField(
                key: const Key('direct-message-composer-field'),
                controller: _controller,
                enabled: !_disabled,
                minLines: 2,
                maxLines: 4,
                maxLength: directMessageMaxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  counterText: '${_controller.text.length}/1000',
                ),
                onChanged: (_) {
                  if (_localFailure != null) {
                    setState(() => _localFailure = null);
                  } else {
                    setState(() {});
                  }
                },
              ),
              if (_uploadProgress != null) ...[
                SizedBox(height: tokens.space8),
                _UploadProgress(
                  progress: _uploadProgress!,
                  onCancel: () => _uploadCancelToken?.cancel('user canceled'),
                ),
              ],
              if (failure != null) ...[
                SizedBox(height: tokens.space8),
                WenyouStatusBanner(
                  key: const Key('direct-message-composer-failure'),
                  tone: WenyouStatusTone.error,
                  message: failure.userMessage,
                  detail: failure.requestId == null
                      ? null
                      : '请求 ID：${failure.requestId}',
                  action: widget.failedDraft == null
                      ? null
                      : Wrap(
                          spacing: tokens.space8,
                          children: [
                            TextButton(
                              key: const Key('direct-message-composer-retry'),
                              onPressed: _busy ? null : _submit,
                              child: const Text('使用原请求重试'),
                            ),
                            TextButton(
                              key: const Key('direct-message-composer-abandon'),
                              onPressed: _busy ? null : _abandonFailedDraft,
                              child: const Text('放弃本次'),
                            ),
                          ],
                        ),
                ),
              ],
              SizedBox(height: tokens.space8),
              Row(
                children: [
                  OutlinedButton.icon(
                    key: const Key('direct-message-composer-image'),
                    onPressed: _disabled || _selectedImage != null
                        ? null
                        : _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('图片'),
                  ),
                  SizedBox(width: tokens.space8),
                  if (ref.watch(stickersEnabledProvider)) ...[
                    IconButton.outlined(
                      key: const Key('direct-message-composer-sticker'),
                      onPressed: _disabled ? null : _pickSticker,
                      tooltip: '收藏表情',
                      icon: const Icon(Icons.add_reaction_outlined),
                    ),
                    SizedBox(width: tokens.space8),
                  ],
                  Expanded(
                    child: Text(
                      _selectedImage == null
                          ? '纯文本；图片最大 10MB'
                          : '图片使用可访问链接，请勿发送敏感内容',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(width: tokens.space8),
                  FilledButton.icon(
                    key: const Key('direct-message-composer-submit'),
                    onPressed: _disabled ? null : _submit,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_submitLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _submitLabel {
    final progress = _uploadProgress;
    if (progress?.stage == MediaUploadStage.uploading &&
        progress?.fraction != null) {
      return '上传 ${(progress!.fraction! * 100).round()}%';
    }
    return _busy ? '处理中' : widget.submitLabel;
  }

  Future<void> _pickImage() async {
    try {
      final input = await ref.read(editorImagePickerProvider).pickFromGallery();
      if (!mounted || input == null) return;
      setState(() {
        _selectedImage = input;
        _uploadedImage = null;
        _localFailure = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _localFailure = _asFailure(error, '无法读取所选图片。'));
    }
  }

  void _removeImage() {
    _uploadCancelToken?.cancel('image removed');
    setState(() {
      _selectedImage = null;
      _uploadedImage = null;
      _uploadProgress = null;
      _localFailure = null;
    });
  }

  Future<void> _submit() async {
    if (_busy || widget.disabled) return;
    final failedDraft = widget.failedDraft;
    final normalized = normalizeDirectMessageContent(_controller.text);
    final validation = validateDirectMessagePayload(
      content: normalized,
      mediaId: _selectedImage == null ? null : 'pending-image',
      stickerAssetId: failedDraft?.stickerAssetId,
    );
    if (failedDraft == null && validation != null) {
      setState(() => _localFailure = ApiFailure(userMessage: validation));
      return;
    }
    setState(() {
      _busy = true;
      _localFailure = null;
    });
    try {
      String? mediaId = failedDraft?.mediaId ?? _uploadedImage?.mediaId;
      if (failedDraft == null && mediaId == null && _selectedImage != null) {
        final cancelToken = CancelToken();
        _uploadCancelToken = cancelToken;
        _uploadedImage = await ref
            .read(mediaUploadRepositoryProvider)
            .uploadImage(
              _selectedImage!,
              cancelToken: cancelToken,
              onProgress: (progress) {
                if (!mounted) return;
                setState(() => _uploadProgress = progress);
              },
            );
        mediaId = _uploadedImage!.mediaId;
      }
      final succeeded = await widget.onSend(
        content:
            failedDraft?.content ?? (normalized.isEmpty ? null : normalized),
        mediaId: mediaId,
        stickerAssetId: failedDraft?.stickerAssetId,
      );
      if (!mounted) return;
      if (succeeded) {
        _controller.clear();
        _selectedImage = null;
        _uploadedImage = null;
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _localFailure = _asFailure(error, '消息发送失败，请重试。'));
    } finally {
      _uploadCancelToken = null;
      if (mounted) {
        setState(() {
          _busy = false;
          _uploadProgress = null;
        });
      }
    }
  }

  Future<void> _pickSticker() async {
    final sticker = await showStickerPicker(context);
    if (!mounted || sticker == null) return;
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
      if (mounted) setState(() => _busy = false);
    }
  }

  void _abandonFailedDraft() {
    widget.onAbandonFailedDraft?.call();
    setState(() {
      _controller.clear();
      _selectedImage = null;
      _uploadedImage = null;
      _localFailure = null;
    });
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.input, this.onRemove});

  final MediaUploadInput input;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: Image.memory(
            input.bytes,
            width: 160,
            height: 112,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
        Positioned(
          right: -8,
          top: -8,
          child: IconButton.filled(
            key: const Key('direct-message-composer-remove-image'),
            onPressed: onRemove,
            tooltip: '移除图片',
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ),
      ],
    );
  }
}

class _UploadProgress extends StatelessWidget {
  const _UploadProgress({required this.progress, required this.onCancel});

  final MediaUploadProgress progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(switch (progress.stage) {
                MediaUploadStage.preparing => '正在准备图片…',
                MediaUploadStage.uploading => '正在上传图片…',
                MediaUploadStage.confirming => '正在确认图片…',
                MediaUploadStage.processing => '正在处理图片…',
              }, style: Theme.of(context).textTheme.bodySmall),
            ),
            TextButton(onPressed: onCancel, child: const Text('取消')),
          ],
        ),
        LinearProgressIndicator(value: progress.fraction),
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
    super.key,
  });

  final DirectMessage message;
  final bool mine;
  final bool hideIncomingRequestImage;
  final bool canRecall;
  final bool isRecalling;
  final VoidCallback onRecall;

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
    final scheme = Theme.of(context).colorScheme;
    final media = widget.message.media;
    final stickersEnabled = ref.watch(stickersEnabledProvider);
    final stickerState = ref.watch(stickerCollectionControllerProvider);
    final savingSticker =
        stickerState.action == StickerAction.importing &&
        stickerState.actionTarget == 'direct:${widget.message.id}';
    final pureSticker =
        media?.isSticker == true && widget.message.content == null;
    return Align(
      alignment: widget.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        child: Column(
          crossAxisAlignment: widget.mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            DecoratedBox(
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
                    widget.mine ? tokens.radius16 : tokens.space4,
                  ),
                  bottomRight: Radius.circular(
                    widget.mine ? tokens.space4 : tokens.radius16,
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
                            SelectableText(
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
                                icon: const Icon(Icons.image_outlined),
                                label: const Text('点击查看陌生人图片'),
                              )
                            else
                              _MessageImage(media: media),
                          ],
                        ],
                      ),
              ),
            ),
            if (!widget.message.isRecalled &&
                ((stickersEnabled && media != null && _imageRevealed) ||
                    widget.canRecall)) ...[
              SizedBox(height: tokens.space4),
              Wrap(
                alignment: widget.mine
                    ? WrapAlignment.end
                    : WrapAlignment.start,
                spacing: tokens.space4,
                children: [
                  if (stickersEnabled && media != null && _imageRevealed)
                    TextButton.icon(
                      key: ValueKey(
                        'direct-message-save-sticker-${widget.message.id}',
                      ),
                      onPressed: stickerState.isBusy ? null : _saveSticker,
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                        minimumSize: const Size(48, 32),
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space8,
                        ),
                      ),
                      icon: savingSticker
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_reaction_outlined, size: 18),
                      label: Text(savingSticker ? '收藏中' : '收藏表情'),
                    ),
                  if (widget.canRecall)
                    TextButton(
                      key: ValueKey(
                        'direct-message-recall-${widget.message.id}',
                      ),
                      onPressed: widget.isRecalling ? null : widget.onRecall,
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                        minimumSize: const Size(48, 32),
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space8,
                        ),
                      ),
                      child: Text(widget.isRecalling ? '撤回中…' : '撤回'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
            child: CachedNetworkImage(
              imageUrl: media.displayUrl,
              fit: BoxFit.contain,
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
                  child: Icon(
                    Icons.broken_image_outlined,
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
                  child: CachedNetworkImage(
                    imageUrl: media.url,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
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
                  icon: const Icon(Icons.close_rounded),
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
