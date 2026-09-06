import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/thread_category_catalog_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_thread_category_catalog_repository.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_category_presentation.dart';

class ApiThreadCategoryCatalogRepository
    implements ThreadCategoryCatalogRepository {
  ApiThreadCategoryCatalogRepository(this._categoriesApi);

  final ThreadCategoriesApi _categoriesApi;

  @override
  Future<List<ThreadCategory>> fetchThreadCategories({
    bool refresh = false,
  }) async {
    try {
      final response = await _categoriesApi.threadCategoriesList(
        extra: ApiRequestPolicy.public.extra,
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '主题分类加载失败，请稍后重试。');
      }
      final ids = <String>{};
      final slugs = <String>{};
      final categories = <ThreadCategory>[];
      for (final item in data.where((item) => item.isActive)) {
        final id = item.id.trim();
        final slug = item.slug.trim();
        final name = item.name.trim();
        if (id.isEmpty ||
            slug.isEmpty ||
            name.isEmpty ||
            !ids.add(id) ||
            !slugs.add(slug)) {
          throw const ApiFailure(userMessage: '主题分类暂时无法显示，请稍后重试。');
        }
        final description = item.description?.trim();
        categories.add(
          ThreadCategory(
            id: id,
            slug: slug,
            name: ThreadCategoryPresentation.catalog(
              slug: slug,
              label: name,
            ).label,
            description: description == null || description.isEmpty
                ? null
                : description,
            sortOrder: item.sortOrder.toInt(),
          ),
        );
      }
      categories.sort(
        (left, right) => left.sortOrder.compareTo(right.sortOrder),
      );
      return List.unmodifiable(categories);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiThreadCategoryCatalogRepositoryProvider =
    Provider<ThreadCategoryCatalogRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      final repository = CachedThreadCategoryCatalogRepository(
        ApiThreadCategoryCatalogRepository(api.getThreadCategoriesApi()),
      );
      ref.onDispose(repository.dispose);
      return repository;
    });
