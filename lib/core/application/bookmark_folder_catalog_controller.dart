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
    this.failure,
    this.actionFailure,
  });

  const BookmarkFolderCatalogState.loading()
    : this(phase: BookmarkFolderCatalogPhase.loading);

  final BookmarkFolderCatalogPhase phase;
  final List<BookmarkFolderItem> folders;
  final bool isRefreshing;
  final bool isCreating;
  final ApiFailure? failure;
  final ApiFailure? actionFailure;

  bool get isBusy => isRefreshing || isCreating;
  int get bookmarkCount =>
      folders.fold(0, (total, folder) => total + folder.bookmarkCount);

  BookmarkFolderCatalogState copyWith({
    BookmarkFolderCatalogPhase? phase,
    List<BookmarkFolderItem>? folders,
    bool? isRefreshing,
    bool? isCreating,
    Object? failure = _unset,
    Object? actionFailure = _unset,
  }) {
    return BookmarkFolderCatalogState(
      phase: phase ?? this.phase,
      folders: folders ?? this.folders,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isCreating: isCreating ?? this.isCreating,
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

  Future<void> load() async {
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
    if (trimmedName.isEmpty || trimmedName.length > 24) {
      state = state.copyWith(
        actionFailure: const ApiFailure(userMessage: '收藏夹名称需为 1–24 个字符。'),
      );
      return null;
    }
    state = state.copyWith(isCreating: true, actionFailure: null);
    try {
      final folder = await _repository.createFolder(trimmedName);
      if (!mounted) return null;
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

  Future<void> _refreshAfterCreation(BookmarkFolderItem folder) async {
    final epoch = ++_epoch;
    final fallbackFolders = state.folders;
    try {
      final folders = await _repository.fetchFolders();
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(folders: folders, failure: null);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        folders: fallbackFolders,
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
