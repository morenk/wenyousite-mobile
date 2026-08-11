import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_draft_store.dart';
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
  MediaUploadProgress? _uploadProgress;
  CancelToken? _uploadCancelToken;
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
    _uploadCancelToken?.cancel('moment composer disposed');
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
      canPop: _allowPop || !_hasUnsavedChanges,
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
                icon: const Icon(Icons.delete_outline_rounded),
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
          _ => WenyouPageBody(
            maxWidth: 600,
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
                          : '请求 ID：${state.failure!.requestId}',
                      tone: WenyouStatusTone.error,
                      action: state.failure!.businessCode == 40002
                          ? TextButton(
                              key: const Key('moment-compose-reload-conflict'),
                              onPressed: () =>
                                  ref.read(provider.notifier).load(),
                              child: const Text('读取最新版'),
                            )
                          : null,
                    ),
                    SizedBox(height: context.wenyouTokens.space12),
                  ],
                  WenyouPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                            return length < 2 || length > 40
                                ? '请输入 2～40 个字符的标题'
                                : null;
                          },
                        ),
                        SizedBox(height: context.wenyouTokens.space12),
                        TextFormField(
                          key: const Key('moment-compose-content'),
                          controller: _contentController,
                          minLines: 6,
                          maxLines: 14,
                          maxLength: 1000,
                          decoration: const InputDecoration(
                            labelText: '正文（可选）',
                            hintText: '动态正文是纯文本，不解析 Markdown',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.wenyouTokens.space12),
                  _MomentImagesEditor(
                    images: _images,
                    coverMediaId: _coverMediaId,
                    uploadProgress: _uploadProgress,
                    onAdd: _images.length >= 9 || state.isSubmitting
                        ? null
                        : _pickAndUpload,
                    onCancelUpload: _uploadProgress == null
                        ? null
                        : () => _uploadCancelToken?.cancel('user cancelled'),
                    onCoverSelected: (mediaId) {
                      setState(() => _coverMediaId = mediaId);
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
                      _onDraftChanged();
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final reordered = [..._images];
                        final image = reordered.removeAt(oldIndex);
                        reordered.insert(newIndex, image);
                        _images = List.unmodifiable(reordered);
                      });
                      _onDraftChanged();
                    },
                  ),
                  SizedBox(height: context.wenyouTokens.space16),
                ],
              ),
            ),
          ),
        },
        bottomNavigationBar: editable
            ? _MomentPublishBar(
                editing: editing,
                submitting: state.isSubmitting,
                onPressed: _uploadProgress == null ? _submit : null,
              )
            : null,
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
    try {
      final input = await ref.read(editorImagePickerProvider).pickFromGallery();
      if (input == null || !mounted) return;
      final cancelToken = CancelToken();
      _uploadCancelToken = cancelToken;
      setState(() {
        _uploadProgress = const MediaUploadProgress(
          stage: MediaUploadStage.preparing,
        );
      });
      final image = await ref
          .read(mediaUploadRepositoryProvider)
          .uploadImage(
            input,
            cancelToken: cancelToken,
            onProgress: (progress) {
              if (mounted) setState(() => _uploadProgress = progress);
            },
          );
      if (!mounted) return;
      setState(() {
        _images = List.unmodifiable([..._images, image]);
        _coverMediaId ??= image.mediaId;
        _uploadProgress = null;
      });
      _onDraftChanged();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _uploadProgress = null);
      final message = error is ApiFailure ? error.userMessage : '图片没有上传成功，请重试。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      _uploadCancelToken = null;
    }
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
        content: Text(
          '已在本机保存 ${_formatDraftTime(draft.updatedAt)} 的草稿，包含文字和图片顺序。',
        ),
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
    required this.onPressed,
  });

  final bool editing;
  final bool submitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
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
                  label: editing ? '保存修改' : '发布动态',
                  loadingLabel: editing ? '正在保存' : '正在发布',
                  isLoading: submitting,
                  icon: editing ? Icons.save_outlined : Icons.send_rounded,
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

class _MomentImagesEditor extends StatelessWidget {
  const _MomentImagesEditor({
    required this.images,
    required this.coverMediaId,
    required this.uploadProgress,
    required this.onAdd,
    required this.onCancelUpload,
    required this.onCoverSelected,
    required this.onRemove,
    required this.onReorder,
  });

  final List<UploadedEditorImage> images;
  final String? coverMediaId;
  final MediaUploadProgress? uploadProgress;
  final VoidCallback? onAdd;
  final VoidCallback? onCancelUpload;
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
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
          ),
          if (uploadProgress != null) ...[
            SizedBox(height: tokens.space12),
            LinearProgressIndicator(value: uploadProgress!.fraction),
            Row(
              children: [
                Expanded(child: Text(_progressLabel(uploadProgress!))),
                TextButton(
                  key: const Key('moment-compose-cancel-upload'),
                  onPressed: onCancelUpload,
                  child: const Text('取消'),
                ),
              ],
            ),
          ],
          if (images.isEmpty) ...[
            SizedBox(height: tokens.space16),
            const WenyouEmptyState(
              icon: Icons.photo_library_outlined,
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
                      child: CachedNetworkImage(
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
                        icon: const Icon(Icons.close_rounded),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.drag_handle_rounded),
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

  String _progressLabel(MediaUploadProgress progress) {
    return switch (progress.stage) {
      MediaUploadStage.preparing => '正在准备图片…',
      MediaUploadStage.uploading when progress.fraction != null =>
        '正在上传 ${(progress.fraction! * 100).round()}%',
      MediaUploadStage.uploading => '正在上传图片…',
      MediaUploadStage.confirming => '正在确认图片…',
      MediaUploadStage.processing => '图片正在安全处理中…',
    };
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
          icon: Icons.cloud_off_outlined,
          title: '动态没有加载完成',
          message: failure?.userMessage ?? '请稍后重试。',
          detail: failure?.requestId == null
              ? null
              : '请求 ID：${failure!.requestId}',
          action: OutlinedButton.icon(
            key: const Key('moment-compose-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
