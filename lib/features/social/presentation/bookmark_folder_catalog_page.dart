import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog_controller.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class BookmarkFolderCatalogPage extends ConsumerWidget {
  const BookmarkFolderCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(
      bookmarkFolderCatalogControllerProvider(BookmarkFolderContentKind.thread),
    );
    final moments = ref.watch(
      bookmarkFolderCatalogControllerProvider(BookmarkFolderContentKind.moment),
    );
    final tokens = context.wenyouTokens;
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: ListView(
        key: const Key('bookmark-overview-list'),
        padding: EdgeInsets.fromLTRB(
          tokens.space16,
          tokens.space16,
          tokens.space16,
          tokens.space32,
        ),
        children: [
          WenyouConstrainedWidth(
            child: WenyouPanel(
              child: Column(
                children: [
                  _BookmarkTypeTile(
                    key: const Key('bookmark-catalog-threads'),
                    icon: WenyouIconIds.actionBookmark,
                    title: '主题帖收藏夹',
                    state: threads,
                    onTap: () => context.pushNamed('me-bookmark-threads'),
                  ),
                  const Divider(height: 1),
                  _BookmarkTypeTile(
                    key: const Key('bookmark-catalog-moments'),
                    icon: WenyouIconIds.navigationMoments,
                    title: '动态收藏夹',
                    state: moments,
                    onTap: () => context.pushNamed('me-bookmark-moments'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookmarkFolderDirectoryPage extends ConsumerWidget {
  const BookmarkFolderDirectoryPage({required this.kind, super.key});

  final BookmarkFolderContentKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = bookmarkFolderCatalogControllerProvider(kind);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kind == BookmarkFolderContentKind.thread ? '主题帖收藏夹' : '动态收藏夹',
        ),
        actions: [
          IconButton(
            key: Key('bookmark-folder-create-${kind.name}'),
            tooltip: '新建收藏夹',
            onPressed:
                state.phase == BookmarkFolderCatalogPhase.ready && !state.isBusy
                ? () => _createFolder(context, ref, provider, notifier)
                : null,
            icon: state.isCreating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const WenyouIcon(WenyouIconIds.actionAddFolder),
          ),
        ],
      ),
      body: switch (state.phase) {
        BookmarkFolderCatalogPhase.loading => const WenyouPageBody(
          maxWidth: 600,
          child: WenyouListSkeleton(label: '正在加载收藏夹'),
        ),
        BookmarkFolderCatalogPhase.failed => WenyouPageBody(
          maxWidth: 600,
          child: WenyouPanel(
            child: WenyouEmptyState(
              icon: WenyouIconIds.statusOffline,
              title: '收藏夹加载失败',
              message: state.failure?.userMessage ?? '请稍后重试。',
              detail: _requestDetail(state.failure?.requestId),
              action: OutlinedButton.icon(
                key: Key('bookmark-folder-catalog-retry-${kind.name}'),
                onPressed: notifier.load,
                icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                label: const Text('重新加载'),
              ),
            ),
          ),
        ),
        BookmarkFolderCatalogPhase.ready => _ReadyFolderDirectory(
          kind: kind,
          state: state,
          onRefresh: notifier.refresh,
        ),
      },
    );
  }

  Future<void> _createFolder(
    BuildContext context,
    WidgetRef ref,
    AutoDisposeStateNotifierProvider<
      BookmarkFolderCatalogController,
      BookmarkFolderCatalogState
    >
    provider,
    BookmarkFolderCatalogController notifier,
  ) async {
    notifier.clearActionFailure();
    final folder = await _showCreateFolderDialog(
      context,
      ref,
      provider,
      notifier,
    );
    if (!context.mounted || folder == null) return;
    showWenyouSnackBar(context, '已新建“${folder.name}”。');
    await _openFolder(context, kind, folder);
  }
}

class _BookmarkTypeTile extends StatelessWidget {
  const _BookmarkTypeTile({
    required this.icon,
    required this.title,
    required this.state,
    required this.onTap,
    super.key,
  });

  final String icon;
  final String title;
  final BookmarkFolderCatalogState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final countLabel = switch (state.phase) {
      BookmarkFolderCatalogPhase.loading => '正在加载',
      BookmarkFolderCatalogPhase.failed => '加载失败，点按重试',
      BookmarkFolderCatalogPhase.ready => '${state.bookmarkCount} 条收藏',
    };
    return Semantics(
      button: true,
      label: '$title，$countLabel',
      excludeSemantics: true,
      child: ListTile(
        leading: WenyouIcon(icon),
        title: Text(title),
        subtitle: Text(countLabel),
        trailing: const WenyouIcon(WenyouIconIds.navigationNext),
        onTap: onTap,
      ),
    );
  }
}

class _ReadyFolderDirectory extends StatelessWidget {
  const _ReadyFolderDirectory({
    required this.kind,
    required this.state,
    required this.onRefresh,
  });

  final BookmarkFolderContentKind kind;
  final BookmarkFolderCatalogState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = wenyouHorizontalPagePadding(
      context,
      availableWidth: MediaQuery.sizeOf(context).width,
    );
    return RefreshIndicator(
      onRefresh: state.isBusy ? () async {} : onRefresh,
      child: ListView(
        key: ValueKey('bookmark-folder-directory-${kind.name}'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontal,
          tokens.space16,
          horizontal,
          tokens.space32,
        ),
        children: [
          if (state.failure != null) ...[
            WenyouConstrainedWidth(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.failure!.userMessage,
                detail: _requestDetail(state.failure!.requestId),
              ),
            ),
            SizedBox(height: tokens.space12),
          ],
          WenyouConstrainedWidth(
            child: WenyouPanel(
              child: state.folders.isEmpty
                  ? const WenyouEmptyState(
                      icon: WenyouIconIds.contentFolder,
                      title: '还没有收藏夹',
                      message: '可使用右上角按钮新建收藏夹。',
                    )
                  : Column(
                      children: [
                        for (
                          var index = 0;
                          index < state.folders.length;
                          index++
                        ) ...[
                          if (index > 0) const Divider(height: 1),
                          _FolderTile(
                            folder: state.folders[index],
                            onTap: () => _openFolder(
                              context,
                              kind,
                              state.folders[index],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.folder, required this.onTap});

  final BookmarkFolderItem folder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final countLabel = '${folder.bookmarkCount} 条收藏';
    return Semantics(
      button: true,
      label: '${folder.name}，$countLabel',
      excludeSemantics: true,
      child: ListTile(
        key: ValueKey('bookmark-catalog-folder-${folder.id}'),
        leading: WenyouIcon(
          folder.isDefault
              ? WenyouIconIds.contentFolderOpen
              : WenyouIconIds.contentFolder,
        ),
        title: Text(folder.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(countLabel),
        trailing: const WenyouIcon(WenyouIconIds.navigationNext),
        onTap: onTap,
      ),
    );
  }
}

Future<void> _openFolder(
  BuildContext context,
  BookmarkFolderContentKind kind,
  BookmarkFolderItem folder,
) {
  return context.pushNamed<void>(
    kind == BookmarkFolderContentKind.thread
        ? 'me-thread-bookmark-folder'
        : 'me-moment-bookmark-folder',
    pathParameters: {'folderId': folder.id},
    queryParameters: {'name': folder.name},
  );
}

Future<BookmarkFolderItem?> _showCreateFolderDialog(
  BuildContext context,
  WidgetRef ref,
  AutoDisposeStateNotifierProvider<
    BookmarkFolderCatalogController,
    BookmarkFolderCatalogState
  >
  provider,
  BookmarkFolderCatalogController notifier,
) async {
  final formKey = GlobalKey<FormState>();
  var folderName = '';
  var submitting = false;
  String? submissionError;
  String? requestId;
  return showDialog<BookmarkFolderItem>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
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
          final failure = ref.read(provider).actionFailure;
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
                  decoration: const InputDecoration(labelText: '收藏夹名称'),
                  onChanged: (value) => folderName = value,
                  onFieldSubmitted: (_) => submit(),
                  validator: (value) {
                    final normalized = value?.trim() ?? '';
                    if (normalized.isEmpty) return '请输入收藏夹名称。';
                    if (normalized.length > 24) return '名称不能超过 24 个字符。';
                    return null;
                  },
                ),
                if (submissionError != null) ...[
                  const SizedBox(height: 8),
                  Text(submissionError!),
                  if (requestId != null) Text('问题编号：$requestId'),
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
            FilledButton(
              key: const Key('bookmark-folder-submit'),
              onPressed: submitting ? null : submit,
              child: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('新建'),
            ),
          ],
        );
      },
    ),
  );
}

String? _requestDetail(String? requestId) =>
    requestId == null ? null : '问题编号：$requestId';
