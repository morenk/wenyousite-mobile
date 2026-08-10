import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/editor/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class ThreadComposePage extends ConsumerStatefulWidget {
  const ThreadComposePage({super.key});

  @override
  ConsumerState<ThreadComposePage> createState() => _ThreadComposePageState();
}

class _ThreadComposePageState extends ConsumerState<ThreadComposePage>
    with WidgetsBindingObserver {
  late final QuillController _editorController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool _applyingDocument = false;
  bool _allowPop = false;
  bool _preparingPop = false;
  int _scheduledDocumentRevision = -1;
  List<MarkdownCodecIssue> _documentIssues = const [];
  String? _codecFailure;
  MediaUploadProgress? _uploadProgress;
  ApiFailure? _uploadFailure;
  CancelToken? _uploadCancelToken;

  bool get _uploading => _uploadCancelToken != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final decoded = MarkdownDeltaCodec.decode('');
    _editorController = QuillController(
      document: Document.fromDelta(decoded.delta),
      selection: const TextSelection.collapsed(offset: 0),
    )..addListener(_onDocumentChanged);
    _titleController.addListener(_onTitleChanged);
    _tagsController.addListener(_onTagsChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_flushSnapshot());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uploadCancelToken?.cancel('editor disposed');
    _editorController
      ..removeListener(_onDocumentChanged)
      ..dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _titleController
      ..removeListener(_onTitleChanged)
      ..dispose();
    _tagsController
      ..removeListener(_onTagsChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadComposeControllerProvider);
    _scheduleDocumentSync(state);
    final locked = state.isSubmitting || _uploading;
    _editorController.readOnly = locked;

    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_saveBeforePop(result));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('创建主题')),
        body: switch (state.phase) {
          ThreadComposePhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          ThreadComposePhase.failed => _LoadFailure(
            failure: state.failure,
            onRetry: () =>
                ref.read(threadComposeControllerProvider.notifier).load(),
          ),
          ThreadComposePhase.ready ||
          ThreadComposePhase.published => _buildEditor(context, state, locked),
        },
      ),
    );
  }

  Widget _buildEditor(
    BuildContext context,
    ThreadComposeState state,
    bool locked,
  ) {
    final tokens = context.wenyouTokens;
    final enabled = !locked && _codecFailure == null;
    return WenyouPageBody(
      maxWidth: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(
            title: '写下这次想聊的事',
            subtitle: '内容会先保存在本机；主动保存时才同步为服务端草稿。',
          ),
          SizedBox(height: tokens.space16),
          if (state.restoredFromLocal) ...[
            const WenyouStatusBanner(
              message: '已恢复上次未完成的本地内容。',
              tone: WenyouStatusTone.accent,
            ),
            SizedBox(height: tokens.space12),
          ],
          if (state.bootstrapLoading) ...[
            const WenyouStatusBanner(message: '正在同步分类与账号发布状态…'),
            SizedBox(height: tokens.space12),
          ],
          if (state.bootstrapFailure != null) ...[
            WenyouStatusBanner(
              message: state.bootstrapFailure!.userMessage,
              detail: _requestDetail(state.bootstrapFailure),
              tone: WenyouStatusTone.error,
              action: TextButton(
                onPressed: state.bootstrapLoading
                    ? null
                    : () => ref
                          .read(threadComposeControllerProvider.notifier)
                          .refreshBootstrap(),
                child: const Text('重新同步'),
              ),
            ),
            SizedBox(height: tokens.space12),
          ],
          if (state.emailVerified == false) ...[
            WenyouStatusBanner(
              message: '邮箱尚未验证，仍可编辑和保存草稿，但暂时不能发布。',
              tone: WenyouStatusTone.error,
              action: TextButton(
                key: const Key('compose-verify-email'),
                onPressed: state.isSubmitting ? null : _openEmailVerification,
                child: const Text('现在验证'),
              ),
            ),
            SizedBox(height: tokens.space12),
          ],
          if (_documentIssues.isNotEmpty) ...[
            WenyouStatusBanner(
              message: '正文含有 ${_documentIssues.length} 个兼容节点。',
              detail: '这些内容会锁定显示并原样保存，避免旧协议数据丢失。',
            ),
            SizedBox(height: tokens.space12),
          ],
          if (_codecFailure != null) ...[
            WenyouStatusBanner(
              message: '当前格式组合暂时不能安全保存。',
              detail: _codecFailure,
              tone: WenyouStatusTone.error,
            ),
            SizedBox(height: tokens.space12),
          ],
          if (state.actionFailure != null) ...[
            WenyouStatusBanner(
              key: const Key('compose-action-failure'),
              message: state.actionFailure!.userMessage,
              detail: _requestDetail(state.actionFailure),
              tone: WenyouStatusTone.error,
              action: state.actionFailure!.businessCode == 40107
                  ? TextButton(
                      key: const Key('compose-action-verify-email'),
                      onPressed: state.isSubmitting
                          ? null
                          : _openEmailVerification,
                      child: const Text('现在验证'),
                    )
                  : null,
            ),
            SizedBox(height: tokens.space12),
          ],
          if (state.successMessage != null) ...[
            WenyouStatusBanner(
              message: state.successMessage!,
              tone: WenyouStatusTone.accent,
            ),
            SizedBox(height: tokens.space12),
          ],
          if (_uploadFailure != null) ...[
            WenyouStatusBanner(
              message: _uploadFailure!.userMessage,
              detail: _requestDetail(_uploadFailure),
              tone: WenyouStatusTone.error,
            ),
            SizedBox(height: tokens.space12),
          ],
          if (_uploading) ...[
            _UploadStatus(progress: _uploadProgress, onCancel: _cancelUpload),
            SizedBox(height: tokens.space12),
          ],
          WenyouPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('compose-title'),
                  controller: _titleController,
                  enabled: !locked,
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '一句话说明你想聊什么',
                  ),
                ),
                SizedBox(height: tokens.space12),
                DropdownButtonFormField<String>(
                  key: const Key('compose-category'),
                  initialValue:
                      state.categories.any(
                        (category) => category.slug == state.categorySlug,
                      )
                      ? state.categorySlug
                      : null,
                  decoration: const InputDecoration(labelText: '分类'),
                  hint: Text(state.categories.isEmpty ? '分类同步后可选择' : '请选择分类'),
                  items: state.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.slug,
                          child: Text(category.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: locked || state.categories.isEmpty
                      ? null
                      : (value) => ref
                            .read(threadComposeControllerProvider.notifier)
                            .updateCategory(value),
                ),
                SizedBox(height: tokens.space12),
                DropdownButtonFormField<ThreadComposeVisibility>(
                  key: const Key('compose-visibility'),
                  initialValue: state.visibility,
                  decoration: const InputDecoration(labelText: '可见范围'),
                  items: ThreadComposeVisibility.values
                      .map(
                        (visibility) => DropdownMenuItem(
                          value: visibility,
                          child: Text(visibility.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: locked
                      ? null
                      : (value) {
                          if (value != null) {
                            ref
                                .read(threadComposeControllerProvider.notifier)
                                .updateVisibility(value);
                          }
                        },
                ),
                SizedBox(height: tokens.space12),
                TextField(
                  key: const Key('compose-tags'),
                  controller: _tagsController,
                  enabled: !locked,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: '标签（可选）',
                    hintText: '用空格或逗号分隔，最多 5 个',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space16),
          Material(
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
                  enabled: enabled,
                  onInsertImage: _insertImage,
                  onSaveDraft: _openContentDrafts,
                ),
                Semantics(
                  textField: true,
                  label: '主题正文编辑器',
                  child: QuillEditor(
                    key: const Key('compose-body'),
                    controller: _editorController,
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    config: QuillEditorConfig(
                      scrollable: false,
                      minHeight: 260,
                      padding: EdgeInsets.all(tokens.space16),
                      placeholder: '写下正文…',
                      embedBuilders: wenyouEditorEmbedBuilders(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space12),
          _LocalSaveStatus(state: state),
          SizedBox(height: tokens.space16),
          OutlinedButton.icon(
            key: const Key('compose-save-draft'),
            onPressed: enabled ? _saveThreadDraft : null,
            icon: state.action == ThreadComposeAction.saveDraft
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(
              state.action == ThreadComposeAction.saveDraft
                  ? '正在保存…'
                  : '保存到服务端草稿',
            ),
          ),
          SizedBox(height: tokens.space12),
          WenyouAsyncPrimaryButton(
            key: const Key('compose-publish'),
            label: '发布主题',
            loadingLabel: '正在发布主题',
            icon: Icons.send_rounded,
            isLoading: state.action == ThreadComposeAction.publish,
            onPressed: enabled && state.canPublish ? _publish : null,
          ),
          SizedBox(height: tokens.space8),
          Text(
            '发布前会再次保存本地快照；若网络结果不确定，重试会沿用同一创建请求。',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
        ],
      ),
    );
  }

  Future<void> _openEmailVerification() async {
    await _flushSnapshot();
    if (!mounted) return;
    final latest = ref.read(threadComposeControllerProvider);
    if (latest.phase == ThreadComposePhase.ready &&
        latest.localSnapshotStatus == LocalSnapshotStatus.failed) {
      final continueAnyway = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('本地内容尚未保存'),
          content: const Text('现在进入邮箱验证可能丢失刚才的修改。建议留下并检查设备存储后重试。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('留下编辑'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('仍然验证'),
            ),
          ],
        ),
      );
      if (continueAnyway != true || !mounted) return;
    }
    final verified = await context.push<bool>(
      Uri(
        path: '/me/security/verify-email',
        queryParameters: const {'returnTo': '/compose/thread'},
      ).toString(),
    );
    if (verified != true || !mounted) return;
    await ref.read(threadComposeControllerProvider.notifier).refreshBootstrap();
  }

  void _scheduleDocumentSync(ThreadComposeState state) {
    if (state.phase != ThreadComposePhase.ready ||
        state.documentRevision == _scheduledDocumentRevision) {
      return;
    }
    _scheduledDocumentRevision = state.documentRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyStateToInputs(state);
    });
  }

  void _applyStateToInputs(ThreadComposeState state) {
    _applyingDocument = true;
    try {
      _titleController.text = state.title;
      _tagsController.text = state.tags.join(' ');
      final decoded = MarkdownDeltaCodec.decode(state.body);
      _documentIssues = decoded.issues;
      _editorController.document = Document.fromDelta(decoded.delta);
      _codecFailure = null;
    } on Object catch (error) {
      _codecFailure = '恢复正文时发生错误：$error';
    } finally {
      _applyingDocument = false;
    }
    if (mounted) setState(() {});
  }

  void _onTitleChanged() {
    if (_applyingDocument) return;
    ref
        .read(threadComposeControllerProvider.notifier)
        .updateTitle(_titleController.text);
  }

  void _onTagsChanged() {
    if (_applyingDocument) return;
    ref
        .read(threadComposeControllerProvider.notifier)
        .updateTags(_tagsController.text.split(RegExp(r'[,，\s]+')));
  }

  void _onDocumentChanged() {
    if (_applyingDocument) return;
    try {
      final markdown = MarkdownDeltaCodec.encode(
        _editorController.document.toDelta(),
      );
      ref.read(threadComposeControllerProvider.notifier).updateBody(markdown);
      if (_codecFailure != null && mounted) {
        setState(() => _codecFailure = null);
      }
    } on MarkdownCodecException catch (error) {
      if (mounted) setState(() => _codecFailure = error.message);
    }
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
    var alt = '主题正文插图';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('描述这张图片'),
        content: TextFormField(
          key: const Key('compose-image-alt'),
          initialValue: alt,
          onChanged: (value) => alt = value,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: '替代文字',
            helperText: '用于无障碍朗读和图片无法加载时的说明',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = alt.replaceAll(RegExp(r'[\]\r\n]'), ' ').trim();
              Navigator.pop(context, value.isEmpty ? '主题正文插图' : value);
            },
            child: const Text('继续上传'),
          ),
        ],
      ),
    );
  }

  void _insertBlockImage(UploadedEditorImage image, String alt) {
    var selection = _editorController.selection;
    final documentLength = _editorController.document.length;
    final offset = selection.start
        .clamp(0, documentLength > 0 ? documentLength - 1 : 0)
        .toInt();
    selection = TextSelection.collapsed(offset: offset);
    final plain = _editorController.document.toPlainText();
    if (selection.start > 0 && plain[selection.start - 1] != '\n') {
      _editorController.replaceText(
        selection.start,
        0,
        '\n',
        TextSelection.collapsed(offset: selection.start + 1),
      );
      selection = TextSelection.collapsed(offset: selection.start + 1);
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

  void _cancelUpload() {
    _uploadCancelToken?.cancel('user cancelled image upload');
  }

  Future<void> _saveThreadDraft() async {
    if (_codecFailure != null || _uploading) return;
    await ref.read(threadComposeControllerProvider.notifier).saveDraft();
  }

  Future<void> _openContentDrafts() async {
    if (_codecFailure != null || _uploading) return;
    await _flushSnapshot();
    if (!mounted) return;
    final currentBody = ref.read(threadComposeControllerProvider).body;
    await showContentDraftsSheet(
      context: context,
      currentContent: currentBody,
      onRestore: (content) => ref
          .read(threadComposeControllerProvider.notifier)
          .restoreContentDraft(content),
    );
  }

  Future<void> _publish() async {
    if (_codecFailure != null || _uploading) return;
    final threadId = await ref
        .read(threadComposeControllerProvider.notifier)
        .publish();
    if (mounted && threadId != null) context.go('/threads/$threadId');
  }

  Future<void> _flushSnapshot() async {
    final state = ref.read(threadComposeControllerProvider);
    if (state.phase == ThreadComposePhase.ready) {
      await ref
          .read(threadComposeControllerProvider.notifier)
          .flushLocalSnapshot();
    }
  }

  Future<void> _saveBeforePop(Object? result) async {
    if (_allowPop || _preparingPop) return;
    _preparingPop = true;
    await _flushSnapshot();
    if (!mounted) return;
    final latest = ref.read(threadComposeControllerProvider);
    if (latest.phase == ThreadComposePhase.ready &&
        latest.localSnapshotStatus == LocalSnapshotStatus.failed) {
      final leaveAnyway = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('本地内容尚未保存'),
          content: const Text('现在退出可能丢失刚才的修改。建议留下并检查设备存储后重试。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('留下'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('仍然退出'),
            ),
          ],
        ),
      );
      if (leaveAnyway != true || !mounted) {
        _preparingPop = false;
        return;
      }
    }
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }
}

String? _requestDetail(ApiFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '请求 ID：$requestId';
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: Icons.edit_off_outlined,
          title: '创作空间没有准备完成',
          message: failure?.userMessage ?? '请重试；原有本地数据不会被覆盖。',
          detail: _requestDetail(failure),
          action: FilledButton(onPressed: onRetry, child: const Text('重试')),
        ),
      ),
    );
  }
}

class _UploadStatus extends StatelessWidget {
  const _UploadStatus({required this.progress, required this.onCancel});

  final MediaUploadProgress? progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final current = progress;
    final label = switch (current?.stage) {
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
          LinearProgressIndicator(value: current?.fraction),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: onCancel, child: const Text('取消上传')),
          ),
        ],
      ),
    );
  }
}

class _LocalSaveStatus extends StatelessWidget {
  const _LocalSaveStatus({required this.state});

  final ThreadComposeState state;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (state.localSnapshotStatus) {
      LocalSnapshotStatus.idle => (Icons.edit_outlined, '内容有变更，稍后自动保存到本机'),
      LocalSnapshotStatus.saving => (Icons.sync_rounded, '正在保存到本机…'),
      LocalSnapshotStatus.saved => (
        Icons.check_circle_outline_rounded,
        '已保存到本机',
      ),
      LocalSnapshotStatus.failed => (
        Icons.error_outline_rounded,
        '本地保存失败，请先不要退出',
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(icon, size: 18),
          SizedBox(width: context.wenyouTokens.space8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
