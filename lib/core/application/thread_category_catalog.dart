import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';

abstract interface class ThreadCategoryCatalogRepository {
  Future<List<HomeCategory>> fetchThreadCategories();
}

final threadCategoryCatalogRepositoryProvider =
    Provider<ThreadCategoryCatalogRepository>((ref) {
      return const _UnboundThreadCategoryCatalogRepository();
    });

class _UnboundThreadCategoryCatalogRepository
    implements ThreadCategoryCatalogRepository {
  const _UnboundThreadCategoryCatalogRepository();

  @override
  Future<List<HomeCategory>> fetchThreadCategories() {
    return Future.error(StateError('主题分类目录尚未在应用组合根绑定。'));
  }
}

enum ThreadCategoryCatalogPhase { loading, ready, failed }

class ThreadCategoryCatalogState {
  const ThreadCategoryCatalogState({
    this.phase = ThreadCategoryCatalogPhase.loading,
    this.categories = const [],
    this.isRefreshing = false,
  });

  final ThreadCategoryCatalogPhase phase;
  final List<HomeCategory> categories;
  final bool isRefreshing;

  ThreadCategoryPresentation? resolve(String? categorySlug) {
    return resolveThreadCategoryPresentation(
      categorySlug,
      categories: categories,
      availability: switch (phase) {
        ThreadCategoryCatalogPhase.loading =>
          ThreadCategoryCatalogAvailability.loading,
        ThreadCategoryCatalogPhase.ready =>
          ThreadCategoryCatalogAvailability.available,
        ThreadCategoryCatalogPhase.failed =>
          ThreadCategoryCatalogAvailability.unavailable,
      },
    );
  }
}

class ThreadCategoryCatalogController
    extends StateNotifier<ThreadCategoryCatalogState> {
  ThreadCategoryCatalogController(this._repository, {bool autoStart = true})
    : super(const ThreadCategoryCatalogState()) {
    if (autoStart) unawaited(load());
  }

  final ThreadCategoryCatalogRepository _repository;
  Future<void>? _pendingLoad;

  Future<void> load({bool refresh = false}) {
    if (!refresh && state.phase == ThreadCategoryCatalogPhase.ready) {
      return Future.value();
    }
    return _pendingLoad ??= _load(refresh: refresh).whenComplete(() {
      _pendingLoad = null;
    });
  }

  Future<void> refresh() => load(refresh: true);

  Future<void> _load({required bool refresh}) async {
    final hadSnapshot = state.phase == ThreadCategoryCatalogPhase.ready;
    state = ThreadCategoryCatalogState(
      phase: hadSnapshot
          ? ThreadCategoryCatalogPhase.ready
          : ThreadCategoryCatalogPhase.loading,
      categories: state.categories,
      isRefreshing: hadSnapshot && refresh,
    );
    try {
      final categories = await _repository.fetchThreadCategories();
      state = ThreadCategoryCatalogState(
        phase: ThreadCategoryCatalogPhase.ready,
        categories: List.unmodifiable(categories),
      );
    } on Object {
      if (hadSnapshot) {
        state = ThreadCategoryCatalogState(
          phase: ThreadCategoryCatalogPhase.ready,
          categories: state.categories,
        );
      } else {
        state = const ThreadCategoryCatalogState(
          phase: ThreadCategoryCatalogPhase.failed,
        );
      }
    }
  }
}

final threadCategoryCatalogControllerProvider =
    StateNotifierProvider<
      ThreadCategoryCatalogController,
      ThreadCategoryCatalogState
    >((ref) {
      return ThreadCategoryCatalogController(
        ref.watch(threadCategoryCatalogRepositoryProvider),
      );
    }, dependencies: [threadCategoryCatalogRepositoryProvider]);
