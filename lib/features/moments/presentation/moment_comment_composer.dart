import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_selection.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_images.dart';
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
    this.momentId,
    super.key,
  });

  final String? momentId;
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
  const MomentCommentDraft({
    this.content = '',
    this.image,
    this.sticker,
    this.pendingInput,
    this.pendingUpload,
    this.attachmentId,
  });

  final MediaUploadInput? pendingInput;
  final PendingMediaUpload? pendingUpload;
  final String? attachmentId;
  final String content;
  final UploadedEditorImage? image;
  final UserSticker? sticker;

  bool get isEmpty =>
      content.trim().isEmpty &&
      image == null &&
      sticker == null &&
      pendingInput == null;
}

class _MomentCommentComposerState extends ConsumerState<MomentCommentComposer>
    with WidgetsBindingObserver {
  late final WenyouAtomicTextController _textController;
  UploadedEditorImage? _image;
  UserSticker? _sticker;
  final Object _uploadTaskId = Object();
  final _imageLimitOverlay = OverlayPortalController();
  Timer? _imageLimitTimer;
  var _closing = false;
  var _waitingToSend = false;
  var _sending = false;
  var _picking = false;
  var _failed = false;
  var _generation = 0;
  var _revision = 0;
  MediaUploadInput? _pendingInput;
  PendingMediaUpload? _pendingUpload;
  String _attachmentId = const Uuid().v4();
  String? _owner;
  late String _draftTarget;
  MediaUploadTaskController? _task;
  Timer? _saveTimer;
  Future<void> _saveQueue = Future.value();
  final _persisting = <String, Future<MediaUploadInput>>{};
  bool _draftSaveFailed = false;
  bool _suspended = false;
  bool get _locked => _waitingToSend || _sending || widget.isSending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController = WenyouAtomicTextController(
      initialMarkdown: widget.initialDraft.content,
      maximumMarkdownLength: 500,
    );
    _textController.addListener(_handleEditorChanged);
    _image = widget.initialDraft.image;
    _sticker = widget.initialDraft.sticker;
    _pendingInput = widget.initialDraft.pendingInput;
    _pendingUpload = widget.initialDraft.pendingUpload;
    _attachmentId = widget.initialDraft.attachmentId ?? _attachmentId;
    _draftTarget =
        'moment-comment:${widget.momentId}:${widget.replyTo?.id ?? 'root'}';
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
  }

  @override
  void didUpdateWidget(covariant MomentCommentComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replyTo?.id == widget.replyTo?.id &&
        oldWidget.momentId == widget.momentId) {
      return;
    }
    final previousTarget = _draftTarget;
    _draftTarget =
        'moment-comment:${widget.momentId}:${widget.replyTo?.id ?? 'root'}';
    _revision++;
    _waitingToSend = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _saveDraft();
      if (!mounted || _draftSaveFailed || _owner == null) return;
      try {
        await ref
            .read(pendingMediaFileStoreProvider)
            .write(
              accountId: _owner!,
              target: previousTarget,
              payload: const {},
            );
      } on Object {
        /* 新目标草稿已保存；旧目录可能仍被图片引用，保留文件。 */
      }
    });
  }

  @override
  void dispose() {
    _imageLimitTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _saveTimer?.cancel();
    _textController.removeListener(_handleEditorChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _suspended = true;
      _generation++;
      _pendingUpload =
          ref
              .read(mediaUploadTaskControllerProvider(_uploadTaskId))
              .pendingUpload ??
          _pendingUpload;
      _task?.pause();
      if (mounted) setState(() => _waitingToSend = false);
      unawaited(_saveDraft());
    } else if (state == AppLifecycleState.resumed && _suspended) {
      _suspended = false;
      if (_pendingInput != null && !_failed && !_closing) {
        unawaited(_runImageUpload());
      }
    }
  }

  void _handleEditorChanged() {
    if (!mounted) return;
    setState(() {});
    _notifyDraftChanged();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    ref.listen(sessionScopeProvider, (previous, next) {
      if (previous == next) return;
      _generation++;
      _waitingToSend = false;
      _closing = true;
      _task?.pause();
      _saveTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onClose();
      });
    });
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    ref.listen(mediaUploadTaskControllerProvider(_uploadTaskId), (
      previous,
      next,
    ) {
      if (next.pendingUpload != null && next.pendingUpload != _pendingUpload) {
        _pendingUpload = next.pendingUpload;
        _notifyDraftChanged();
      }
    });
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
            editorKey: const Key('moment-comment-input'),
            placeholder: widget.replyTo == null ? '发表评论…' : '写下回复…',
            semanticLabel: widget.replyTo == null ? '发表评论' : '写下回复',
            autofocus: true,
            enabled: !_locked && !_picking,
          ),
          dockKey: const Key('moment-comment-editor-dock'),
          supporting: [
            if (widget.replyTo != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text('回复 @${widget.replyTo!.author.username}'),
                  onDeleted: _locked ? null : widget.onCancelReply,
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
            if (_pendingInput == null &&
                (_image != null || _sticker != null)) ...[
              _SelectedCommentAsset(
                image: _image,
                sticker: _sticker,
                onRemove: _locked
                    ? null
                    : () {
                        _hideImageLimitHint();
                        setState(() {
                          _image = null;
                          _sticker = null;
                        });
                        _notifyDraftChanged();
                      },
              ),
              SizedBox(height: tokens.space8),
            ],
            if (_pendingInput != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 112,
                  child: MomentPendingImageThumbnail(
                    key: ValueKey(_attachmentId),
                    pending: MomentPendingComposeImage(
                      id: _attachmentId,
                      input: _pendingInput!,
                      state: uploadState,
                      completed: false,
                      active: uploadState.isActivelyWorking,
                      failed: _failed,
                    ),
                    index: 0,
                    onRemove: _locked ? null : _removePending,
                    onRetry: _locked ? null : _retryImage,
                  ),
                ),
              ),
              SizedBox(height: tokens.space8),
            ],
            if (_waitingToSend)
              DelayedPendingNotice(
                waiting: true,
                child: Row(
                  children: [
                    const Expanded(child: Text('还有 1 张图片未就绪')),
                    TextButton(
                      key: const Key('moment-comment-cancel-publish'),
                      onPressed: () => setState(() => _waitingToSend = false),
                      child: const Text('取消发布'),
                    ),
                  ],
                ),
              ),
          ],
          leadingActions: [
            IconButton(
              key: const Key('moment-comment-image'),
              onPressed: _locked || _picking ? null : _pickImage,
              tooltip: '添加一张图片',
              icon: const WenyouIcon(WenyouIconIds.actionImage),
            ),
          ],
          trailingActions: [
            if (ref.watch(stickersEnabledProvider))
              IconButton(
                key: const Key('moment-comment-sticker'),
                onPressed: _locked || _picking ? null : _pickSticker,
                tooltip: '添加一个表情',
                icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
              ),
          ],
          submitAction: WenyouComposerSubmitButton(
            key: const Key('moment-comment-send'),
            enabled: !_locked && !_picking,
            loading: _locked,
            label: _waitingToSend ? '正在发布…' : '发送',
            onPressed: () => _send(),
          ),
        ),
      ),
    );
  }

  Future<void> _requestClose() async {
    if (_closing || _sending || widget.isSending) return;
    _hideImageLimitHint();
    _waitingToSend = false;
    _pendingUpload =
        ref
            .read(mediaUploadTaskControllerProvider(_uploadTaskId))
            .pendingUpload ??
        _pendingUpload;
    _generation++;
    _task?.pause();
    if (mounted && _pendingInput != null) setState(() => _failed = true);
    if (_pendingInput != null) {
      try {
        _pendingInput = await _persistSelection(_pendingInput!);
      } on Object {
        if (mounted) showWenyouSnackBar(context, '图片保存失败，请重试后退出。');
        return;
      }
    }
    if (!mounted) return;
    _notifyDraftChanged();
    await _saveDraft();
    if (!mounted || _draftSaveFailed) return;
    setState(() => _closing = true);
    widget.onClose();
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

  Future<void> _pickImage() async {
    if (_locked || _picking) return;
    if (_pendingInput != null || _image != null) {
      _imageLimitTimer?.cancel();
      _imageLimitOverlay.show();
      _imageLimitTimer = Timer(
        wenyouBriefSnackBarDuration,
        _hideImageLimitHint,
      );
      return;
    }
    setState(() => _picking = true);
    final selectionGeneration = _generation;
    final inputs = await pickEditorImages(
      context,
      ref,
      purpose: MediaUploadPurpose.momentComment,
      isCurrent: () =>
          mounted && !_closing && selectionGeneration == _generation,
    );
    if (!mounted || _closing) return;
    setState(() => _picking = false);
    if (inputs == null || inputs.isEmpty || _locked) return;
    _generation++;
    _task?.reset();
    setState(() {
      _pendingInput = inputs.single;
      _pendingUpload = null;
      _attachmentId = const Uuid().v4();
      _failed = false;
    });
    _notifyDraftChanged();
    await _runImageUpload();
  }

  Future<void> _retryImage() => _runImageUpload();

  void _removePending() {
    _hideImageLimitHint();
    _generation++;
    _task?.reset();
    setState(() {
      _pendingInput = null;
      _pendingUpload = null;
      _failed = false;
    });
    _notifyDraftChanged();
  }

  Future<MediaUploadInput> _persistSelection(MediaUploadInput input) {
    if (_pendingUpload != null) return Future.value(input);
    final attachmentId = _attachmentId;
    return _persisting[attachmentId] ??=
        (() async {
          final resolveOwner = ref.read(momentComposerOwnerResolverProvider);
          final store = ref.read(pendingMediaFileStoreProvider);
          _owner ??= await resolveOwner();
          return store.persist(
            input,
            accountId: _owner!,
            target: _draftTarget,
            attachmentId: attachmentId,
          );
        })().whenComplete(() {
          _persisting.remove(attachmentId);
        });
  }

  Future<void> _runImageUpload() async {
    final input = _pendingInput;
    if (input == null) return;
    final generation = ++_generation;
    final controller = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    _task = controller;
    setState(() => _failed = false);
    try {
      final persisted = await _persistSelection(input);
      if (!mounted || generation != _generation || _closing) return;
      _pendingInput = persisted;
      await _saveDraft();
    } on Object {
      if (mounted && generation == _generation) {
        setState(() {
          _failed = true;
          _waitingToSend = false;
        });
      }
      return;
    }
    if (!mounted || generation != _generation || _closing) return;
    final image = _pendingUpload == null
        ? await controller.uploadInput(_pendingInput!)
        : await controller.resumeUpload(_pendingInput!, _pendingUpload!);
    if (!mounted || generation != _generation || _closing) return;
    if (image == null) {
      _pendingUpload = ref
          .read(mediaUploadTaskControllerProvider(_uploadTaskId))
          .pendingUpload;
      setState(() {
        _failed = true;
        _waitingToSend = false;
      });
      _notifyDraftChanged();
      return;
    }
    setState(() {
      _sticker = null;
      _image = image;
      _pendingInput = null;
      _pendingUpload = null;
    });
    _notifyDraftChanged();
    if (_waitingToSend) await _sendReady();
  }

  Future<void> _pickSticker() async {
    if (!ref.read(stickersEnabledProvider)) return;
    _hideImageLimitHint();
    final sticker = await showStickerPicker(context);
    if (sticker == null || !mounted) return;
    _generation++;
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    setState(() {
      _image = null;
      _pendingInput = null;
      _pendingUpload = null;
      _sticker = sticker;
    });
    _notifyDraftChanged();
  }

  Future<void> _send() async {
    if (_locked || _picking || !_textController.flush()) return;
    _hideImageLimitHint();
    if (_pendingInput != null) {
      if (_failed) {
        showWenyouSnackBar(context, '先处理未完成的图片');
        return;
      }
      setState(() => _waitingToSend = true);
      return;
    }
    await _sendReady();
  }

  Future<void> _sendReady() async {
    if (_sending || !mounted) return;
    setState(() {
      _waitingToSend = false;
      _sending = true;
    });
    final sent = await widget.onSend(
      MomentCommentInput(
        content: _textController.markdown,
        mediaId: _image?.mediaId,
        stickerAssetId: _sticker?.asset.id,
        replyToCommentId: widget.replyTo?.id,
      ),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (!sent) return;
    _textController.clear();
    setState(() {
      _image = null;
      _sticker = null;
      _closing = true;
    });
    _notifyDraftChanged();
    await _saveDraft();
    if (mounted) widget.onClose();
  }

  void _notifyDraftChanged() {
    _revision++;
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_saveDraft()),
    );
    widget.onDraftChanged?.call(
      MomentCommentDraft(
        content: _textController.markdown,
        image: _image,
        sticker: _sticker,
      ),
    );
  }

  Future<void> _restoreDraft() async {
    final revision = _revision;
    try {
      _owner = await ref.read(momentComposerOwnerResolverProvider)();
      if (!mounted) return;
      final raw = widget.momentId == null
          ? null
          : await ref
                .read(pendingMediaFileStoreProvider)
                .read(accountId: _owner!, target: _draftTarget);
      if (!mounted || revision != _revision) return;
      if (raw != null && widget.initialDraft.isEmpty) {
        final draft = MomentLocalDraft.fromJson(raw);
        if (draft != null) {
          _textController.applyMarkdown(draft.content);
          setState(() {
            _image = draft.images.firstOrNull;
            _sticker = _decodeSticker(raw['sticker']);
            final pending = draft.pendingImages.firstOrNull;
            _pendingInput = pending?.input;
            _pendingUpload = pending?.pending;
            _attachmentId = pending?.id ?? _attachmentId;
          });
        }
      }
      if (_pendingInput != null) await _runImageUpload();
    } on Object {
      /* 保留当前编辑内容，后续保存会再次尝试。 */
    }
  }

  Future<void> _saveDraft() {
    final owner = _owner;
    if (owner == null || widget.momentId == null) return Future.value();
    final store = ref.read(pendingMediaFileStoreProvider);
    final target = _draftTarget;
    final draft = MomentLocalDraft(
      title: '',
      content: _textController.markdown,
      images: _image == null ? const [] : [_image!],
      updatedAt: DateTime.now(),
      pendingImages: _pendingInput?.sourcePath == null
          ? const []
          : [
              MomentPendingDraftImage(
                id: _attachmentId,
                input: _pendingInput!,
                pending: _pendingUpload,
              ),
            ],
    );
    final sticker = _sticker;
    final payload = {...draft.toJson(), 'sticker': _encodeSticker(sticker)};
    _saveQueue = _saveQueue.catchError((Object _) {}).then((_) async {
      if (draft.content.isEmpty &&
          draft.images.isEmpty &&
          draft.pendingImages.isEmpty &&
          sticker == null) {
        await store.delete(accountId: owner, target: target);
      } else {
        await store.write(accountId: owner, target: target, payload: payload);
      }
    });
    return _saveQueue
        .then((_) {
          _draftSaveFailed = false;
        })
        .catchError((Object _) {
          _draftSaveFailed = true;
          if (mounted && !_closing) {
            showWenyouSnackBar(context, '草稿保存失败，请稍后重试。');
          }
        });
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

Map<String, Object?>? _encodeSticker(UserSticker? sticker) {
  if (sticker == null) return null;
  final asset = sticker.asset;
  return {
    'id': sticker.id,
    'position': sticker.position,
    'markdown': sticker.markdown,
    'asset': {
      'id': asset.id,
      'url': asset.url,
      'display': asset.display?.toJson(),
      'thumbnailUrl': asset.thumbnailUrl,
      'width': asset.width,
      'height': asset.height,
      'animated': asset.animated,
      'frameCount': asset.frameCount,
      'durationMs': asset.durationMs,
    },
  };
}

UserSticker? _decodeSticker(Object? raw) {
  if (raw is! Map || raw['asset'] is! Map) return null;
  try {
    final asset = raw['asset'] as Map;
    return UserSticker(
      id: raw['id'] as String,
      position: raw['position'] as int,
      markdown: raw['markdown'] as String,
      asset: StickerAsset(
        id: asset['id'] as String,
        url: asset['url'] as String,
        display: cachedMediaDisplayFromJson(asset['display']),
        thumbnailUrl: asset['thumbnailUrl'] as String,
        width: asset['width'] as int,
        height: asset['height'] as int,
        animated: asset['animated'] as bool,
        frameCount: asset['frameCount'] as int,
        durationMs: asset['durationMs'] as int,
      ),
    );
  } on Object {
    return null;
  }
}

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
