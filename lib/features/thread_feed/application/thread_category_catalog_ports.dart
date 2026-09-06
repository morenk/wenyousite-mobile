import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_category_presentation.dart';

abstract interface class ThreadCategoryCatalogRepository {
  Future<List<ThreadCategory>> fetchThreadCategories({bool refresh = false});
}

/// Shared display projections may follow refreshes initiated by other readers.
abstract interface class ThreadCategoryCatalogUpdates {
  Stream<List<ThreadCategory>> get changes;
}

final threadCategoryCatalogRepositoryProvider =
    Provider<ThreadCategoryCatalogRepository>((ref) {
      return const _UnboundThreadCategoryCatalogRepository();
    });

class _UnboundThreadCategoryCatalogRepository
    implements ThreadCategoryCatalogRepository {
  const _UnboundThreadCategoryCatalogRepository();

  @override
  Future<List<ThreadCategory>> fetchThreadCategories({bool refresh = false}) {
    return Future.error(StateError('主题分类目录尚未在应用组合根绑定。'));
  }
}
