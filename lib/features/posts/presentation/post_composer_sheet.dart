import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_composer_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/media/presentation/media_upload_status_banner.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
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
          pageBuilder: (context, _, _) => _ExpandablePostComposer(
            target: widget.target,
            baseline: widget.baseline,
            onDraftChanged: widget.onDraftChanged,
            composerKey: _composerKey,
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

class _ExpandablePostComposer extends StatefulWidget {
  const _ExpandablePostComposer({
    required this.target,
    required this.baseline,
    required this.composerKey,
    required this.onClose,
    this.onDraftChanged,
  });

  final PostComposerTarget target;
  final PostComposerBaseline baseline;
  final ValueChanged<PostComposerDraft?>? onDraftChanged;
  final GlobalKey<_PostComposerSheetState> composerKey;
  final ValueChanged<PostItem?> onClose;

  @override
  State<_ExpandablePostComposer> createState() =>
      _ExpandablePostComposerState();
}

class _ExpandablePostComposerState extends State<_ExpandablePostComposer> {
  static const _minimumExtent = .30;
  static const _maximumExtent = .94;
  late final double _restingExtent;
  late double _extent;
  double? _extentBeforeToolbar;
  bool _toolbarAutoExpanded = false;
  bool _dismissEnabled = true;

  @override
  void initState() {
    super.initState();
    _restingExtent = switch (widget.target.kind) {
      PostComposerKind.createFloor || PostComposerKind.createReply => .30,
      PostComposerKind.editPost || PostComposerKind.upsertBody => .52,
    };
    _extent = _restingExtent;
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = (constraints.maxHeight - keyboard).clamp(
          0.0,
          constraints.maxHeight,
        );
        final desiredHeight = constraints.maxHeight * _extent;
        final sheetHeight = desiredHeight < availableHeight
            ? desiredHeight
            : availableHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label: '收起编辑器并保留草稿',
              button: true,
              enabled: _dismissEnabled,
              child: GestureDetector(
                key: const Key('post-composer-dismiss-region'),
                behavior: HitTestBehavior.opaque,
                onTap: _dismissEnabled
                    ? () => widget.composerKey.currentState
                          ?.requestCloseFromOutside()
                    : null,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: keyboard),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  key: const Key('post-composer-viewport'),
                  height: sheetHeight,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: PostComposerSheet(
                        key: widget.composerKey,
                        target: widget.target,
                        baseline: widget.baseline,
                        onDraftChanged: widget.onDraftChanged,
                        onClose: widget.onClose,
                        expanded: _extent >= _maximumExtent - .01,
                        onResize: (delta) {
                          _cancelToolbarRestore();
                          setState(() {
                            _extent = (_extent - delta / constraints.maxHeight)
                                .clamp(_minimumExtent, _maximumExtent);
                          });
                        },
                        onToggleExpanded: () {
                          _cancelToolbarRestore();
                          setState(() {
                            _extent = _extent >= _maximumExtent - .01
                                ? _restingExtent
                                : _maximumExtent;
                          });
                        },
                        onToolbarInteractionChanged: (open, requiredHeight) =>
                            _handleToolbarInteraction(
                              open: open,
                              requiredHeight: requiredHeight,
                              viewportHeight: constraints.maxHeight,
                            ),
                        onMinimumHeightRequired: (requiredHeight) =>
                            _ensureMinimumHeight(
                              requiredHeight: requiredHeight,
                              viewportHeight: constraints.maxHeight,
                            ),
                        onDismissEnabledChanged: (enabled) {
                          if (!mounted || _dismissEnabled == enabled) return;
                          setState(() => _dismissEnabled = enabled);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleToolbarInteraction({
    required bool open,
    required double requiredHeight,
    required double viewportHeight,
  }) {
    if (!mounted || viewportHeight <= 0) return;
    if (!open) {
      final previous = _extentBeforeToolbar;
      final shouldRestore = _toolbarAutoExpanded && previous != null;
      _extentBeforeToolbar = null;
      _toolbarAutoExpanded = false;
      if (shouldRestore && (_extent - previous).abs() > .001) {
        setState(() => _extent = previous);
      }
      return;
    }
    final requiredExtent = (requiredHeight / viewportHeight).clamp(
      _minimumExtent,
      _maximumExtent,
    );
    if (requiredExtent <= _extent + .001) return;
    _extentBeforeToolbar ??= _extent;
    _toolbarAutoExpanded = true;
    setState(() => _extent = requiredExtent);
  }

  void _cancelToolbarRestore() {
    _extentBeforeToolbar = null;
    _toolbarAutoExpanded = false;
  }

  void _ensureMinimumHeight({
    required double requiredHeight,
    required double viewportHeight,
  }) {
    if (!mounted || viewportHeight <= 0) return;
    final requiredExtent = (requiredHeight / viewportHeight).clamp(
      _minimumExtent,
      _maximumExtent,
    );
    if (requiredExtent <= _extent + .001) return;
    setState(() => _extent = requiredExtent);
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

class _PostComposerSheetState extends ConsumerState<PostComposerSheet> {
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
  final Object _uploadTaskId = Object();
  final Object _contentDraftSessionKey = Object();

  bool get _uploading =>
      ref.read(mediaUploadTaskControllerProvider(_uploadTaskId)).isBusy;

  @override
  void initState() {
    super.initState();
    _openedSessionScope = ref.read(sessionScopeProvider);
    _editorSession = RichEditorSession(
      initialMarkdown: widget.target.initialContent,
      clipboardScope: _openedSessionScope,
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
    ref.listen(sessionScopeProvider, (previous, next) {
      if (next == _openedSessionScope || _closing) return;
      _closeForSessionChange();
    });
    final provider = postComposerControllerProvider(widget.target);
    final state = ref.watch(provider);
    final contentDraftsState = ref.watch(
      contentDraftsControllerProvider(_contentDraftSessionKey),
    );
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
    final hasSupportContent =
        state.failure != null ||
        state.hasAmbiguousCreate ||
        _editorSession.codecFailure != null ||
        _editorSession.operationFailure != null ||
        _editorSession.issues.isNotEmpty ||
        uploadState.failure != null ||
        uploadState.isBusy;
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
          if (uploadState.failure != null || uploadState.isBusy)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space12,
                tokens.space12,
                0,
              ),
              child: MediaUploadStatusBanner(
                state: uploadState,
                onCancel: () => ref
                    .read(
                      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
                    )
                    .cancel(),
                onRetry: _retryImageUpload,
                retryKey: const Key('post-composer-retry-upload'),
              ),
            ),
          PostComposerEditorRegion(
            editorSession: _editorSession,
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
              draftStatusLabel: contentDraftsState.autoSaveToolbarLabel,
              onSubmit: _submit,
              isSubmitting: state.isSubmitting,
              submitLabel: _submitLabel(widget.target.kind),
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

  void _onEditorSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (_closing || ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    if (!await _editorSession.flush()) return;
    if (!mounted ||
        _closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    final result = await ref
        .read(postComposerControllerProvider(widget.target).notifier)
        .submit();
    if (!mounted) return;
    if (_closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        result == null) {
      return;
    }
    widget.onDraftChanged?.call(null);
    setState(() => _closing = true);
    widget.onClose(result);
  }

  Future<void> _confirmConflictRetry() async {
    if (_closing || ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    if (!await _editorSession.flush()) return;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        title: const Text('覆盖最新版正文？'),
        content: const Text('正文已有更新。继续会用当前编辑器全文替换刚读取的最新版。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('仍然覆盖'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (_closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        confirmed != true) {
      return;
    }
    final result = await ref
        .read(postComposerControllerProvider(widget.target).notifier)
        .retryConflict();
    if (!mounted) return;
    if (_closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        result == null) {
      return;
    }
    widget.onDraftChanged?.call(null);
    setState(() => _closing = true);
    widget.onClose(result);
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
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
    if (!await _editorSession.flush()) {
      _preparingClose = false;
      _reportDismissEnabled(true);
      return;
    }
    if (!mounted ||
        _closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    final current = ref.read(postComposerControllerProvider(widget.target));
    _notifyDraft(current.content);
    setState(() => _closing = true);
    widget.onClose(null);
  }

  void _notifyDraft(String content) {
    widget.onDraftChanged?.call(widget.baseline.draftFor(content));
  }

  Future<void> _openContentDrafts() async {
    if (_closing || ref.read(sessionScopeProvider) != _openedSessionScope) {
      return;
    }
    if (!await _editorSession.flush()) return;
    if (!mounted) return;
    final state = ref.read(postComposerControllerProvider(widget.target));
    await showContentDraftsSheet(
      context: context,
      draftSessionKey: _contentDraftSessionKey,
      currentContent: state.content,
      onRestore: (content) {
        if (!mounted ||
            _closing ||
            ref.read(sessionScopeProvider) != _openedSessionScope) {
          return;
        }
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
    if (!mounted) return;
    if (_preparingClose ||
        _closing ||
        ref.read(sessionScopeProvider) != _openedSessionScope ||
        uploaded == null) {
      return;
    }
    _insertBlockImage(uploaded);
  }

  void _insertBlockImage(UploadedEditorImage image) {
    _editorSession.insertBlockImage(url: image.url);
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
    );
  }

  void _closeForSessionChange() {
    _closing = true;
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
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
  final requestId = failure?.requestId;
  return requestId == null ? null : '问题编号：$requestId';
}
