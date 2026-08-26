import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';

abstract interface class ThreadInteractionRepository {
  Future<int> like(String threadId);

  Future<int> unlike(String threadId);

  Future<String> createBookmark(String threadId, String folderId);

  Future<void> removeBookmark(String bookmarkId);
}

abstract interface class ThreadInteractionProjectionReader {
  Future<ThreadInteractionProjection> fetchInteraction(String threadId);
}

final threadInteractionRepositoryProvider =
    Provider<ThreadInteractionRepository>((ref) {
      return const _UnboundThreadInteractionRepository();
    });

class _UnboundThreadInteractionRepository
    implements ThreadInteractionRepository {
  const _UnboundThreadInteractionRepository();

  @override
  Future<int> like(String threadId) => Future.error(_error());

  @override
  Future<int> unlike(String threadId) => Future.error(_error());

  @override
  Future<String> createBookmark(String threadId, String folderId) =>
      Future.error(_error());

  @override
  Future<void> removeBookmark(String bookmarkId) => Future.error(_error());
}

StateError _error() => StateError('主题互动仓储尚未在应用组合根绑定。');
