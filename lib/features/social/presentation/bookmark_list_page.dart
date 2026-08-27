import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';
import 'package:wenyousite_mobile/core/models/thread_feed_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_bookmark_folder_picker.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_thread_feed_card.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

class BookmarkListPage extends ConsumerWidget {
  const BookmarkListPage({
    required this.folderId,
    this.initialFolderName,
    super.key,
  });

  final String folderId;
  final String? initialFolderName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkListControllerProvider(folderId));
    final title =
        state.folderById(folderId)?.name ?? initialFolderName ?? '收藏夹';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BookmarkListView(folderId: folderId),
    );
  }
}

class BookmarkListView extends ConsumerWidget {
  const BookmarkListView({
    required this.folderId,
    this.additionalRefresh,
    this.onCatalogChanged,
    super.key,
  });

  final String folderId;
  final Future<void> Function()? additionalRefresh;
  final Future<void> Function()? onCatalogChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = bookmarkListControllerProvider(folderId);
    final state = ref.watch(provider);
    final categoryCatalog = ref.watch(threadCategoryCatalogControllerProvider);
    final notifier = ref.read(provider.notifier);
    return switch (state.phase) {
      BookmarkListPhase.loading => const WenyouPageBody(
        maxWidth: 600,
        child: WenyouListSkeleton(label: '正在加载收藏内容'),
      ),
      BookmarkListPhase.failed => WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: WenyouIconIds.statusOffline,
            title: '收藏列表加载失败',
            message: state.failure?.userMessage ?? '请稍后重试。',
            detail: _requestDetail(state.failure?.requestId),
            action: OutlinedButton.icon(
              key: const Key('bookmark-list-retry'),
              onPressed: notifier.load,
              icon: const WenyouIcon(WenyouIconIds.actionRefresh),
              label: const Text('重新加载'),
            ),
          ),
        ),
      ),
      BookmarkListPhase.ready => _ReadyBookmarkList(
        state: state,
        categoryCatalog: categoryCatalog,
        onRefresh: () => Future.wait([
          notifier.refresh(),
          ref.read(threadCategoryCatalogControllerProvider.notifier).refresh(),
          if (additionalRefresh case final refresh?) refresh(),
        ]),
        onRetryFolders: () async {
          await Future.wait([
            notifier.reloadFolders(),
            ref
                .read(threadCategoryCatalogControllerProvider.notifier)
                .refresh(),
          ]);
        },
        onRetryList: () async {
          await Future.wait([
            notifier.retrySelectedFolder(),
            ref
                .read(threadCategoryCatalogControllerProvider.notifier)
                .refresh(),
          ]);
        },
        onMove: (item) async {
          final folder = await showBookmarkFolderPicker(
            context: context,
            catalog: ref.read(bookmarkListRepositoryProvider),
            mode: BookmarkFolderPickerMode.move,
            currentFolderId: item.folderId,
            onConfirm: (targetFolderId) async {
              final succeeded = await notifier.moveBookmark(
                item.bookmarkId,
                targetFolderId,
              );
              if (succeeded) return;
              throw ref.read(provider).actionFailure ??
                  const ApiFailure(userMessage: '移动收藏失败，请稍后重试。');
            },
          );
          if (!context.mounted || folder == null) return;
          if (onCatalogChanged case final refresh?) unawaited(refresh());
          showWenyouSnackBar(context, '已移动到“${folder.name}”。');
        },
        onLoadMore: notifier.loadMore,
        onRemove: (bookmarkId) async {
          final succeeded = await notifier.removeBookmark(bookmarkId);
          if (!context.mounted || !succeeded) return;
          if (onCatalogChanged case final refresh?) unawaited(refresh());
          showWenyouSnackBar(context, '已取消收藏。');
        },
        onDismissFailure: notifier.clearActionFailure,
      ),
    };
  }
}

class _ReadyBookmarkList extends StatelessWidget {
  const _ReadyBookmarkList({
    required this.state,
    required this.categoryCatalog,
    required this.onRefresh,
    required this.onRetryFolders,
    required this.onRetryList,
    required this.onMove,
    required this.onLoadMore,
    required this.onRemove,
    required this.onDismissFailure,
  });

  final BookmarkListState state;
  final ThreadCategoryCatalogState categoryCatalog;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetryFolders;
  final Future<void> Function() onRetryList;
  final Future<void> Function(BookmarkListItem item) onMove;
  final Future<void> Function() onLoadMore;
  final Future<void> Function(String bookmarkId) onRemove;
  final VoidCallback onDismissFailure;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = wenyouHorizontalPagePadding(
      context,
      availableWidth: width,
    );
    return RefreshIndicator(
      onRefresh: state.isBusy ? () async {} : onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontal,
          tokens.space16,
          horizontal,
          tokens.space32,
        ),
        children: [
          if (state.folderFailure != null) ...[
            SizedBox(height: tokens.space12),
            _CenteredContent(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.folderFailure!.userMessage,
                detail: _requestDetail(state.folderFailure!.requestId),
                action: TextButton.icon(
                  key: const Key('bookmark-folders-retry'),
                  onPressed: state.isBusy ? null : onRetryFolders,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
                  label: const Text('重试分类'),
                ),
              ),
            ),
          ],
          if (state.actionFailure != null) ...[
            SizedBox(height: tokens.space12),
            _CenteredContent(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.actionFailure!.userMessage,
                detail: _requestDetail(state.actionFailure!.requestId),
                action: TextButton(
                  key: const Key('bookmark-list-error-dismiss'),
                  onPressed: onDismissFailure,
                  child: const Text('知道了'),
                ),
              ),
            ),
          ],
          SizedBox(height: tokens.space16),
          if (state.isRefreshingList && state.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: tokens.space24 + tokens.space24,
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (state.failure != null && state.items.isEmpty)
            _CenteredContent(
              child: WenyouPanel(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.statusOffline,
                  title: '这个收藏夹加载失败',
                  message: state.failure!.userMessage,
                  detail: _requestDetail(state.failure!.requestId),
                  action: OutlinedButton.icon(
                    key: const Key('bookmark-selected-folder-retry'),
                    onPressed: state.isBusy ? null : onRetryList,
                    icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                    label: const Text('重新加载'),
                  ),
                ),
              ),
            )
          else ...[
            if (state.failure != null) ...[
              _CenteredContent(
                child: WenyouStatusBanner(
                  tone: WenyouStatusTone.error,
                  message: state.failure!.userMessage,
                  detail: _requestDetail(state.failure!.requestId),
                  action: TextButton.icon(
                    onPressed: state.isBusy ? null : onRetryList,
                    icon: const WenyouIcon(
                      WenyouIconIds.actionRefresh,
                      size: 18,
                    ),
                    label: const Text('重新加载'),
                  ),
                ),
              ),
              SizedBox(height: tokens.space12),
            ],
            if (state.items.isEmpty)
              _CenteredContent(
                child: WenyouPanel(
                  child: WenyouEmptyState(
                    icon: WenyouIconIds.actionBookmark,
                    title: '这个收藏夹还是空的',
                    message: '收藏主题时可以直接选择这个收藏夹。',
                  ),
                ),
              )
            else
              for (var index = 0; index < state.items.length; index++) ...[
                if (index > 0) SizedBox(height: tokens.space12),
                _CenteredContent(
                  child: _BookmarkThreadListItem(
                    item: state.items[index],
                    category: categoryCatalog.resolve(
                      state.items[index].categorySlug,
                    ),
                    folderName: state
                        .folderById(state.items[index].folderId)
                        ?.name,
                    canMove: state.folders.isNotEmpty,
                    pendingAction:
                        state.pendingBookmarkId == state.items[index].bookmarkId
                        ? state.pendingAction
                        : null,
                    disableActions:
                        state.isBusy &&
                        state.pendingBookmarkId !=
                            state.items[index].bookmarkId,
                    onMove: () => onMove(state.items[index]),
                    onRemove: () => onRemove(state.items[index].bookmarkId),
                  ),
                ),
              ],
          ],
          if (state.loadMoreFailure != null) ...[
            SizedBox(height: tokens.space12),
            _CenteredContent(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.loadMoreFailure!.userMessage,
                detail: _requestDetail(state.loadMoreFailure!.requestId),
                action: TextButton.icon(
                  key: const Key('bookmark-list-load-more-retry'),
                  onPressed: state.isBusy ? null : onLoadMore,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
                  label: const Text('重试'),
                ),
              ),
            ),
          ] else if (state.hasMore) ...[
            SizedBox(height: tokens.space12),
            _CenteredContent(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('bookmark-list-load-more'),
                  onPressed: state.isBusy ? null : onLoadMore,
                  icon: state.isLoadingMore
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const WenyouIcon(WenyouIconIds.navigationExpand),
                  label: Text(state.isLoadingMore ? '正在加载' : '加载更多'),
                ),
              ),
            ),
          ] else if (state.items.isNotEmpty && !state.isRefreshingList) ...[
            SizedBox(height: tokens.space12),
            Text(
              '没有更多了',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookmarkThreadListItem extends StatelessWidget {
  const _BookmarkThreadListItem({
    required this.item,
    required this.category,
    required this.folderName,
    required this.canMove,
    required this.pendingAction,
    required this.disableActions,
    required this.onMove,
    required this.onRemove,
  });

  final BookmarkListItem item;
  final ThreadCategoryPresentation? category;
  final String? folderName;
  final bool canMove;
  final BookmarkPendingAction? pendingAction;
  final bool disableActions;
  final VoidCallback onMove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final isMoving = pendingAction == BookmarkPendingAction.move;
    final isRemoving = pendingAction == BookmarkPendingAction.remove;
    return Column(
      key: ValueKey('bookmark-thread-${item.threadId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThreadFeedCard(
          thread: _threadModel(item),
          category: category,
          onTap: () => context.pushNamed(
            'thread-detail',
            pathParameters: {'threadId': item.threadId},
          ),
          onTagTap: (tag) => context.pushNamed(
            'tag-threads',
            pathParameters: {'tagId': tag.id},
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            tokens.space4,
            tokens.space8,
            tokens.space8,
          ),
          child: Row(
            children: [
              if (canMove)
                Flexible(
                  child: Semantics(
                    label: '移动“${item.title}”到收藏夹',
                    button: true,
                    enabled: !(disableActions || isMoving || isRemoving),
                    excludeSemantics: true,
                    child: OutlinedButton.icon(
                      key: ValueKey('bookmark-move-${item.bookmarkId}'),
                      onPressed: disableActions || isMoving || isRemoving
                          ? null
                          : onMove,
                      icon: isMoving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(
                              WenyouIconIds.actionMove,
                              size: 18,
                            ),
                      label: Text(
                        folderName ?? '选择收藏夹',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Semantics(
                label: '取消收藏“${item.title}”',
                button: true,
                enabled: !(disableActions || isMoving || isRemoving),
                excludeSemantics: true,
                child: IconButton(
                  key: ValueKey('bookmark-remove-${item.bookmarkId}'),
                  tooltip: '取消收藏',
                  onPressed: disableActions || isMoving || isRemoving
                      ? null
                      : onRemove,
                  icon: isRemoving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const WenyouIcon(WenyouIconIds.actionRemoveBookmark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

ThreadFeedCardModel _threadModel(BookmarkListItem item) {
  return ThreadFeedCardModel(
    id: item.threadId,
    title: item.title,
    categorySlug: item.categorySlug,
    status: switch (item.status) {
      BookmarkedThreadStatus.recruiting => HomeThreadStatus.recruiting,
      BookmarkedThreadStatus.closed => HomeThreadStatus.closed,
      BookmarkedThreadStatus.finished => HomeThreadStatus.finished,
      BookmarkedThreadStatus.unknown => HomeThreadStatus.unknown,
    },
    isPinned: item.isPinned,
    isPrivate: item.isPrivate,
    isPublished: item.isPublished,
    ownerId: item.ownerId,
    ownerName: item.ownerName,
    ownerAvatarUrl: item.ownerAvatarUrl,
    ownerLevel: item.ownerLevel,
    createdAt: item.createdAt,
    lastActivityAt: item.lastActivityAt,
    preview: item.preview,
    tags: item.tags,
    coverImageUrls: item.coverImageUrls,
    memberCount: item.memberCount,
    playerCount: item.playerCount,
    postCount: item.postCount,
    tipTotal: item.tipTotal,
  );
}

class _CenteredContent extends StatelessWidget {
  const _CenteredContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WenyouConstrainedWidth(child: child);
  }
}

String? _requestDetail(String? requestId) =>
    requestId == null ? null : '问题编号：$requestId';
