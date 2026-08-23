import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/home/application/home_repository_ports.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_feed_mapper.dart';

export 'package:wenyousite_mobile/features/home/application/home_repository_ports.dart'
    show HomeRepository, homeRepositoryProvider;

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._threadsApi, this._categoriesApi);

  final ThreadsApi _threadsApi;
  final ThreadCategoriesApi _categoriesApi;

  @override
  Future<List<HomeCategory>> fetchCategories() async {
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

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _threadsApi.threadsFindAll(
        cursor: cursor,
        limit: limit,
        filter: 'all',
        category: query.categorySlug,
        sort: query.sort.wireValue,
        status: query.status.wireValue,
        tagId: query.tagId,
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '主题列表加载失败，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data
            .map(mapHomeThreadCardResponse)
            .toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiHomeRepositoryProvider = Provider<HomeRepository>((ref) {
  final api = ref.watch(wenyouApiProvider);
  return ApiHomeRepository(api.getThreadsApi(), api.getThreadCategoriesApi());
});
