import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_search_mapper.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

abstract interface class SearchRepository {
  Future<SearchOverviewResult> searchOverview(String query);

  Future<CursorPage<MomentCard>> searchMoments(
    String query, {
    String? cursor,
    int limit = 20,
  });

  Future<List<SearchThreadResult>> searchThreads(String query);

  Future<List<SearchUserResult>> searchUsers(String query);

  Future<CursorPage<SearchPostResult>> searchPosts(
    String query, {
    String? cursor,
    int limit = 20,
  });

  Future<CursorPage<SearchPostResult>> searchThreadPosts(
    String threadId,
    String query, {
    String? cursor,
    int limit = 20,
  });
}

class ApiSearchRepository implements SearchRepository {
  ApiSearchRepository(this._api);

  final SearchApi _api;

  @override
  Future<SearchOverviewResult> searchOverview(String query) async {
    try {
      final data = (await _api.searchSearch(
        q: _query(query),
        extra: const {'skipAuth': true},
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '综合搜索返回不完整，请稍后重试。');
      }
      return SearchOverviewResult(
        threads: List.unmodifiable(data.threads.map(_mapThread)),
        users: List.unmodifiable(data.users.map(_mapUser)),
        posts: List.unmodifiable(data.posts.map(_mapPost)),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<MomentCard>> searchMoments(
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    _validatePage(limit);
    try {
      final envelope = (await _api.searchSearchMoments(
        q: _contentQuery(query),
        cursor: _optionalText(cursor),
        limit: limit,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '动态搜索返回不完整，请稍后重试。');
      }
      final items = envelope.data
          .map(MomentSearchMapper.map)
          .toList(growable: false);
      _validateUnique(items.map((item) => item.id), '动态搜索结果');
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: _pageCursor(envelope.meta.cursor, envelope.meta.hasMore),
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<SearchThreadResult>> searchThreads(String query) async {
    try {
      final response = await _api.searchSearchThreads(
        q: _query(query),
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
        q: _query(query),
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
    _validatePage(limit);
    try {
      final response = await _api.searchSearchPosts(
        q: _contentQuery(query),
        cursor: _optionalText(cursor),
        limit: limit,
        extra: const {'skipAuth': true},
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '正文搜索返回不完整，请稍后重试。');
      }
      final items = envelope.data.map(_mapPost).toList(growable: false);
      _validateUnique(items.map((item) => item.id), '正文搜索结果');
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: _pageCursor(envelope.meta.cursor, envelope.meta.hasMore),
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<SearchPostResult>> searchThreadPosts(
    String threadId,
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    final id = _requiredText(threadId, '主题 ID');
    _validatePage(limit);
    try {
      final envelope = (await _api.threadSearchSearchPosts(
        threadId: id,
        q: _contentQuery(query),
        cursor: _optionalText(cursor),
        limit: limit,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '主题内搜索返回不完整，请稍后重试。');
      }
      final items = envelope.data.map(_mapPost).toList(growable: false);
      if (items.any((item) => item.threadId != id)) {
        throw const ApiFailure(userMessage: '主题内搜索返回了其他主题的内容，请重新搜索。');
      }
      _validateUnique(items.map((item) => item.id), '主题内搜索结果');
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: _pageCursor(envelope.meta.cursor, envelope.meta.hasMore),
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

  String _query(String value) {
    final query = value.trim();
    if (query.isEmpty || query.runes.length > 100) {
      throw const ApiFailure(userMessage: '搜索关键词需要 1～100 个字符。');
    }
    return query;
  }

  String _contentQuery(String value) {
    final query = _query(value);
    if (query.runes.length < 2) {
      throw const ApiFailure(userMessage: '正文和动态搜索至少需要 2 个字符。');
    }
    return query;
  }

  String _requiredText(String value, String label) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw ApiFailure(userMessage: '$label不能为空。');
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  void _validatePage(int limit) {
    if (limit < 1 || limit > 20) {
      throw const ApiFailure(userMessage: '搜索分页大小无效，请重新加载。');
    }
  }

  String? _pageCursor(String? cursor, bool hasMore) {
    final safe = _optionalText(cursor);
    if (hasMore && safe == null) {
      throw const ApiFailure(userMessage: '搜索分页游标缺失，请重新搜索。');
    }
    return safe;
  }

  void _validateUnique(Iterable<String> ids, String label) {
    final list = ids.toList(growable: false);
    if (list.toSet().length != list.length) {
      throw ApiFailure(userMessage: '$label包含重复内容，请重新搜索。');
    }
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return ApiSearchRepository(ref.watch(wenyouApiProvider).getSearchApi());
});
