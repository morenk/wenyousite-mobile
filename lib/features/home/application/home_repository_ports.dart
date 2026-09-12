import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';

abstract interface class HomeRepository {
  Future<List<ThreadCategory>> fetchCategories();

  Future<CursorPage<ThreadFeedCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  });
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const _UnboundHomeRepository();
});

class _UnboundHomeRepository implements HomeRepository {
  const _UnboundHomeRepository();

  @override
  Future<List<ThreadCategory>> fetchCategories() {
    return Future.error(_unboundError());
  }

  @override
  Future<CursorPage<ThreadFeedCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() => StateError('首页仓储尚未在应用组合根绑定。');
