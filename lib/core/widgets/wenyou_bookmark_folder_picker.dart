import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

export 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart'
    show BookmarkFolderContentKind;

enum BookmarkFolderPickerMode { initial, move }

Future<BookmarkFolderItem?> showBookmarkFolderPicker({
  required BuildContext context,
  required BookmarkFolderCatalog catalog,
  required Future<void> Function(String folderId) onConfirm,
  BookmarkFolderPickerMode mode = BookmarkFolderPickerMode.initial,
  String? currentFolderId,
}) {
  return showModalBottomSheet<BookmarkFolderItem>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BookmarkFolderPickerSheet(
      catalog: catalog,
      onConfirm: onConfirm,
      mode: mode,
      currentFolderId: currentFolderId,
    ),
  );
}

class BookmarkFolderPickerSheet extends StatefulWidget {
  const BookmarkFolderPickerSheet({
    required this.catalog,
    required this.onConfirm,
    this.mode = BookmarkFolderPickerMode.initial,
    this.currentFolderId,
    super.key,
  });

  final BookmarkFolderCatalog catalog;
  final Future<void> Function(String folderId) onConfirm;
  final BookmarkFolderPickerMode mode;
  final String? currentFolderId;

  @override
  State<BookmarkFolderPickerSheet> createState() =>
      _BookmarkFolderPickerSheetState();
}

class _BookmarkFolderPickerSheetState extends State<BookmarkFolderPickerSheet> {
  final _nameController = TextEditingController();
  List<BookmarkFolderItem>? _folders;
  ApiFailure? _failure;
  String? _selectedFolderId;
  bool _isCreating = false;
  bool _showCreator = false;
  bool _isConfirming = false;

  bool get _isBusy => _isCreating || _isConfirming;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _folders = null;
      _failure = null;
    });
    try {
      final folders = await widget.catalog.fetchFolders();
      if (!mounted) return;
      setState(() {
        _folders = folders;
        if (widget.mode == BookmarkFolderPickerMode.initial) {
          _selectedFolderId = folders
              .where((folder) => folder.isDefault)
              .firstOrNull
              ?.id;
        }
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = mapApplicationFailure(error, '收藏夹加载失败，请稍后重试。');
      });
    }
  }

  Future<void> _createFolder() async {
    if (_isBusy) return;
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length > 24) {
      setState(() {
        _failure = const ApiFailure(userMessage: '收藏夹名称需为 1–24 个字符。');
      });
      return;
    }
    setState(() {
      _isCreating = true;
      _failure = null;
    });
    try {
      final folder = await widget.catalog.createFolder(name);
      if (!mounted) return;
      setState(() {
        _folders = List.unmodifiable([
          ...?_folders?.where((item) => item.id != folder.id),
          folder,
        ]);
        _selectedFolderId = folder.id;
        _isCreating = false;
        _showCreator = false;
        _nameController.clear();
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
        _failure = mapApplicationFailure(error, '新建收藏夹失败，请稍后重试。');
      });
    }
  }

  Future<void> _confirm() async {
    final folderId = _selectedFolderId;
    final folders = _folders;
    if (_isBusy || folderId == null || folders == null) return;
    final folder = folders.where((item) => item.id == folderId).firstOrNull;
    if (folder == null) return;
    setState(() {
      _isConfirming = true;
      _failure = null;
    });
    try {
      await widget.onConfirm(folder.id);
      if (!mounted) return;
      Navigator.of(context).pop(folder);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
        _failure = mapApplicationFailure(
          error,
          widget.mode == BookmarkFolderPickerMode.initial
              ? '收藏失败，请稍后重试。'
              : '移动收藏失败，请稍后重试。',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final title = widget.mode == BookmarkFolderPickerMode.initial
        ? '收藏到收藏夹'
        : '移动到收藏夹';
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space16,
          0,
          tokens.space16,
          MediaQuery.viewInsetsOf(context).bottom + tokens.space16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 260,
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.wenyouOverlayTitle,
                    ),
                  ),
                  IconButton(
                    key: const Key('bookmark-folder-picker-close'),
                    tooltip: '关闭',
                    onPressed: _isBusy
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const WenyouIcon(WenyouIconIds.actionClose),
                  ),
                ],
              ),
              Text(
                '选择收藏夹后确认，本次内容只会保存在一个收藏夹中。',
                style: Theme.of(
                  context,
                ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
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
              Flexible(child: _buildContent()),
              SizedBox(height: tokens.space8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('bookmark-folder-picker-confirm'),
                  onPressed: _selectedFolderId == null || _isBusy
                      ? null
                      : _confirm,
                  child: _isConfirming
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('确认'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
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
    return ListView(
      shrinkWrap: true,
      children: [
        RadioGroup<String>(
          groupValue: _selectedFolderId,
          onChanged: (value) {
            if (!_isBusy) setState(() => _selectedFolderId = value);
          },
          child: Column(
            children: [for (final folder in folders) _folderTile(folder)],
          ),
        ),
        if (_showCreator) _folderCreator() else _createButton(),
      ],
    );
  }

  Widget _folderTile(BookmarkFolderItem folder) {
    final current =
        widget.mode == BookmarkFolderPickerMode.move &&
        folder.id == widget.currentFolderId;
    return RadioListTile<String>(
      key: ValueKey('bookmark-folder-picker-option-${folder.id}'),
      value: folder.id,
      enabled: !_isBusy && !current,
      secondary: WenyouIcon(
        folder.isDefault
            ? WenyouIconIds.contentFolderOpen
            : WenyouIconIds.contentFolder,
      ),
      title: Text(folder.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        current
            ? '${folder.bookmarkCount} 条收藏 · 当前'
            : '${folder.bookmarkCount} 条收藏',
      ),
    );
  }

  Widget _createButton() {
    return ListTile(
      key: const Key('bookmark-folder-picker-create'),
      enabled: !_isBusy,
      leading: const WenyouIcon(WenyouIconIds.actionAddFolder),
      title: const Text('新建收藏夹'),
      onTap: () => setState(() {
        _showCreator = true;
        _failure = null;
      }),
    );
  }

  Widget _folderCreator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('bookmark-folder-picker-name'),
              controller: _nameController,
              autofocus: true,
              enabled: !_isBusy,
              maxLength: 24,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '收藏夹名称',
                counterText: '',
              ),
              onSubmitted: (_) => _createFolder(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: const Key('bookmark-folder-picker-create-confirm'),
            tooltip: '新建',
            onPressed: _isBusy ? null : _createFolder,
            icon: _isCreating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const WenyouIcon(WenyouIconIds.actionConfirm),
          ),
        ],
      ),
    );
  }
}
