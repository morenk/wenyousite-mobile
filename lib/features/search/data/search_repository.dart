import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

abstract interface class SearchRepository {
  Future<List<SearchThreadResult>> searchThreads(String query);

  Future<List<SearchUserResult>> searchUsers(String query);

  Future<CursorPage<SearchPostResult>> searchPosts(
    String query, {
    String? cursor,
    int limit = 20,
  });
}

class ApiSearchRepository implements SearchRepository {
  ApiSearchRepository(this._api);

  final SearchApi _api;

  @override
  Future<List<SearchThreadResult>> searchThreads(String query) async {
    try {
      final response = await _api.searchSearchThreads(
        q: query.trim(),
        extra: const {'skipAuth': true},
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '主题搜索返回不完整，请稍后重试。');
      }
      return List.unmodifiable(data.map(_mapThread));
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<SearchUserResult>> searchUsers(String query) async {
    try {
      final response = await _api.searchSearchUsers(
        q: query.trim(),
        extra: const {'skipAuth': true},
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '用户搜索返回不完整，请稍后重试。');
      }
      return List.unmodifiable(data.map(_mapUser));
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<SearchPostResult>> searchPosts(
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _api.searchSearchPosts(
        q: query.trim(),
        cursor: cursor,
        limit: limit,
        extra: const {'skipAuth': true},
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '正文搜索返回不完整，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapPost).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  SearchThreadResult _mapThread(SearchThreadResponseDto dto) {
    return SearchThreadResult(
      id: dto.id,
      title: dto.title.trim().isEmpty ? '未命名主题' : dto.title.trim(),
      categorySlug: dto.category,
      ownerId: dto.owner.id,
      ownerName: dto.owner.username,
      ownerAvatarUrl: _safeHttpUrl(dto.owner.avatar),
      createdAt: dto.createdAt,
      memberCount: dto.count.members.toInt(),
      playerCount: dto.count.players.toInt(),
      postCount: dto.count.posts.toInt(),
      coverImageUrls: dto.coverImages
          .map(_safeHttpUrl)
          .whereType<String>()
          .take(3)
          .toList(growable: false),
    );
  }

  SearchUserResult _mapUser(SearchUserResponseDto dto) {
    final bio = dto.bio?.trim();
    return SearchUserResult(
      id: dto.id,
      username: dto.username,
      avatarUrl: _safeHttpUrl(dto.avatar),
      bio: bio == null || bio.isEmpty ? null : bio,
    );
  }

  SearchPostResult _mapPost(SearchPostResponseDto dto) {
    return SearchPostResult(
      id: dto.id,
      floorNumber: dto.floorNumber?.toInt(),
      parentPostId: dto.parentPostId,
      content: dto.content,
      preview: MarkdownContent.toPlainTextPreview(dto.content),
      authorId: dto.author.id,
      authorName: dto.author.username,
      threadId: dto.thread.id,
      threadTitle: dto.thread.title,
      subthreadId: dto.subthread.id,
      subthreadTitle: dto.subthread.title,
      createdAt: dto.createdAt,
    );
  }

  String? _safeHttpUrl(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return value;
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return ApiSearchRepository(ref.watch(wenyouApiProvider).getSearchApi());
});
