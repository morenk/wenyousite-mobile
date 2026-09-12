import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_reorder_grid.dart';

class StickerCollectionPage extends ConsumerStatefulWidget {
  const StickerCollectionPage({super.key});

  @override
  ConsumerState<StickerCollectionPage> createState() =>
      _StickerCollectionPageState();
}

class _StickerCollectionPageState extends ConsumerState<StickerCollectionPage> {
  final Object _uploadTaskId = Object();
  final _scrollController = ScrollController();
  final _viewportKey = GlobalKey();
  bool _managing = false;
  bool _dragging = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(stickersEnabledProvider);
    if (!enabled) return const _StickersUnavailablePage();
    final state = ref.watch(stickerCollectionControllerProvider);
    final uploadState = ref.watch(
      mediaUploadTaskControllerProvider(_uploadTaskId),
    );
    final notifier = ref.read(stickerCollectionControllerProvider.notifier);
    return WenyouSettingsTypography(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('表情包'),
          actions: [
            TextButton(
              key: const Key('stickers-manage'),
              onPressed: _dragging
                  ? null
                  : () => setState(() => _managing = !_managing),
              child: Text(_managing ? '完成' : '管理'),
            ),
          ],
        ),
        body: switch (state.phase) {
          StickerCollectionPhase.loading => const WenyouPageBody(
            maxWidth: 680,
            child: StickerGridSkeleton(),
          ),
          StickerCollectionPhase.failed => WenyouPageBody(
            maxWidth: 680,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.statusOffline,
                title: '表情收藏加载失败',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: wenyouFailureDetail(state.failure),
                action: OutlinedButton.icon(
                  key: const Key('stickers-retry'),
                  onPressed: notifier.load,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
              ),
            ),
          ),
          StickerCollectionPhase.ready => _buildReady(
            context,
            state,
            notifier,
            uploadState,
          ),
        },
      ),
    );
  }

  Widget _buildReady(
    BuildContext context,
    StickerCollectionState state,
    StickerCollectionController notifier,
    MediaUploadTaskState uploadState,
  ) {
    final collection = state.collection!;
    final tokens = context.wenyouTokens;
    final horizontal = wenyouHorizontalPagePadding(context);
    return RefreshIndicator(
      notificationPredicate: (_) => !_dragging && !state.isBusy,
      onRefresh: notifier.load,
      child: ListView(
        key: _viewportKey,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontal,
          tokens.space16,
          horizontal,
          tokens.space24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          WenyouConstrainedWidth(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: tokens.space12,
                  children: [
                    Text(
                      '长按拖动排序',
                      style: Theme.of(context).textTheme.wenyouCaption,
                    ),
                    Text(
                      '${collection.items.length}/${collection.limit} 个收藏',
                      style: Theme.of(context).textTheme.wenyouCaption,
                    ),
                  ],
                ),
                SizedBox(height: tokens.space12),
                if (state.transientFailure != null) ...[
                  WenyouStatusBanner(
                    key: const Key('stickers-action-failure'),
                    tone: WenyouStatusTone.error,
                    message: state.transientFailure!.userMessage,
                    detail: wenyouFailureDetail(
                      state.transientFailure,
                      treatAsWrite: true,
                    ),
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
                            child: const Text('重试'),
                          ),
                  ),
                  SizedBox(height: tokens.space12),
                ],
                if (uploadState.failure case final uploadFailure?) ...[
                  WenyouStatusBanner(
                    key: const Key('stickers-upload-failure'),
                    tone: WenyouStatusTone.error,
                    message: uploadFailure.userMessage,
                    detail: uploadFailure.resolvedPresentation.problemDetail,
                    action: uploadFailure.canRetry
                        ? TextButton(
                            key: const Key('stickers-retry-upload'),
                            onPressed: _retryUpload,
                            child: const Text('重试上传'),
                          )
                        : null,
                  ),
                  SizedBox(height: tokens.space12),
                ],
                if (uploadState.isBusy) ...[
                  SizedBox(height: tokens.space12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          uploadState.progressLabel,
                          style: Theme.of(context).textTheme.wenyouCaption,
                        ),
                      ),
                      TextButton(
                        key: const Key('stickers-cancel-upload'),
                        onPressed: () => ref
                            .read(
                              mediaUploadTaskControllerProvider(
                                _uploadTaskId,
                              ).notifier,
                            )
                            .cancel(),
                        child: const Text('取消'),
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: uploadState.progress?.fraction,
                  ),
                ],
                if (collection.pendingImports.isNotEmpty) ...[
                  SizedBox(height: tokens.space12),
                  Text(
                    '正在处理 ${collection.pendingImports.length} 个表情…',
                    style: Theme.of(context).textTheme.wenyouCaption,
                  ),
                ],
                SizedBox(height: tokens.space12),
                StickerReorderGrid(
                  items: collection.items,
                  scrollController: _scrollController,
                  viewportKey: _viewportKey,
                  managing: _managing,
                  canRemove: !state.isBusy && !uploadState.isBusy,
                  enabled:
                      !uploadState.isBusy &&
                      (!state.isBusy ||
                          (state.action == StickerAction.reordering &&
                              state.transientFailure == null)),
                  resetSignal: state.transientFailure,
                  onDragChanged: (value) => setState(() => _dragging = value),
                  onReorder: notifier.reorder,
                  onRemove: _confirmRemove,
                  addButton: Tooltip(
                    message: '从相册添加',
                    child: OutlinedButton(
                      key: const Key('stickers-add-gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: tokens.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(tokens.radius12),
                        ),
                      ),
                      onPressed:
                          state.isBusy ||
                              uploadState.isBusy ||
                              collection.isFull ||
                              _dragging
                          ? null
                          : _addFromGallery,
                      child: Semantics(
                        label: '从相册添加',
                        child: const WenyouIcon(WenyouIconIds.actionAddImage),
                      ),
                    ),
                  ),
                ),
                if (collection.items.isEmpty) ...[
                  SizedBox(height: tokens.space24),
                  const WenyouEmptyState(
                    icon: WenyouIconIds.actionAddReaction,
                    title: '还没有收藏表情',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFromGallery() async {
    await _uploadAndImport(retry: false);
  }

  Future<void> _retryUpload() async {
    await _uploadAndImport(retry: true);
  }

  Future<void> _uploadAndImport({required bool retry}) async {
    final uploadController = ref.read(
      mediaUploadTaskControllerProvider(_uploadTaskId).notifier,
    );
    final uploaded = retry
        ? await uploadController.retryUpload()
        : await pickCropAndUploadEditorImage(
            context,
            ref,
            uploadTaskId: _uploadTaskId,
            purpose: MediaUploadPurpose.stickerSource,
            title: '裁剪收藏表情',
          );
    if (!mounted || uploaded == null) return;
    await ref
        .read(stickerCollectionControllerProvider.notifier)
        .importMedia(uploaded.mediaId);
  }

  Future<void> _confirmRemove(UserSticker sticker) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '移除这个表情？',
      message: '移除后不会影响已经发送或发布的内容。',
      confirmLabel: '确认移除',
      confirmKey: const Key('stickers-remove-confirm'),
      tone: WenyouConfirmationTone.destructive,
    );
    if (!confirmed || !mounted) return;
    await ref
        .read(stickerCollectionControllerProvider.notifier)
        .remove(sticker.id);
  }
}

class _StickersUnavailablePage extends StatelessWidget {
  const _StickersUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return WenyouSettingsTypography(
      child: Scaffold(
        appBar: AppBar(title: const Text('表情包')),
        body: const WenyouPageBody(
          maxWidth: 600,
          child: WenyouPanel(
            child: WenyouEmptyState(
              icon: WenyouIconIds.actionAddReaction,
              title: '表情包功能当前未开放',
            ),
          ),
        ),
      ),
    );
  }
}
