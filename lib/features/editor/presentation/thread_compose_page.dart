import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/application/remote_thread_drafts_controller.dart';
import 'package:wenyousite_mobile/features/editor/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/editor/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/editor/presentation/remote_thread_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

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
  final WenyouEditorToolbarController _toolbarController =
      WenyouEditorToolbarController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final Object _uploadTaskId = Object();

  bool _applyingDocument = false;
  bool _allowPop = false;
  bool _preparingPop = false;
  _ComposeMetadataPanel? _metadataPanel;
  int _scheduledDocumentRevision = -1;
  List<MarkdownCodecIssue> _documentIssues = const [];
  String? _codecFailure;
  bool get _uploading =>
      ref.read(mediaUploadTaskControllerProvider(_uploadTaskId)).isBusy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final decoded = MarkdownDeltaCodec.decode('');
    _editorController = QuillController(
      document: Document.fromDelta(decoded.delta),
      selection: const TextSelection.collapsed(offset: 0),
    )..addListener(_onDocumentChanged);
    _editorFocusNode.addListener(_onEditorFocusChanged);
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
    _editorController
      ..removeListener(_onDocumentChanged)
      ..dispose();
    _editorFocusNode
      ..removeListener(_onEditorFocusChanged)
      ..dispose();
    _editorScrollController.dispose();
    _toolbarController.dispose();
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
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    _scheduleDocumentSync(state);
    final locked = state.isSubmitting || uploadState.isBusy;
    _editorController.readOnly = locked;

    return PopScope<Object?>(
      canPop: _allowPop && !_toolbarController.trayOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_toolbarController.closeTray()) return;
        unawaited(_saveBeforePop(result));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('写主题'),
          actions: [
            if (state.phase == ThreadComposePhase.ready ||
                state.phase == ThreadComposePhase.published)
              IconButton(
                key: const Key('compose-remote-drafts'),
                tooltip: state.remoteDraft == null ? '云端草稿' : '云端草稿 · 当前已同步',
                onPressed: locked ? null : _openRemoteDraftActions,
                icon: Badge(
                  isLabelVisible: state.remoteDraft != null,
                  child: const Icon(Icons.cloud_outlined),
                ),
              ),
            if (state.phase == ThreadComposePhase.ready ||
                state.phase == ThreadComposePhase.published)
              TextButton(
                key: const Key('compose-publish'),
                onPressed: !locked && _codecFailure == null && state.canPublish
                    ? _publish
                    : null,
                child: state.action == ThreadComposeAction.publish
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('发布'),
              ),
          ],
        ),
        body: switch (state.phase) {
          ThreadComposePhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          ThreadComposePhase.failed => _LoadFailure(
            failure: state.failure,
            onRetry: () =>
                ref.read(threadComposeControllerProvider.notifier).load(),
          ),
          ThreadComposePhase.ready || ThreadComposePhase.published =>
            _buildEditor(context, state, uploadState, locked),
        },
      ),
    );
  }

  Widget _buildEditor(
    BuildContext context,
    ThreadComposeState state,
    MediaUploadTaskState uploadState,
    bool locked,
  ) {
    final tokens = context.wenyouTokens;
    final enabled = !locked && _codecFailure == null;
    final selectedCategory = state.categories
        .where((category) => category.slug == state.categorySlug)
        .firstOrNull;
    final settingsSummary = [
      selectedCategory?.name ?? '未选分类',
      state.visibility.label,
      if (state.tags.isNotEmpty) '${state.tags.length} 个标签',
    ].join(' · ');
    final horizontalPadding = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ComposeStatusArea(
                state: state,
                documentIssues: _documentIssues,
                codecFailure: _codecFailure,
                uploadFailure: uploadState.failure,
                uploadProgress: uploadState.progress,
                uploading: uploadState.isBusy,
                onCancelUpload: _cancelUpload,
                onRetryUpload: _retryImageUpload,
                onVerifyEmail: _openEmailVerification,
                onRefreshBootstrap: () => ref
                    .read(threadComposeControllerProvider.notifier)
                    .refreshBootstrap(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: TextField(
                  key: const Key('compose-title'),
                  controller: _titleController,
                  enabled: !locked,
                  maxLength: 100,
                  maxLines: _editorFocusNode.hasFocus ? 1 : 3,
                  minLines: 1,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.headlineSmall,
                  decoration: const InputDecoration(
                    hintText: '主题标题',
                    counterText: '',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              _ComposeMetadataBar(
                summary: settingsSummary,
                activePanel: _metadataPanel,
                enabled: !locked,
                onPanelChanged: (panel) {
                  setState(() {
                    _metadataPanel = _metadataPanel == panel ? null : panel;
                  });
                },
              ),
              _buildMetadataPanel(state, locked),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Semantics(
                      textField: true,
                      label: '主题正文编辑器',
                      child: QuillEditor(
                        key: const Key('compose-body'),
                        controller: _editorController,
                        focusNode: _editorFocusNode,
                        scrollController: _editorScrollController,
                        config: QuillEditorConfig(
                          scrollable: true,
                          expands: true,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            tokens.space16,
                            horizontalPadding,
                            tokens.space16,
                          ),
                          placeholder: '从这里开始写正文…',
                          customStyles: wenyouEditorTextStyles(context),
                          embedBuilders: wenyouEditorEmbedBuilders(),
                        ),
                      ),
                    ),
                    MentionSuggestions(
                      controller: _editorController,
                      focusNode: _editorFocusNode,
                      threadId: state.remoteDraft?.id,
                      enabled: enabled,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _LocalSaveStatus(state: state),
              ),
              WenyouComposerDock(
                key: const Key('compose-toolbar'),
                controller: _editorController,
                surface: WenyouComposerSurface.page,
                profile: WenyouComposerProfile.richMarkdown,
                enabled: enabled,
                editorFocusNode: _editorFocusNode,
                onInsertImage: _insertImage,
                onInsertSticker: ref.watch(stickersEnabledProvider)
                    ? _insertSticker
                    : null,
                onSaveDraft: _openContentDrafts,
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
    );
  }

  Widget _buildMetadataPanel(ThreadComposeState state, bool locked) {
    final tokens = context.wenyouTokens;
    final panel = _metadataPanel;
    if (panel == null) return const SizedBox.shrink();
    return Container(
      key: const Key('compose-metadata-panel'),
      constraints: const BoxConstraints(maxHeight: 152),
      padding: EdgeInsets.all(tokens.space12),
      decoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: switch (panel) {
        _ComposeMetadataPanel.category => SingleChildScrollView(
          child: Wrap(
            spacing: tokens.space8,
            runSpacing: tokens.space8,
            children: state.categories
                .map(
                  (category) => ChoiceChip(
                    label: Text(category.name),
                    selected: category.slug == state.categorySlug,
                    onSelected: locked
                        ? null
                        : (_) {
                            ref
                                .read(threadComposeControllerProvider.notifier)
                                .updateCategory(category.slug);
                            setState(() => _metadataPanel = null);
                            _editorFocusNode.requestFocus();
                          },
                  ),
                )
                .toList(growable: false),
          ),
        ),
        _ComposeMetadataPanel.visibility => Wrap(
          spacing: tokens.space8,
          children: ThreadComposeVisibility.values
              .map(
                (visibility) => ChoiceChip(
                  label: Text(visibility.label),
                  selected: visibility == state.visibility,
                  onSelected: locked
                      ? null
                      : (_) {
                          ref
                              .read(threadComposeControllerProvider.notifier)
                              .updateVisibility(visibility);
                          setState(() => _metadataPanel = null);
                          _editorFocusNode.requestFocus();
                        },
                ),
              )
              .toList(growable: false),
        ),
        _ComposeMetadataPanel.tags => TextField(
          key: const Key('compose-tags'),
          controller: _tagsController,
          enabled: !locked,
          autofocus: true,
          maxLength: 120,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: '标签（可选）',
            hintText: '用空格或逗号分隔，最多 5 个',
          ),
          onSubmitted: (_) {
            setState(() => _metadataPanel = null);
            _editorFocusNode.requestFocus();
          },
        ),
      },
    );
  }

  void _onEditorFocusChanged() {
    if (mounted) setState(() {});
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
    if (!mounted || _preparingPop || uploaded == null) return;
    _insertBlockImage(uploaded);
  }

  void _insertBlockImage(UploadedEditorImage image) {
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
    final documentLength = _editorController.document.length;
    final offset = selection.start
        .clamp(0, documentLength > 0 ? documentLength - 1 : 0)
        .toInt();
    selection = TextSelection.collapsed(offset: offset);
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

  void _cancelUpload() {
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
  }

  Future<void> _saveThreadDraft() async {
    if (_codecFailure != null || _uploading) return;
    final saved = await ref
        .read(threadComposeControllerProvider.notifier)
        .saveDraft();
    if (saved == null) return;
    ref.invalidate(remoteThreadDraftsControllerProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已保存到云端草稿')));
  }

  Future<void> _openRemoteDraftActions() async {
    final action = await showModalBottomSheet<_RemoteDraftAction>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          const ListTile(
            title: Text('云端草稿'),
            subtitle: Text('只在需要时保存或切换，不占用正文编辑空间。'),
          ),
          ListTile(
            key: const Key('compose-save-draft'),
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('保存当前主题'),
            subtitle: const Text('保存标题、正文和发布设置'),
            onTap: () => Navigator.pop(context, _RemoteDraftAction.save),
          ),
          ListTile(
            key: const Key('compose-open-remote-drafts'),
            leading: const Icon(Icons.folder_open_outlined),
            title: const Text('打开云端草稿'),
            subtitle: const Text('浏览并切换本人未发布的主题'),
            onTap: () => Navigator.pop(context, _RemoteDraftAction.open),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _RemoteDraftAction.save:
        await _saveThreadDraft();
      case _RemoteDraftAction.open:
        await _openRemoteDrafts();
    }
  }

  Future<void> _openRemoteDrafts() async {
    if (_codecFailure != null || _uploading) return;
    final before = ref.read(threadComposeControllerProvider);
    final selected = await showRemoteThreadDraftsSheet(
      context: context,
      currentDraftId: before.remoteDraft?.id,
    );
    if (!mounted || selected == null) return;
    final latest = ref.read(threadComposeControllerProvider);
    if (latest.remoteDraft?.id != selected.id &&
        _hasMeaningfulContent(latest)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('切换服务端草稿？'),
          content: const Text(
            '打开后会用所选服务端版本替换当前编辑器内容。若当前修改还需要保留，请先取消，再从顶栏云端草稿入口选择“保存当前主题”。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('先不切换'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认切换'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await ref
        .read(threadComposeControllerProvider.notifier)
        .openRemoteDraft(selected.id);
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
    if (mounted && threadId != null) {
      ref.invalidate(remoteThreadDraftsControllerProvider);
      context.go(AppRouteLocations.thread(threadId));
    }
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
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
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

enum _RemoteDraftAction { save, open }

enum _ComposeMetadataPanel { category, visibility, tags }

class _ComposeMetadataBar extends StatelessWidget {
  const _ComposeMetadataBar({
    required this.summary,
    required this.activePanel,
    required this.enabled,
    required this.onPanelChanged,
  });

  final String summary;
  final _ComposeMetadataPanel? activePanel;
  final bool enabled;
  final ValueChanged<_ComposeMetadataPanel> onPanelChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      key: const Key('compose-publish-settings'),
      height: tokens.minimumTouchTarget,
      padding: EdgeInsets.symmetric(horizontal: tokens.space8),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: tokens.border)),
      ),
      child: Row(
        children: [
          _MetadataButton(
            key: const Key('compose-category'),
            icon: Icons.category_outlined,
            label: '分类',
            selected: activePanel == _ComposeMetadataPanel.category,
            enabled: enabled,
            onPressed: () => onPanelChanged(_ComposeMetadataPanel.category),
          ),
          _MetadataButton(
            key: const Key('compose-visibility'),
            icon: Icons.visibility_outlined,
            label: '可见性',
            selected: activePanel == _ComposeMetadataPanel.visibility,
            enabled: enabled,
            onPressed: () => onPanelChanged(_ComposeMetadataPanel.visibility),
          ),
          _MetadataButton(
            icon: Icons.sell_outlined,
            label: '标签',
            selected: activePanel == _ComposeMetadataPanel.tags,
            enabled: enabled,
            onPressed: () => onPanelChanged(_ComposeMetadataPanel.tags),
          ),
          SizedBox(width: tokens.space4),
          Expanded(
            child: Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataButton extends StatelessWidget {
  const _MetadataButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: enabled ? onPressed : null,
      isSelected: selected,
      selectedIcon: Icon(icon, color: context.wenyouTokens.brand),
      icon: Icon(icon),
    );
  }
}

class _ComposeStatusArea extends StatelessWidget {
  const _ComposeStatusArea({
    required this.state,
    required this.documentIssues,
    required this.codecFailure,
    required this.uploadFailure,
    required this.uploadProgress,
    required this.uploading,
    required this.onCancelUpload,
    required this.onRetryUpload,
    required this.onVerifyEmail,
    required this.onRefreshBootstrap,
  });

  final ThreadComposeState state;
  final List<MarkdownCodecIssue> documentIssues;
  final String? codecFailure;
  final MediaUploadFailure? uploadFailure;
  final MediaUploadProgress? uploadProgress;
  final bool uploading;
  final VoidCallback onCancelUpload;
  final VoidCallback onRetryUpload;
  final VoidCallback onVerifyEmail;
  final VoidCallback onRefreshBootstrap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final banners = <Widget>[
      if (state.action == ThreadComposeAction.openRemoteDraft)
        const WenyouStatusBanner(message: '正在读取服务端草稿最新版…'),
      if (state.restoredFromLocal)
        const WenyouStatusBanner(
          message: '已恢复上次未完成的本地内容。',
          tone: WenyouStatusTone.accent,
        ),
      if (state.bootstrapLoading)
        const WenyouStatusBanner(message: '正在同步分类与账号发布状态…'),
      if (state.bootstrapFailure != null)
        WenyouStatusBanner(
          message: state.bootstrapFailure!.userMessage,
          detail: _requestDetail(state.bootstrapFailure),
          tone: WenyouStatusTone.error,
          action: TextButton(
            onPressed: state.bootstrapLoading ? null : onRefreshBootstrap,
            child: const Text('重新同步'),
          ),
        ),
      if (state.emailVerified == false)
        WenyouStatusBanner(
          message: '邮箱尚未验证，仍可编辑和保存草稿，但暂时不能发布。',
          tone: WenyouStatusTone.error,
          action: TextButton(
            key: const Key('compose-verify-email'),
            onPressed: state.isSubmitting ? null : onVerifyEmail,
            child: const Text('现在验证'),
          ),
        ),
      if (documentIssues.isNotEmpty)
        WenyouStatusBanner(
          message: '正文含有 ${documentIssues.length} 个兼容节点。',
          detail: '这些内容会锁定显示并原样保存。',
        ),
      if (codecFailure != null)
        WenyouStatusBanner(
          message: '当前格式组合暂时不能安全保存。',
          detail: codecFailure,
          tone: WenyouStatusTone.error,
        ),
      if (state.actionFailure != null)
        WenyouStatusBanner(
          key: const Key('compose-action-failure'),
          message: state.actionFailure!.userMessage,
          detail: _requestDetail(state.actionFailure),
          tone: WenyouStatusTone.error,
          action: state.actionFailure!.businessCode == 40107
              ? TextButton(
                  key: const Key('compose-action-verify-email'),
                  onPressed: state.isSubmitting ? null : onVerifyEmail,
                  child: const Text('现在验证'),
                )
              : null,
        ),
      if (state.successMessage != null)
        WenyouStatusBanner(
          message: state.successMessage!,
          tone: WenyouStatusTone.accent,
        ),
      if (uploadFailure != null)
        WenyouStatusBanner(
          message: uploadFailure!.userMessage,
          detail: _uploadRequestDetail(uploadFailure),
          tone: WenyouStatusTone.error,
          action: uploadFailure!.canRetry
              ? TextButton(
                  key: const Key('compose-retry-upload'),
                  onPressed: onRetryUpload,
                  child: const Text('重试上传'),
                )
              : null,
        ),
      if (uploading)
        _UploadStatus(progress: uploadProgress, onCancel: onCancelUpload),
    ];
    if (banners.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          tokens.space12,
          tokens.space8,
          tokens.space12,
          tokens.space4,
        ),
        child: Column(
          children: [
            for (var index = 0; index < banners.length; index++) ...[
              banners[index],
              if (index != banners.length - 1) SizedBox(height: tokens.space8),
            ],
          ],
        ),
      ),
    );
  }
}

bool _hasMeaningfulContent(ThreadComposeState state) {
  return state.title.trim().isNotEmpty ||
      state.categorySlug != null ||
      state.tags.isNotEmpty ||
      MarkdownContent.hasVisibleContent(state.body) ||
      state.remoteDraft != null;
}

String? _requestDetail(ApiFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '请求 ID：$requestId';
}

String? _uploadRequestDetail(MediaUploadFailure? failure) {
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
