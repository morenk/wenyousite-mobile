import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog_controller.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_bookmark_folder_create_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

typedef BookmarkFolderContentBuilder =
    Widget Function(
      BuildContext context,
      BookmarkFolderContentKind kind,
      BookmarkFolderItem folder,
      Future<void> Function() refreshCatalog,
    );

class BookmarkFolderCatalogPage extends ConsumerStatefulWidget {
  const BookmarkFolderCatalogPage({
    required this.contentBuilder,
    this.initialKind,
    super.key,
  });

  final BookmarkFolderContentKind? initialKind;
  final BookmarkFolderContentBuilder contentBuilder;

  @override
  ConsumerState<BookmarkFolderCatalogPage> createState() =>
      _BookmarkFolderCatalogPageState();
}

class _BookmarkFolderCatalogPageState
    extends ConsumerState<BookmarkFolderCatalogPage> {
  late BookmarkFolderContentKind _kind =
      widget.initialKind ?? BookmarkFolderContentKind.thread;
  final _selectedFolderIds = <BookmarkFolderContentKind, String>{};

  @override
  Widget build(BuildContext context) {
    final provider = bookmarkFolderCatalogControllerProvider(_kind);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final selectedFolder = _selectedFolder(state);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          IconButton(
            key: Key('bookmark-folder-create-${_kind.name}'),
            tooltip: '新建收藏夹',
            onPressed:
                state.phase == BookmarkFolderCatalogPhase.ready && !state.isBusy
                ? () => _createFolder(provider, notifier)
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
      body: Column(
        children: [
          WenyouContentTabs<BookmarkFolderContentKind>(
            key: const Key('bookmark-kind-tabs'),
            keyPrefix: 'bookmark-kind',
            semanticsLabel: '收藏类型',
            placement: WenyouTabPlacement.page,
            options: const [
              WenyouFilterOption(
                value: BookmarkFolderContentKind.thread,
                label: '主题',
                keyValue: 'thread',
              ),
              WenyouFilterOption(
                value: BookmarkFolderContentKind.moment,
                label: '动态',
                keyValue: 'moment',
              ),
            ],
            selected: _kind,
            enabled: !state.isBusy,
            onSelected: (kind) => setState(() => _kind = kind),
          ),
          if (state.phase == BookmarkFolderCatalogPhase.ready &&
              selectedFolder != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wenyouHorizontalPagePadding(context),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: WenyouDropdownFilter<String>(
                  key: const Key('bookmark-folder-menu'),
                  optionKeyPrefix: 'bookmark-folder',
                  tooltip: '切换收藏夹',
                  icon: WenyouIconIds.contentFolderOpen,
                  appearance: WenyouDropdownFilterAppearance.quiet,
                  enabled: !state.isBusy,
                  selected: selectedFolder.id,
                  options: [
                    for (final folder in state.folders)
                      WenyouFilterOption(
                        value: folder.id,
                        keyValue: folder.id,
                        label: folder.name,
                        supportingLabel: '${folder.bookmarkCount} 条收藏',
                      ),
                  ],
                  onSelected: (folderId) =>
                      setState(() => _selectedFolderIds[_kind] = folderId),
                ),
              ),
            ),
          if (state.phase == BookmarkFolderCatalogPhase.ready &&
              state.failure != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                wenyouHorizontalPagePadding(context),
                context.wenyouTokens.space8,
                wenyouHorizontalPagePadding(context),
                0,
              ),
              child: WenyouStatusBanner(
                key: const Key('bookmark-folder-refresh-failure'),
                tone: WenyouStatusTone.error,
                message: state.failure!.userMessage,
                detail: _requestDetail(state.failure!.requestId),
                action: TextButton(
                  onPressed: state.isBusy ? null : notifier.refresh,
                  child: const Text('重新刷新'),
                ),
              ),
            ),
          Expanded(child: _body(state, notifier, selectedFolder)),
        ],
      ),
    );
  }

  BookmarkFolderItem? _selectedFolder(BookmarkFolderCatalogState state) {
    if (state.phase != BookmarkFolderCatalogPhase.ready ||
        state.folders.isEmpty) {
      return null;
    }
    final requestedId = _selectedFolderIds[_kind];
    for (final folder in state.folders) {
      if (folder.id == requestedId) return folder;
    }
    return state.folders.where((folder) => folder.isDefault).firstOrNull ??
        state.folders.first;
  }

  Widget _body(
    BookmarkFolderCatalogState state,
    BookmarkFolderCatalogController notifier,
    BookmarkFolderItem? selectedFolder,
  ) {
    return switch (state.phase) {
      BookmarkFolderCatalogPhase.loading => const WenyouPageBody(
        maxWidth: 600,
        child: WenyouListSkeleton(label: '正在加载收藏'),
      ),
      BookmarkFolderCatalogPhase.failed => WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: WenyouIconIds.statusOffline,
            title: '收藏加载失败',
            message: state.failure?.userMessage ?? '请稍后重试。',
            detail: _requestDetail(state.failure?.requestId),
            action: OutlinedButton.icon(
              key: Key('bookmark-folder-catalog-retry-${_kind.name}'),
              onPressed: notifier.load,
              icon: const WenyouIcon(WenyouIconIds.actionRefresh),
              label: const Text('重新加载'),
            ),
          ),
        ),
      ),
      BookmarkFolderCatalogPhase.ready =>
        selectedFolder == null
            ? WenyouPageBody(
                maxWidth: 600,
                child: WenyouPanel(
                  child: WenyouEmptyState(
                    icon: WenyouIconIds.contentFolder,
                    title: '还没有收藏夹',
                    action: FilledButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => _createFolder(
                              bookmarkFolderCatalogControllerProvider(_kind),
                              notifier,
                            ),
                      icon: const WenyouIcon(WenyouIconIds.actionAddFolder),
                      label: const Text('新建收藏夹'),
                    ),
                  ),
                ),
              )
            : widget.contentBuilder(
                context,
                _kind,
                selectedFolder,
                notifier.refresh,
              ),
    };
  }

  Future<void> _createFolder(
    AutoDisposeStateNotifierProvider<
      BookmarkFolderCatalogController,
      BookmarkFolderCatalogState
    >
    provider,
    BookmarkFolderCatalogController notifier,
  ) async {
    notifier.clearActionFailure();
    final folder = await showWenyouBookmarkFolderCreateDialog(
      context: context,
      onCreate: notifier.createFolder,
      readFailure: () => ref.read(provider).actionFailure,
    );
    if (!mounted || folder == null) return;
    setState(() => _selectedFolderIds[_kind] = folder.id);
    showWenyouSnackBar(context, '已新建“${folder.name}”。');
  }
}

String? _requestDetail(String? requestId) =>
    requestId == null ? null : '问题编号：$requestId';
