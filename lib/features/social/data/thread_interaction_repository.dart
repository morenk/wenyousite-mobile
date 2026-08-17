import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_repository_ports.dart';

export 'package:wenyousite_mobile/features/social/application/thread_interaction_repository_ports.dart'
    show ThreadInteractionRepository, threadInteractionRepositoryProvider;

class ApiThreadInteractionRepository implements ThreadInteractionRepository {
  ApiThreadInteractionRepository(this._threadsApi, this._bookmarksApi);

  final ThreadsApi _threadsApi;
  final BookmarksApi _bookmarksApi;

  @override
  Future<int> like(String threadId) async {
    try {
      final data = (await _threadsApi.threadsLike(id: threadId)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '点赞失败，请重新加载。');
      }
      return data.likeCount.toInt();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<int> unlike(String threadId) async {
    try {
      final data = (await _threadsApi.threadsUnlike(id: threadId)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '取消点赞失败，请重新加载。');
      }
      return data.likeCount.toInt();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<String> createBookmark(String threadId) async {
    try {
      final data = (await _bookmarksApi.bookmarksCreate(
        createBookmarkDto: CreateBookmarkDto((dto) => dto.threadId = threadId),
      )).data?.data;
      if (data == null || data.id.trim().isEmpty) {
        throw const ApiFailure(userMessage: '收藏失败，请重新加载。');
      }
      return data.id;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    try {
      final data = (await _bookmarksApi.bookmarksRemove(
        id: bookmarkId,
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '取消收藏失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiThreadInteractionRepositoryProvider =
    Provider<ThreadInteractionRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      return ApiThreadInteractionRepository(
        api.getThreadsApi(),
        api.getBookmarksApi(),
      );
    });
