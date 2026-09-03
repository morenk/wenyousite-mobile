import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';
import 'package:wenyousite_mobile/features/threads/application/remote_thread_drafts_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/remote_thread_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_compose_support.dart';

class ThreadComposePage extends ConsumerStatefulWidget {
  const ThreadComposePage({super.key});

  @override
  ConsumerState<ThreadComposePage> createState() => _ThreadComposePageState();
}

class _ThreadComposePageState extends ConsumerState<ThreadComposePage>
    with WidgetsBindingObserver {
  late final RichEditorSession _editorSession;
  final WenyouEditorToolbarController _toolbarController =
      WenyouEditorToolbarController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final Object _uploadTaskId = Object();
  final Object _contentDraftSessionKey = Object();

  bool _applyingInputs = false;
  bool _allowPop = false;
  bool _preparingPop = false;
  ThreadComposeMetadataPanel? _metadataPanel;
  int _scheduledDocumentRevision = -1;
  bool get _uploading =>
      ref.read(mediaUploadTaskControllerProvider(_uploadTaskId)).isBusy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _editorSession = RichEditorSession(
      initialMarkdown: '',
      clipboardScope: ref.read(sessionScopeProvider),
      imageAlignment: ref.read(appCapabilitiesProvider).markdownImageAlignment,
      onMarkdownChanged: (markdown) {
        ref.read(threadComposeControllerProvider.notifier).updateBody(markdown);
        ref
            .read(
              contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
            )
            .updateAutoSaveContent(markdown);
      },
    )..addListener(_onEditorSessionChanged);
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
    _editorSession
      ..removeListener(_onEditorSessionChanged)
      ..dispose();
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
    final tokens = context.wenyouTokens;
    _editorSession.readOnly = locked;

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
              WenyouAnchoredActionBubble<ThreadRemoteDraftAction>(
                actions: const [
                  WenyouPopoverAction(
                    value: ThreadRemoteDraftAction.save,
                    icon: WenyouIconIds.statusSyncing,
                    label: '保存',
                    semanticsLabel: '保存当前主题到云端草稿',
                    key: Key('compose-save-draft'),
                  ),
                  WenyouPopoverAction(
                    value: ThreadRemoteDraftAction.open,
                    icon: WenyouIconIds.contentFolderOpen,
                    label: '打开',
                    semanticsLabel: '打开云端草稿',
                    key: Key('compose-open-remote-drafts'),
                  ),
                ],
                placement: WenyouPopoverPlacement.below,
                alignment: WenyouPopoverAlignment.end,
                semanticLabel: '云端草稿操作',
                onSelected: (action) =>
                    unawaited(_handleRemoteDraftAction(action)),
                anchorBuilder: (context, handle) => IconButton(
                  key: const Key('compose-remote-drafts'),
                  tooltip: state.remoteDraft == null ? '云端草稿' : '云端草稿 · 当前已同步',
                  onPressed: locked ? null : handle.toggle,
                  icon: Badge(
                    isLabelVisible: state.remoteDraft != null,
                    child: const WenyouIcon(WenyouIconIds.statusCloud),
                  ),
                ),
              ),
            if (state.phase == ThreadComposePhase.ready ||
                state.phase == ThreadComposePhase.published)
              FilledButton.icon(
                key: const Key('compose-publish'),
                style: FilledButton.styleFrom(
                  minimumSize: Size(0, tokens.minimumTouchTarget),
                  padding: EdgeInsets.symmetric(horizontal: tokens.space12),
                  backgroundColor: tokens.actionSurface,
                  foregroundColor: tokens.onActionSurface,
                  disabledBackgroundColor: tokens.border,
                  disabledForegroundColor: tokens.mutedText,
                ),
                onPressed:
                    !locked &&
                        _editorSession.codecFailure == null &&
                        state.canPublish
                    ? _publish
                    : null,
                icon: state.action == ThreadComposeAction.publish
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          color: tokens.onActionSurface,
                          strokeWidth: 2,
                        ),
                      )
                    : const WenyouIcon(WenyouIconIds.actionSend, size: 18),
                label: const Text('发布'),
              ),
          ],
        ),
        body: switch (state.phase) {
          ThreadComposePhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          ThreadComposePhase.failed => ThreadComposeLoadFailure(
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
    final enabled = !locked && _editorSession.codecFailure == null;
    final selectedCategory = state.categories
        .where((category) => category.slug == state.categorySlug)
        .firstOrNull;
    final horizontalPadding = wenyouHorizontalPagePadding(context);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThreadComposeStatusArea(
                state: state,
                documentIssues: _editorSession.issues,
                codecFailure: _editorSession.codecFailure,
                operationFailure: _editorSession.operationFailure?.message,
                uploadState: uploadState,
                onCancelUpload: _cancelUpload,
                onRetryUpload: _retryImageUpload,
                onRefreshBootstrap: () => ref
                    .read(threadComposeControllerProvider.notifier)
                    .refreshBootstrap(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '主题标题',
                      key: const Key('compose-title-label'),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                    TextField(
                      key: const Key('compose-title'),
                      controller: _titleController,
                      enabled: !locked,
                      maxLength: 100,
                      maxLines: _editorSession.hasFocus ? 1 : 3,
                      minLines: 1,
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context).textTheme.wenyouPageTitle,
                      decoration: const InputDecoration(
                        hintText: '一句话说明这个主题',
                        counterText: '',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ],
                ),
              ),
              ThreadComposeMetadataBar(
                categoryValue: selectedCategory?.name ?? '未选择',
                visibilityValue: state.visibility.label,
                tagsValue: state.tags.isEmpty
                    ? '未添加'
                    : '${state.tags.length} 个',
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
                        controller: _editorSession.controller,
                        focusNode: _editorSession.focusNode,
                        scrollController: _editorSession.scrollController,
                        config: QuillEditorConfig(
                          scrollable: true,
                          expands: true,
                          paintCursorAboveText: true,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            tokens.space16,
                            horizontalPadding,
                            tokens.space16,
                          ),
                          placeholder: '从这里开始写正文…',
                          customStyles: wenyouEditorTextStyles(context),
                          // Flutter Quill 尚未稳定开放自定义块前导渲染入口。
                          // ignore: experimental_member_use
                          customLeadingBlockBuilder:
                              wenyouEditorLeadingBlockBuilder(context),
                          embedBuilders: wenyouEditorEmbedBuilders(),
                          customShortcuts: _editorSession.clipboardShortcuts,
                          customActions: _editorSession.clipboardActions,
                          contextMenuBuilder: _editorSession.buildContextMenu,
                        ),
                      ),
                    ),
                    MentionSuggestions(
                      controller: _editorSession.controller,
                      focusNode: _editorSession.focusNode,
                      threadId: state.remoteDraft?.id,
                      enabled: enabled,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ThreadComposeLocalSaveStatus(state: state),
              ),
              WenyouComposerDock(
                key: const Key('compose-toolbar'),
                controller: _editorSession.controller,
                capabilities: WenyouEditorCapabilities.forAlignment(
                  ref.watch(
                    appCapabilitiesProvider.select(
                      (capabilities) => capabilities.markdownAlignment,
                    ),
                  ),
                  imageAlignment: _editorSession.imageAlignment,
                ),
                surface: WenyouComposerSurface.page,
                enabled: enabled,
                editorFocusNode: _editorSession.focusNode,
                onInsertImage: _insertImage,
                onInsertHorizontalRule: _editorSession.insertHorizontalRule,
                onInsertSticker: ref.watch(stickersEnabledProvider)
                    ? _insertSticker
                    : null,
                onSaveDraft: _openContentDrafts,
                draftStatusLabel: ref
                    .watch(
                      contentDraftsControllerProvider(_contentDraftSessionKey),
                    )
                    .autoSaveToolbarLabel,
                characterCount: _editorSession.characterCount,
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
        ThreadComposeMetadataPanel.category => SingleChildScrollView(
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
                            _editorSession.focusNode.requestFocus();
                          },
                  ),
                )
                .toList(growable: false),
          ),
        ),
        ThreadComposeMetadataPanel.visibility => Wrap(
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
                          _editorSession.focusNode.requestFocus();
                        },
                ),
              )
              .toList(growable: false),
        ),
        ThreadComposeMetadataPanel.tags => TextField(
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
            _editorSession.focusNode.requestFocus();
          },
        ),
      },
    );
  }

  void _onEditorSessionChanged() {
    if (mounted) setState(() {});
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
    _applyingInputs = true;
    try {
      _titleController.text = state.title;
      _tagsController.text = state.tags.join(' ');
      _editorSession.applyExternalMarkdown(state.body);
      ref
          .read(
            contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
          )
          .updateAutoSaveContent(state.body);
    } finally {
      _applyingInputs = false;
    }
    if (mounted) setState(() {});
  }

  void _onTitleChanged() {
    if (_applyingInputs) return;
    ref
        .read(threadComposeControllerProvider.notifier)
        .updateTitle(_titleController.text);
  }

  void _onTagsChanged() {
    if (_applyingInputs) return;
    ref
        .read(threadComposeControllerProvider.notifier)
        .updateTags(_tagsController.text.split(RegExp(r'[,，\s]+')));
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
        : await pickCropAndUploadEditorImage(
            context,
            ref,
            uploadTaskId: _uploadTaskId,
            title: '裁剪正文图片',
          );
    if (!mounted || _preparingPop || uploaded == null) return;
    _insertBlockImage(uploaded);
  }

  void _insertBlockImage(UploadedEditorImage image) {
    _editorSession.insertBlockImage(url: image.url);
  }

  Future<void> _insertSticker(TextSelection selection) async {
    final sticker = await showStickerPicker(context);
    if (!mounted || sticker == null) return;
    _editorSession.insertSticker(
      selection: selection,
      assetId: sticker.asset.id,
      url: sticker.asset.url,
    );
  }

  void _cancelUpload() {
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
  }

  Future<void> _saveThreadDraft() async {
    if (_uploading || !await _editorSession.flush()) return;
    if (!mounted) return;
    final saved = await ref
        .read(threadComposeControllerProvider.notifier)
        .saveDraft();
    if (saved == null) return;
    ref.invalidate(remoteThreadDraftsControllerProvider);
    if (!mounted) return;
    showWenyouSnackBar(context, '已保存到云端草稿');
  }

  Future<void> _handleRemoteDraftAction(ThreadRemoteDraftAction action) async {
    switch (action) {
      case ThreadRemoteDraftAction.save:
        await _saveThreadDraft();
      case ThreadRemoteDraftAction.open:
        await _openRemoteDrafts();
    }
  }

  Future<void> _openRemoteDrafts() async {
    if (_uploading || !await _editorSession.flush()) return;
    if (!mounted) return;
    final before = ref.read(threadComposeControllerProvider);
    final selected = await showRemoteThreadDraftsSheet(
      context: context,
      currentDraftId: before.remoteDraft?.id,
    );
    if (!mounted || selected == null) return;
    final latest = ref.read(threadComposeControllerProvider);
    if (latest.remoteDraft?.id != selected.id &&
        hasMeaningfulThreadComposeContent(latest)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('切换云端草稿？'),
          content: const Text('打开后会用所选云端草稿替换当前内容。若要保留当前修改，请先取消并保存到云端。'),
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
    if (_uploading || !await _editorSession.flush()) return;
    if (!mounted) return;
    await _flushSnapshot();
    if (!mounted) return;
    final currentBody = ref.read(threadComposeControllerProvider).body;
    await showContentDraftsSheet(
      context: context,
      draftSessionKey: _contentDraftSessionKey,
      currentContent: currentBody,
      onRestore: (content) {
        ref
            .read(threadComposeControllerProvider.notifier)
            .restoreContentDraft(content);
        ref
            .read(
              contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
            )
            .updateAutoSaveContent(content);
      },
    );
  }

  Future<void> _publish() async {
    if (_uploading || !await _editorSession.flush()) return;
    if (!mounted) return;
    final threadId = await ref
        .read(threadComposeControllerProvider.notifier)
        .publish();
    if (mounted && threadId != null) {
      ref.invalidate(remoteThreadDraftsControllerProvider);
      context.go(AppRouteLocations.thread(threadId));
    }
  }

  Future<void> _flushSnapshot() async {
    if (!await _editorSession.flush()) return;
    if (!mounted) return;
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
