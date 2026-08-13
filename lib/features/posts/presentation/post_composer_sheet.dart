import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

Future<PostItem?> showPostComposerSheet({
  required BuildContext context,
  required PostComposerTarget target,
}) {
  return showModalBottomSheet<PostItem>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: false,
    sheetAnimationStyle: AnimationStyle.noAnimation,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (context) => _ExpandablePostComposer(target: target),
  );
}

class _ExpandablePostComposer extends StatefulWidget {
  const _ExpandablePostComposer({required this.target});

  final PostComposerTarget target;

  @override
  State<_ExpandablePostComposer> createState() =>
      _ExpandablePostComposerState();
}

class _ExpandablePostComposerState extends State<_ExpandablePostComposer> {
  static const _minimumExtent = .42;
  static const _maximumExtent = .94;
  late final double _restingExtent;
  late double _extent;

  @override
  void initState() {
    super.initState();
    _restingExtent = switch (widget.target.kind) {
      PostComposerKind.createFloor || PostComposerKind.createReply => .56,
      PostComposerKind.editPost || PostComposerKind.upsertBody => .82,
    };
    _extent = _restingExtent;
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = (constraints.maxHeight - keyboard).clamp(
          240.0,
          constraints.maxHeight,
        );
        return Padding(
          padding: EdgeInsets.only(bottom: keyboard),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              key: const Key('post-composer-viewport'),
              height: availableHeight * _extent,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: PostComposerSheet(
                    target: widget.target,
                    expanded: _extent >= _maximumExtent - .01,
                    onResize: (delta) {
                      setState(() {
                        _extent = (_extent - delta / availableHeight).clamp(
                          _minimumExtent,
                          _maximumExtent,
                        );
                      });
                    },
                    onToggleExpanded: () {
                      setState(() {
                        _extent = _extent >= _maximumExtent - .01
                            ? _restingExtent
                            : _maximumExtent;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PostComposerSheet extends ConsumerStatefulWidget {
  const PostComposerSheet({
    required this.target,
    this.expanded = false,
    this.onResize,
    this.onToggleExpanded,
    super.key,
  });

  final PostComposerTarget target;
  final bool expanded;
  final ValueChanged<double>? onResize;
  final VoidCallback? onToggleExpanded;

  @override
  ConsumerState<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends ConsumerState<PostComposerSheet> {
  late final QuillController _editorController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final WenyouEditorToolbarController _toolbarController =
      WenyouEditorToolbarController();
  bool _applyingDocument = false;
  bool _closing = false;
  bool _preparingClose = false;
  int _scheduledRevision = -1;
  String? _codecFailure;
  List<MarkdownCodecIssue> _issues = const [];
  final Object _uploadTaskId = Object();

  bool get _uploading =>
      ref.read(mediaUploadTaskControllerProvider(_uploadTaskId)).isBusy;

  @override
  void initState() {
    super.initState();
    final decoded = MarkdownDeltaCodec.decode(widget.target.initialContent);
    _issues = decoded.issues;
    final document = Document.fromDelta(decoded.delta);
    _editorController = QuillController(
      document: document,
      selection: TextSelection.collapsed(offset: document.length - 1),
    )..addListener(_onDocumentChanged);
    _focusNode.addListener(_onEditorFocusChanged);
  }

  @override
  void dispose() {
    _editorController
      ..removeListener(_onDocumentChanged)
      ..dispose();
    _focusNode
      ..removeListener(_onEditorFocusChanged)
      ..dispose();
    _scrollController.dispose();
    _toolbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = postComposerControllerProvider(widget.target);
    final state = ref.watch(provider);
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    _scheduleDocumentSync(state);
    final tokens = context.wenyouTokens;
    final locked = state.isSubmitting || uploadState.isBusy;
    _editorController.readOnly = locked;
    return PopScope<Object?>(
      canPop: _closing && !_toolbarController.trayOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_toolbarController.closeTray()) return;
        unawaited(_requestClose());
      },
      child: Column(
        key: const Key('post-composer-sheet'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            key: const Key('post-composer-header'),
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: widget.onResize == null
                ? null
                : (details) => widget.onResize!(details.delta.dy),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: tokens.space12,
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: tokens.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: tokens.minimumTouchTarget,
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('post-composer-close'),
                        tooltip: '关闭编辑器',
                        onPressed: locked ? null : _requestClose,
                        icon: const Icon(Icons.close_rounded),
                      ),
                      SizedBox(width: tokens.space4),
                      Expanded(
                        child: Text(
                          widget.target.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        key: const Key('post-composer-expand'),
                        tooltip: widget.expanded ? '恢复半屏' : '展开编辑器',
                        onPressed: widget.onToggleExpanded,
                        icon: Icon(
                          widget.expanded
                              ? Icons.close_fullscreen_rounded
                              : Icons.open_in_full_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (state.failure != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                key: const Key('post-composer-failure'),
                message: state.failure!.userMessage,
                detail: _requestDetail(state.failure),
                tone: WenyouStatusTone.error,
                action: state.conflict == null
                    ? null
                    : TextButton.icon(
                        key: const Key('post-composer-retry-conflict'),
                        onPressed: locked ? null : _confirmConflictRetry,
                        icon: const Icon(Icons.sync_rounded),
                        label: const Text('用当前正文覆盖最新版'),
                      ),
              ),
            ),
          if (state.hasAmbiguousCreate)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: const WenyouStatusBanner(
                message: '上次发布结果尚未确认。',
                detail: '再次提交会先用原请求确认创建结果；若正文已继续修改，再以版本更新保存当前内容。',
              ),
            ),
          if (_codecFailure != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                message: '当前格式组合暂时不能安全保存。',
                detail: _codecFailure,
                tone: WenyouStatusTone.error,
              ),
            ),
          if (_issues.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                message: '正文含有 ${_issues.length} 个兼容节点。',
                detail: '这些节点会锁定显示并原样保存。',
              ),
            ),
          if (uploadState.failure != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                message: uploadState.failure!.userMessage,
                detail: _uploadRequestDetail(uploadState.failure),
                tone: WenyouStatusTone.error,
                action: uploadState.failure!.canRetry
                    ? TextButton(
                        key: const Key('post-composer-retry-upload'),
                        onPressed: _retryImageUpload,
                        child: const Text('重试上传'),
                      )
                    : null,
              ),
            ),
          if (uploadState.isBusy)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: _UploadStatus(
                progress: uploadState.progress,
                onCancel: () => ref
                    .read(
                      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
                    )
                    .cancel(),
              ),
            ),
          Expanded(
            child: ColoredBox(
              key: const Key('post-composer-canvas'),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Semantics(
                          textField: true,
                          label: widget.target.label,
                          child: QuillEditor(
                            key: const Key('post-composer-body'),
                            controller: _editorController,
                            focusNode: _focusNode,
                            scrollController: _scrollController,
                            config: QuillEditorConfig(
                              scrollable: true,
                              expands: true,
                              autoFocus: true,
                              padding: EdgeInsets.fromLTRB(
                                tokens.space16,
                                tokens.space16,
                                tokens.space16,
                                tokens.space16,
                              ),
                              placeholder: _placeholder(widget.target.kind),
                              customStyles: wenyouEditorTextStyles(context),
                              embedBuilders: wenyouEditorEmbedBuilders(),
                            ),
                          ),
                        ),
                        MentionSuggestions(
                          controller: _editorController,
                          focusNode: _focusNode,
                          threadId: widget.target.threadId,
                          enabled: !locked && _codecFailure == null,
                        ),
                      ],
                    ),
                  ),
                  WenyouComposerDock(
                    key: const Key('post-composer-toolbar'),
                    controller: _editorController,
                    surface: WenyouComposerSurface.expandableSheet,
                    profile: WenyouComposerProfile.richMarkdown,
                    enabled: !locked && _codecFailure == null,
                    editorFocusNode: _focusNode,
                    onInsertImage: _insertImage,
                    onInsertSticker: ref.watch(stickersEnabledProvider)
                        ? _insertSticker
                        : null,
                    onSaveDraft: _openContentDrafts,
                    onSubmit: _submit,
                    isSubmitting: state.isSubmitting,
                    submitLabel: _submitLabel(widget.target.kind),
                    characterCount: _editorController.document
                        .toPlainText()
                        .trim()
                        .length,
                    characterLimit: 10000,
                    toolbarController: _toolbarController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onEditorFocusChanged() {
    if (mounted) setState(() {});
  }

  void _scheduleDocumentSync(PostComposerState state) {
    if (state.documentRevision == _scheduledRevision) return;
    _scheduledRevision = state.documentRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyingDocument = true;
      try {
        final decoded = MarkdownDeltaCodec.decode(state.content);
        _issues = decoded.issues;
        final document = Document.fromDelta(decoded.delta);
        _editorController.document = document;
        _editorController.updateSelection(
          TextSelection.collapsed(offset: document.length - 1),
          ChangeSource.local,
        );
        _codecFailure = null;
      } on Object catch (error) {
        _codecFailure = '恢复正文时发生错误：$error';
      } finally {
        _applyingDocument = false;
      }
      setState(() {});
    });
  }

  void _onDocumentChanged() {
    if (_applyingDocument) return;
    try {
      final markdown = MarkdownDeltaCodec.encode(
        _editorController.document.toDelta(),
      );
      ref
          .read(postComposerControllerProvider(widget.target).notifier)
          .updateContent(markdown);
      if (_codecFailure != null && mounted) {
        setState(() => _codecFailure = null);
      }
    } on MarkdownCodecException catch (error) {
      if (mounted) setState(() => _codecFailure = error.message);
    }
  }

  Future<void> _submit() async {
    final result = await ref
        .read(postComposerControllerProvider(widget.target).notifier)
        .submit();
    if (!mounted || result == null) return;
    setState(() => _closing = true);
    Navigator.pop(context, result);
  }

  Future<void> _confirmConflictRetry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('覆盖云端最新版？'),
        content: const Text('内容已被其他设备修改。继续会用当前编辑器全文覆盖刚读取的最新版。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('保留云端'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('仍然覆盖'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref
        .read(postComposerControllerProvider(widget.target).notifier)
        .retryConflict();
    if (!mounted || result == null) return;
    setState(() => _closing = true);
    Navigator.pop(context, result);
  }

  Future<void> _requestClose() async {
    if (_closing || _preparingClose) return;
    _preparingClose = true;
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
    final current = ref.read(postComposerControllerProvider(widget.target));
    var confirmed = true;
    if (current.content != widget.target.initialContent &&
        current.content.trim().isNotEmpty) {
      confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('放弃当前修改？'),
              content: const Text('尚未提交的正文会丢失；可先使用工具栏“正文草稿”保存到云端槽位。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('继续编辑'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('放弃修改'),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!confirmed || !mounted) {
      _preparingClose = false;
      return;
    }
    setState(() => _closing = true);
    Navigator.pop(context);
  }

  Future<void> _openContentDrafts() async {
    final state = ref.read(postComposerControllerProvider(widget.target));
    await showContentDraftsSheet(
      context: context,
      currentContent: state.content,
      onRestore: (content) => ref
          .read(postComposerControllerProvider(widget.target).notifier)
          .restoreContent(content),
    );
  }

  Future<void> _insertImage() async {
    await _runImageUpload(retry: false);
  }

  Future<void> _retryImageUpload() async {
    await _runImageUpload(retry: true);
  }

  Future<void> _runImageUpload({required bool retry}) async {
    if (_uploading) return;
    final controller = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    final uploaded = retry
        ? await controller.retryUpload()
        : await controller.pickAndUpload();
    if (!mounted || _preparingClose || _closing || uploaded == null) return;
    _insertBlockImage(uploaded);
  }

  void _insertBlockImage(UploadedEditorImage image) {
    var selection = _editorController.selection;
    if (!selection.isCollapsed) {
      _editorController.replaceText(
        selection.start,
        selection.end - selection.start,
        '',
        TextSelection.collapsed(offset: selection.start),
      );
      selection = TextSelection.collapsed(offset: selection.start);
    }
    _editorController.replaceText(
      selection.start,
      0,
      Embeddable(MarkdownDeltaCodec.imageEmbed, {
        'version': 1,
        'url': image.url,
        'alt': '图片',
        'title': null,
      }),
      TextSelection.collapsed(offset: selection.start + 1),
    );
    _editorController.replaceText(
      selection.start + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: selection.start + 2),
    );
  }

  Future<void> _insertSticker() async {
    final sticker = await showStickerPicker(context);
    if (!mounted || sticker == null) return;
    var selection = _editorController.selection;
    if (!selection.isCollapsed) {
      _editorController.replaceText(
        selection.start,
        selection.end - selection.start,
        '',
        TextSelection.collapsed(offset: selection.start),
      );
      selection = TextSelection.collapsed(offset: selection.start);
    }
    _editorController.replaceText(
      selection.start,
      0,
      Embeddable(MarkdownDeltaCodec.stickerEmbed, {
        'version': 1,
        'assetId': sticker.asset.id,
        'url': sticker.asset.url,
        'alt': '表情',
      }),
      TextSelection.collapsed(offset: selection.start + 1),
    );
  }
}

class _UploadStatus extends StatelessWidget {
  const _UploadStatus({required this.progress, required this.onCancel});

  final MediaUploadProgress? progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final label = switch (progress?.stage) {
      MediaUploadStage.preparing => '正在准备图片…',
      MediaUploadStage.uploading => '正在上传图片…',
      MediaUploadStage.confirming => '正在确认上传…',
      MediaUploadStage.processing => '图片处理中…',
      null => '正在准备图片…',
    };
    return WenyouStatusBanner(
      message: label,
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: progress?.fraction),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: onCancel, child: const Text('取消上传')),
          ),
        ],
      ),
    );
  }
}

String _placeholder(PostComposerKind kind) => switch (kind) {
  PostComposerKind.createFloor => '输入楼层正文…',
  PostComposerKind.createReply => '输入回复内容…',
  PostComposerKind.editPost => '编辑正文内容…',
  PostComposerKind.upsertBody => '输入子贴正文…',
};

String _submitLabel(PostComposerKind kind) => switch (kind) {
  PostComposerKind.createFloor => '发表楼层',
  PostComposerKind.createReply => '回复',
  PostComposerKind.editPost || PostComposerKind.upsertBody => '保存修改',
};

String? _requestDetail(ApiFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '请求 ID：$requestId';
}

String? _uploadRequestDetail(MediaUploadFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '请求 ID：$requestId';
}
