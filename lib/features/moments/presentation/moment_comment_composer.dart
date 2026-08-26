import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_selection.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

class MomentCommentComposer extends ConsumerStatefulWidget {
  const MomentCommentComposer({
    required this.replyTo,
    required this.isSending,
    required this.onCancelReply,
    required this.onClose,
    required this.onSend,
    this.initialDraft = const MomentCommentDraft(),
    this.onDraftChanged,
    super.key,
  });

  final MomentComment? replyTo;
  final bool isSending;
  final VoidCallback onCancelReply;
  final VoidCallback onClose;
  final Future<bool> Function(MomentCommentInput input) onSend;
  final MomentCommentDraft initialDraft;
  final ValueChanged<MomentCommentDraft>? onDraftChanged;

  @override
  ConsumerState<MomentCommentComposer> createState() =>
      _MomentCommentComposerState();
}

@immutable
class MomentCommentDraft {
  const MomentCommentDraft({this.content = '', this.image, this.sticker});

  final String content;
  final UploadedEditorImage? image;
  final UserSticker? sticker;

  bool get isEmpty =>
      content.trim().isEmpty && image == null && sticker == null;
}

class _MomentCommentComposerState extends ConsumerState<MomentCommentComposer> {
  late final WenyouAtomicTextController _textController;
  UploadedEditorImage? _image;
  UserSticker? _sticker;
  final Object _uploadTaskId = Object();
  var _closing = false;

  @override
  void initState() {
    super.initState();
    _textController = WenyouAtomicTextController(
      initialMarkdown: widget.initialDraft.content,
      maximumMarkdownLength: 500,
    );
    _textController.addListener(_handleEditorChanged);
    _image = widget.initialDraft.image;
    _sticker = widget.initialDraft.sticker;
  }

  @override
  void dispose() {
    _textController.removeListener(_handleEditorChanged);
    _textController.dispose();
    super.dispose();
  }

  void _handleEditorChanged() {
    if (!mounted) return;
    setState(() {});
    _notifyDraftChanged();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    final uploading = uploadState.isBusy;
    return PopScope<Object?>(
      canPop: _closing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestClose());
      },
      child: WenyouInlineComposerDock(
        editor: WenyouAtomicTextEditor(
          controller: _textController,
          editorKey: const Key('moment-comment-input'),
          placeholder: widget.replyTo == null ? '发表评论…' : '写下回复…',
          semanticLabel: widget.replyTo == null ? '发表评论' : '写下回复',
          autofocus: true,
        ),
        dockKey: const Key('moment-comment-editor-dock'),
        supporting: [
          if (widget.replyTo != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                label: Text('回复 @${widget.replyTo!.author.username}'),
                onDeleted: widget.onCancelReply,
              ),
            ),
            SizedBox(height: tokens.space8),
          ],
          if (_textController.failure case final failure?) ...[
            WenyouStatusBanner(
              key: const Key('moment-comment-content-failure'),
              message: failure,
              tone: WenyouStatusTone.error,
            ),
            SizedBox(height: tokens.space8),
          ],
          if (_image != null || _sticker != null) ...[
            _SelectedCommentAsset(
              image: _image,
              sticker: _sticker,
              onRemove: () {
                setState(() {
                  _image = null;
                  _sticker = null;
                });
                _notifyDraftChanged();
              },
            ),
            SizedBox(height: tokens.space8),
          ],
          if (uploadState.isBusy) ...[
            LinearProgressIndicator(value: uploadState.progress?.fraction),
            SizedBox(height: tokens.space4),
            Row(
              children: [
                Expanded(child: Text(uploadState.progressLabel)),
                TextButton(
                  key: const Key('moment-comment-cancel-upload'),
                  onPressed: () => ref
                      .read(
                        mediaUploadTaskControllerProvider(
                          _uploadTaskId,
                        ).notifier,
                      )
                      .cancel(),
                  child: const Text('取消'),
                ),
              ],
            ),
            SizedBox(height: tokens.space8),
          ],
          if (uploadState.failure case final failure?) ...[
            WenyouStatusBanner(
              key: const Key('moment-comment-upload-failure'),
              message: failure.userMessage,
              detail: failure.requestId == null
                  ? null
                  : '问题编号：${failure.requestId}',
              tone: WenyouStatusTone.error,
              action: failure.canRetry
                  ? TextButton(
                      key: const Key('moment-comment-retry-upload'),
                      onPressed: _retryImage,
                      child: const Text('重试上传'),
                    )
                  : null,
            ),
            SizedBox(height: tokens.space8),
          ],
        ],
        leadingActions: [
          IconButton(
            key: const Key('moment-comment-image'),
            onPressed: uploading || widget.isSending ? null : _pickImage,
            tooltip: '添加一张图片',
            icon: const WenyouIcon(WenyouIconIds.actionImage),
          ),
        ],
        trailingActions: [
          IconButton(
            key: const Key('moment-comment-sticker'),
            onPressed: uploading || widget.isSending ? null : _pickSticker,
            tooltip: '添加一个表情',
            icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
          ),
        ],
        submitAction: WenyouComposerSubmitButton(
          key: const Key('moment-comment-send'),
          enabled: !uploading && !widget.isSending,
          loading: widget.isSending,
          label: '发送',
          onPressed: () => _send(),
        ),
      ),
    );
  }

  Future<void> _requestClose() async {
    if (_closing || widget.isSending) return;
    final uploadController = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    if (ref.read(mediaUploadTaskControllerProvider(_uploadTaskId)).isBusy) {
      uploadController.cancel();
      if (!mounted) return;
    }
    _notifyDraftChanged();
    if (!mounted) return;
    setState(() => _closing = true);
    widget.onClose();
  }

  Future<void> _pickImage() => _runImageUpload(retry: false);

  Future<void> _retryImage() => _runImageUpload(retry: true);

  Future<void> _runImageUpload({required bool retry}) async {
    final controller = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    final image = retry
        ? await controller.retryUpload()
        : await pickAndUploadEditorImage(
            context,
            ref,
            uploadTaskId: _uploadTaskId,
            purpose: MediaUploadPurpose.momentComment,
          );
    if (!mounted || _closing || image == null) return;
    setState(() {
      _sticker = null;
      _image = image;
    });
    _notifyDraftChanged();
  }

  Future<void> _pickSticker() async {
    final sticker = await showStickerPicker(context);
    if (sticker == null || !mounted) return;
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    setState(() {
      _image = null;
      _sticker = sticker;
    });
    _notifyDraftChanged();
  }

  Future<void> _send() async {
    if (!_textController.flush()) return;
    final sent = await widget.onSend(
      MomentCommentInput(
        content: _textController.markdown,
        mediaId: _image?.mediaId,
        stickerAssetId: _sticker?.asset.id,
        replyToCommentId: widget.replyTo?.id,
      ),
    );
    if (!sent || !mounted) return;
    _textController.clear();
    setState(() {
      _image = null;
      _sticker = null;
      _closing = true;
    });
    _notifyDraftChanged();
    widget.onClose();
  }

  void _notifyDraftChanged() {
    widget.onDraftChanged?.call(
      MomentCommentDraft(
        content: _textController.markdown,
        image: _image,
        sticker: _sticker,
      ),
    );
  }
}

class _SelectedCommentAsset extends StatelessWidget {
  const _SelectedCommentAsset({
    required this.image,
    required this.sticker,
    required this.onRemove,
  });

  final UploadedEditorImage? image;
  final UserSticker? sticker;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final urls = image?.previewUrls;
    final url = urls?.first ?? sticker!.asset.thumbnailUrl;
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          SizedBox.square(
            dimension: 112,
            child: WenyouCachedImage(
              imageUrl: url,
              fallbackImageUrls:
                  urls?.skip(1).toList(growable: false) ?? const [],
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton.filledTonal(
              onPressed: onRemove,
              tooltip: '移除附件',
              icon: const WenyouIcon(WenyouIconIds.actionClose),
            ),
          ),
        ],
      ),
    );
  }
}
