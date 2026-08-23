class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.sortOrder,
    this.description,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final int sortOrder;
}

enum ThreadCategoryCatalogAvailability { loading, available, unavailable }

enum ThreadCategoryPresentationKind {
  named,
  uncategorized,
  historical,
  unavailable,
}

class ThreadCategoryPresentation {
  const ThreadCategoryPresentation._(this.label, this.kind);

  factory ThreadCategoryPresentation.named(String label) {
    return ThreadCategoryPresentation._(
      label,
      ThreadCategoryPresentationKind.named,
    );
  }

  factory ThreadCategoryPresentation.catalog({
    required String slug,
    required String label,
  }) {
    final normalizedSlug = slug.trim();
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty ||
        normalizedLabel.toUpperCase() == normalizedSlug.toUpperCase()) {
      return historical;
    }
    return ThreadCategoryPresentation.named(normalizedLabel);
  }

  static const uncategorized = ThreadCategoryPresentation._(
    '未分类',
    ThreadCategoryPresentationKind.uncategorized,
  );
  static const historical = ThreadCategoryPresentation._(
    '历史分类',
    ThreadCategoryPresentationKind.historical,
  );
  static const unavailable = ThreadCategoryPresentation._(
    '分类暂不可用',
    ThreadCategoryPresentationKind.unavailable,
  );

  final String label;
  final ThreadCategoryPresentationKind kind;
}

ThreadCategoryPresentation? resolveThreadCategoryPresentation(
  String? categorySlug, {
  required Iterable<HomeCategory> categories,
  ThreadCategoryCatalogAvailability availability =
      ThreadCategoryCatalogAvailability.available,
}) {
  final slug = categorySlug?.trim();
  if (slug == null || slug.isEmpty) {
    return ThreadCategoryPresentation.uncategorized;
  }
  if (availability == ThreadCategoryCatalogAvailability.loading) {
    return null;
  }
  if (availability == ThreadCategoryCatalogAvailability.unavailable) {
    return ThreadCategoryPresentation.unavailable;
  }
  for (final category in categories) {
    if (category.slug != slug) continue;
    return ThreadCategoryPresentation.catalog(
      slug: category.slug,
      label: category.name,
    );
  }
  return ThreadCategoryPresentation.historical;
}
