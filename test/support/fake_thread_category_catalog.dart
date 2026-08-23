import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';

class FakeThreadCategoryCatalogRepository
    implements ThreadCategoryCatalogRepository {
  FakeThreadCategoryCatalogRepository({
    this.categories = const [
      HomeCategory(
        id: 'category-deduction',
        slug: 'DEDUCTION',
        name: '演绎',
        sortOrder: 1,
      ),
    ],
    this.failure,
  });

  final List<HomeCategory> categories;
  final Object? failure;
  int calls = 0;

  @override
  Future<List<HomeCategory>> fetchThreadCategories() async {
    calls += 1;
    if (failure case final error?) throw error;
    return categories;
  }
}
