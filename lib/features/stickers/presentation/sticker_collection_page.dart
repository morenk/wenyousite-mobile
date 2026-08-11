import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

class StickerCollectionPage extends ConsumerStatefulWidget {
  const StickerCollectionPage({super.key});

  @override
  ConsumerState<StickerCollectionPage> createState() =>
      _StickerCollectionPageState();
}

class _StickerCollectionPageState extends ConsumerState<StickerCollectionPage> {
  CancelToken? _uploadCancelToken;
  MediaUploadProgress? _uploadProgress;
  ApiFailure? _uploadFailure;

  bool get _uploading => _uploadCancelToken != null;

  @override
  void dispose() {
    _uploadCancelToken?.cancel('sticker page disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(stickersEnabledProvider);
    if (!enabled) return const _StickersUnavailablePage();
    final state = ref.watch(stickerCollectionControllerProvider);
    final notifier = ref.read(stickerCollectionControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('表情包')),
      body: switch (state.phase) {
        StickerCollectionPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        StickerCollectionPhase.failed => WenyouPageBody(
          maxWidth: 680,
          child: WenyouPanel(
            child: WenyouEmptyState(
              icon: Icons.cloud_off_outlined,
              title: '表情收藏没有加载完成',
              message: state.failure?.userMessage ?? '请稍后重试。',
              detail: state.failure?.requestId == null
                  ? null
                  : '请求 ID：${state.failure!.requestId}',
              action: OutlinedButton.icon(
                key: const Key('stickers-retry'),
                onPressed: notifier.load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重新加载'),
              ),
            ),
          ),
        ),
        StickerCollectionPhase.ready => _buildReady(context, state, notifier),
      },
    );
  }

  Widget _buildReady(
    BuildContext context,
    StickerCollectionState state,
    StickerCollectionController notifier,
  ) {
    final collection = state.collection!;
    final tokens = context.wenyouTokens;
    return RefreshIndicator(
      onRefresh: notifier.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          tokens.space12,
          tokens.space16,
          tokens.space12,
          tokens.space24,
        ),
        children: [
          WenyouConstrainedWidth(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WenyouSectionHeader(
                  title: '我的表情包',
                  subtitle: '可从相册添加，也可在帖子图片或私聊图片旁收藏。长按拖动即可排序。',
                ),
                SizedBox(height: tokens.space12),
                if (state.transientFailure != null) ...[
                  WenyouStatusBanner(
                    key: const Key('stickers-action-failure'),
                    tone: WenyouStatusTone.error,
                    message: state.transientFailure!.userMessage,
                    detail: state.transientFailure!.requestId == null
                        ? null
                        : '请求 ID：${state.transientFailure!.requestId}',
                    action: state.retrySource == null
                        ? TextButton(
                            onPressed: state.isBusy ? null : notifier.load,
                            child: const Text('刷新'),
                          )
                        : TextButton(
                            key: const Key('stickers-retry-import'),
                            onPressed: state.isBusy
                                ? null
                                : notifier.retryImport,
                            child: const Text('使用原请求重试'),
                          ),
                  ),
                  SizedBox(height: tokens.space12),
                ],
                if (_uploadFailure != null) ...[
                  WenyouStatusBanner(
                    tone: WenyouStatusTone.error,
                    message: _uploadFailure!.userMessage,
                    detail: _uploadFailure!.requestId == null
                        ? null
                        : '请求 ID：${_uploadFailure!.requestId}',
                  ),
                  SizedBox(height: tokens.space12),
                ],
                if (state.successMessage != null) ...[
                  WenyouStatusBanner(
                    tone: WenyouStatusTone.accent,
                    message: state.successMessage!,
                  ),
                  SizedBox(height: tokens.space12),
                ],
                WenyouPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${collection.items.length}/${collection.limit} 个收藏',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          FilledButton.icon(
                            key: const Key('stickers-add-gallery'),
                            onPressed:
                                state.isBusy || _uploading || collection.isFull
                                ? null
                                : _addFromGallery,
                            icon: _uploading
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_photo_alternate_outlined,
                                  ),
                            label: Text(_uploading ? '处理中' : '从相册添加'),
                          ),
                        ],
                      ),
                      if (_uploadProgress != null) ...[
                        SizedBox(height: tokens.space12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _uploadProgressLabel(_uploadProgress!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _uploadCancelToken?.cancel('user canceled'),
                              child: const Text('取消'),
                            ),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: _uploadProgress!.fraction,
                        ),
                      ],
                      if (collection.pendingImports.isNotEmpty) ...[
                        SizedBox(height: tokens.space12),
                        Text(
                          '正在处理 ${collection.pendingImports.length} 个表情，页面会自动刷新。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: tokens.space12),
                if (collection.items.isEmpty)
                  const WenyouPanel(
                    child: WenyouEmptyState(
                      icon: Icons.add_reaction_outlined,
                      title: '还没有收藏表情',
                      message: '从相册添加一张图片，或在帖子与私聊图片旁点按收藏。',
                    ),
                  )
                else
                  WenyouPanel(
                    padding: EdgeInsets.zero,
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: collection.items.length,
                      onReorderItem: (oldIndex, newIndex) {
                        if (state.isBusy) return;
                        final items = [...collection.items];
                        final item = items.removeAt(oldIndex);
                        items.insert(newIndex, item);
                        notifier.reorder(items);
                      },
                      itemBuilder: (context, index) {
                        final sticker = collection.items[index];
                        return _StickerListTile(
                          key: ValueKey(sticker.id),
                          sticker: sticker,
                          index: index,
                          removing:
                              state.action == StickerAction.removing &&
                              state.actionTarget == sticker.id,
                          disabled: state.isBusy || _uploading,
                          onRemove: () => _confirmRemove(sticker),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFromGallery() async {
    setState(() => _uploadFailure = null);
    try {
      final input = await ref.read(editorImagePickerProvider).pickFromGallery();
      if (!mounted || input == null) return;
      final cancelToken = CancelToken();
      setState(() {
        _uploadCancelToken = cancelToken;
        _uploadProgress = const MediaUploadProgress(
          stage: MediaUploadStage.preparing,
        );
      });
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
      await ref
          .read(stickerCollectionControllerProvider.notifier)
          .importMedia(uploaded.mediaId);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _uploadFailure = error is ApiFailure
            ? error
            : ApiFailure(userMessage: '图片没有添加成功，请重试。', cause: error);
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

  Future<void> _confirmRemove(UserSticker sticker) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除这个表情？'),
        content: const Text('移除后不会影响已经发送或发布的内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('stickers-remove-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(stickerCollectionControllerProvider.notifier)
        .remove(sticker.id);
  }

  String _uploadProgressLabel(MediaUploadProgress progress) {
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

class _StickerListTile extends StatelessWidget {
  const _StickerListTile({
    required this.sticker,
    required this.index,
    required this.removing,
    required this.disabled,
    required this.onRemove,
    super.key,
  });

  final UserSticker sticker;
  final int index;
  final bool removing;
  final bool disabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.image_outlined, color: tokens.mutedText),
    );
    return Column(
      children: [
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: SizedBox.square(
              dimension: 56,
              child: CachedNetworkImage(
                imageUrl: sticker.asset.thumbnailUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
            ),
          ),
          title: Text(sticker.asset.animated ? '动态表情' : '静态表情'),
          subtitle: Text('${sticker.asset.width} × ${sticker.asset.height}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: ValueKey('sticker-remove-${sticker.id}'),
                onPressed: disabled ? null : onRemove,
                tooltip: '移除表情',
                icon: removing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded),
              ),
              ReorderableDragStartListener(
                index: index,
                enabled: !disabled,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.drag_handle_rounded),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _StickersUnavailablePage extends StatelessWidget {
  const _StickersUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('表情包')),
      body: const WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: Icons.add_reaction_outlined,
            title: '表情包功能当前未开放',
            message: '服务端暂未启用此能力，请稍后再试。',
          ),
        ),
      ),
    );
  }
}
