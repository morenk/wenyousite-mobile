import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog_controller.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_bookmark_folder_picker.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_waterfall_card.dart';

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
  bool get _usesTwoColumnWaterfall =>
      WenyouCollectionContract.mobileDomainLayoutExceptions['moments-feed'] ==
      'two-column-waterfall';

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
    ref.listen(provider.select((value) => value.transientFailure), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        final message = wenyouFailureMessage(
          next,
          treatAsWrite: true,
          objectName: '动态收藏',
          operationName: '移动收藏',
        );
        if (message != null) {
          showWenyouSnackBar(
            context,
            message,
            pacing: WenyouSnackBarPacing.extended,
            tone: WenyouSnackBarTone.error,
          );
        }
      }
    });
    final body = RefreshIndicator(
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
      appBar: AppBar(
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
      return [
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: context.wenyouTokens.space16,
            bottom: context.wenyouTokens.space32,
            child: const WenyouListSkeleton(label: '正在加载动态收藏'),
          ),
        ),
      ];
    }
    if (state.phase == MomentBookmarkListPhase.failed) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: WenyouContentFrame(
            top: 16,
            bottom: 80,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.statusOffline,
                title: '动态收藏加载失败',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: wenyouFailureDetail(state.failure),
                action: OutlinedButton.icon(
                  key: const Key('moment-bookmark-folder-retry'),
                  onPressed: ref.read(provider.notifier).load,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
              ),
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
    final itemIndexByKey = <Key, int>{
      for (var index = 0; index < state.items.length; index++)
        Key('moment-bookmark-card-${state.items[index].id}'): index,
      const Key('moment-bookmark-footer'): state.items.length,
    };
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _horizontalPadding(context),
          context.wenyouTokens.space8,
          _horizontalPadding(context),
          0,
        ),
        sliver: SliverWaterfallFlow(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: _usesTwoColumnWaterfall ? 2 : 1,
            mainAxisSpacing: context.wenyouTokens.space12,
            crossAxisSpacing: context.wenyouTokens.space12,
            lastChildLayoutTypeBuilder: (index) => index == state.items.length
                ? LastChildLayoutType.fullCrossAxisExtent
                : LastChildLayoutType.none,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == state.items.length) {
                return KeyedSubtree(
                  key: const Key('moment-bookmark-footer'),
                  child: _footer(context, state, provider),
                );
              }
              final card = state.items[index];
              return MomentWaterfallCard(
                key: Key('moment-bookmark-card-${card.id}'),
                moment: card,
                managePending: state.pendingMomentId == card.id,
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
            childCount: state.items.length + 1,
            addAutomaticKeepAlives: false,
            findChildIndexCallback: (key) => itemIndexByKey[key],
          ),
        ),
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
      child: Center(
        child: state.isLoadingMore
            ? const CircularProgressIndicator()
            : state.hasMore
            ? OutlinedButton.icon(
                key: const Key('moment-bookmark-load-more'),
                onPressed: ref.read(provider.notifier).loadMore,
                icon: const WenyouIcon(WenyouIconIds.navigationExpand),
                label: const Text('加载更多'),
              )
            : Text('已经看到这里了', style: Theme.of(context).textTheme.wenyouCaption),
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
    final action = await showModalBottomSheet<_BookmarkManageAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const WenyouIcon(WenyouIconIds.contentFolderOpen),
              title: Text(folderName ?? '当前收藏夹'),
              subtitle: const Text('当前所在收藏夹'),
            ),
            ListTile(
              key: Key('moment-bookmark-move-${card.id}'),
              enabled: card.canInteract,
              leading: const WenyouIcon(WenyouIconIds.actionMove),
              title: const Text('移动到其他收藏夹'),
              subtitle: card.canInteract ? null : const Text('这条动态暂时无法移动'),
              onTap: card.canInteract
                  ? () => Navigator.of(context).pop(_BookmarkManageAction.move)
                  : null,
            ),
            ListTile(
              key: Key('moment-bookmark-remove-${card.id}'),
              leading: const WenyouIcon(WenyouIconIds.actionRemoveBookmark),
              title: const Text('取消收藏'),
              onTap: () =>
                  Navigator.of(context).pop(_BookmarkManageAction.remove),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    final notifier = ref.read(provider.notifier);
    if (action == _BookmarkManageAction.remove) {
      final succeeded = await notifier.remove(card);
      if (!mounted || !succeeded) return;
      _refreshCatalog();
      showWenyouSnackBar(context, '已取消收藏。', tone: WenyouSnackBarTone.success);
      return;
    }
    final repository = ref.read(momentBookmarkRepositoryProvider);
    final folder = await showBookmarkFolderPicker(
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

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final base = wenyouHorizontalPagePadding(context, availableWidth: width);
    final available = width - base * 2;
    final contentWidth = available < 600 ? available : 600.0;
    return (width - contentWidth) / 2;
  }
}

enum _BookmarkManageAction { move, remove }
