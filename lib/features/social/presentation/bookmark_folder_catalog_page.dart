import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_folder_catalog_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

class BookmarkFolderCatalogPage extends ConsumerWidget {
  const BookmarkFolderCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkFolderCatalogControllerProvider);
    final notifier = ref.read(bookmarkFolderCatalogControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          IconButton(
            key: const Key('bookmark-folder-create'),
            tooltip: '新建收藏夹',
            onPressed:
                state.phase == BookmarkFolderCatalogPhase.ready && !state.isBusy
                ? () => _createFolder(context, ref, notifier)
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
                key: const Key('bookmark-folder-catalog-retry'),
                onPressed: notifier.load,
                icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                label: const Text('重新加载'),
              ),
            ),
          ),
        ),
        BookmarkFolderCatalogPhase.ready => _ReadyBookmarkFolderCatalog(
          state: state,
          onRefresh: notifier.refresh,
        ),
      },
    );
  }

  Future<void> _createFolder(
    BuildContext context,
    WidgetRef ref,
    BookmarkFolderCatalogController notifier,
  ) async {
    notifier.clearActionFailure();
    final folder = await _showCreateFolderDialog(context, ref, notifier);
    if (!context.mounted || folder == null) return;
    showWenyouSnackBar(context, '已新建“${folder.name}”。');
    await context.pushNamed<void>(
      'me-bookmark-folder',
      pathParameters: {'folderId': folder.id},
      queryParameters: {'name': folder.name},
    );
  }
}

class _ReadyBookmarkFolderCatalog extends StatelessWidget {
  const _ReadyBookmarkFolderCatalog({
    required this.state,
    required this.onRefresh,
  });

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
        key: const Key('bookmark-folder-catalog-list'),
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
          const _CatalogSectionTitle('收藏内容'),
          SizedBox(height: tokens.space8),
          WenyouConstrainedWidth(
            child: WenyouPanel(
              child: Column(
                children: [
                  _CatalogTile(
                    key: const Key('bookmark-catalog-all-threads'),
                    icon: WenyouIconIds.actionBookmark,
                    title: '全部主题帖',
                    countLabel: '${state.threadBookmarkCount} 条收藏',
                    onTap: () => context.pushNamed('me-bookmark-threads'),
                  ),
                  const Divider(height: 1),
                  _CatalogTile(
                    key: const Key('bookmark-catalog-moments'),
                    icon: WenyouIconIds.navigationMoments,
                    title: '动态收藏',
                    countLabel: '${state.momentBookmarkCount} 条收藏',
                    onTap: () => context.pushNamed('moment-bookmarks'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.space24),
          const _CatalogSectionTitle('主题帖收藏夹'),
          SizedBox(height: tokens.space8),
          if (state.folders.isEmpty)
            WenyouConstrainedWidth(
              child: WenyouPanel(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.contentFolder,
                  title: '还没有收藏夹',
                  message: '可使用右上角按钮新建收藏夹。',
                ),
              ),
            )
          else
            WenyouConstrainedWidth(
              child: WenyouPanel(
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < state.folders.length;
                      index++
                    ) ...[
                      if (index > 0) const Divider(height: 1),
                      _CatalogTile(
                        key: ValueKey(
                          'bookmark-catalog-folder-${state.folders[index].id}',
                        ),
                        icon: state.folders[index].isDefault
                            ? WenyouIconIds.contentFolderOpen
                            : WenyouIconIds.contentFolder,
                        title: state.folders[index].name,
                        countLabel: '${state.folders[index].bookmarkCount} 条收藏',
                        onTap: () => context.pushNamed(
                          'me-bookmark-folder',
                          pathParameters: {'folderId': state.folders[index].id},
                          queryParameters: {'name': state.folders[index].name},
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

class _CatalogSectionTitle extends StatelessWidget {
  const _CatalogSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return WenyouConstrainedWidth(
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.icon,
    required this.title,
    required this.countLabel,
    required this.onTap,
    super.key,
  });

  final String icon;
  final String title;
  final String countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title，$countLabel',
      excludeSemantics: true,
      child: ListTile(
        leading: WenyouIcon(icon),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(countLabel),
        trailing: const WenyouIcon(WenyouIconIds.navigationNext),
        onTap: onTap,
      ),
    );
  }
}

Future<BookmarkFolderItem?> _showCreateFolderDialog(
  BuildContext context,
  WidgetRef ref,
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
              .read(bookmarkFolderCatalogControllerProvider)
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
}

String? _requestDetail(String? requestId) =>
    requestId == null ? null : '问题编号：$requestId';
