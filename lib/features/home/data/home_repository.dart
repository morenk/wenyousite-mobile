import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';

abstract interface class HomeRepository {
  Future<List<HomeCategory>> fetchCategories();

  Future<CursorPage<HomeThreadCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  });
}

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._threadsApi, this._categoriesApi);

  final ThreadsApi _threadsApi;
  final ThreadCategoriesApi _categoriesApi;

  @override
  Future<List<HomeCategory>> fetchCategories() async {
    try {
      final response = await _categoriesApi.threadCategoriesList(
        extra: const {'skipAuth': true},
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '主题分类返回不完整，请稍后重试。');
      }
      final categories =
          data
              .where((item) => item.isActive)
              .map(
                (item) => HomeCategory(
                  id: item.id,
                  slug: item.slug,
                  name: item.name,
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
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '主题列表返回不完整，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapThread).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  HomeThreadCardModel _mapThread(HomeThreadListItemResponseDto item) {
    final preview = item.preview?.trim();
    return HomeThreadCardModel(
      id: item.id,
      title: item.title,
      categorySlug: item.category,
      status: _mapStatus(item.status),
      isPinned: item.pinned,
      ownerId: item.owner.id,
      ownerName: item.owner.username,
      ownerAvatarUrl: item.owner.avatar,
      ownerLevel: item.owner.level.toInt(),
      preview: preview == null || preview.isEmpty ? null : preview,
      tags: item.topicTags
          .map(
            (relation) =>
                HomeThreadTag(id: relation.tag.id, name: relation.tag.name),
          )
          .toList(growable: false),
      coverImageUrls: item.coverImages
          .where((url) {
            final uri = Uri.tryParse(url);
            return uri != null &&
                (uri.scheme == 'https' || uri.scheme == 'http');
          })
          .take(3)
          .toList(growable: false),
      memberCount: item.count.members.toInt(),
      playerCount: item.count.players.toInt(),
      postCount: item.count.posts.toInt(),
      tipTotal: item.tipTotal,
      lastActivityAt: item.defaultSubthread?.lastPostAt ?? item.updatedAt,
    );
  }

  HomeThreadStatus _mapStatus(HomeThreadListItemResponseDtoStatusEnum value) {
    if (value == HomeThreadListItemResponseDtoStatusEnum.RECRUITING) {
      return HomeThreadStatus.recruiting;
    }
    if (value == HomeThreadListItemResponseDtoStatusEnum.CLOSED) {
      return HomeThreadStatus.closed;
    }
    if (value == HomeThreadListItemResponseDtoStatusEnum.FINISHED) {
      return HomeThreadStatus.finished;
    }
    return HomeThreadStatus.unknown;
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final api = ref.watch(wenyouApiProvider);
  return ApiHomeRepository(api.getThreadsApi(), api.getThreadCategoriesApi());
});
