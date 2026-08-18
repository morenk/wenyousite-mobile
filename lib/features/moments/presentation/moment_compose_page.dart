import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

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
      _baselineSignature = _signature();
      _scheduleDraftRead();
    }
    final editable =
        state.phase != MomentComposerPhase.loading &&
        state.phase != MomentComposerPhase.failed;
    return PopScope(
      canPop: _allowPop || (!_hasUnsavedChanges && !uploadState.isBusy),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? '编辑动态' : '发布动态'),
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
          _ => _buildEditorBody(state, provider),
        },
        bottomNavigationBar: editable
            ? _MomentPublishBar(
                editing: editing,
                submitting: state.isSubmitting,
                imageCount: _images.length,
                uploading: uploadState.isBusy,
                onImagesPressed: state.isSubmitting
                    ? null
                    : () => _openImagesEditor(state),
                onPressed: uploadState.isBusy ? null : _submit,
              )
            : null,
      ),
    );
  }

  Widget _buildEditorBody(
    MomentComposerState state,
    AutoDisposeStateNotifierProvider<
      MomentComposerController,
      MomentComposerState
    >
    provider,
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
                            key: const Key('moment-compose-reload-conflict'),
                            onPressed: () => ref.read(provider.notifier).load(),
                            child: const Text('读取最新版'),
                          )
                        : null,
                  ),
                  SizedBox(height: tokens.space8),
                ],
                TextFormField(
                  key: const Key('moment-compose-title'),
                  controller: _titleController,
                  maxLength: 40,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '用 2～40 个字符概括这一刻',
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
                      labelText: '正文（可选）',
                      hintText: '动态正文是纯文本，不解析 Markdown',
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

  Future<void> _openImagesEditor(MomentComposerState state) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (context, sheetRef, _) {
          final uploadState = sheetRef.watch(
            mediaUploadTaskControllerProvider(_uploadTaskId),
          );
          return StatefulBuilder(
            builder: (context, setSheetState) => FractionallySizedBox(
              heightFactor: 0.78,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.wenyouTokens.space12,
                  0,
                  context.wenyouTokens.space12,
                  context.wenyouTokens.space16,
                ),
                child: _MomentImagesEditor(
                  images: _images,
                  coverMediaId: _coverMediaId,
                  uploadState: uploadState,
                  onAdd:
                      _images.length >= 9 ||
                          state.isSubmitting ||
                          uploadState.isBusy
                      ? null
                      : () async {
                          await _pickAndUpload();
                          if (sheetContext.mounted) setSheetState(() {});
                        },
                  onCancelUpload: uploadState.isBusy
                      ? _cancelPendingImageUpload
                      : null,
                  onRetryUpload:
                      uploadState.failure?.canRetry == true &&
                          !state.isSubmitting
                      ? () async {
                          await _retryUpload();
                          if (sheetContext.mounted) setSheetState(() {});
                        }
                      : null,
                  onCoverSelected: (mediaId) {
                    setState(() => _coverMediaId = mediaId);
                    setSheetState(() {});
                    _onDraftChanged();
                  },
                  onRemove: (mediaId) {
                    setState(() {
                      _images = _images
                          .where((image) => image.mediaId != mediaId)
                          .toList(growable: false);
                      if (_coverMediaId == mediaId) {
                        _coverMediaId = _images.isEmpty
                            ? null
                            : _images.first.mediaId;
                      }
                    });
                    setSheetState(() {});
                    _onDraftChanged();
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      final reordered = [..._images];
                      final image = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, image);
                      _images = List.unmodifiable(reordered);
                    });
                    setSheetState(() {});
                    _onDraftChanged();
                  },
                ),
              ),
            ),
          );
        },
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
    _pendingImageInputs = inputs;
    _pendingImageIndex = 0;
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
      });
      _pendingImageIndex += 1;
      _onDraftChanged();
    }
    _pendingImageInputs = const [];
    _pendingImageIndex = 0;
  }

  void _cancelPendingImageUpload() {
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
    _pendingImageInputs = const [];
    _pendingImageIndex = 0;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await ref
        .read(momentComposerControllerProvider(widget.momentId).notifier)
        .submit(
          MomentDraftInput(
            title: _titleController.text,
            content: _contentController.text,
            mediaIds: _images.map((image) => image.mediaId).toList(),
            coverMediaId: _coverMediaId,
          ),
        );
    if (saved == null || !mounted) return;
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

  String _signature() => jsonEncode({
    'title': _titleController.text,
    'content': _contentController.text,
    'coverMediaId': _coverMediaId,
    'mediaIds': [for (final image in _images) image.mediaId],
  });

  void _onDraftChanged() {
    if (_applyingContent || !_contentReady) return;
    if (mounted) setState(() {});
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 500), _saveDraftNow);
  }

  void _scheduleDraftRead() {
    if (_draftReadScheduled) return;
    _draftReadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerSavedDraft());
  }

  Future<void> _offerSavedDraft() async {
    final draft = await ref
        .read(momentDraftStoreProvider)
        .read(widget.momentId);
    if (!mounted || draft == null) return;
    final restore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('恢复未完成的动态？'),
        content: Text('已在这台设备上保存 ${_formatDraftTime(draft.updatedAt)} 的草稿。'),
        actions: [
          TextButton(
            key: const Key('moment-draft-discard'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('放弃草稿'),
          ),
          FilledButton(
            key: const Key('moment-draft-restore'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('继续编辑'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (restore != true) {
      await ref.read(momentDraftStoreProvider).delete(widget.momentId);
      return;
    }
    _applyingContent = true;
    _titleController.text = draft.title;
    _contentController.text = draft.content;
    setState(() {
      _images = draft.images;
      _coverMediaId = draft.coverMediaId;
    });
    _applyingContent = false;
  }

  Future<void> _saveDraftNow() async {
    if (!_contentReady) return;
    final store = ref.read(momentDraftStoreProvider);
    if (!_hasUnsavedChanges) {
      await store.delete(widget.momentId);
      return;
    }
    await store.write(
      widget.momentId,
      MomentLocalDraft(
        title: _titleController.text,
        content: _contentController.text,
        images: List.unmodifiable(_images),
        coverMediaId: _coverMediaId,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final uploadController = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    if (ref.read(mediaUploadTaskControllerProvider(_uploadTaskId)).isBusy) {
      uploadController.cancel();
      if (!_hasUnsavedChanges && mounted) {
        setState(() => _allowPop = true);
        Navigator.of(context).pop();
        return;
      }
    }
    final decision = await showDialog<_LeaveDraftDecision>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('离开动态编辑？'),
        content: const Text('当前修改会自动保存在这台设备上，下次进入时可以继续编辑。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续编辑'),
          ),
          TextButton(
            key: const Key('moment-leave-discard'),
            onPressed: () =>
                Navigator.pop(context, _LeaveDraftDecision.discard),
            child: const Text('放弃修改'),
          ),
          FilledButton(
            key: const Key('moment-leave-save'),
            onPressed: () => Navigator.pop(context, _LeaveDraftDecision.save),
            child: const Text('保留并退出'),
          ),
        ],
      ),
    );
    if (!mounted || decision == null) return;
    _draftTimer?.cancel();
    final store = ref.read(momentDraftStoreProvider);
    if (decision == _LeaveDraftDecision.save) {
      await _saveDraftNow();
    } else {
      await store.delete(widget.momentId);
    }
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  String _formatDraftTime(DateTime value) {
    final local = value.toLocal();
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${local.month}月${local.day}日 '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

enum _LeaveDraftDecision { save, discard }

class _MomentPublishBar extends StatelessWidget {
  const _MomentPublishBar({
    required this.editing,
    required this.submitting,
    required this.imageCount,
    required this.uploading,
    required this.onImagesPressed,
    required this.onPressed,
  });

  final bool editing;
  final bool submitting;
  final int imageCount;
  final bool uploading;
  final VoidCallback? onImagesPressed;
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
              child: Row(
                children: [
                  OutlinedButton.icon(
                    key: const Key('moment-compose-images'),
                    onPressed: onImagesPressed,
                    icon: uploading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const WenyouIcon(WenyouIconIds.contentGallery),
                    label: Text('图片 $imageCount/9'),
                  ),
                  SizedBox(width: tokens.space8),
                  Expanded(
                    child: WenyouAsyncPrimaryButton(
                      key: const Key('moment-compose-submit'),
                      label: editing ? '保存修改' : '发布动态',
                      loadingLabel: editing ? '正在保存' : '正在发布',
                      isLoading: submitting,
                      icon: editing
                          ? WenyouIconIds.actionSave
                          : WenyouIconIds.actionSend,
                      onPressed: onPressed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MomentImagesEditor extends StatelessWidget {
  const _MomentImagesEditor({
    required this.images,
    required this.coverMediaId,
    required this.uploadState,
    required this.onAdd,
    required this.onCancelUpload,
    required this.onRetryUpload,
    required this.onCoverSelected,
    required this.onRemove,
    required this.onReorder,
  });

  final List<UploadedEditorImage> images;
  final String? coverMediaId;
  final MediaUploadTaskState uploadState;
  final VoidCallback? onAdd;
  final VoidCallback? onCancelUpload;
  final VoidCallback? onRetryUpload;
  final ValueChanged<String> onCoverSelected;
  final ValueChanged<String> onRemove;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WenyouSectionHeader(
            title: '图片 ${images.length}/9',
            subtitle: '长按拖动排序；封面只在信息流裁切，详情始终完整展示。',
            trailing: IconButton.filledTonal(
              key: const Key('moment-compose-add-image'),
              onPressed: onAdd,
              tooltip: '从相册添加图片',
              icon: const WenyouIcon(WenyouIconIds.actionAddImage),
            ),
          ),
          if (uploadState.isBusy) ...[
            SizedBox(height: tokens.space12),
            LinearProgressIndicator(value: uploadState.progress?.fraction),
            Row(
              children: [
                Expanded(child: Text(uploadState.progressLabel)),
                TextButton(
                  key: const Key('moment-compose-cancel-upload'),
                  onPressed: onCancelUpload,
                  child: const Text('取消'),
                ),
              ],
            ),
          ],
          if (uploadState.failure case final failure?) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('moment-compose-upload-failure'),
              message: failure.userMessage,
              detail: failure.requestId == null
                  ? null
                  : '问题编号：${failure.requestId}',
              tone: WenyouStatusTone.error,
              action: failure.canRetry
                  ? TextButton(
                      key: const Key('moment-compose-retry-upload'),
                      onPressed: onRetryUpload,
                      child: const Text('重试上传'),
                    )
                  : null,
            ),
          ],
          if (images.isEmpty) ...[
            SizedBox(height: tokens.space16),
            const WenyouEmptyState(
              icon: WenyouIconIds.contentGallery,
              title: '还没有图片',
              message: '可以发布纯文字动态；添加图片后可指定其中一张为封面。',
            ),
          ] else ...[
            SizedBox(height: tokens.space12),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: images.length,
              onReorderItem: onReorder,
              itemBuilder: (context, index) {
                final image = images[index];
                return ListTile(
                  key: ValueKey(image.mediaId),
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radius12),
                    child: SizedBox.square(
                      dimension: 56,
                      child: WenyouCachedImage(
                        imageUrl: image.url,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  title: Text('图片 ${index + 1}'),
                  subtitle: RadioGroup<String>(
                    groupValue: coverMediaId,
                    onChanged: (value) {
                      if (value != null) onCoverSelected(value);
                    },
                    child: RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: image.mediaId,
                      title: const Text('设为信息流封面'),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => onRemove(image.mediaId),
                        tooltip: '移除图片 ${index + 1}',
                        icon: const WenyouIcon(WenyouIconIds.actionClose),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: WenyouIcon(WenyouIconIds.actionReorder),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
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
