import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

Future<PostItem?> showPostComposerSheet({
  required BuildContext context,
  required PostComposerTarget target,
}) {
  return showModalBottomSheet<PostItem>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.94,
      child: PostComposerSheet(target: target),
    ),
  );
}

class PostComposerSheet extends ConsumerStatefulWidget {
  const PostComposerSheet({required this.target, super.key});

  final PostComposerTarget target;

  @override
  ConsumerState<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends ConsumerState<PostComposerSheet> {
  late final QuillController _editorController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _applyingDocument = false;
  bool _closing = false;
  int _scheduledRevision = -1;
  String? _codecFailure;
  List<MarkdownCodecIssue> _issues = const [];
  CancelToken? _uploadCancelToken;
  MediaUploadProgress? _uploadProgress;
  ApiFailure? _uploadFailure;

  bool get _uploading => _uploadCancelToken != null;

  @override
  void initState() {
    super.initState();
    final decoded = MarkdownDeltaCodec.decode(widget.target.initialContent);
    _issues = decoded.issues;
    _editorController = QuillController(
      document: Document.fromDelta(decoded.delta),
      selection: const TextSelection.collapsed(offset: 0),
    )..addListener(_onDocumentChanged);
  }

  @override
  void dispose() {
    _uploadCancelToken?.cancel('post composer disposed');
    _editorController
      ..removeListener(_onDocumentChanged)
      ..dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = postComposerControllerProvider(widget.target);
    final state = ref.watch(provider);
    _scheduleDocumentSync(state);
    final tokens = context.wenyouTokens;
    final locked = state.isSubmitting || _uploading;
    _editorController.readOnly = locked;
    return PopScope<Object?>(
      canPop: _closing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestClose());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              tokens.space12,
              tokens.space8,
              tokens.space12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.target.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: tokens.space4),
                      Text(
                        _subtitle(widget.target.kind),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('post-composer-close'),
                  tooltip: '关闭编辑器',
                  onPressed: locked ? null : _requestClose,
                  icon: const Icon(Icons.close_rounded),
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
          if (_uploadFailure != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                message: _uploadFailure!.userMessage,
                detail: _requestDetail(_uploadFailure),
                tone: WenyouStatusTone.error,
              ),
            ),
          if (_uploading)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: _UploadStatus(
                progress: _uploadProgress,
                onCancel: () =>
                    _uploadCancelToken?.cancel('user cancelled image upload'),
              ),
            ),
          SizedBox(height: tokens.space12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space12),
              child: Material(
                color: tokens.panel,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius20),
                  side: BorderSide(color: tokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WenyouEditorToolbar(
                      controller: _editorController,
                      enabled: !locked && _codecFailure == null,
                      onInsertImage: _insertImage,
                      onSaveDraft: _openContentDrafts,
                    ),
                    MentionSuggestions(
                      controller: _editorController,
                      focusNode: _focusNode,
                      threadId: widget.target.threadId,
                      enabled: !locked && _codecFailure == null,
                    ),
                    Expanded(
                      child: Semantics(
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
                            padding: EdgeInsets.all(tokens.space16),
                            placeholder: _placeholder(widget.target.kind),
                            embedBuilders: wenyouEditorEmbedBuilders(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.space12),
            child: WenyouAsyncPrimaryButton(
              key: const Key('post-composer-submit'),
              label: _submitLabel(widget.target.kind),
              loadingLabel: '正在提交',
              icon:
                  widget.target.kind == PostComposerKind.editPost ||
                      widget.target.kind == PostComposerKind.upsertBody
                  ? Icons.check_rounded
                  : Icons.send_rounded,
              isLoading: state.isSubmitting,
              onPressed: locked || _codecFailure != null ? null : _submit,
            ),
          ),
        ],
      ),
    );
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
        _editorController.document = Document.fromDelta(decoded.delta);
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
    if (_closing) return;
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
    if (!confirmed || !mounted) return;
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
    if (_uploading) return;
    setState(() {
      _uploadFailure = null;
      _uploadProgress = const MediaUploadProgress(
        stage: MediaUploadStage.preparing,
      );
    });
    try {
      final input = await ref.read(editorImagePickerProvider).pickFromGallery();
      if (input == null || !mounted) {
        setState(() => _uploadProgress = null);
        return;
      }
      final alt = await _askImageAlt();
      if (alt == null || !mounted) {
        setState(() => _uploadProgress = null);
        return;
      }
      final cancelToken = CancelToken();
      setState(() => _uploadCancelToken = cancelToken);
      final uploaded = await ref
          .read(mediaUploadRepositoryProvider)
          .uploadImage(
            input,
            cancelToken: cancelToken,
            onProgress: (progress) {
              if (mounted) setState(() => _uploadProgress = progress);
            },
          );
      if (!mounted) return;
      _insertBlockImage(uploaded, alt);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _uploadFailure = error is ApiFailure
            ? error
            : ApiFailure(userMessage: '图片没有插入成功，请重试。', cause: error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _uploadCancelToken = null;
          _uploadProgress = null;
        });
      }
    }
  }

  Future<String?> _askImageAlt() async {
    var alt = '帖子插图';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('描述这张图片'),
        content: TextFormField(
          initialValue: alt,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(labelText: '替代文字'),
          onChanged: (value) => alt = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, alt.trim()),
            child: const Text('继续上传'),
          ),
        ],
      ),
    );
  }

  void _insertBlockImage(UploadedEditorImage image, String alt) {
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
        'alt': alt,
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

String _subtitle(PostComposerKind kind) => switch (kind) {
  PostComposerKind.createFloor => '发表到当前子贴，成功后成为新楼层。',
  PostComposerKind.createReply => '回复会平级挂在当前主楼层下。',
  PostComposerKind.editPost => '保存时携带当前版本，冲突不会静默覆盖。',
  PostComposerKind.upsertBody => '只有楼主和协作者可以修改子贴正文。',
};

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
