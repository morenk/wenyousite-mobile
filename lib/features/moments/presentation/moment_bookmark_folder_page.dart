import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog_controller.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_bookmark_folder_picker.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_bookmark_manage_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_refresh_indicator.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_waterfall_card.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_waterfall_sliver.dart';

class MomentBookmarkFolderPage extends ConsumerStatefulWidget {
  const MomentBookmarkFolderPage({
    required this.folderId,
    this.initialFolderName,
    this.embedded = false,
    super.key,
  });

  final String folderId;
  final String? initialFolderName;
  final bool embedded;

  @override
  ConsumerState<MomentBookmarkFolderPage> createState() =>
      _MomentBookmarkFolderPageState();
}

class _MomentBookmarkFolderPageState
    extends ConsumerState<MomentBookmarkFolderPage> {
  @override
  Widget build(BuildContext context) {
    final provider = momentBookmarkListControllerProvider(widget.folderId);
    final state = ref.watch(provider);
    final catalog = ref.watch(
      bookmarkFolderCatalogControllerProvider(BookmarkFolderContentKind.moment),
    );
    final folderName = catalog.folders
        .where((folder) => folder.id == widget.folderId)
        .firstOrNull
        ?.name;
    final body = WenyouRefreshIndicator(
      onRefresh: () => _refresh(provider),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) =>
            _loadMoreNearEnd(notification, provider),
        child: CustomScrollView(
          key: PageStorageKey('moment-bookmark-folder-${widget.folderId}'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _slivers(context, state, provider, folderName),
        ),
      ),
    );
    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: wenyouBrowsePageBackground(context),
      appBar: AppBar(
        backgroundColor: wenyouBrowsePageBackground(context),
        title: Text(folderName ?? widget.initialFolderName ?? '动态收藏夹'),
      ),
      body: body,
    );
  }

  Future<void> _refresh(
    AutoDisposeStateNotifierProvider<
      MomentBookmarkListController,
      MomentBookmarkListState
    >
    provider,
  ) async {
    await Future.wait([
      ref.read(provider.notifier).refresh(),
      ref
          .read(
            bookmarkFolderCatalogControllerProvider(
              BookmarkFolderContentKind.moment,
            ).notifier,
          )
          .refresh(),
    ]);
  }

  bool _loadMoreNearEnd(
    ScrollNotification notification,
    AutoDisposeStateNotifierProvider<
      MomentBookmarkListController,
      MomentBookmarkListState
    >
    provider,
  ) {
    if (notification.metrics.axis == Axis.vertical &&
        ref.read(provider).loadMoreFailure == null &&
        notification.metrics.extentAfter <= 480 &&
        (notification is ScrollUpdateNotification ||
            notification is OverscrollNotification)) {
      ref.read(provider.notifier).loadMore();
    }
    return false;
  }

  List<Widget> _slivers(
    BuildContext context,
    MomentBookmarkListState state,
    AutoDisposeStateNotifierProvider<
      MomentBookmarkListController,
      MomentBookmarkListState
    >
    provider,
    String? folderName,
  ) {
    if (state.phase == MomentBookmarkListPhase.loading) {
      return const [MomentWaterfallLoadingSliver(label: '正在加载动态收藏')];
    }
    if (state.phase == MomentBookmarkListPhase.failed) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: WenyouContentFrame(
            top: 16,
            bottom: 80,
            child: WenyouRetryFailure(
              panel: true,
              icon: WenyouIconIds.statusOffline,
              title: '动态收藏加载失败',
              message: state.failure?.userMessage ?? '请稍后重试。',
              failure: state.failure,
              retryKey: const Key('moment-bookmark-folder-retry'),
              onRetry: ref.read(provider.notifier).load,
              retryLabel: '重试',
            ),
          ),
        ),
      ];
    }
    if (state.items.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: WenyouContentFrame(
            top: 16,
            bottom: 80,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.actionBookmark,
                title: '这个收藏夹还是空的',
                message: '收藏动态时可以直接选择这个收藏夹。',
              ),
            ),
          ),
        ),
      ];
    }
    return [
      MomentWaterfallSliver(
        itemKeys: [
          for (final item in state.items)
            Key('moment-bookmark-card-${item.id}'),
        ],
        footerKey: const Key('moment-bookmark-footer'),
        footer: _footer(context, state, provider),
        itemBuilder: (context, index) {
          final card = state.items[index];
          return MomentWaterfallCard(
            moment: card,
            managePending: state.pendingMomentId == card.id,
            manageEnabled: !state.isBusy,
            onTap: () => context.pushNamed(
              'moment-detail',
              pathParameters: {'momentId': card.id},
            ),
            onAuthorTap: () => context.pushNamed(
              'user-profile',
              pathParameters: {'userId': card.author.id},
            ),
            onManage: () => _manage(card, provider, folderName),
          );
        },
      ),
    ];
  }

  Widget _footer(
    BuildContext context,
    MomentBookmarkListState state,
    AutoDisposeStateNotifierProvider<
      MomentBookmarkListController,
      MomentBookmarkListState
    >
    provider,
  ) {
    return WenyouContentFrame(
      top: 12,
      bottom: 80,
      child: WenyouLoadMoreControl(
        hasMore: state.hasMore,
        isLoading: state.isLoadingMore,
        failure: state.loadMoreFailure,
        onLoadMore: state.isBusy ? null : ref.read(provider.notifier).loadMore,
        loadMoreKey: const Key('moment-bookmark-load-more'),
        retryKey: const Key('moment-bookmark-load-more-retry'),
      ),
    );
  }

  Future<void> _manage(
    MomentCard card,
    AutoDisposeStateNotifierProvider<
      MomentBookmarkListController,
      MomentBookmarkListState
    >
    provider,
    String? folderName,
  ) async {
    if (ref.read(provider).isBusy) return;
    final action = await showWenyouBookmarkManageSheet(
      context: context,
      folderName: folderName ?? widget.initialFolderName,
      canMove: card.canInteract,
      moveUnavailableReason: '这条动态暂时无法移动',
      moveKey: Key('moment-bookmark-move-${card.id}'),
      removeKey: Key('moment-bookmark-remove-${card.id}'),
    );
    if (!mounted || action == null) return;
    final notifier = ref.read(provider.notifier);
    if (action == BookmarkManageAction.remove) {
      final succeeded = await notifier.remove(card);
      if (!mounted) return;
      if (!succeeded) {
        final message = wenyouFailureMessage(
          ref.read(provider).transientFailure,
          treatAsWrite: true,
          objectName: '动态收藏',
          operationName: '取消收藏',
        );
        if (message != null) {
          showWenyouSnackBar(
            context,
            message,
            pacing: WenyouSnackBarPacing.extended,
            tone: WenyouSnackBarTone.error,
          );
        }
        return;
      }
      _refreshCatalog();
      showWenyouSnackBar(context, '已取消收藏。', tone: WenyouSnackBarTone.success);
      return;
    }
    final repository = ref.read(momentBookmarkRepositoryProvider);
    final folder = await showBookmarkFolderPicker(
      closeBeforeWrite: true,
      context: context,
      catalog: repository,
      mode: BookmarkFolderPickerMode.move,
      currentFolderId: card.bookmarkFolderId ?? widget.folderId,
      onConfirm: (folderId) async {
        final succeeded = await notifier.move(card, folderId);
        if (succeeded) return;
        throw ref.read(provider).transientFailure ??
            const ApiFailure(userMessage: '移动收藏失败，请稍后重试。');
      },
    );
    if (!mounted || folder == null) return;
    _refreshCatalog();
    showWenyouSnackBar(
      context,
      '已移动到“${folder.name}”。',
      tone: WenyouSnackBarTone.success,
    );
  }

  void _refreshCatalog() {
    unawaited(
      ref
          .read(
            bookmarkFolderCatalogControllerProvider(
              BookmarkFolderContentKind.moment,
            ).notifier,
          )
          .refresh(),
    );
  }
}
