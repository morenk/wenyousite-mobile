import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/models/thread_feed_models.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_thread_feed_card.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

typedef BookmarkMomentsBuilder = Widget Function();

enum BookmarkContentTab { threads, moments }

extension on BookmarkContentTab {
  String get label => switch (this) {
    BookmarkContentTab.threads => '主题帖',
    BookmarkContentTab.moments => '动态',
  };
}

class BookmarkListPage extends StatefulWidget {
  const BookmarkListPage({
    this.initialTab = BookmarkContentTab.threads,
    this.momentBookmarksBuilder,
    super.key,
  });

  final BookmarkContentTab initialTab;
  final BookmarkMomentsBuilder? momentBookmarksBuilder;

  @override
  State<BookmarkListPage> createState() => _BookmarkListPageState();
}

class _BookmarkListPageState extends State<BookmarkListPage> {
  late BookmarkContentTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _BookmarkListAppBar(),
      body: Column(
        children: [
          WenyouContentTabs<BookmarkContentTab>(
            key: const Key('bookmark-content-filter'),
            keyPrefix: 'bookmark-content',
            semanticsLabel: '收藏内容',
            placement: WenyouTabPlacement.page,
            options: [
              for (final tab in BookmarkContentTab.values)
                WenyouFilterOption(
                  value: tab,
                  label: tab.label,
                  keyValue: tab.name,
                ),
            ],
            selected: _tab,
            onSelected: (tab) => setState(() => _tab = tab),
          ),
          Expanded(
            child: _tab == BookmarkContentTab.threads
                ? const BookmarkListView()
                : widget.momentBookmarksBuilder?.call() ??
                      _MomentBookmarksFallback(
                        onPressed: () => context.pushNamed('moment-bookmarks'),
                      ),
          ),
        ],
      ),
    );
  }
}

class _MomentBookmarksFallback extends StatelessWidget {
  const _MomentBookmarksFallback({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(context.wenyouTokens.space16),
      children: [
        WenyouConstrainedWidth(
          child: WenyouEmptyState(
            icon: WenyouIconIds.navigationMoments,
            title: '动态收藏',
            action: OutlinedButton(
              onPressed: onPressed,
              child: const Text('打开列表'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookmarkListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _BookmarkListAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('我的收藏'));
  }
}

class BookmarkListView extends ConsumerWidget {
  const BookmarkListView({this.additionalRefresh, super.key});

  final Future<void> Function()? additionalRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkListControllerProvider);
    final notifier = ref.read(bookmarkListControllerProvider.notifier);
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
        onRefresh: () => Future.wait([
          notifier.refresh(),
          if (additionalRefresh case final refresh?) refresh(),
        ]),
        onRetryFolders: notifier.reloadFolders,
        onRetryList: notifier.retrySelectedFolder,
        onSelectFolder: notifier.selectFolder,
        onCreateFolder: () async {
          notifier.clearActionFailure();
          final folder = await _showCreateFolderDialog(context, ref, notifier);
          if (!context.mounted || folder == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('已新建“${folder.name}”。')));
        },
        onMove: (item) async {
          final folderId = await _showMoveFolderSheet(
            context,
            item,
            state.folders,
          );
          if (!context.mounted || folderId == null) return;
          final folder = state.folderById(folderId);
          final succeeded = await notifier.moveBookmark(
            item.bookmarkId,
            folderId,
          );
          if (!context.mounted || !succeeded) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已移动到“${folder?.name ?? '收藏夹'}”。')),
          );
        },
        onLoadMore: notifier.loadMore,
        onRemove: (bookmarkId) async {
          final succeeded = await notifier.removeBookmark(bookmarkId);
          if (!context.mounted || !succeeded) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已取消收藏。')));
        },
        onDismissFailure: notifier.clearActionFailure,
      ),
    };
  }
}

class _ReadyBookmarkList extends StatelessWidget {
  const _ReadyBookmarkList({
    required this.state,
    required this.onRefresh,
    required this.onRetryFolders,
    required this.onRetryList,
    required this.onSelectFolder,
    required this.onCreateFolder,
    required this.onMove,
    required this.onLoadMore,
    required this.onRemove,
    required this.onDismissFailure,
  });

  final BookmarkListState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetryFolders;
  final Future<void> Function() onRetryList;
  final Future<void> Function(String? folderId) onSelectFolder;
  final Future<void> Function() onCreateFolder;
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
          _CenteredContent(
            child: _BookmarkFolderBar(
              state: state,
              compactAction: width <= 400,
              onSelect: onSelectFolder,
              onCreate: onCreateFolder,
            ),
          ),
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
                    title: state.selectedFolderId == null
                        ? '还没有收藏'
                        : '这个收藏夹还是空的',
                    message: state.selectedFolderId == null
                        ? ''
                        : '可从“全部”中移动收藏。',
                  ),
                ),
              )
            else
              for (var index = 0; index < state.items.length; index++) ...[
                if (index > 0) SizedBox(height: tokens.space12),
                _CenteredContent(
                  child: _BookmarkThreadListItem(
                    item: state.items[index],
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

class _BookmarkFolderBar extends StatelessWidget {
  const _BookmarkFolderBar({
    required this.state,
    required this.compactAction,
    required this.onSelect,
    required this.onCreate,
  });

  final BookmarkListState state;
  final bool compactAction;
  final Future<void> Function(String? folderId) onSelect;
  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (state.folderFailure != null && state.folders.isEmpty) {
      return SizedBox(height: tokens.space4);
    }
    final options = <({String? id, String name, int count})>[
      (id: null, name: '全部', count: state.totalBookmarkCount),
      for (final folder in state.folders)
        (id: folder.id, name: folder.name, count: folder.bookmarkCount),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: tokens.space12),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                label: '主题帖收藏夹',
                child: SizedBox(
                  height: tokens.minimumTouchTarget,
                  child: state.isLoadingFolders && state.folders.isEmpty
                      ? const Center(child: LinearProgressIndicator())
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: options.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(width: tokens.space4),
                          itemBuilder: (context, index) {
                            final option = options[index];
                            final selected =
                                state.selectedFolderId == option.id;
                            return ChoiceChip(
                              key: ValueKey(
                                option.id == null
                                    ? 'bookmark-folder-all'
                                    : 'bookmark-folder-${option.id}',
                              ),
                              selected: selected,
                              showCheckmark: false,
                              avatar: WenyouIcon(
                                selected
                                    ? WenyouIconIds.contentFolderOpen
                                    : WenyouIconIds.contentFolder,
                                size: 18,
                              ),
                              label: Text('${option.name}  ${option.count}'),
                              tooltip: '${option.name}，${option.count} 条收藏',
                              onSelected: state.isBusy
                                  ? null
                                  : (_) => onSelect(option.id),
                            );
                          },
                        ),
                ),
              ),
            ),
            SizedBox(width: tokens.space8),
            if (compactAction)
              IconButton(
                key: const Key('bookmark-folder-create'),
                tooltip: '新建收藏夹',
                onPressed: state.isBusy ? null : onCreate,
                icon: state.isCreatingFolder
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const WenyouIcon(WenyouIconIds.actionAddFolder),
              )
            else
              TextButton.icon(
                key: const Key('bookmark-folder-create'),
                onPressed: state.isBusy ? null : onCreate,
                icon: state.isCreatingFolder
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const WenyouIcon(WenyouIconIds.actionAdd),
                label: const Text('新建收藏夹'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkThreadListItem extends StatelessWidget {
  const _BookmarkThreadListItem({
    required this.item,
    required this.folderName,
    required this.canMove,
    required this.pendingAction,
    required this.disableActions,
    required this.onMove,
    required this.onRemove,
  });

  final BookmarkListItem item;
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
          categoryName: item.categorySlug,
          onTap: () => context.pushNamed(
            'thread-detail',
            pathParameters: {'threadId': item.threadId},
            extra: item.categorySlug,
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

Future<BookmarkFolderItem?> _showCreateFolderDialog(
  BuildContext context,
  WidgetRef ref,
  BookmarkListController notifier,
) async {
  final formKey = GlobalKey<FormState>();
  var folderName = '';
  var submitting = false;
  String? submissionError;
  String? requestId;
  final result = await showDialog<BookmarkFolderItem>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final tokens = context.wenyouTokens;
        Future<void> submit() async {
          if (submitting || !(formKey.currentState?.validate() ?? false)) {
            return;
          }
          setState(() => submitting = true);
          final folder = await notifier.createFolder(folderName);
          if (!dialogContext.mounted) return;
          if (folder != null) {
            Navigator.of(dialogContext).pop(folder);
            return;
          }
          final failure = ref
              .read(bookmarkListControllerProvider)
              .actionFailure;
          setState(() {
            submitting = false;
            submissionError = failure?.userMessage ?? '新建收藏夹失败，请稍后重试。';
            requestId = failure?.requestId;
          });
        }

        return AlertDialog(
          title: const Text('新建收藏夹'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('bookmark-folder-name'),
                  autofocus: true,
                  enabled: !submitting,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: '收藏夹名称',
                    hintText: '例如：跑团资料',
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) return '请输入收藏夹名称';
                    if (name.length > 24) return '名称最多 24 个字符';
                    return null;
                  },
                  onChanged: (value) {
                    folderName = value;
                    if (submissionError == null) return;
                    setState(() {
                      submissionError = null;
                      requestId = null;
                    });
                  },
                  onFieldSubmitted: submitting ? null : (_) => submit(),
                ),
                if (submissionError != null) ...[
                  SizedBox(height: tokens.space8),
                  Text(
                    submissionError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (requestId != null) ...[
                    SizedBox(height: tokens.space4),
                    SelectableText(
                      '问题编号：$requestId',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton.icon(
              key: const Key('bookmark-folder-submit'),
              onPressed: submitting ? null : submit,
              icon: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const WenyouIcon(WenyouIconIds.actionAdd),
              label: const Text('新建'),
            ),
          ],
        );
      },
    ),
  );
  return result;
}

Future<String?> _showMoveFolderSheet(
  BuildContext context,
  BookmarkListItem item,
  List<BookmarkFolderItem> folders,
) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final tokens = context.wenyouTokens;
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space20,
                  0,
                  tokens.space20,
                  tokens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '移动到收藏夹',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final current = folder.id == item.folderId;
                    return ListTile(
                      key: ValueKey('bookmark-move-option-${folder.id}'),
                      enabled: !current,
                      leading: WenyouIcon(
                        current
                            ? WenyouIconIds.contentFolderOpen
                            : WenyouIconIds.contentFolder,
                      ),
                      title: Text(
                        folder.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${folder.bookmarkCount} 条收藏'),
                      trailing: current
                          ? const WenyouIcon(WenyouIconIds.actionConfirm)
                          : null,
                      onTap: current
                          ? null
                          : () => Navigator.of(context).pop(folder.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String? _requestDetail(String? requestId) =>
    requestId == null ? null : '问题编号：$requestId';
