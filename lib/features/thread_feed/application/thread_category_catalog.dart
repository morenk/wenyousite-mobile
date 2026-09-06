import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/thread_category_catalog_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_models.dart';

enum ThreadCategoryCatalogPhase { loading, ready, failed }

class ThreadCategoryCatalogState {
  const ThreadCategoryCatalogState({
    this.phase = ThreadCategoryCatalogPhase.loading,
    this.categories = const [],
    this.isRefreshing = false,
  });

  final ThreadCategoryCatalogPhase phase;
  final List<ThreadCategory> categories;
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
    if (_repository case final ThreadCategoryCatalogUpdates updates) {
      _subscription = updates.changes.listen((categories) {
        if (!mounted) return;
        state = ThreadCategoryCatalogState(
          phase: ThreadCategoryCatalogPhase.ready,
          categories: categories,
        );
      });
    }
    if (autoStart) unawaited(load());
  }

  final ThreadCategoryCatalogRepository _repository;
  Future<void>? _pendingLoad;
  StreamSubscription<List<ThreadCategory>>? _subscription;

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> load({bool refresh = false}) {
    if (!mounted) return Future.value();
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
      final categories = await _repository.fetchThreadCategories(
        refresh: refresh,
      );
      if (!mounted) return;
      state = ThreadCategoryCatalogState(
        phase: ThreadCategoryCatalogPhase.ready,
        categories: List.unmodifiable(categories),
      );
    } on Object {
      if (!mounted) return;
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
