import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_images.dart';

class MomentComposePage extends ConsumerStatefulWidget {
  const MomentComposePage({this.momentId, super.key});

  final String? momentId;

  @override
  ConsumerState<MomentComposePage> createState() => _MomentComposePageState();
}

class _MomentComposePageState extends ConsumerState<MomentComposePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<UploadedEditorImage> _images = [];
  String? _coverMediaId;
  int? _hydratedVersion;
  final Object _uploadTaskId = Object();
  List<MediaUploadInput> _pendingImageInputs = const [];
  var _pendingImageIndex = 0;
  Timer? _draftTimer;
  MomentLocalDraft? _baselineDraft;
  var _baselineSignature = '';
  var _contentReady = false;
  var _draftReadScheduled = false;
  var _applyingContent = false;
  var _allowPop = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onDraftChanged);
    _contentController.addListener(_onDraftChanged);
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _titleController.removeListener(_onDraftChanged);
    _contentController.removeListener(_onDraftChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = momentComposerControllerProvider(widget.momentId);
    final state = ref.watch(provider);
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    _hydrate(state.initialDetail);
    final editing = widget.momentId != null;
    if (!editing && !_contentReady) {
      _contentReady = true;
      _baselineDraft = _currentDraft();
      _baselineSignature = _signature();
      _scheduleDraftRead();
    }
    final editable =
        state.phase != MomentComposerPhase.loading &&
        state.phase != MomentComposerPhase.failed;
    final pendingImages = _hasPendingImageWork(uploadState);
    return PopScope(
      canPop: _allowPop || (!_hasUnsavedChanges && !pendingImages),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave(uploadState));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? '编辑动态' : '发动态'),
          actions: [
            if (editing && state.initialDetail?.canDelete == true)
              IconButton(
                key: const Key('moment-compose-delete'),
                onPressed: state.isSubmitting ? null : _confirmDelete,
                tooltip: '删除动态',
                icon: const WenyouIcon(WenyouIconIds.actionDelete),
              ),
          ],
        ),
        body: switch (state.phase) {
          MomentComposerPhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MomentComposerPhase.failed => _ComposeFailure(
            failure: state.failure,
            onRetry: () => ref.read(provider.notifier).load(),
          ),
          _ => _buildEditorBody(state, uploadState),
        },
        bottomNavigationBar: editable
            ? _MomentPublishBar(
                editing: editing,
                submitting: state.isSubmitting,
                onPressed: pendingImages ? null : _submit,
              )
            : null,
      ),
    );
  }

  Widget _buildEditorBody(
    MomentComposerState state,
    MediaUploadTaskState uploadState,
  ) {
    final tokens = context.wenyouTokens;
    final horizontal = wenyouHorizontalPagePadding(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontal,
          tokens.space12,
          horizontal,
          tokens.space8,
        ),
        child: WenyouConstrainedWidth(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.failure != null) ...[
                  WenyouStatusBanner(
                    message: state.failure!.userMessage,
                    detail: state.failure!.requestId == null
                        ? null
                        : '问题编号：${state.failure!.requestId}',
                    tone: WenyouStatusTone.error,
                    action: state.failure!.businessCode == 40002
                        ? TextButton(
                            key: const Key('moment-compose-resolve-conflict'),
                            onPressed: _resolveConflict,
                            child: const Text('处理'),
                          )
                        : null,
                  ),
                  SizedBox(height: tokens.space8),
                ],
                MomentComposeImageStrip(
                  images: _images,
                  coverMediaId: _coverMediaId,
                  uploadState: uploadState,
                  pendingIndex: _pendingImageIndex,
                  pendingCount: _pendingImageInputs.length,
                  onAdd:
                      _images.length >= 9 ||
                          state.isSubmitting ||
                          _hasPendingImageWork(uploadState)
                      ? null
                      : _pickAndUpload,
                  onCancelUpload: state.isSubmitting
                      ? null
                      : _cancelPendingImageUpload,
                  onRetryUpload:
                      uploadState.failure?.canRetry == true &&
                          !state.isSubmitting
                      ? _retryUpload
                      : null,
                  onCoverSelected: _selectCover,
                  onRemove: _removeImage,
                  onReorder: _reorderImages,
                ),
                SizedBox(height: tokens.space12),
                TextFormField(
                  key: const Key('moment-compose-title'),
                  controller: _titleController,
                  maxLength: 40,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '标题（必填）',
                    hintText: '给这一刻起个标题',
                  ),
                  validator: (value) {
                    final length = value?.trim().length ?? 0;
                    return length < 2 || length > 40 ? '请输入 2～40 个字符的标题' : null;
                  },
                ),
                SizedBox(height: tokens.space8),
                Expanded(
                  child: TextFormField(
                    key: const Key('moment-compose-content'),
                    controller: _contentController,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    maxLength: 1000,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: '正文（选填）',
                      hintText: '分享此刻的想法…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hydrate(MomentDetail? detail) {
    if (detail == null || _hydratedVersion == detail.version) return;
    _hydratedVersion = detail.version;
    _applyingContent = true;
    _titleController.text = detail.card.title;
    _contentController.text = detail.content;
    _images = detail.images
        .map(
          (image) => UploadedEditorImage(
            mediaId: image.id,
            url: image.url,
            width: image.width,
            height: image.height,
          ),
        )
        .toList(growable: false);
    _coverMediaId = detail.card.coverMedia?.id;
    _applyingContent = false;
    _contentReady = true;
    _baselineDraft = _currentDraft();
    _baselineSignature = _signature();
    _scheduleDraftRead();
  }

  Future<void> _pickAndUpload() async {
    final inputs = await pickAndCropEditorImages(
      context,
      ref,
      maximumSelection: 9 - _images.length,
      title: '裁剪动态图片',
    );
    if (!mounted || inputs == null || inputs.isEmpty) return;
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    setState(() {
      _pendingImageInputs = inputs;
      _pendingImageIndex = 0;
    });
    await _runImageUpload(retry: false);
  }

  Future<void> _retryUpload() => _runImageUpload(retry: true);

  Future<void> _runImageUpload({required bool retry}) async {
    final controller = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    if (_pendingImageInputs.isEmpty) return;
    var retryCurrent = retry;
    while (_pendingImageIndex < _pendingImageInputs.length) {
      final image = retryCurrent
          ? await controller.retryUpload()
          : await controller.uploadInput(
              _pendingImageInputs[_pendingImageIndex],
            );
      retryCurrent = false;
      if (!mounted || image == null) return;
      setState(() {
        _images = List.unmodifiable([..._images, image]);
        _coverMediaId ??= image.mediaId;
        _pendingImageIndex += 1;
      });
      _onDraftChanged();
    }
    setState(() {
      _pendingImageInputs = const [];
      _pendingImageIndex = 0;
    });
  }

  void _cancelPendingImageUpload() {
    ref.read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier).reset();
    setState(() {
      _pendingImageInputs = const [];
      _pendingImageIndex = 0;
    });
  }

  void _selectCover(String mediaId) {
    if (_coverMediaId == mediaId) return;
    setState(() => _coverMediaId = mediaId);
    _onDraftChanged();
  }

  void _removeImage(String mediaId) {
    setState(() {
      _images = _images
          .where((image) => image.mediaId != mediaId)
          .toList(growable: false);
      if (_coverMediaId == mediaId ||
          !_images.any((image) => image.mediaId == _coverMediaId)) {
        _coverMediaId = _images.isEmpty ? null : _images.first.mediaId;
      }
    });
    _onDraftChanged();
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (oldIndex == newIndex ||
        oldIndex < 0 ||
        oldIndex >= _images.length ||
        newIndex < 0 ||
        newIndex >= _images.length) {
      return;
    }
    setState(() {
      final reordered = [..._images];
      final image = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, image);
      _images = List.unmodifiable(reordered);
    });
    _onDraftChanged();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await ref
        .read(momentComposerControllerProvider(widget.momentId).notifier)
        .submit(_draftInput());
    if (saved == null || !mounted) return;
    await _finishSubmit(saved);
  }

  MomentDraftInput _draftInput() => MomentDraftInput(
    title: _titleController.text,
    content: _contentController.text,
    mediaIds: _images.map((image) => image.mediaId).toList(),
    coverMediaId: _coverMediaId,
  );

  Future<void> _finishSubmit(MomentDetail saved) async {
    _draftTimer?.cancel();
    await ref.read(momentDraftStoreProvider).delete(widget.momentId);
    if (!mounted) return;
    _allowPop = true;
    ref.invalidate(momentFeedControllerProvider);
    ref.invalidate(momentDetailControllerProvider(saved.card.id));
    if (widget.momentId == null) {
      context.replaceNamed(
        'moment-detail',
        pathParameters: {'momentId': saved.card.id},
      );
    } else {
      context.pop(saved);
    }
  }

  Future<void> _resolveConflict() async {
    final decision = await showDialog<_ConflictDecision>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('这条动态刚刚更新了'),
        content: const Text('你可以保留当前内容后重新保存，或改用最新内容。'),
        actions: [
          TextButton(
            key: const Key('moment-conflict-use-latest'),
            onPressed: () =>
                Navigator.pop(context, _ConflictDecision.useLatest),
            child: const Text('使用最新内容'),
          ),
          FilledButton(
            key: const Key('moment-conflict-keep-mine'),
            onPressed: () => Navigator.pop(context, _ConflictDecision.keepMine),
            child: const Text('保留我的内容'),
          ),
        ],
      ),
    );
    if (!mounted || decision == null) return;
    final controller = ref.read(
      momentComposerControllerProvider(widget.momentId).notifier,
    );
    if (decision == _ConflictDecision.keepMine) {
      final saved = await controller.resubmitAfterConflict(_draftInput());
      if (saved != null && mounted) await _finishSubmit(saved);
      return;
    }
    _draftTimer?.cancel();
    try {
      await ref.read(momentDraftStoreProvider).delete(widget.momentId);
    } on Object {
      if (mounted) _showFeedback('操作失败，请稍后重试。');
      return;
    }
    _hydratedVersion = null;
    await controller.load();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这条动态？'),
        content: const Text('删除后无法恢复，相关评论也不会再显示。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('moment-compose-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await ref
        .read(momentComposerControllerProvider(widget.momentId).notifier)
        .remove();
    if (!removed || !mounted) return;
    _draftTimer?.cancel();
    await ref.read(momentDraftStoreProvider).delete(widget.momentId);
    if (!mounted) return;
    _allowPop = true;
    ref.invalidate(momentFeedControllerProvider);
    context.go(AppRouteLocations.moments);
  }

  bool get _hasUnsavedChanges =>
      _contentReady && _signature() != _baselineSignature;

  bool _hasPendingImageWork(MediaUploadTaskState uploadState) =>
      uploadState.isBusy || _pendingImageInputs.isNotEmpty;

  String _signature() => jsonEncode({
    'title': _titleController.text,
    'content': _contentController.text,
    'coverMediaId': _coverMediaId,
    'mediaIds': [for (final image in _images) image.mediaId],
  });

  MomentLocalDraft _currentDraft() => MomentLocalDraft(
    title: _titleController.text,
    content: _contentController.text,
    images: List.unmodifiable(_images),
    coverMediaId: _coverMediaId,
    updatedAt: DateTime.now(),
  );

  void _onDraftChanged() {
    if (_applyingContent || !_contentReady) return;
    if (mounted) setState(() {});
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(_saveDraftNow());
    });
  }

  void _scheduleDraftRead() {
    if (_draftReadScheduled) return;
    _draftReadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSavedDraft());
  }

  Future<void> _restoreSavedDraft() async {
    MomentLocalDraft? draft;
    try {
      draft = await ref.read(momentDraftStoreProvider).read(widget.momentId);
    } on Object {
      if (mounted) _showFeedback('草稿加载失败，请稍后重试。');
      return;
    }
    if (!mounted || draft == null) return;
    _applyDraft(draft);
    showWenyouSnackBar(
      context,
      '已恢复上次的草稿',
      actionLabel: widget.momentId == null ? '重新开始' : '恢复原内容',
      actionKey: const Key('moment-draft-reset'),
      onAction: () => unawaited(_restoreBaseline()),
    );
  }

  void _applyDraft(MomentLocalDraft draft) {
    _applyingContent = true;
    _titleController.text = draft.title;
    _contentController.text = draft.content;
    final images = draft.images.take(9).toList(growable: false);
    final cover = images.any((image) => image.mediaId == draft.coverMediaId)
        ? draft.coverMediaId
        : images.firstOrNull?.mediaId;
    setState(() {
      _images = images;
      _coverMediaId = cover;
    });
    _applyingContent = false;
  }

  Future<void> _restoreBaseline() async {
    final baseline = _baselineDraft;
    if (baseline == null) return;
    try {
      await ref.read(momentDraftStoreProvider).delete(widget.momentId);
    } on Object {
      if (mounted) _showFeedback('操作失败，请稍后重试。');
      return;
    }
    if (mounted) _applyDraft(baseline);
  }

  Future<bool> _saveDraftNow({bool reportFailure = false}) async {
    if (!_contentReady) return true;
    final store = ref.read(momentDraftStoreProvider);
    try {
      if (!_hasUnsavedChanges) {
        await store.delete(widget.momentId);
      } else {
        await store.write(widget.momentId, _currentDraft());
      }
      return true;
    } on Object {
      if (reportFailure && mounted) {
        _showFeedback('草稿保存失败，请稍后重试。');
      }
      return false;
    }
  }

  Future<void> _confirmLeave(MediaUploadTaskState uploadState) async {
    final hasPendingImages = _hasPendingImageWork(uploadState);
    final decision = await showModalBottomSheet<_LeaveDraftDecision>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final tokens = context.wenyouTokens;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            0,
            tokens.space16,
            tokens.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('要保存这次编辑吗？', style: Theme.of(context).textTheme.titleLarge),
              if (hasPendingImages) ...[
                SizedBox(height: tokens.space8),
                Text(
                  '尚未完成的图片不会保留，已完成的图片会随草稿保存。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                ),
              ],
              SizedBox(height: tokens.space16),
              FilledButton(
                key: const Key('moment-leave-save'),
                onPressed: () =>
                    Navigator.pop(context, _LeaveDraftDecision.save),
                child: const Text('保存草稿并退出'),
              ),
              SizedBox(height: tokens.space8),
              TextButton(
                key: const Key('moment-leave-discard'),
                onPressed: () =>
                    Navigator.pop(context, _LeaveDraftDecision.discard),
                child: const Text('不保存'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || decision == null) return;
    _draftTimer?.cancel();
    _cancelPendingImageUpload();
    final completed = decision == _LeaveDraftDecision.save
        ? await _saveDraftNow(reportFailure: true)
        : await _deleteDraft();
    if (!completed || !mounted) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  Future<bool> _deleteDraft() async {
    try {
      await ref.read(momentDraftStoreProvider).delete(widget.momentId);
      return true;
    } on Object {
      if (mounted) _showFeedback('操作失败，请稍后重试。');
      return false;
    }
  }

  void _showFeedback(String message) {
    showWenyouSnackBar(context, message, pacing: WenyouSnackBarPacing.extended);
  }
}

enum _LeaveDraftDecision { save, discard }

enum _ConflictDecision { keepMine, useLatest }

class _MomentPublishBar extends StatelessWidget {
  const _MomentPublishBar({
    required this.editing,
    required this.submitting,
    required this.onPressed,
  });

  final bool editing;
  final bool submitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = wenyouHorizontalPagePadding(context);
    return Material(
      color: tokens.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            tokens.space8,
            horizontal,
            tokens.space8,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                width: double.infinity,
                child: WenyouAsyncPrimaryButton(
                  key: const Key('moment-compose-submit'),
                  label: editing ? '保存' : '发布',
                  loadingLabel: editing ? '正在保存' : '正在发布',
                  isLoading: submitting,
                  icon: editing
                      ? WenyouIconIds.actionSave
                      : WenyouIconIds.actionSend,
                  onPressed: onPressed,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposeFailure extends StatelessWidget {
  const _ComposeFailure({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 600,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.statusOffline,
          title: '动态加载失败',
          message: failure?.userMessage ?? '请稍后重试。',
          detail: failure?.requestId == null
              ? null
              : '问题编号：${failure!.requestId}',
          action: OutlinedButton.icon(
            key: const Key('moment-compose-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
