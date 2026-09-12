import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/home/application/home_repository_ports.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_catalog_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_mapping.dart';

export 'package:wenyousite_mobile/features/home/application/home_repository_ports.dart'
    show HomeRepository, homeRepositoryProvider;

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._threadsApi, this._categories);

  final ThreadsApi _threadsApi;
  final ThreadCategoryCatalogRepository _categories;

  @override
  Future<List<ThreadCategory>> fetchCategories() =>
      _categories.fetchThreadCategories(refresh: true);

  @override
  Future<CursorPage<ThreadFeedCardModel>> fetchThreads({
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
            .map(mapThreadFeedCardResponse)
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
  return ApiHomeRepository(
    api.getThreadsApi(),
    ref.watch(threadCategoryCatalogRepositoryProvider),
  );
});
