import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

abstract interface class ThreadInteractionRepository {
  Future<int> like(String threadId);

  Future<int> unlike(String threadId);

  Future<String> createBookmark(String threadId);

  Future<void> removeBookmark(String bookmarkId);
}

class ApiThreadInteractionRepository implements ThreadInteractionRepository {
  ApiThreadInteractionRepository(this._threadsApi, this._bookmarksApi);

  final ThreadsApi _threadsApi;
  final BookmarksApi _bookmarksApi;

  @override
  Future<int> like(String threadId) async {
    try {
      final data = (await _threadsApi.threadsLike(id: threadId)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '点赞结果返回不完整，请重新加载确认。');
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
        throw const ApiFailure(userMessage: '取消点赞结果返回不完整，请重新加载确认。');
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
        throw const ApiFailure(userMessage: '收藏结果返回不完整，请重新加载确认。');
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
        throw const ApiFailure(userMessage: '取消收藏结果返回不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final threadInteractionRepositoryProvider =
    Provider<ThreadInteractionRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      return ApiThreadInteractionRepository(
        api.getThreadsApi(),
        api.getBookmarksApi(),
      );
    });
