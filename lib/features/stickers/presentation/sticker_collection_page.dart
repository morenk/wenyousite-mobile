import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';
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
  MediaUploadInput? _pendingInput;
  String? _pendingImportId;
  bool _pendingFailed = false;

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
    ref.listen(stickerCollectionControllerProvider, (previous, next) {
      final id = _pendingImportId;
      if (id == null ||
          previous?.collection == null ||
          next.collection == null) {
        return;
      }
      final wasPending = previous!.collection!.pendingImports.any(
        (item) => item.id == id,
      );
      final stillPending = next.collection!.pendingImports.any(
        (item) => item.id == id,
      );
      if (wasPending && !stillPending && mounted) {
        setState(() {
          _pendingFailed = next.transientFailure != null;
          if (!_pendingFailed) {
            _pendingInput = null;
            _pendingImportId = null;
          }
        });
      }
    });
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
                  label: const Text('重试'),
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
                if (state.transientFailure != null &&
                    _pendingInput == null) ...[
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
                SizedBox(height: tokens.space12),
                StickerReorderGrid(
                  items: collection.items,
                  pendingTiles: [
                    if (_pendingInput != null)
                      _buildPendingTile(context, uploadState, state),
                    for (final pending in collection.pendingImports)
                      if (pending.id != _pendingImportId)
                        _buildServerPendingTile(context, pending),
                  ],
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
                          borderRadius: BorderRadius.circular(
                            tokens.radiusControl,
                          ),
                        ),
                      ),
                      onPressed:
                          state.isBusy ||
                              uploadState.isBusy ||
                              _pendingInput != null ||
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
                if (collection.items.isEmpty &&
                    collection.pendingImports.isEmpty &&
                    _pendingInput == null) ...[
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
    final inputs = await pickAndCropEditorImages(
      context,
      ref,
      purpose: MediaUploadPurpose.stickerSource,
      title: '裁剪收藏表情',
    );
    if (!mounted || inputs == null || inputs.isEmpty) return;
    final input = inputs.single;
    setState(() {
      _pendingInput = input;
      _pendingImportId = null;
      _pendingFailed = false;
    });
    final uploaded = await ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .uploadInput(input);
    if (!mounted || !identical(_pendingInput, input) || uploaded == null) {
      return;
    }
    await _importUploaded(uploaded.mediaId);
  }

  Future<void> _retryUpload() async {
    final input = _pendingInput;
    setState(() => _pendingFailed = false);
    final uploaded = await ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .retryUpload();
    if (!mounted || !identical(_pendingInput, input) || uploaded == null) {
      return;
    }
    await _importUploaded(uploaded.mediaId);
  }

  Future<void> _importUploaded(String mediaId) async {
    final result = await ref
        .read(stickerCollectionControllerProvider.notifier)
        .importMedia(mediaId);
    if (!mounted) return;
    if (result == null) {
      setState(() => _pendingFailed = true);
      return;
    }
    if (result.status == StickerImportStatus.processing) {
      setState(() {
        _pendingImportId = result.id;
        _pendingFailed = false;
      });
      return;
    }
    setState(() {
      _pendingInput = null;
      _pendingImportId = null;
      _pendingFailed = false;
    });
    if (result.alreadySaved) showWenyouSnackBar(context, '已经收藏过这个表情。');
  }

  Widget _buildPendingTile(
    BuildContext context,
    MediaUploadTaskState upload,
    StickerCollectionState collectionState,
  ) {
    final tokens = context.wenyouTokens;
    final pendingOnServer =
        _pendingImportId != null &&
        (collectionState.collection?.pendingImports.any(
              (item) => item.id == _pendingImportId,
            ) ??
            false);
    final failed = upload.failure != null || _pendingFailed;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusCompact),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PendingImageOverlay(
            key: const Key('sticker-local-pending'),
            active:
                upload.isActivelyWorking ||
                collectionState.action == StickerAction.importing ||
                pendingOnServer,
            failed: failed,
            onFailureTap: () => _showPendingFailure(upload, collectionState),
            child: SizedBox.expand(
              child: MediaUploadInputImage(
                input: _pendingInput!,
                fit: BoxFit.contain,
                cacheWidth: 256,
              ),
            ),
          ),
          if (!failed &&
              _pendingImportId == null &&
              collectionState.action != StickerAction.importing)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.filledTonal(
                key: const Key('stickers-cancel-upload'),
                tooltip: '取消添加表情',
                onPressed: _cancelPendingSticker,
                icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  void _cancelPendingSticker() {
    ref
        .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
        .cancel();
    setState(() {
      _pendingInput = null;
      _pendingImportId = null;
      _pendingFailed = false;
    });
  }

  Widget _buildServerPendingTile(BuildContext context, StickerImport pending) {
    final tokens = context.wenyouTokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusCompact),
      child: PendingImageOverlay(
        key: ValueKey('sticker-server-pending-${pending.id}'),
        active: false,
        semanticLabel: '收藏表情待处理',
        child: ColoredBox(
          color: tokens.softPanel,
          child: Center(
            child: WenyouIcon(
              WenyouIconIds.actionImage,
              color: tokens.mutedText,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPendingFailure(
    MediaUploadTaskState upload,
    StickerCollectionState collectionState,
  ) async {
    final delayed = upload.phase == MediaUploadTaskPhase.processingPending;
    final canRetry =
        upload.failure?.canRetry == true || collectionState.retrySource != null;
    final action = await showPendingImageActions(
      context,
      title: delayed ? '图片准备较久' : '收藏表情未完成',
      retryLabel: delayed
          ? '继续等待'
          : canRetry
          ? '重试'
          : '重新选择',
      removeLabel: '放弃本次添加',
      detail:
          upload.failure?.userMessage ??
          collectionState.transientFailure?.userMessage,
      canRetry: true,
    );
    if (!mounted) return;
    if (action == PendingImageAction.retry) {
      if (upload.failure != null && upload.failure!.canRetry) {
        await _retryUpload();
      } else if (collectionState.retrySource != null) {
        final result = await ref
            .read(stickerCollectionControllerProvider.notifier)
            .retryImport();
        if (!mounted) return;
        if (result == null) {
          setState(() => _pendingFailed = true);
        } else if (result.status == StickerImportStatus.processing) {
          setState(() {
            _pendingImportId = result.id;
            _pendingFailed = false;
          });
        } else {
          setState(() {
            _pendingInput = null;
            _pendingImportId = null;
            _pendingFailed = false;
          });
        }
      } else {
        ref
            .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
            .reset();
        setState(() {
          _pendingInput = null;
          _pendingImportId = null;
          _pendingFailed = false;
        });
        await _addFromGallery();
      }
    } else if (action == PendingImageAction.remove) {
      ref
          .read(mediaUploadTaskControllerProvider(_uploadTaskId).notifier)
          .reset();
      setState(() {
        _pendingInput = null;
        _pendingImportId = null;
        _pendingFailed = false;
      });
    }
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
