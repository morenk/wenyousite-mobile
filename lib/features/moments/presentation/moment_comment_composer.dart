import 'dart:async';
import 'dart:math' as math;

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
import 'package:wenyousite_mobile/features/media/presentation/media_upload_status_banner.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
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
  var _attachmentBusy = false;
  var _attachmentGeneration = 0;
  var _sending = false;
  final _imageLimitOverlay = OverlayPortalController();
  Timer? _imageLimitTimer;

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
    _imageLimitTimer?.cancel();
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
    final uploading = _attachmentBusy || uploadState.isBusy;
    return PopScope<Object?>(
      canPop: _closing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestClose());
      },
      child: OverlayPortal.overlayChildLayoutBuilder(
        controller: _imageLimitOverlay,
        overlayChildBuilder: _buildImageLimitHint,
        child: WenyouInlineComposerDock(
          editor: WenyouAtomicTextEditor(
            controller: _textController,
            enabled: !_sending && !widget.isSending,
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
                  onDeleted: _sending || widget.isSending
                      ? null
                      : widget.onCancelReply,
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
                onRemove: _sending || widget.isSending
                    ? null
                    : () {
                        if (_sending || widget.isSending) return;
                        _cancelAttachment();
                        setState(() {
                          _image = null;
                          _sticker = null;
                        });
                        _notifyDraftChanged();
                      },
              ),
              SizedBox(height: tokens.space8),
            ],
            if (uploadState.isBusy || uploadState.failure != null) ...[
              MediaUploadStatusBanner(
                key: const Key('moment-comment-upload-failure'),
                state: uploadState,
                onCancel: _cancelAttachment,
                onRetry: _retryImage,
                cancelLabel: '取消',
                cancelKey: const Key('moment-comment-cancel-upload'),
                retryKey: const Key('moment-comment-retry-upload'),
              ),
              if (uploadState.failure != null)
                TextButton(
                  key: const Key('moment-comment-discard-upload'),
                  onPressed: _cancelAttachment,
                  child: const Text('放弃这次上传'),
                ),
              SizedBox(height: tokens.space8),
            ],
          ],
          leadingActions: [
            IconButton(
              key: const Key('moment-comment-image'),
              onPressed: uploading || _sending || widget.isSending
                  ? null
                  : _pickImage,
              tooltip: '添加图片',
              icon: const WenyouIcon(WenyouIconIds.actionImage),
            ),
          ],
          trailingActions: [
            if (ref.watch(stickersEnabledProvider))
              IconButton(
                key: const Key('moment-comment-sticker'),
                onPressed: uploading || _sending || widget.isSending
                    ? null
                    : _pickSticker,
                tooltip: '添加一个表情',
                icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
              ),
          ],
          submitAction: WenyouComposerSubmitButton(
            key: const Key('moment-comment-send'),
            enabled:
                !uploading &&
                !_sending &&
                !widget.isSending &&
                uploadState.failure == null,
            loading: _sending || widget.isSending,
            label: '发送',
            onPressed: () => _send(),
          ),
        ),
      ),
    );
  }

  Future<void> _requestClose() async {
    if (_closing || _sending || widget.isSending) return;
    _cancelAttachment();
    _notifyDraftChanged();
    if (!mounted) return;
    setState(() => _closing = true);
    widget.onClose();
  }

  Future<void> _pickImage() async {
    if (_attachmentBusy || _closing || _sending || widget.isSending) return;
    if (_image != null) {
      _imageLimitTimer?.cancel();
      _imageLimitOverlay.show();
      _imageLimitTimer = Timer(
        wenyouBriefSnackBarDuration,
        _hideImageLimitHint,
      );
      return;
    }
    await _runImageUpload(retry: false);
  }

  void _hideImageLimitHint() {
    _imageLimitTimer?.cancel();
    _imageLimitTimer = null;
    _imageLimitOverlay.hide();
  }

  Widget _buildImageLimitHint(
    BuildContext context,
    OverlayChildLayoutInfo info,
  ) {
    // ModalBottomSheet 会移除顶部 padding；系统安全区取实际 FlutterView。
    final media = MediaQuery.of(context);
    final systemPadding = MediaQueryData.fromView(View.of(context)).viewPadding;
    final safeRect = Rect.fromLTRB(
      systemPadding.left + 16,
      systemPadding.top + 8,
      info.overlaySize.width - systemPadding.right - 16,
      info.overlaySize.height -
          math.max(media.viewInsets.bottom, systemPadding.bottom) -
          8,
    );
    final top = MatrixUtils.transformPoint(
      info.childPaintTransform,
      Offset.zero,
    ).dy;
    final bar = buildWenyouSnackBar(context, '评论只能添加一张图片');
    return CustomSingleChildLayout(
      delegate: _CommentHintLayout(safeRect, top),
      child: Semantics(
        container: true,
        liveRegion: true,
        onDismiss: _hideImageLimitHint,
        child: SingleChildScrollView(
          key: const Key('moment-comment-image-limit-hint'),
          child: Material(
            color: bar.backgroundColor,
            elevation: bar.elevation!,
            shape: bar.shape,
            child: Padding(padding: bar.padding!, child: bar.content),
          ),
        ),
      ),
    );
  }

  Future<void> _retryImage() => _runImageUpload(retry: true);

  Future<void> _runImageUpload({required bool retry}) async {
    if (_attachmentBusy || _closing || _sending || widget.isSending) return;
    _hideImageLimitHint();
    final generation = ++_attachmentGeneration;
    setState(() => _attachmentBusy = true);
    final controller = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    try {
      UploadedEditorImage? image;
      if (retry) {
        image = await controller.retryUpload();
      } else {
        // 新选择替代旧失败任务，取消相册也不能重试上一次附件。
        controller.reset();
        final inputs = await pickEditorImages(
          context,
          ref,
          purpose: MediaUploadPurpose.momentComment,
          isCurrent: () => _isCurrentAttachment(generation),
        );
        if (!_isCurrentAttachment(generation) ||
            inputs == null ||
            inputs.isEmpty) {
          return;
        }
        image = await controller.uploadInput(inputs.single);
      }
      if (!_isCurrentAttachment(generation) || image == null) return;
      setState(() {
        _sticker = null;
        _image = image;
      });
      _notifyDraftChanged();
    } finally {
      if (_isCurrentAttachment(generation)) {
        setState(() => _attachmentBusy = false);
      }
    }
  }

  Future<void> _pickSticker() async {
    if (!ref.read(stickersEnabledProvider)) return;
    if (_attachmentBusy || _closing || _sending || widget.isSending) return;
    _hideImageLimitHint();
    final generation = ++_attachmentGeneration;
    setState(() => _attachmentBusy = true);
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    try {
      final sticker = await showStickerPicker(context);
      if (sticker == null || !_isCurrentAttachment(generation)) return;
      setState(() {
        _image = null;
        _sticker = sticker;
      });
      _notifyDraftChanged();
    } finally {
      if (_isCurrentAttachment(generation)) {
        setState(() => _attachmentBusy = false);
      }
    }
  }

  bool _isCurrentAttachment(int generation) =>
      mounted && !_closing && generation == _attachmentGeneration;

  void _cancelAttachment() {
    _hideImageLimitHint();
    _attachmentGeneration++;
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    setState(() => _attachmentBusy = false);
  }

  Future<void> _send() async {
    final upload = ref.read(mediaUploadTaskControllerProvider(_uploadTaskId));
    if (_attachmentBusy ||
        _closing ||
        _sending ||
        widget.isSending ||
        upload.isBusy ||
        upload.failure != null) {
      return;
    }
    if (!_textController.flush()) return;
    _hideImageLimitHint();
    setState(() => _sending = true);
    bool sent;
    try {
      sent = await widget.onSend(
        MomentCommentInput(
          content: _textController.markdown,
          mediaId: _image?.mediaId,
          stickerAssetId: _sticker?.asset.id,
          replyToCommentId: widget.replyTo?.id,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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
  final VoidCallback? onRemove;

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

/// 用弹层实际坐标定位，不叠加 dock 已处理过的键盘 inset。
class _CommentHintLayout extends SingleChildLayoutDelegate {
  const _CommentHintLayout(this.safeRect, this.composerTop);
  final Rect safeRect;
  final double composerTop;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.max(0, math.min(600, safeRect.width)),
        maxHeight: math.max(0, safeRect.height),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    safeRect.center.dx - childSize.width / 2,
    (composerTop - childSize.height - 8).clamp(
      safeRect.top,
      math.max(safeRect.top, safeRect.bottom - childSize.height),
    ),
  );

  @override
  bool shouldRelayout(_CommentHintLayout oldDelegate) =>
      safeRect != oldDelegate.safeRect ||
      composerTop != oldDelegate.composerTop;
}
