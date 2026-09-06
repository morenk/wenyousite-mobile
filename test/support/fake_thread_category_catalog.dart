import 'package:wenyousite_mobile/features/thread_feed/thread_feed_catalog.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_models.dart';

class FakeThreadCategoryCatalogRepository
    implements ThreadCategoryCatalogRepository {
  FakeThreadCategoryCatalogRepository({
    this.categories = const [
      ThreadCategory(
        id: 'category-deduction',
        slug: 'DEDUCTION',
        name: '演绎',
        sortOrder: 1,
      ),
    ],
    this.failure,
  });

  final List<ThreadCategory> categories;
  final Object? failure;
  int calls = 0;

  @override
  Future<List<ThreadCategory>> fetchThreadCategories({
    bool refresh = false,
  }) async {
    calls += 1;
    if (failure case final error?) throw error;
    return categories;
  }
}
