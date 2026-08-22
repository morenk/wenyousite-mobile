import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

abstract interface class ThreadDetailRepository {
  Future<ThreadDetailModel> fetchThread(String threadId);

  Future<ThreadPostTargetModel> fetchPostTarget(String postId);

  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  });
}

final threadDetailRepositoryProvider = Provider<ThreadDetailRepository>((ref) {
  return const _UnboundThreadDetailRepository();
});

class _UnboundThreadDetailRepository implements ThreadDetailRepository {
  const _UnboundThreadDetailRepository();

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) {
    return Future.error(_error());
  }

  @override
  Future<ThreadPostTargetModel> fetchPostTarget(String postId) {
    return Future.error(_error());
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) => Future.error(_error());
}

StateError _error() => StateError('主题详情仓储尚未在应用组合根绑定。');
