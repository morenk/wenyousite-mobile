import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

class ThreadManagementBodyEditorController extends ChangeNotifier {
  RichEditorSession? _session;
  WenyouEditorToolbarController? _toolbar;

  bool flush() => _session?.flush() ?? true;

  bool closeToolbarTray() => _toolbar?.closeTray() ?? false;

  String? get codecFailure => _session?.codecFailure;

  void _attach(
    RichEditorSession session,
    WenyouEditorToolbarController toolbar,
  ) {
    _session = session;
    _toolbar = toolbar;
  }

  void _detach(RichEditorSession session) {
    if (identical(_session, session)) {
      _session = null;
      _toolbar = null;
    }
  }
}

class ThreadManagementBodyEditor extends ConsumerStatefulWidget {
  const ThreadManagementBodyEditor({
    required this.threadId,
    required this.initialMarkdown,
    required this.onChanged,
    required this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.label = '正文编辑器',
    this.placeholder = '从这里开始写正文…',
    this.onSubmit,
    this.submitLabel = '保存修改',
    this.showSubmit = false,
    this.surface = WenyouComposerSurface.inline,
    super.key,
  });

  final String threadId;
  final String initialMarkdown;
  final ValueChanged<String> onChanged;
  final ThreadManagementBodyEditorController controller;
  final bool enabled;
  final bool autofocus;
  final String label;
  final String placeholder;
  final Future<void> Function()? onSubmit;
  final String submitLabel;
  final bool showSubmit;
  final WenyouComposerSurface surface;

  @override
  ConsumerState<ThreadManagementBodyEditor> createState() =>
      _ThreadManagementBodyEditorState();
}

class _ThreadManagementBodyEditorState
    extends ConsumerState<ThreadManagementBodyEditor> {
  late final RichEditorSession _session;
  final _toolbar = WenyouEditorToolbarController();
  final Object _uploadTaskId = Object();
  final Object _contentDraftSessionKey = Object();
  var _externalRevision = 0;
  late String _markdown;

  @override
  void initState() {
    super.initState();
    _markdown = widget.initialMarkdown;
    _session = RichEditorSession(
      initialMarkdown: widget.initialMarkdown,
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: (markdown) {
        _markdown = markdown;
        widget.onChanged(markdown);
        ref
            .read(
              contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
            )
            .updateAutoSaveContent(markdown);
      },
    )..addListener(_onSessionChanged);
    widget.controller._attach(_session, _toolbar);
  }

  @override
  void didUpdateWidget(covariant ThreadManagementBodyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller._detach(_session);
      widget.controller._attach(_session, _toolbar);
    }
    if (oldWidget.initialMarkdown != widget.initialMarkdown) {
      _markdown = widget.initialMarkdown;
      ref
          .read(
            contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
          )
          .updateAutoSaveContent(widget.initialMarkdown);
      _session.scheduleExternalMarkdown(
        markdown: widget.initialMarkdown,
        revision: ++_externalRevision,
        selection: RichEditorSelectionPlacement.end,
      );
    }
  }

  @override
  void dispose() {
    widget.controller._detach(_session);
    _session
      ..removeListener(_onSessionChanged)
      ..dispose();
    _toolbar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentDraftsState = ref.watch(
      contentDraftsControllerProvider(_contentDraftSessionKey),
    );
    final tokens = context.wenyouTokens;
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    final enabled =
        widget.enabled && !uploadState.isBusy && _session.codecFailure == null;
    _session.readOnly = !enabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_session.codecFailure != null)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space8),
            child: WenyouStatusBanner(
              tone: WenyouStatusTone.error,
              message: '当前格式组合暂时不能安全保存。',
              detail: _session.codecFailure,
            ),
          ),
        if (_session.issues.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space8),
            child: WenyouStatusBanner(
              message: '正文中有 ${_session.issues.length} 处内容暂时无法编辑。',
              detail: '这些内容会原样保留。',
            ),
          ),
        if (uploadState.failure != null)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space8),
            child: WenyouStatusBanner(
              tone: WenyouStatusTone.error,
              message: uploadState.failure!.userMessage,
              detail: uploadState.failure!.requestId == null
                  ? null
                  : '问题编号：${uploadState.failure!.requestId}',
              action: uploadState.failure!.canRetry
                  ? TextButton(
                      onPressed: _retryImageUpload,
                      child: const Text('重试上传'),
                    )
                  : null,
            ),
          ),
        if (uploadState.isBusy)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space8),
            child: WenyouStatusBanner(
              message: _uploadLabel(uploadState.progress),
              action: TextButton(
                onPressed: () => ref
                    .read(
                      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
                    )
                    .cancel(),
                child: const Text('取消上传'),
              ),
            ),
          ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                textField: true,
                label: widget.label,
                child: QuillEditor(
                  key: const Key('thread-management-body-editor'),
                  controller: _session.controller,
                  focusNode: _session.focusNode,
                  scrollController: _session.scrollController,
                  config: QuillEditorConfig(
                    scrollable: true,
                    expands: true,
                    autoFocus: widget.autofocus,
                    padding: EdgeInsets.all(tokens.space16),
                    placeholder: widget.placeholder,
                    customStyles: wenyouEditorTextStyles(context),
                    embedBuilders: wenyouEditorEmbedBuilders(),
                    customShortcuts: _session.clipboardShortcuts,
                    customActions: _session.clipboardActions,
                    contextMenuBuilder: _session.buildContextMenu,
                  ),
                ),
              ),
              MentionSuggestions(
                controller: _session.controller,
                focusNode: _session.focusNode,
                threadId: widget.threadId,
                enabled: enabled,
              ),
            ],
          ),
        ),
        WenyouComposerDock(
          key: const Key('thread-management-body-toolbar'),
          controller: _session.controller,
          surface: widget.surface,
          enabled: enabled,
          editorFocusNode: _session.focusNode,
          onInsertImage: _insertImage,
          onInsertSticker: ref.watch(stickersEnabledProvider)
              ? _insertSticker
              : null,
          onSaveDraft: _openDrafts,
          draftStatusLabel: contentDraftsState.autoSaveToolbarLabel,
          onSubmit: widget.showSubmit ? widget.onSubmit : null,
          submitLabel: widget.submitLabel,
          characterCount: _session.characterCount,
          characterLimit: 10000,
          toolbarController: _toolbar,
        ),
      ],
    );
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openDrafts() async {
    if (!_session.flush()) return;
    await showContentDraftsSheet(
      context: context,
      draftSessionKey: _contentDraftSessionKey,
      currentContent: _markdown,
      onRestore: (content) {
        _markdown = content;
        widget.onChanged(content);
        ref
            .read(
              contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
            )
            .updateAutoSaveContent(content);
        _session.scheduleExternalMarkdown(
          markdown: content,
          revision: ++_externalRevision,
          selection: RichEditorSelectionPlacement.end,
        );
      },
    );
  }

  Future<void> _insertImage() => _runImageUpload(retry: false);

  Future<void> _retryImageUpload() => _runImageUpload(retry: true);

  Future<void> _runImageUpload({required bool retry}) async {
    final controller = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    final uploaded = retry
        ? await controller.retryUpload()
        : await pickCropAndUploadEditorImage(
            context,
            ref,
            uploadTaskId: _uploadTaskId,
            title: '裁剪正文图片',
          );
    if (!mounted || uploaded == null) return;
    _session.insertBlockImage(url: uploaded.url);
  }

  Future<void> _insertSticker() async {
    final sticker = await showStickerPicker(context);
    if (!mounted || sticker == null) return;
    _session.insertSticker(assetId: sticker.asset.id, url: sticker.asset.url);
  }
}

String _uploadLabel(MediaUploadProgress? progress) => switch (progress?.stage) {
  MediaUploadStage.preparing => '正在准备图片…',
  MediaUploadStage.uploading => '正在上传图片…',
  MediaUploadStage.confirming => '正在确认上传…',
  MediaUploadStage.processing => '图片处理中…',
  null => '正在准备图片…',
};
