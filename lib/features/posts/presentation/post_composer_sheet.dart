import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

Future<PostItem?> showPostComposerSheet({
  required BuildContext context,
  required PostComposerTarget target,
  String? initialDraft,
  ValueChanged<String>? onDraftChanged,
}) {
  final effectiveTarget = initialDraft == null
      ? target
      : _targetWithInitialContent(target, initialDraft);
  return showModalBottomSheet<PostItem>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: false,
    useSafeArea: false,
    sheetAnimationStyle: AnimationStyle.noAnimation,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (context) => _ExpandablePostComposer(
      target: effectiveTarget,
      onDraftChanged: onDraftChanged,
    ),
  );
}

String postComposerDraftKey(PostComposerTarget target) => [
  target.kind.name,
  target.threadId,
  target.subthreadId,
  target.postId ?? '',
  target.parentPostId ?? '',
  target.replyToPostId ?? '',
].join(':');

PostComposerTarget _targetWithInitialContent(
  PostComposerTarget target,
  String content,
) => (
  kind: target.kind,
  threadId: target.threadId,
  subthreadId: target.subthreadId,
  postId: target.postId,
  parentPostId: target.parentPostId,
  replyToPostId: target.replyToPostId,
  version: target.version,
  initialContent: content,
  label: target.label,
);

class _ExpandablePostComposer extends StatefulWidget {
  const _ExpandablePostComposer({required this.target, this.onDraftChanged});

  final PostComposerTarget target;
  final ValueChanged<String>? onDraftChanged;

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
                    onDraftChanged: widget.onDraftChanged,
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
    this.onDraftChanged,
    this.expanded = false,
    this.onResize,
    this.onToggleExpanded,
    super.key,
  });

  final PostComposerTarget target;
  final ValueChanged<String>? onDraftChanged;
  final bool expanded;
  final ValueChanged<double>? onResize;
  final VoidCallback? onToggleExpanded;

  @override
  ConsumerState<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends ConsumerState<PostComposerSheet> {
  late final RichEditorSession _editorSession;
  final WenyouEditorToolbarController _toolbarController =
      WenyouEditorToolbarController();
  bool _closing = false;
  bool _preparingClose = false;
  final Object _uploadTaskId = Object();

  bool get _uploading =>
      ref.read(mediaUploadTaskControllerProvider(_uploadTaskId)).isBusy;

  @override
  void initState() {
    super.initState();
    _editorSession = RichEditorSession(
      initialMarkdown: widget.target.initialContent,
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: (markdown) {
        ref
            .read(postComposerControllerProvider(widget.target).notifier)
            .updateContent(markdown);
        widget.onDraftChanged?.call(markdown);
      },
    )..addListener(_onEditorSessionChanged);
  }

  @override
  void dispose() {
    _editorSession
      ..removeListener(_onEditorSessionChanged)
      ..dispose();
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
    _editorSession.scheduleExternalMarkdown(
      markdown: state.content,
      revision: state.documentRevision,
      selection: RichEditorSelectionPlacement.end,
    );
    final tokens = context.wenyouTokens;
    final locked = state.isSubmitting || uploadState.isBusy;
    _editorSession.readOnly = locked;
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
                        icon: const WenyouIcon(WenyouIconIds.actionClose),
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
                        icon: WenyouIcon(
                          widget.expanded
                              ? WenyouIconIds.actionExitFullscreen
                              : WenyouIconIds.actionFullscreen,
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
                        icon: const WenyouIcon(WenyouIconIds.actionSync),
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
                message: '上次发布失败。',
                detail: '再次提交会先确认上次结果，不会重复发布；之后再保存本次修改。',
              ),
            ),
          if (_editorSession.codecFailure != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                message: '当前格式组合暂时不能安全保存。',
                detail: _editorSession.codecFailure,
                tone: WenyouStatusTone.error,
              ),
            ),
          if (_editorSession.issues.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                message: '正文中有 ${_editorSession.issues.length} 处内容暂时无法编辑。',
                detail: '这些内容会原样保留。',
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
                            controller: _editorSession.controller,
                            focusNode: _editorSession.focusNode,
                            scrollController: _editorSession.scrollController,
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
                          controller: _editorSession.controller,
                          focusNode: _editorSession.focusNode,
                          threadId: widget.target.threadId,
                          enabled:
                              !locked && _editorSession.codecFailure == null,
                        ),
                      ],
                    ),
                  ),
                  WenyouComposerDock(
                    key: const Key('post-composer-toolbar'),
                    controller: _editorSession.controller,
                    surface: WenyouComposerSurface.expandableSheet,
                    enabled: !locked && _editorSession.codecFailure == null,
                    editorFocusNode: _editorSession.focusNode,
                    onInsertImage: _insertImage,
                    onInsertSticker: ref.watch(stickersEnabledProvider)
                        ? _insertSticker
                        : null,
                    onSaveDraft: _openContentDrafts,
                    onSubmit: _submit,
                    isSubmitting: state.isSubmitting,
                    submitLabel: _submitLabel(widget.target.kind),
                    characterCount: _editorSession.characterCount,
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

  void _onEditorSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_editorSession.flush()) return;
    final result = await ref
        .read(postComposerControllerProvider(widget.target).notifier)
        .submit();
    if (!mounted || result == null) return;
    widget.onDraftChanged?.call('');
    setState(() => _closing = true);
    Navigator.pop(context, result);
  }

  Future<void> _confirmConflictRetry() async {
    if (!_editorSession.flush()) return;
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
    if (!_editorSession.flush()) {
      _preparingClose = false;
      return;
    }
    final current = ref.read(postComposerControllerProvider(widget.target));
    widget.onDraftChanged?.call(current.content);
    if (!mounted) return;
    setState(() => _closing = true);
    Navigator.pop(context);
  }

  Future<void> _openContentDrafts() async {
    if (!_editorSession.flush()) return;
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
    _editorSession.insertBlockImage(url: image.url);
  }

  Future<void> _insertSticker() async {
    final sticker = await showStickerPicker(context);
    if (!mounted || sticker == null) return;
    _editorSession.insertSticker(
      assetId: sticker.asset.id,
      url: sticker.asset.url,
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
  return requestId == null ? null : '问题编号：$requestId';
}

String? _uploadRequestDetail(MediaUploadFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '问题编号：$requestId';
}
