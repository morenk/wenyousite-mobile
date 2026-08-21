import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_composer_support.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_media.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_notice.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

export 'direct_message_avatar.dart';

typedef DirectMessageReportCallback =
    Future<void> Function(BuildContext context, String messageId);

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
  var _restoreFocusAfterSticker = false;
  var _selectionBeforeSticker = const TextSelection.collapsed(offset: 0);

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
    final mediaQuery = MediaQuery.of(context);
    final stickerPopoverSize = Size(
      (mediaQuery.size.width - tokens.space16).clamp(280.0, 360.0),
      (mediaQuery.size.height -
              mediaQuery.viewPadding.top -
              mediaQuery.viewInsets.bottom -
              112)
          .clamp(220.0, 320.0),
    );
    final supporting = <Widget>[
      if (widget.requestHint != null) ...[
        DirectMessageComposerStatusLine(
          icon: WenyouIconIds.statusInfo,
          message: widget.requestHint!,
        ),
        SizedBox(height: tokens.space8),
      ],
      if (_uploadedImage != null) ...[
        DirectMessageImagePreview(
          image: _uploadedImage!,
          onRemove: _disabled ? null : _removeImage,
        ),
        SizedBox(height: tokens.space8),
      ],
      if (uploadState.isBusy) ...[
        DirectMessageUploadProgress(
          state: uploadState,
          onCancel: () => ref
              .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
              .cancel(),
        ),
        SizedBox(height: tokens.space8),
      ],
      if (uploadState.failure case final uploadFailure?) ...[
        DirectMessageComposerStatusLine(
          key: const Key('direct-message-composer-upload-failure'),
          icon: WenyouIconIds.statusError,
          message: uploadFailure.requestId == null
              ? uploadFailure.userMessage
              : '${uploadFailure.userMessage} · 问题编号：${uploadFailure.requestId}',
          error: true,
          onRetry: uploadFailure.canRetry ? _retryImageUpload : null,
          onDismiss: _abandonImageUpload,
          retryKey: const Key('direct-message-composer-retry-upload'),
          dismissKey: const Key('direct-message-composer-abandon-upload'),
        ),
        SizedBox(height: tokens.space8),
      ],
      if (failure != null) ...[
        DirectMessageComposerStatusLine(
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
          WenyouAnchoredPopover(
            size: stickerPopoverSize,
            placement: WenyouPopoverPlacement.above,
            alignment: WenyouPopoverAlignment.end,
            semanticLabel: '收藏表情选择器',
            anchorBuilder: (context, handle) => IconButton(
              key: const Key('direct-message-composer-sticker'),
              onPressed: _disabled
                  ? null
                  : () {
                      _restoreFocusAfterSticker = _focusNode.hasFocus;
                      _selectionBeforeSticker = _controller.selection;
                      handle.toggle();
                    },
              tooltip: handle.isOpen ? '收起表情' : '表情',
              icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
            ),
            popoverBuilder: (context, close) => StickerPickerPanel(
              compact: true,
              onSelected: (sticker) {
                close();
                unawaited(_sendSticker(sticker));
              },
              onManage: () {
                close();
                if (_restoreFocusAfterSticker) {
                  _restoreFocus(_selectionBeforeSticker);
                }
                context.pushNamed('me-stickers');
              },
            ),
          ),
      ],
      submitAction: WenyouComposerSubmitButton(
        key: const Key('direct-message-composer-submit'),
        enabled: !_disabled && !uploadLocked && _hasPayload,
        loading: _busy,
        label: _submitLabel(uploadState),
        onPressed: () => _submit(),
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
        : await pickCropAndUploadEditorImage(
            context,
            ref,
            uploadTaskId: _uploadTaskId,
            title: '裁剪私聊图片',
          );
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

  Future<void> _sendSticker(UserSticker sticker) async {
    final shouldRestoreFocus = _restoreFocusAfterSticker;
    final selection = _selectionBeforeSticker;
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

enum _DirectMessageAction { copy, saveSticker, recall, report, retry, abandon }

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
    this.onReport,
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
  final DirectMessageReportCallback? onReport;

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
    final canReport =
        widget.onReport != null &&
        !widget.mine &&
        !widget.message.isRecalled &&
        widget.message.deliveryState == DirectMessageDeliveryState.sent;
    final semanticActions = <CustomSemanticsAction, VoidCallback>{
      if (!widget.message.isRecalled && widget.message.content != null)
        const CustomSemanticsAction(label: '复制消息'): _copyMessage,
      if (!widget.message.isRecalled && canSaveSticker && !stickerBusy)
        const CustomSemanticsAction(label: '收藏表情'): _saveSticker,
      if (!widget.message.isRecalled && widget.canRecall && !widget.isRecalling)
        const CustomSemanticsAction(label: '撤回消息'): widget.onRecall,
      if (canReport) const CustomSemanticsAction(label: '举报消息'): _reportMessage,
      if (failed && widget.onRetry != null)
        const CustomSemanticsAction(label: '重试发送'): widget.onRetry!,
      if (failed && widget.onAbandon != null)
        const CustomSemanticsAction(label: '删除失败消息'): widget.onAbandon!,
    };
    final popoverActions = <WenyouPopoverAction<_DirectMessageAction>>[
      if (!widget.message.isRecalled && widget.message.content != null)
        WenyouPopoverAction(
          value: _DirectMessageAction.copy,
          icon: WenyouIconIds.actionCopy,
          label: '复制',
          semanticsLabel: '复制消息',
          key: ValueKey('direct-message-copy-${widget.message.id}'),
        ),
      if (!widget.message.isRecalled && canSaveSticker)
        WenyouPopoverAction(
          value: _DirectMessageAction.saveSticker,
          icon: WenyouIconIds.actionAddReaction,
          label: stickerBusy ? '处理中' : '收藏',
          semanticsLabel: '收藏表情',
          enabled: !stickerBusy,
          loading: stickerBusy,
          key: ValueKey('direct-message-save-sticker-${widget.message.id}'),
        ),
      if (!widget.message.isRecalled && widget.canRecall)
        WenyouPopoverAction(
          value: _DirectMessageAction.recall,
          icon: WenyouIconIds.actionUndo,
          label: widget.isRecalling ? '撤回中' : '撤回',
          semanticsLabel: '撤回消息',
          enabled: !widget.isRecalling,
          loading: widget.isRecalling,
          key: ValueKey('direct-message-recall-${widget.message.id}'),
        ),
      if (canReport)
        WenyouPopoverAction(
          value: _DirectMessageAction.report,
          icon: WenyouIconIds.actionReport,
          label: '举报',
          semanticsLabel: '举报消息',
          tone: WenyouPopoverActionTone.destructive,
          key: ValueKey('direct-message-report-${widget.message.id}'),
        ),
      if (failed && widget.onRetry != null)
        WenyouPopoverAction(
          value: _DirectMessageAction.retry,
          icon: WenyouIconIds.actionRefresh,
          label: '重试',
          semanticsLabel: '重新发送消息',
          key: ValueKey('direct-message-retry-${widget.message.id}'),
        ),
      if (failed && widget.onAbandon != null)
        WenyouPopoverAction(
          value: _DirectMessageAction.abandon,
          icon: WenyouIconIds.actionDelete,
          label: '删除',
          semanticsLabel: '删除失败消息',
          tone: WenyouPopoverActionTone.destructive,
          key: ValueKey('direct-message-abandon-${widget.message.id}'),
        ),
    ];
    final maxWidth = MediaQuery.sizeOf(context).width >= 600
        ? 420.0
        : widget.mine && (sending || failed)
        ? MediaQuery.sizeOf(context).width * 0.68
        : MediaQuery.sizeOf(context).width * 0.8;
    Widget buildBubble(VoidCallback? openActions) {
      return Semantics(
        onLongPress: openActions,
        onLongPressHint: openActions == null ? null : '打开消息操作',
        customSemanticsActions: semanticActions,
        child: Align(
          alignment: widget.mine ? Alignment.centerRight : Alignment.centerLeft,
          heightFactor: 1,
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
                    onPressed: openActions,
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
                  onLongPress: openActions,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: pureSticker
                          ? Colors.transparent
                          : widget.mine
                          ? tokens.brandSurface
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
                                    ? tokens.onBrandSurface.withValues(
                                        alpha: 0.82,
                                      )
                                    : tokens.mutedText,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.message.content != null)
                                  Text(
                                    widget.message.content!,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: widget.mine
                                              ? tokens.onBrandSurface
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
                                    DirectMessageImage(media: media),
                                ],
                                if (media == null &&
                                    widget.message.content == null &&
                                    widget.message.localDraft != null)
                                  DirectMessageOptimisticMediaPlaceholder(
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

    if (popoverActions.isEmpty) return buildBubble(null);
    return WenyouAnchoredActionBubble<_DirectMessageAction>(
      actions: popoverActions,
      placement: WenyouPopoverPlacement.above,
      alignment: widget.mine
          ? WenyouPopoverAlignment.end
          : WenyouPopoverAlignment.start,
      semanticLabel: '消息操作',
      onSelected: _handleAction,
      anchorBuilder: (context, handle) => buildBubble(handle.open),
    );
  }

  void _handleAction(_DirectMessageAction action) {
    switch (action) {
      case _DirectMessageAction.copy:
        unawaited(_copyMessage());
      case _DirectMessageAction.saveSticker:
        unawaited(_saveSticker());
      case _DirectMessageAction.recall:
        widget.onRecall();
      case _DirectMessageAction.report:
        unawaited(_reportMessage());
      case _DirectMessageAction.retry:
        widget.onRetry?.call();
      case _DirectMessageAction.abandon:
        widget.onAbandon?.call();
    }
  }

  Future<void> _copyMessage() async {
    final content = widget.message.content;
    if (content == null) return;
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    showDirectMessageNotice(context, '已复制');
  }

  Future<void> _reportMessage() async {
    final onReport = widget.onReport;
    if (onReport == null) return;
    await onReport(context, widget.message.id);
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
    showDirectMessageNotice(context, message);
  }
}

ApiFailure _asFailure(Object error, String fallback) {
  return mapApplicationFailure(error, fallback);
}
