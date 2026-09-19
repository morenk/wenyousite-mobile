import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum BookmarkFolderCatalogPhase { loading, ready, failed }

const _unset = Object();

class BookmarkFolderCatalogState {
  const BookmarkFolderCatalogState({
    required this.phase,
    this.folders = const [],
    this.isRefreshing = false,
    this.isCreating = false,
    this.isManaging = false,
    this.managingFolderId,
    this.failure,
    this.actionFailure,
  });

  const BookmarkFolderCatalogState.loading()
    : this(phase: BookmarkFolderCatalogPhase.loading);

  final BookmarkFolderCatalogPhase phase;
  final List<BookmarkFolderItem> folders;
  final bool isRefreshing;
  final bool isCreating;
  final bool isManaging;
  final String? managingFolderId;
  final ApiFailure? failure;
  final ApiFailure? actionFailure;

  bool get isBusy => isRefreshing || isCreating || isManaging;
  int get bookmarkCount =>
      folders.fold(0, (total, folder) => total + folder.bookmarkCount);

  BookmarkFolderCatalogState copyWith({
    BookmarkFolderCatalogPhase? phase,
    List<BookmarkFolderItem>? folders,
    bool? isRefreshing,
    bool? isCreating,
    bool? isManaging,
    Object? managingFolderId = _unset,
    Object? failure = _unset,
    Object? actionFailure = _unset,
  }) {
    return BookmarkFolderCatalogState(
      phase: phase ?? this.phase,
      folders: folders ?? this.folders,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isCreating: isCreating ?? this.isCreating,
      isManaging: isManaging ?? this.isManaging,
      managingFolderId: identical(managingFolderId, _unset)
          ? this.managingFolderId
          : managingFolderId as String?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      actionFailure: identical(actionFailure, _unset)
          ? this.actionFailure
          : actionFailure as ApiFailure?,
    );
  }
}

class BookmarkFolderCatalogController
    extends StateNotifier<BookmarkFolderCatalogState> {
  BookmarkFolderCatalogController(this._repository)
    : super(const BookmarkFolderCatalogState.loading()) {
    load();
  }

  final BookmarkFolderCatalog _repository;
  var _epoch = 0;

  bool get isBusy => state.isBusy;
  ApiFailure? get actionFailure => state.actionFailure;

  Future<void> load() async {
    if (state.isBusy) return;
    final epoch = ++_epoch;
    state = const BookmarkFolderCatalogState.loading();
    try {
      final folders = await _repository.fetchFolders();
      if (!mounted || epoch != _epoch) return;
      state = BookmarkFolderCatalogState(
        phase: BookmarkFolderCatalogPhase.ready,
        folders: folders,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = BookmarkFolderCatalogState(
        phase: BookmarkFolderCatalogPhase.failed,
        failure: _asFailure(error, '收藏夹加载失败，请稍后重试。'),
      );
    }
  }

  Future<void> refresh() async {
    if (state.phase != BookmarkFolderCatalogPhase.ready || state.isBusy) {
      return;
    }
    final epoch = ++_epoch;
    final oldFolders = state.folders;
    state = state.copyWith(
      isRefreshing: true,
      failure: null,
      actionFailure: null,
    );
    try {
      final folders = await _repository.fetchFolders();
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        folders: folders,
        isRefreshing: false,
        failure: null,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        folders: oldFolders,
        isRefreshing: false,
        failure: _asFailure(error, '刷新收藏夹失败，请稍后重试。'),
      );
    }
  }

  Future<BookmarkFolderItem?> createFolder(String name) async {
    if (state.phase != BookmarkFolderCatalogPhase.ready || state.isBusy) {
      return null;
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.runes.length > 24) {
      state = state.copyWith(
        actionFailure: const ApiFailure(userMessage: '收藏夹名称需为 1–24 个字符。'),
      );
      return null;
    }
    final epoch = ++_epoch;
    state = state.copyWith(isCreating: true, actionFailure: null);
    try {
      final folder = await _repository.createFolder(trimmedName);
      if (!mounted || epoch != _epoch) return null;
      state = state.copyWith(
        folders: List.unmodifiable([...state.folders, folder]),
        isCreating: false,
      );
      await _refreshAfterCreation(folder);
      return folder;
    } on Object catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isCreating: false,
        actionFailure: _asFailure(error, '新建收藏夹失败，请稍后重试。'),
      );
      return null;
    }
  }

  Future<BookmarkFolderItem?> renameFolder(String folderId, String name) async {
    if (state.phase != BookmarkFolderCatalogPhase.ready || state.isBusy) {
      return null;
    }
    final current = state.folders
        .where((folder) => folder.id == folderId)
        .firstOrNull;
    if (current == null || current.isDefault) {
      return null;
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.runes.length > 24) {
      return null;
    }
    final epoch = ++_epoch;
    state = state.copyWith(
      isManaging: true,
      managingFolderId: folderId,
      actionFailure: null,
    );
    try {
      final renamed = await _repository.renameFolder(folderId, trimmedName);
      if (!mounted || epoch != _epoch) return null;
      if (renamed.id != folderId || renamed.isDefault) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'bookmark_folder_rename_response',
        );
      }
      final updatedFolders = [
        for (final folder in state.folders)
          if (folder.id == folderId) renamed else folder,
      ];
      state = state.copyWith(
        folders: List.unmodifiable(updatedFolders),
        isManaging: false,
        managingFolderId: null,
      );
      await _refreshAfterMutation(
        state.folders,
        fallbackMessage: '名称已更新，但收藏夹目录刷新失败。',
      );
      return renamed;
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return null;
      state = state.copyWith(
        isManaging: false,
        managingFolderId: null,
        actionFailure: _asFailure(error, '重命名收藏夹失败，请重试。'),
      );
      return null;
    }
  }

  Future<BookmarkFolderDeleteResult?> deleteFolder(String folderId) async {
    if (state.phase != BookmarkFolderCatalogPhase.ready || state.isBusy) {
      return null;
    }
    final folder = state.folders
        .where((item) => item.id == folderId)
        .firstOrNull;
    if (folder == null || folder.isDefault) {
      return null;
    }
    final epoch = ++_epoch;
    state = state.copyWith(
      isManaging: true,
      managingFolderId: folderId,
      actionFailure: null,
    );
    try {
      final result = await _repository.deleteFolder(folderId);
      if (!mounted || epoch != _epoch) return null;
      if (result.deletedFolderId != folderId ||
          result.destinationFolderId == folderId ||
          result.destinationFolderId.trim().isEmpty) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'bookmark_folder_delete_response',
        );
      }
      final updatedFolders = [
        for (final item in state.folders)
          if (item.id != folderId)
            item.id == result.destinationFolderId && item.isDefault
                ? item.copyWith(
                    bookmarkCount: item.bookmarkCount + folder.bookmarkCount,
                  )
                : item,
      ];
      state = state.copyWith(
        folders: List.unmodifiable(updatedFolders),
        isManaging: false,
        managingFolderId: null,
      );
      return result;
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return null;
      state = state.copyWith(
        isManaging: false,
        managingFolderId: null,
        actionFailure: _asFailure(error, '删除收藏夹失败，请重试。'),
      );
      return null;
    }
  }

  Future<void> _refreshAfterMutation(
    List<BookmarkFolderItem> fallbackFolders, {
    required String fallbackMessage,
  }) async {
    final epoch = ++_epoch;
    state = state.copyWith(isRefreshing: true, failure: null);
    try {
      final folders = await _repository.fetchFolders();
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        folders: folders,
        isRefreshing: false,
        failure: null,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        folders: fallbackFolders,
        isRefreshing: false,
        failure: _asFailure(error, fallbackMessage),
      );
    }
  }

  Future<void> _refreshAfterCreation(BookmarkFolderItem folder) async {
    final epoch = ++_epoch;
    final fallbackFolders = state.folders;
    state = state.copyWith(isRefreshing: true, failure: null);
    try {
      final folders = await _repository.fetchFolders();
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        folders: folders,
        isRefreshing: false,
        failure: null,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        folders: fallbackFolders,
        isRefreshing: false,
        failure: _asFailure(error, '已新建“${folder.name}”，但数量刷新失败。'),
      );
    }
  }

  void clearActionFailure() {
    if (state.actionFailure == null) return;
    state = state.copyWith(actionFailure: null);
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final bookmarkFolderCatalogControllerProvider = StateNotifierProvider
    .autoDispose
    .family<
      BookmarkFolderCatalogController,
      BookmarkFolderCatalogState,
      BookmarkFolderContentKind
    >((ref, kind) {
      return BookmarkFolderCatalogController(
        ref.watch(bookmarkFolderCatalogProvider(kind)),
      );
    }, dependencies: [bookmarkFolderCatalogProvider]);
