import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

class ApiThreadCategoryCatalogRepository
    implements ThreadCategoryCatalogRepository {
  ApiThreadCategoryCatalogRepository(this._categoriesApi);

  final ThreadCategoriesApi _categoriesApi;

  @override
  Future<List<HomeCategory>> fetchThreadCategories() async {
    try {
      final response = await _categoriesApi.threadCategoriesList(
        extra: ApiRequestPolicy.public.extra,
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '主题分类加载失败，请稍后重试。');
      }
      final categories =
          data
              .where((item) => item.isActive)
              .map(
                (item) => HomeCategory(
                  id: item.id,
                  slug: item.slug,
                  name: ThreadCategoryPresentation.catalog(
                    slug: item.slug,
                    label: item.name,
                  ).label,
                  description: item.description,
                  sortOrder: item.sortOrder.toInt(),
                ),
              )
              .toList()
            ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
      return List.unmodifiable(categories);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiThreadCategoryCatalogRepositoryProvider =
    Provider<ThreadCategoryCatalogRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      return ApiThreadCategoryCatalogRepository(api.getThreadCategoriesApi());
    });
