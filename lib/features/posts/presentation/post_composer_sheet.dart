import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_widgets.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_composer_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_diagnostics.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_expansion.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_opening.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet_layout.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

export 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart'
    show PostComposerDraft, setPostComposerDraft;

Future<PostItem?> showPostComposerSheet({
  required BuildContext context,
  required PostComposerTarget target,
  PostComposerDraft? initialDraft,
  ValueChanged<PostComposerDraft?>? onDraftChanged,
}) {
  return showWenyouComposerSheet<PostItem>(
    context: context,
    isDismissible: false,
    builder: (context) => PostComposerOpening(
      target: target,
      initialDraft: initialDraft,
      onDraftChanged: onDraftChanged,
      builder: (context, composer) => _PostComposerRouteHost(
        target: composer.target,
        baseline: composer.baseline,
        onDraftChanged: onDraftChanged,
      ),
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

class _PostComposerRouteHost extends StatefulWidget {
  const _PostComposerRouteHost({
    required this.target,
    required this.baseline,
    this.onDraftChanged,
  });

  final PostComposerTarget target;
  final PostComposerBaseline baseline;
  final ValueChanged<PostComposerDraft?>? onDraftChanged;

  @override
  State<_PostComposerRouteHost> createState() => _PostComposerRouteHostState();
}

class _PostComposerRouteHostState extends State<_PostComposerRouteHost> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _composerKey = GlobalKey<_PostComposerSheetState>();
  ModalRoute<Object?>? _outerRoute;
  NavigatorState? _outerNavigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _outerRoute ??= ModalRoute.of(context);
    _outerNavigator ??= Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return;
        }
        _composerKey.currentState?.handleSystemBack();
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => PageRouteBuilder<void>(
          settings: settings,
          opaque: false,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, _, _) => ExpandablePostComposer(
            target: widget.target,
            baseline: widget.baseline,
            onDraftChanged: widget.onDraftChanged,
            composerKey: _composerKey,
            onRequestClose: () =>
                _composerKey.currentState?.requestCloseFromOutside(),
            onClose: _close,
          ),
        ),
      ),
    );
  }

  void _close(PostItem? result) {
    final route = _outerRoute;
    final navigator = _outerNavigator;
    if (route == null || navigator == null || !route.isActive) return;
    navigator.removeRoute<Object?>(route, result);
  }
}

typedef PostComposerToolbarInteractionChanged =
    void Function(bool open, double requiredHeight);

class PostComposerSheet extends ConsumerStatefulWidget {
  const PostComposerSheet({
    required this.target,
    required this.baseline,
    required this.onClose,
    this.onDraftChanged,
    this.expanded = false,
    this.onResize,
    this.onToggleExpanded,
    this.onToolbarInteractionChanged,
    this.onMinimumHeightRequired,
    this.onDismissEnabledChanged,
    super.key,
  });

  final PostComposerTarget target;
  final PostComposerBaseline baseline;
  final ValueChanged<PostItem?> onClose;
  final ValueChanged<PostComposerDraft?>? onDraftChanged;
  final bool expanded;
  final ValueChanged<double>? onResize;
  final VoidCallback? onToggleExpanded;
  final PostComposerToolbarInteractionChanged? onToolbarInteractionChanged;
  final ValueChanged<double>? onMinimumHeightRequired;
  final ValueChanged<bool>? onDismissEnabledChanged;

  @override
  ConsumerState<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends ConsumerState<PostComposerSheet>
    with WidgetsBindingObserver {
  late final RichEditorSession _editorSession;
  late final Object _openedSessionScope;
  final WenyouEditorToolbarController _toolbarController =
      WenyouEditorToolbarController();
  final GlobalKey _sheetMeasureKey = GlobalKey();
  final GlobalKey _canvasMeasureKey = GlobalKey();
  final GlobalKey _toolbarMeasureKey = GlobalKey();
  bool _closing = false;
  bool _preparingClose = false;
  bool? _reportedDismissEnabled;
  int _toolbarInteractionGeneration = 0;
  int _minimumHeightGeneration = 0;
  late final EditorPendingImages _pendingImages;
  bool _publishing = false;
  final _diagnostics = PostComposerDiagnostics();
  final Object _contentDraftSessionKey = Object();

  bool get _uploading => _pendingImages.hasPending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openedSessionScope = ref.read(sessionScopeProvider);
    _editorSession = RichEditorSession(
      initialMarkdown: widget.target.initialContent,
      initialMediaDisplays: widget.baseline.mediaDisplays,
      clipboardScope: _openedSessionScope,
      blockAlignment: ref.read(appCapabilitiesProvider).markdownAlignment,
      imageAlignment: ref.read(appCapabilitiesProvider).markdownImageAlignment,
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: (markdown) {
        if (_closing || ref.read(sessionScopeProvider) != _openedSessionScope) {
          return;
        }
        ref
            .read(postComposerControllerProvider(widget.target).notifier)
            .updateContent(markdown);
        ref
            .read(
              contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
            )
            .updateAutoSaveContent(markdown);
        _notifyDraft(markdown);
      },
    )..addListener(_onEditorSessionChanged);
    _pendingImages = EditorPendingImages(
      ref: ref,
      editor: _editorSession,
      target: 'post:${postComposerDraftKey(widget.target)}',
      baseline: jsonEncode([
        widget.baseline.postId,
        widget.baseline.version,
        widget.baseline.content,
      ]),
      confirmRestore: () async => await showWenyouConfirmationDialog(
        context: context,
        title: '正文已有更新',
        message: '本机仍有之前的草稿。恢复后发布会覆盖当前正文；选择使用最新版会丢弃这份本机草稿。',
        confirmLabel: '恢复本机草稿',
        cancelLabel: '使用最新版',
        useRootNavigator: false,
        tone: WenyouConfirmationTone.destructive,
      ),
    )..addListener(_onPendingImagesChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_pendingImages.restore());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _pendingImages.pause();
      unawaited(_editorSession.flush().then((_) => _pendingImages.save()));
    } else if (state == AppLifecycleState.resumed) {
      _pendingImages.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingImages
      ..removeListener(_onPendingImagesChanged)
      ..dispose();
    _editorSession
      ..removeListener(_onEditorSessionChanged)
      ..dispose();
    _toolbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (previous, next) {
      if (next == _openedSessionScope || _closing) return;
      _closeForSessionChange();
    });
    final provider = postComposerControllerProvider(widget.target);
    final state = ref.watch(provider);
    final contentDraftsState = ref.watch(
      contentDraftsControllerProvider(_contentDraftSessionKey),
    );

    _editorSession.scheduleExternalMarkdown(
      markdown: state.content,
      revision: state.documentRevision,
      selection: RichEditorSelectionPlacement.end,
    );
    final tokens = context.wenyouTokens;
    final locked =
        state.isSubmitting || _publishing || _pendingImages.restoring;
    final hasSupportContent =
        state.failure != null ||
        state.hasAmbiguousCreate ||
        _editorSession.codecFailure != null ||
        _editorSession.operationFailure != null ||
        _editorSession.issues.isNotEmpty ||
        _pendingImages.waitingToPublish;
    _scheduleMinimumHeightCheck(hasSupportContent);
    _reportDismissEnabled(!state.isSubmitting && !_closing && !_preparingClose);
    _editorSession.readOnly = locked;
    return KeyedSubtree(
      key: const Key('post-composer-sheet'),
      child: Column(
        key: _sheetMeasureKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostComposerSheetHeader(
            label: widget.target.label,
            expanded: widget.expanded,
            onResize: widget.onResize,
            onToggleExpanded: widget.onToggleExpanded,
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
                action: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CopyDiagnosticButton(failure: state.failure),
                    if (state.conflict != null)
                      TextButton.icon(
                        key: const Key('post-composer-retry-conflict'),
                        onPressed: locked ? null : _confirmConflictRetry,
                        icon: const WenyouIcon(WenyouIconIds.actionSync),
                        label: const Text('用当前正文覆盖最新版'),
                      ),
                  ],
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
                action: CopyDiagnosticButton(
                  diagnosticId: _editorSession.diagnosticId,
                ),
              ),
            ),
          if (_editorSession.operationFailure != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: WenyouStatusBanner(
                message: _editorSession.operationFailure!.message,
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
          EditorPublishWaiting(images: _pendingImages),
          PostComposerEditorRegion(
            editorSession: _editorSession,
            pendingImages: _pendingImages,
            label: widget.target.label,
            placeholder: _placeholder(widget.target.kind),
            threadId: widget.target.threadId,
            locked: locked,
            canvasMeasureKey: _canvasMeasureKey,
            toolbarMeasureKey: _toolbarMeasureKey,
            toolbar: WenyouComposerDock(
              key: const Key('post-composer-toolbar'),
              controller: _editorSession.controller,
              capabilities: WenyouEditorCapabilities.forAlignment(
                ref.watch(
                  appCapabilitiesProvider.select(
                    (capabilities) => capabilities.markdownAlignment,
                  ),
                ),
                imageAlignment: _editorSession.imageAlignment,
              ),
              surface: WenyouComposerSurface.expandableSheet,
              enabled: !locked && _editorSession.codecFailure == null,
              editorFocusNode: _editorSession.focusNode,
              onInsertImage: _insertImage,
              onInsertHorizontalRule: _editorSession.insertHorizontalRule,
              onInsertSticker: ref.watch(stickersEnabledProvider)
                  ? _insertSticker
                  : null,
              onSaveDraft: _openContentDrafts,
              draftStatusLabel: _uploading
                  ? _pendingImages.localSaveLabel
                  : contentDraftsState.autoSaveToolbarLabel,
              onSubmit: _submit,
              isSubmitting: state.isSubmitting || _publishing,
              submitLabel: _publishing
                  ? '正在发布…'
                  : _submitLabel(widget.target.kind),
              characterCount: _editorSession.characterCount,
              characterLimit: 10000,
              toolbarController: _toolbarController,
              onInteractionChanged: _handleToolbarInteractionChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _handleToolbarInteractionChanged(bool open) {
    final generation = ++_toolbarInteractionGeneration;
    if (!open) {
      widget.onToolbarInteractionChanged?.call(false, 0);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _toolbarInteractionGeneration) return;
      final requiredHeight = _minimumRequiredHeight();
      if (requiredHeight != null) {
        widget.onToolbarInteractionChanged?.call(true, requiredHeight);
      }
    });
  }

  void _scheduleMinimumHeightCheck(bool required) {
    final generation = ++_minimumHeightGeneration;
    if (!required) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _minimumHeightGeneration) return;
      final requiredHeight = _minimumRequiredHeight();
      if (requiredHeight != null) {
        widget.onMinimumHeightRequired?.call(requiredHeight);
      }
    });
  }

  double? _minimumRequiredHeight() {
    final sheet = _sheetMeasureKey.currentContext?.findRenderObject();
    final canvas = _canvasMeasureKey.currentContext?.findRenderObject();
    final toolbar = _toolbarMeasureKey.currentContext?.findRenderObject();
    if (sheet is! RenderBox || canvas is! RenderBox || toolbar is! RenderBox) {
      return null;
    }
    final fixedContentHeight = sheet.size.height - canvas.size.height;
    final minimumEditorHeight = context.wenyouTokens.minimumTouchTarget * 2;
    return fixedContentHeight + toolbar.size.height + minimumEditorHeight;
  }

  void _reportDismissEnabled(bool enabled) {
    if (_reportedDismissEnabled == enabled) return;
    _reportedDismissEnabled = enabled;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _reportedDismissEnabled != enabled) return;
      widget.onDismissEnabledChanged?.call(enabled);
    });
  }

  void requestCloseFromOutside() {
    if (_closing || _preparingClose) return;
    final state = ref.read(postComposerControllerProvider(widget.target));
    if (state.isSubmitting) return;
    unawaited(_requestClose());
  }

  void handleSystemBack() {
    if (_closing) return;
    if (_toolbarController.closeTray()) return;
    final state = ref.read(postComposerControllerProvider(widget.target));
    if (state.isSubmitting) return;
    unawaited(_requestClose());
  }

  void _onPendingImagesChanged() {
    if (!mounted || _closing) return;
    ref
        .read(contentDraftsControllerProvider(_contentDraftSessionKey).notifier)
        .pauseForLocalAttachments(_pendingImages.hasPending);
    setState(() {});
  }

  void _onEditorSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() => _diagnostics.submit(
    kind: widget.target.kind,
    content: ref.read(postComposerControllerProvider(widget.target)).content,
    failure: () => mounted
        ? ref.read(postComposerControllerProvider(widget.target)).failure
        : null,
    action: _submitContent,
  );

  Future<void> _submitContent() async {
    if (_publishing ||
        ref.read(postComposerControllerProvider(widget.target)).isSubmitting) {
      return;
    }
    setState(() => _publishing = true);
    _editorSession.readOnly = true;
    try {
      final readiness = _pendingImages.waitForReady();
      final intent = _pendingImages.publishGeneration;
      final ready = await readiness;
      if (!mounted) return;
      if (!ready) {
        if (await _pendingImages.revealFirstFailure() && mounted) {
          showWenyouSnackBar(context, '先处理未完成的图片');
        }
        return;
      }
      await _submitReadyContent(intent);
    } finally {
      _pendingImages.finishWaiting();
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _submitReadyContent(int intent) async {
    if (_closing || ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    if (!await _editorSession.flush()) return;
    if (!mounted ||
        _closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        !_pendingImages.isPublishIntentCurrent(intent)) {
      return;
    }
    _pendingImages.finishWaiting();
    final result = await ref
        .read(postComposerControllerProvider(widget.target).notifier)
        .submit();
    if (!mounted) return;
    if (_closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        result == null) {
      return;
    }
    final cleaned = await _pendingImages.clear();
    if (!mounted) return;
    if (!cleaned) showWenyouSnackBar(context, _pendingImages.saveFailure!);
    widget.onDraftChanged?.call(null);
    setState(() => _closing = true);
    widget.onClose(result);
  }

  Future<void> _confirmConflictRetry() async {
    if (_closing ||
        _publishing ||
        ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    var intent = _pendingImages.publishGeneration;
    if (_pendingImages.hasPending) {
      setState(() => _publishing = true);
      _editorSession.readOnly = true;
      try {
        final readiness = _pendingImages.waitForReady();
        intent = _pendingImages.publishGeneration;
        if (!await readiness || !mounted) return;
      } finally {
        _pendingImages.finishWaiting();
        if (mounted) setState(() => _publishing = false);
      }
    }
    if (!await _editorSession.flush()) return;
    if (!mounted || !_pendingImages.isPublishIntentCurrent(intent)) return;
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '覆盖最新版正文？',
      message: '正文已有更新。继续会用当前编辑器全文替换刚读取的最新版。',
      confirmLabel: '仍然覆盖',
      cancelLabel: '取消',
      useRootNavigator: false,
      tone: WenyouConfirmationTone.destructive,
    );
    if (!mounted) return;
    if (_closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        confirmed != true ||
        !_pendingImages.isPublishIntentCurrent(intent)) {
      return;
    }
    await _diagnostics.submit(
      kind: widget.target.kind,
      content: ref.read(postComposerControllerProvider(widget.target)).content,
      failure: () => mounted
          ? ref.read(postComposerControllerProvider(widget.target)).failure
          : null,
      action: () async {
        final result = await ref
            .read(postComposerControllerProvider(widget.target).notifier)
            .retryConflict();
        if (!mounted) return;
        if (_closing ||
            ref.read(sessionScopeProvider) != _openedSessionScope ||
            result == null) {
          return;
        }
        final cleaned = await _pendingImages.clear();
        if (!mounted) return;
        if (!cleaned) showWenyouSnackBar(context, _pendingImages.saveFailure!);
        widget.onDraftChanged?.call(null);
        setState(() => _closing = true);
        widget.onClose(result);
      },
    );
  }

  Future<void> _requestClose() async {
    if (_closing ||
        _preparingClose ||
        ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    final composerState = ref.read(
      postComposerControllerProvider(widget.target),
    );
    if (composerState.isSubmitting) return;
    _preparingClose = true;
    _reportDismissEnabled(false);
    _pendingImages.pause();
    if (!_editorSession.canCloseProtectedSource &&
        !await _editorSession.flush()) {
      _preparingClose = false;
      _pendingImages.resume();
      _reportDismissEnabled(true);
      return;
    }
    if (!mounted ||
        _closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    if (!await _pendingImages.save()) {
      _preparingClose = false;
      _pendingImages.resume();
      _reportDismissEnabled(true);
      return;
    }
    final current = ref.read(postComposerControllerProvider(widget.target));
    _notifyDraft(current.content);
    setState(() => _closing = true);
    widget.onClose(null);
  }

  void _notifyDraft(String content) {
    widget.onDraftChanged?.call(
      widget.baseline.draftFor(content, displays: _editorSession.mediaDisplays),
    );
  }

  Future<void> _openContentDrafts() async {
    if (_uploading) {
      await _pendingImages.save();
      return;
    }
    if (_closing || ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    if (!await _editorSession.flush()) return;
    if (!mounted) return;
    final state = ref.read(postComposerControllerProvider(widget.target));
    var restoredDisplays = _editorSession.mediaDisplays;
    await showContentDraftsSheet(
      context: context,
      draftSessionKey: _contentDraftSessionKey,
      currentContent: state.content,
      onRestoreDisplays: (values) => restoredDisplays = values,
      onRestore: (content) {
        if (!mounted ||
            _closing ||
            ref.read(sessionScopeProvider) != _openedSessionScope) {
          return;
        }
        _editorSession.replaceMediaDisplays(restoredDisplays);
        ref
            .read(postComposerControllerProvider(widget.target).notifier)
            .restoreContent(content);
        ref
            .read(
              contentDraftsControllerProvider(_contentDraftSessionKey).notifier,
            )
            .updateAutoSaveContent(content);
      },
    );
  }

  Future<void> _insertImage() async {
    await _diagnostics.upload(() async {
      final inputs = await pickAndCropEditorImages(
        context,
        ref,
        title: '裁剪正文图片',
      );
      if (!mounted ||
          _preparingClose ||
          _closing ||
          ref.read(sessionScopeProvider) != _openedSessionScope ||
          inputs == null) {
        return;
      }
      for (final input in inputs) {
        _pendingImages.add(input);
      }
    });
  }

  Future<void> _insertSticker(TextSelection selection) async {
    if (_closing || ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    final sticker = await showStickerPicker(context);
    if (!mounted) return;
    if (_closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        sticker == null) {
      return;
    }
    _editorSession.insertSticker(
      selection: selection,
      assetId: sticker.asset.id,
      url: sticker.asset.url,
      display: sticker.asset.display,
    );
  }

  void _closeForSessionChange() {
    _closing = true;
    _pendingImages.pause();
    widget.onClose(null);
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
  return wenyouFailureDetail(failure, treatAsWrite: true);
}
