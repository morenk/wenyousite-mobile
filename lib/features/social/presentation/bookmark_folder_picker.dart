import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

Future<BookmarkFolderItem?> showBookmarkFolderPicker({
  required BuildContext context,
  required BookmarkListRepository repository,
  required String bookmarkId,
}) {
  return showModalBottomSheet<BookmarkFolderItem>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BookmarkFolderPickerSheet(
      repository: repository,
      bookmarkId: bookmarkId,
    ),
  );
}

class BookmarkFolderPickerSheet extends StatefulWidget {
  const BookmarkFolderPickerSheet({
    required this.repository,
    required this.bookmarkId,
    super.key,
  });

  final BookmarkListRepository repository;
  final String bookmarkId;

  @override
  State<BookmarkFolderPickerSheet> createState() =>
      _BookmarkFolderPickerSheetState();
}

class _BookmarkFolderPickerSheetState extends State<BookmarkFolderPickerSheet> {
  List<BookmarkFolderItem>? _folders;
  ApiFailure? _failure;
  String? _pendingFolderId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _folders = null;
      _failure = null;
    });
    try {
      final folders = await widget.repository.fetchFolders();
      if (!mounted) return;
      setState(() => _folders = folders);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = mapApplicationFailure(error, '收藏夹加载失败，请稍后重试。');
      });
    }
  }

  Future<void> _moveTo(BookmarkFolderItem folder) async {
    if (_pendingFolderId != null || folder.isDefault) return;
    setState(() {
      _pendingFolderId = folder.id;
      _failure = null;
    });
    try {
      await widget.repository.move(widget.bookmarkId, folder.id);
      if (!mounted) return;
      Navigator.of(context).pop(folder);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingFolderId = null;
        _failure = mapApplicationFailure(error, '移动收藏失败，请稍后重试。');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 240,
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            0,
            tokens.space16,
            tokens.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '修改收藏夹',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    key: const Key('bookmark-folder-picker-close'),
                    tooltip: '关闭',
                    onPressed: _pendingFolderId == null
                        ? () => Navigator.of(context).pop()
                        : null,
                    icon: const WenyouIcon(WenyouIconIds.actionClose),
                  ),
                ],
              ),
              Text(
                '当前已保存在默认收藏夹，选择后立即移动。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
              ),
              if (_failure != null) ...[
                SizedBox(height: tokens.space12),
                WenyouFailureBanner(
                  failure: _failure!,
                  action: _folders == null
                      ? TextButton(
                          key: const Key('bookmark-folder-picker-retry'),
                          onPressed: _load,
                          child: const Text('重试'),
                        )
                      : null,
                ),
              ],
              SizedBox(height: tokens.space8),
              Flexible(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final folders = _folders;
    if (folders == null) {
      if (_failure != null) return const SizedBox.shrink();
      return Center(
        child: Semantics(
          label: '正在加载收藏夹',
          child: const CircularProgressIndicator(),
        ),
      );
    }
    if (folders.isEmpty) {
      return const Center(child: Text('还没有可用的收藏夹。'));
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        final pending = _pendingFolderId == folder.id;
        return ListTile(
          key: ValueKey('bookmark-folder-picker-option-${folder.id}'),
          enabled: _pendingFolderId == null && !folder.isDefault,
          leading: WenyouIcon(
            folder.isDefault
                ? WenyouIconIds.contentFolderOpen
                : WenyouIconIds.contentFolder,
          ),
          title: Text(
            folder.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${folder.bookmarkCount} 条收藏'),
          trailing: pending
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : folder.isDefault
              ? const WenyouIcon(WenyouIconIds.actionConfirm)
              : null,
          onTap: () => _moveTo(folder),
        );
      },
    );
  }
}
