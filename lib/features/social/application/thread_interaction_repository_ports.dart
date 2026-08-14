import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ThreadInteractionRepository {
  Future<int> like(String threadId);

  Future<int> unlike(String threadId);

  Future<String> createBookmark(String threadId);

  Future<void> removeBookmark(String bookmarkId);
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
  Future<String> createBookmark(String threadId) => Future.error(_error());

  @override
  Future<void> removeBookmark(String bookmarkId) => Future.error(_error());
}

StateError _error() => StateError('主题互动仓储尚未在应用组合根绑定。');
