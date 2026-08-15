part of 'moment_detail_page.dart';

class _MomentCommentComposer extends ConsumerStatefulWidget {
  const _MomentCommentComposer({
    required this.replyTo,
    required this.isSending,
    required this.onCancelReply,
    required this.onClose,
    required this.onSend,
  });

  final MomentComment? replyTo;
  final bool isSending;
  final VoidCallback onCancelReply;
  final VoidCallback onClose;
  final Future<bool> Function(MomentCommentInput input) onSend;

  @override
  ConsumerState<_MomentCommentComposer> createState() =>
      _MomentCommentComposerState();
}

class _MomentCommentComposerState
    extends ConsumerState<_MomentCommentComposer> {
  final _textController = TextEditingController();
  UploadedEditorImage? _image;
  UserSticker? _sticker;
  final Object _uploadTaskId = Object();
  var _closing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
        controller: _textController,
        fieldKey: const Key('moment-comment-input'),
        dockKey: const Key('moment-comment-editor-dock'),
        placeholder: widget.replyTo == null ? '发表评论…' : '写下回复…',
        maxLength: 500,
        autofocus: true,
        onChanged: (_) => setState(() {}),
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
          if (_image != null || _sticker != null) ...[
            _SelectedCommentAsset(
              image: _image,
              sticker: _sticker,
              onRemove: () => setState(() {
                _image = null;
                _sticker = null;
              }),
            ),
            SizedBox(height: tokens.space8),
          ],
          if (uploadState.isBusy) ...[
            LinearProgressIndicator(value: uploadState.progress?.fraction),
            SizedBox(height: tokens.space4),
            Row(
              children: [
                Expanded(child: Text(_uploadProgressLabel(uploadState))),
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
                  : '请求 ID：${failure.requestId}',
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
            key: const Key('moment-comment-close'),
            onPressed: uploading || widget.isSending ? null : _requestClose,
            tooltip: '关闭评论编辑器',
            icon: const WenyouIcon(WenyouIconIds.actionClose),
          ),
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
        submitAction: IconButton.filled(
          key: const Key('moment-comment-send'),
          onPressed: uploading || widget.isSending ? null : _send,
          tooltip: '发送',
          icon: widget.isSending
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const WenyouIcon(WenyouIconIds.actionSend),
        ),
        characterCountText: '${_textController.text.length}/500',
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
    var confirmed = true;
    final hasDraft =
        _textController.text.trim().isNotEmpty ||
        _image != null ||
        _sticker != null;
    if (hasDraft) {
      confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('放弃这条评论？'),
              content: const Text('尚未发送的文字、图片或表情会丢失。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('继续编辑'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('放弃评论'),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!confirmed || !mounted) return;
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
        : await controller.pickAndUpload();
    if (!mounted || _closing || image == null) return;
    setState(() {
      _sticker = null;
      _image = image;
    });
  }

  Future<void> _pickSticker() async {
    final sticker = await showStickerPicker(context);
    if (sticker == null || !mounted) return;
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    setState(() {
      _image = null;
      _sticker = sticker;
    });
  }

  Future<void> _send() async {
    final sent = await widget.onSend(
      MomentCommentInput(
        content: _textController.text,
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
    widget.onClose();
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
    final url = image?.url ?? sticker!.asset.thumbnailUrl;
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          SizedBox.square(
            dimension: 112,
            child: WenyouCachedImage(imageUrl: url, fit: BoxFit.contain),
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

String _uploadProgressLabel(MediaUploadTaskState state) {
  final progress = state.progress;
  return switch (state.phase) {
    MediaUploadTaskPhase.picking => '正在打开相册…',
    MediaUploadTaskPhase.preparing => '正在准备图片…',
    MediaUploadTaskPhase.uploading when progress?.fraction != null =>
      '正在上传 ${(progress!.fraction! * 100).round()}%',
    MediaUploadTaskPhase.uploading => '正在上传图片…',
    MediaUploadTaskPhase.confirming => '正在确认图片…',
    MediaUploadTaskPhase.processing => '图片正在安全处理中…',
    MediaUploadTaskPhase.idle || MediaUploadTaskPhase.failed => '',
  };
}
