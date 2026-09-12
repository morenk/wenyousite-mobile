import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog_controller.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  test('重命名 trim 名称并丢弃并发管理请求', () async {
    final gate = Completer<BookmarkFolderItem>();
    final repository = _CatalogRepository()..renameGate = gate;
    final controller = BookmarkFolderCatalogController(repository);
    await controller.load();

    final name = List.filled(24, '😀').join();
    final rename = controller.renameFolder('folder-custom', '  $name  ');
    expect(controller.state.isManaging, isTrue);
    expect(controller.state.managingFolderId, 'folder-custom');
    expect(await controller.deleteFolder('folder-custom'), isNull);
    expect(repository.deleteCalls, isEmpty);

    gate.complete(_folder('folder-custom', name));
    final renamed = await rename;
    expect(renamed?.name, name);
    expect(repository.renameCalls, [('folder-custom', name)]);
    expect(controller.state.folders.last.name, name);
    expect(controller.state.isBusy, isFalse);
    controller.dispose();
  });

  test('删除只按响应 destinationFolderId 更新目录并返回强类型结果', () async {
    final repository = _CatalogRepository(
      folders: [
        _folder('server-default', '默认收藏夹', isDefault: true, count: 1),
        _folder('folder-custom', '灵感', count: 3),
      ],
    );
    final controller = BookmarkFolderCatalogController(repository);
    await controller.load();

    final deleted = await controller.deleteFolder('folder-custom');

    expect(deleted, isA<BookmarkFolderDeleteResult>());
    expect(deleted!.deletedFolderId, 'folder-custom');
    expect(deleted.destinationFolderId, 'server-default');
    expect(controller.state.folders.map((folder) => folder.id), [
      'server-default',
    ]);
    expect(controller.state.folders.single.bookmarkCount, 4);
    expect(repository.deleteCalls, ['folder-custom']);
    controller.dispose();
  });

  test('删除失败保留当前收藏夹和可重试状态', () async {
    final repository = _CatalogRepository()..failDelete = true;
    final controller = BookmarkFolderCatalogController(repository);
    await controller.load();

    expect(await controller.deleteFolder('folder-custom'), isNull);
    expect(controller.state.folders.map((folder) => folder.id), [
      'folder-default',
      'folder-custom',
    ]);
    expect(controller.state.isBusy, isFalse);
    expect(controller.state.actionFailure?.userMessage, '删除失败，请重试。');
    controller.dispose();
  });

  test('控制器释放后忽略迟到的重命名响应', () async {
    final gate = Completer<BookmarkFolderItem>();
    final repository = _CatalogRepository()..renameGate = gate;
    final controller = BookmarkFolderCatalogController(repository);
    await controller.load();

    final rename = controller.renameFolder('folder-custom', '新名称');
    controller.dispose();
    gate.complete(_folder('folder-custom', '新名称'));

    expect(await rename, isNull);
  });
}

class _CatalogRepository implements BookmarkFolderCatalog {
  _CatalogRepository({List<BookmarkFolderItem>? folders})
    : _folders = List.of(
        folders ??
            [
              _folder('folder-default', '默认收藏夹', isDefault: true, count: 2),
              _folder('folder-custom', '灵感', count: 3),
            ],
      );

  final List<BookmarkFolderItem> _folders;
  final List<(String, String)> renameCalls = [];
  final List<String> deleteCalls = [];
  Completer<BookmarkFolderItem>? renameGate;
  bool failDelete = false;

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async =>
      List.unmodifiable(_folders);

  @override
  Future<BookmarkFolderItem> createFolder(String name) async =>
      _folder('folder-created', name);

  @override
  Future<BookmarkFolderItem> renameFolder(String folderId, String name) async {
    renameCalls.add((folderId, name));
    final result = _folder(folderId, name);
    if (renameGate case final gate?) {
      return gate.future.then((renamed) {
        _replaceFolder(renamed);
        return renamed;
      });
    }
    _replaceFolder(result);
    return result;
  }

  void _replaceFolder(BookmarkFolderItem updated) {
    final index = _folders.indexWhere((folder) => folder.id == updated.id);
    _folders[index] = updated;
  }

  @override
  Future<BookmarkFolderDeleteResult> deleteFolder(String folderId) async {
    deleteCalls.add(folderId);
    if (failDelete) {
      throw const ApiFailure(userMessage: '删除失败，请重试。');
    }
    final folder = _folders.firstWhere((item) => item.id == folderId);
    final destination = _folders.firstWhere((item) => item.isDefault);
    _folders.removeWhere((item) => item.id == folderId);
    final index = _folders.indexWhere((item) => item.id == destination.id);
    _folders[index] = destination.copyWith(
      bookmarkCount: destination.bookmarkCount + folder.bookmarkCount,
    );
    return BookmarkFolderDeleteResult(
      deletedFolderId: folderId,
      destinationFolderId: destination.id,
    );
  }
}

BookmarkFolderItem _folder(
  String id,
  String name, {
  bool isDefault = false,
  int count = 0,
}) {
  return BookmarkFolderItem(
    id: id,
    name: name,
    isDefault: isDefault,
    bookmarkCount: count,
    createdAt: DateTime.utc(2026, 9, 13),
  );
}
