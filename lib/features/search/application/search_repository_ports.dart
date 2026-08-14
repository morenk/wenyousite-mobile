import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
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

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return const _UnboundSearchRepository();
});

class _UnboundSearchRepository implements SearchRepository {
  const _UnboundSearchRepository();

  @override
  Future<CursorPage<MomentCard>> searchMoments(
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<SearchOverviewResult> searchOverview(String query) {
    return Future.error(_unboundError());
  }

  @override
  Future<CursorPage<SearchPostResult>> searchPosts(
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<CursorPage<SearchPostResult>> searchThreadPosts(
    String threadId,
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<List<SearchThreadResult>> searchThreads(String query) {
    return Future.error(_unboundError());
  }

  @override
  Future<List<SearchUserResult>> searchUsers(String query) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() => StateError('搜索仓储尚未在应用组合根绑定。');
