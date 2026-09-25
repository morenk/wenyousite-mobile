import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_selection.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_actions.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_images.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_leave.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_upload.dart';

class MomentComposePage extends ConsumerWidget {
  const MomentComposePage({this.momentId, super.key});

  final String? momentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _MomentComposeEditor(
    key: ValueKey((momentId, ref.watch(sessionScopeProvider))),
    momentId: momentId,
  );
}

class _MomentComposeEditor extends ConsumerStatefulWidget {
  const _MomentComposeEditor({this.momentId, super.key});

  final String? momentId;

  @override
  ConsumerState<_MomentComposeEditor> createState() =>
      _MomentComposePageState();
}

class _MomentComposePageState extends ConsumerState<_MomentComposeEditor>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late final WenyouAtomicTextController _contentController;
  List<UploadedEditorImage> _images = [];
  String? _coverMediaId;
  List<String> _imageOrder = [];
  bool _waitingToPublish = false;
  bool _selectingImages = false;
  int? _hydratedVersion;
  List<MomentComposeUpload> _pendingImageUploads = const [];
  Timer? _draftTimer;
  MomentLocalDraft? _baselineDraft;
  var _baselineSignature = '';
  var _contentReady = false;
  var _draftReadScheduled = false;
  var _applyingContent = false;
  var _allowPop = false;
  var _leaving = false;
  var _suspended = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _contentController = WenyouAtomicTextController(
      initialMarkdown: '',
      maximumMarkdownLength: 1000,
    );
    _titleController.addListener(_onDraftChanged);
    _contentController.addListener(_onDraftChanged);
  }

  @override
  void dispose() {
    _leaving = true;
    for (final upload in _pendingImageUploads) {
      upload.generation++;
    }
    WidgetsBinding.instance.removeObserver(this);
    _draftTimer?.cancel();
    _titleController.removeListener(_onDraftChanged);
    _contentController.removeListener(_onDraftChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _suspended = true;
      _pauseUploads();
      for (final upload in _pendingImageUploads) {
        upload.active = false;
        upload.started = upload.failed;
      }
      _draftTimer?.cancel();
      unawaited(_saveDraftNow(reportFailure: true));
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _suspended) {
      _suspended = false;
      if (!_leaving) _pumpImageUploads();
    }
  }

  MomentComposerController get _composer =>
      ref.read(momentComposerControllerProvider(widget.momentId).notifier);

  MomentComposerState get _composerState =>
      ref.read(momentComposerControllerProvider(widget.momentId));

  @override
  Widget build(BuildContext context) {
    final provider = momentComposerControllerProvider(widget.momentId);
    final state = ref.watch(provider);
    final pendingImages = _pendingImageUploads
        .map((upload) {
          final taskState = ref.watch(
            mediaUploadTaskControllerProvider(upload.taskId),
          );
          ref.listen(mediaUploadTaskControllerProvider(upload.taskId), (
            previous,
            next,
          ) {
            if (next.pendingUpload != null &&
                next.pendingUpload != upload.pending) {
              upload.pending = next.pendingUpload;
              _onDraftChanged();
            }
          });
          return MomentPendingComposeImage(
            id: upload.id,
            input: upload.input,
            state: upload.failure == null || taskState.failure != null
                ? taskState
                : MediaUploadTaskState(
                    phase: MediaUploadTaskPhase.failed,
                    failure: upload.failure,
                  ),
            completed: false,
            active: upload.active,
            failed: upload.failed,
          );
        })
        .toList(growable: false);
    final uploadState = aggregateMomentUploadState(pendingImages);
    _hydrate(state.initialDetail);
    final editing = widget.momentId != null;
    if (!editing &&
        !_contentReady &&
        state.phase == MomentComposerPhase.editing) {
      _contentReady = true;
      _baselineDraft = _currentDraft();
      _baselineSignature = _signature();
      _scheduleDraftRead();
    }
    final editable =
        state.phase != MomentComposerPhase.loading &&
        state.phase != MomentComposerPhase.failed;
    final hasPendingImages = _pendingImageUploads.isNotEmpty;
    return PopScope(
      canPop:
          _allowPop ||
          (!state.isSubmitting &&
              !state.awaitingConfirmation &&
              !_hasUnsavedChanges &&
              !hasPendingImages),
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
                onPressed:
                    _waitingToPublish ||
                        state.isSubmitting ||
                        state.phase == MomentComposerPhase.succeeded
                    ? null
                    : _confirmDelete,
                tooltip: '删除动态',
                icon: const WenyouIcon(WenyouIconIds.actionDelete),
              ),
          ],
        ),
        body: switch (state.phase) {
          MomentComposerPhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MomentComposerPhase.failed => MomentComposeFailure(
            failure: state.failure,
            onRetry: () => ref.read(provider.notifier).load(),
          ),
          _ => _buildEditorBody(state, uploadState, pendingImages),
        },
        bottomNavigationBar: editable
            ? MomentPublishBar(
                editing: editing,
                submitting: state.isSubmitting || _waitingToPublish,
                pendingCount: _waitingToPublish
                    ? _pendingImageUploads.length
                    : 0,
                onCancelWait: _waitingToPublish ? _cancelPublishWait : null,
                awaitingConfirmation: state.awaitingConfirmation,
                cleanupPending: state.phase == MomentComposerPhase.succeeded,
                onPressed: _submit,
              )
            : null,
      ),
    );
  }

  Widget _buildEditorBody(
    MomentComposerState state,
    MediaUploadTaskState uploadState,
    List<MomentPendingComposeImage> pendingImages,
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
                if (state.failure != null || state.awaitingConfirmation) ...[
                  WenyouStatusBanner(
                    key: state.awaitingConfirmation
                        ? const Key('moment-compose-pending')
                        : null,
                    message: state.awaitingConfirmation
                        ? '请重试确认发布结果。已保留这次内容，确认前不能修改。'
                        : state.failure!.userMessage,
                    detail: wenyouFailureDetail(
                      state.failure,
                      treatAsWrite: true,
                    ),
                    tone: WenyouStatusTone.error,
                    action: state.failure?.businessCode == 40002
                        ? TextButton(
                            key: const Key('moment-compose-resolve-conflict'),
                            onPressed: _resolveConflict,
                            child: const Text('处理'),
                          )
                        : null,
                  ),
                  SizedBox(height: tokens.space8),
                ],
                IgnorePointer(
                  ignoring: (!state.canEditContent || _waitingToPublish),
                  child: MomentComposeImageStrip(
                    images: _images,
                    coverMediaId: _coverMediaId,
                    uploadState: uploadState,
                    pendingImages: pendingImages,
                    order: _imageOrder,
                    onAdd:
                        _imageOrder.length >= 9 ||
                            !state.canEditContent ||
                            _waitingToPublish ||
                            _selectingImages
                        ? null
                        : _pickAndUpload,
                    onRetry: _retryUpload,
                    onCoverSelected: _selectCover,
                    onRemove: _removeImage,
                    onReorder: _reorderImages,
                  ),
                ),
                SizedBox(height: tokens.space12),
                TextFormField(
                  key: const Key('moment-compose-title'),
                  controller: _titleController,
                  readOnly: (!state.canEditContent || _waitingToPublish),
                  maxLength: 40,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '标题（必填）',
                    hintText: '给这一刻起个标题',
                    counterText: '',
                  ),
                  validator: (value) {
                    final length = value?.trim().runes.length ?? 0;
                    return length < 2 || length > 40 ? '请输入 2～40 个字符的标题' : null;
                  },
                ),
                SizedBox(height: tokens.space8),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: tokens.border),
                      borderRadius: BorderRadius.circular(tokens.radiusCompact),
                    ),
                    child: WenyouAtomicTextEditor(
                      controller: _contentController,
                      enabled: state.canEditContent && !_waitingToPublish,
                      editorKey: const Key('moment-compose-content'),
                      placeholder: '分享此刻的想法…',
                      semanticLabel: '正文（选填）',
                      expands: true,
                    ),
                  ),
                ),
                if (_contentController.failure case final failure?) ...[
                  SizedBox(height: tokens.space8),
                  Text(
                    failure,
                    key: const Key('moment-compose-content-failure'),
                    style: Theme.of(context).textTheme.wenyouCaption.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
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
    _contentController.applyMarkdown(detail.content);
    _images = detail.images
        .map(
          (image) => UploadedEditorImage(
            mediaId: image.id,
            url: image.url,
            display: image.display,
            thumbnailUrl: image.thumbnailUrl,
            feedUrl: image.feedUrl,
            mediumUrl: image.mediumUrl,
            contentType: image.contentType,
            animated: image.animated,
            width: image.width,
            height: image.height,
          ),
        )
        .toList(growable: false);
    _coverMediaId = detail.card.coverMedia?.id;
    _imageOrder = _images.map((image) => image.mediaId).toList();
    _applyingContent = false;
    _contentReady = true;
    _baselineDraft = _currentDraft();
    _baselineSignature = _signature();
    _scheduleDraftRead();
  }

  Future<void> _pickAndUpload() async {
    if (_selectingImages || _waitingToPublish) return;
    setState(() => _selectingImages = true);
    final inputs = await pickEditorImages(
      context,
      ref,
      maximumSelection: 9 - _imageOrder.length,
      purpose: MediaUploadPurpose.moment,
    );
    if (!mounted) return;
    setState(() => _selectingImages = false);
    if (inputs == null || inputs.isEmpty || _waitingToPublish) return;
    final uploads = inputs.map(MomentComposeUpload.new).toList();
    setState(() {
      _pendingImageUploads = [..._pendingImageUploads, ...uploads];
      _imageOrder = [..._imageOrder, ...uploads.map((item) => item.id)];
      _coverMediaId ??= uploads.first.id;
    });
    _onDraftChanged();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pumpImageUploads();
    });
  }

  void _retryUpload(String id) {
    final upload = _pendingImageUploads
        .where((item) => item.id == id)
        .firstOrNull;
    if (upload == null || upload.active || _waitingToPublish) return;
    unawaited(_runImageUpload(upload));
  }

  void _pauseUploads() {
    _waitingToPublish = false;
    for (final upload in _pendingImageUploads) {
      final controller = ref.read(
        mediaUploadTaskControllerProvider(upload.taskId).notifier,
      );
      upload.pending =
          ref
              .read(mediaUploadTaskControllerProvider(upload.taskId))
              .pendingUpload ??
          upload.pending;
      upload.generation++;
      controller.pause();
    }
  }

  void _pumpImageUploads() {
    for (final upload
        in _pendingImageUploads.where((item) => !item.started).toList()) {
      upload.started = true;
      unawaited(_runImageUpload(upload));
    }
  }

  Future<void> _persistUpload(MomentComposeUpload upload) {
    return upload.persisting ??= (() async {
      final resolveOwner = ref.read(momentComposerOwnerResolverProvider);
      final store = ref.read(pendingMediaFileStoreProvider);
      final owner = await resolveOwner();
      upload.input = await store.persist(
        upload.input,
        accountId: owner,
        target: 'moment:${widget.momentId ?? 'new'}',
        attachmentId: upload.id,
      );
      upload.persisted = true;
    })().whenComplete(() => upload.persisting = null);
  }

  Future<void> _runImageUpload(MomentComposeUpload upload) async {
    final generation = ++upload.generation;
    upload
      ..active = true
      ..failed = false
      ..failure = null;
    if (mounted) setState(() {});
    final controller = ref.read(
      mediaUploadTaskControllerProvider(upload.taskId).notifier,
    );
    try {
      if (!upload.persisted) {
        await _persistUpload(upload);
        upload.persisted = true;
        if (!mounted ||
            _leaving ||
            _suspended ||
            generation != upload.generation ||
            !_pendingImageUploads.contains(upload)) {
          return;
        }
        await _saveDraftNow();
      }
    } on Object {
      // 保留预览与原始选择，让本机保存失败可由用户重试。
      if (!mounted ||
          _leaving ||
          generation != upload.generation ||
          !_pendingImageUploads.contains(upload)) {
        return;
      }
      setState(() {
        upload.active = false;
        upload.failed = true;
        _waitingToPublish = false;
      });
      return;
    }
    if (!mounted ||
        _leaving ||
        _suspended ||
        generation != upload.generation ||
        !_pendingImageUploads.contains(upload)) {
      return;
    }
    final image = upload.pending != null
        ? await controller.resumeUpload(upload.input, upload.pending!)
        : await controller.uploadInput(upload.input);
    if (!mounted ||
        _leaving ||
        generation != upload.generation ||
        !_pendingImageUploads.contains(upload)) {
      return;
    }
    upload.active = false;
    upload.pending = ref
        .read(mediaUploadTaskControllerProvider(upload.taskId))
        .pendingUpload;
    if (image == null) {
      upload.failure = ref
          .read(mediaUploadTaskControllerProvider(upload.taskId))
          .failure;
      setState(() {
        upload.failed = true;
        _waitingToPublish = false;
      });
      _onDraftChanged();
      return;
    }
    setState(() {
      _images = [..._images, image];
      _imageOrder = _imageOrder
          .map((id) => id == upload.id ? image.mediaId : id)
          .toList();
      if (_coverMediaId == upload.id) _coverMediaId = image.mediaId;
      _pendingImageUploads = _pendingImageUploads
          .where((item) => item != upload)
          .toList();
    });
    _onDraftChanged();
    if (_waitingToPublish && _pendingImageUploads.isEmpty) {
      unawaited(_submitReady());
    }
  }

  void _cancelPublishWait() => setState(() => _waitingToPublish = false);

  void _selectCover(String mediaId) {
    if (_coverMediaId == mediaId) return;
    setState(() => _coverMediaId = mediaId);
    _onDraftChanged();
  }

  void _removeImage(String id) {
    if (_waitingToPublish) return;
    final upload = _pendingImageUploads
        .where((item) => item.id == id)
        .firstOrNull;
    if (upload != null) {
      ref
          .read(mediaUploadTaskControllerProvider(upload.taskId).notifier)
          .reset();
    }
    setState(() {
      _pendingImageUploads = _pendingImageUploads
          .where((item) => item.id != id)
          .toList();
      _images = _images.where((image) => image.mediaId != id).toList();
      _imageOrder = _imageOrder.where((item) => item != id).toList();
      if (_coverMediaId == id) _coverMediaId = _imageOrder.firstOrNull;
    });
    _onDraftChanged();
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (_waitingToPublish ||
        oldIndex == newIndex ||
        oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= _imageOrder.length ||
        newIndex >= _imageOrder.length) {
      return;
    }
    setState(() {
      final order = [..._imageOrder];
      final item = order.removeAt(oldIndex);
      order.insert(newIndex, item);
      _imageOrder = order;
    });
    _onDraftChanged();
  }

  Future<void> _submit() async {
    if (_waitingToPublish || _composerState.isSubmitting) return;
    if (_composerState.phase == MomentComposerPhase.succeeded) {
      final saved = _composerState.savedDetail;
      if (saved != null) {
        await _finishSubmit(saved);
      } else {
        await _finishRemoval();
      }
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_contentController.flush()) {
      _showFeedback(_contentController.failure ?? '正文暂时无法保存，请重新编辑后再试。');
      return;
    }
    if (_pendingImageUploads.any((item) => item.failed)) {
      _showFeedback('请先重试或移除未完成的图片');
      return;
    }
    if (_pendingImageUploads.isNotEmpty) {
      setState(() => _waitingToPublish = true);
      return;
    }
    await _submitReady();
  }

  Future<void> _submitReady() async {
    if (!mounted || _composerState.isSubmitting) return;
    setState(() => _waitingToPublish = false);
    _draftTimer?.cancel();
    final saved = await _composer.submit(_draftInput(), draft: _currentDraft());
    if (saved == null || !mounted) return;
    await _finishSubmit(saved);
  }

  MomentDraftInput _draftInput() => MomentDraftInput(
    title: _titleController.text,
    content: _contentController.markdown,
    mediaIds: List.of(_imageOrder),
    coverMediaId: _coverMediaId,
  );

  Future<void> _finishSubmit(MomentDetail saved) async {
    _draftTimer?.cancel();
    if (widget.momentId != null && !await _deleteDraft()) return;
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
      await _composer.deleteDraft();
    } on Object {
      if (mounted) _showFeedback('操作失败，请稍后重试。');
      return;
    }
    _hydratedVersion = null;
    await controller.load();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '删除这条动态？',
      message: '删除后无法恢复，相关评论也不会再显示。',
      confirmLabel: '确认删除',
      cancelLabel: '取消',
      confirmKey: const Key('moment-compose-delete-confirm'),
      tone: WenyouConfirmationTone.destructive,
    );
    if (confirmed != true || !mounted) return;
    final removed = await ref
        .read(momentComposerControllerProvider(widget.momentId).notifier)
        .remove();
    if (!removed || !mounted) return;
    await _finishRemoval();
  }

  Future<void> _finishRemoval() async {
    _draftTimer?.cancel();
    if (!await _deleteDraft()) return;
    if (!mounted) return;
    _allowPop = true;
    ref.invalidate(momentFeedControllerProvider);
    context.go(AppRouteLocations.moments);
  }

  bool get _hasUnsavedChanges =>
      _contentReady && _signature() != _baselineSignature;

  String _signature() => jsonEncode({
    'title': _titleController.text,
    'content': _contentController.markdown,
    'coverMediaId': _coverMediaId,
    'mediaIds': _imageOrder,
    'pending': [
      for (final upload in _pendingImageUploads) upload.pending?.mediaId,
    ],
  });

  MomentLocalDraft _currentDraft() => MomentLocalDraft(
    title: _titleController.text,
    content: _contentController.markdown,
    images: [
      for (final id in _imageOrder)
        ..._images.where((image) => image.mediaId == id),
    ],
    imageOrder: List.unmodifiable(_imageOrder),
    pendingImages: [
      for (final upload in _pendingImageUploads)
        if (upload.persisted)
          MomentPendingDraftImage(
            id: upload.id,
            input: upload.input,
            pending: upload.pending,
          ),
    ],
    coverMediaId: _coverMediaId,
    updatedAt: DateTime.now(),
  );

  void _onDraftChanged() {
    if (_applyingContent || !_contentReady || !_composerState.canEditContent) {
      return;
    }
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

  void _restoreSavedDraft() {
    if (!mounted) return;
    final draft = ref
        .read(momentComposerControllerProvider(widget.momentId))
        .localDraft;
    if (draft == null) return;
    _applyDraft(draft);
    if (draft.pendingCreate != null) return;
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
    _contentController.applyMarkdown(draft.content);
    final images = draft.images.take(9).toList(growable: false);
    final uploads = draft.pendingImages
        .map(
          (item) => MomentComposeUpload(item.input, id: item.id)
            ..pending = item.pending
            ..persisted = true,
        )
        .toList();
    final validIds = {
      ...images.map((image) => image.mediaId),
      ...uploads.map((item) => item.id),
    };
    final order = [
      ...draft.imageOrder.where(validIds.contains),
      ...validIds.where((id) => !draft.imageOrder.contains(id)),
    ];
    final cover = order.contains(draft.coverMediaId)
        ? draft.coverMediaId
        : order.firstOrNull;
    setState(() {
      _images = images;
      _pendingImageUploads = uploads;
      _imageOrder = order;
      _coverMediaId = cover;
    });
    _applyingContent = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pumpImageUploads();
    });
  }

  Future<void> _restoreBaseline() async {
    final baseline = _baselineDraft;
    if (baseline == null ||
        !_composerState.canEditContent ||
        _waitingToPublish) {
      return;
    }
    _draftTimer?.cancel();
    try {
      await _composer.deleteDraft();
    } on Object {
      if (mounted) _showFeedback('操作失败，请稍后重试。');
      return;
    }
    if (mounted) _applyDraft(baseline);
  }

  Future<bool> _saveDraftNow({bool reportFailure = false}) async {
    if (!_contentReady) return true;
    final composer = _composer;
    if (_composerState.awaitingConfirmation) return true;
    if (!_composerState.canEditContent) return false;
    try {
      if (!_hasUnsavedChanges) {
        return await composer.deleteDraft();
      } else {
        return await composer.saveDraft(_currentDraft());
      }
    } on Object {
      if (reportFailure && mounted) {
        _showFeedback('草稿保存失败，请稍后重试。');
      }
      return false;
    }
  }

  Future<void> _confirmLeave(MediaUploadTaskState uploadState) async {
    if (_composerState.isSubmitting) return;
    if (_waitingToPublish) setState(() => _waitingToPublish = false);
    final pending = _composerState.awaitingConfirmation;
    final hasPendingImages = _pendingImageUploads.isNotEmpty;
    final decision = await showMomentLeaveDraftSheet(
      context,
      pending: pending,
      hasPendingImages: hasPendingImages,
    );
    if (!mounted || decision == null) return;
    _draftTimer?.cancel();
    _waitingToPublish = false;
    if (decision == MomentLeaveDraftDecision.save) {
      try {
        await Future.wait(
          _pendingImageUploads
              .where((item) => !item.persisted)
              .map(_persistUpload),
        );
      } on Object {
        if (mounted) _showFeedback('图片保存失败，请重试后退出。');
        return;
      }
      if (!mounted) return;
    }
    final completed = decision == MomentLeaveDraftDecision.save
        ? await _saveDraftNow(reportFailure: true)
        : await _deleteDraft();
    if (!completed || !mounted) return;
    _leaving = true;
    _pauseUploads();
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  Future<bool> _deleteDraft() async {
    try {
      return await _composer.deleteDraft();
    } on Object {
      if (mounted) _showFeedback('草稿清理失败，请重试。');
      return false;
    }
  }

  void _showFeedback(String message) {
    showWenyouSnackBar(
      context,
      message,
      pacing: WenyouSnackBarPacing.extended,
      tone: WenyouSnackBarTone.error,
    );
  }
}

enum _ConflictDecision { keepMine, useLatest }
