import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

abstract interface class TagRepository {
  Future<TagThreadsBootstrap> loadTagThreads(String tagId);

  Future<CursorPage<HomeThreadCardModel>> fetchTagThreads({
    required String tagId,
    String? cursor,
    int limit = 20,
  });

  Future<ThreadTagManagementBootstrap> loadManagement(String threadId);

  Future<List<TopicTagModel>> search(String query);

  Future<TopicTagModel> findById(String tagId);

  Future<TopicTagModel> create(String name);

  Future<TopicTagModel> addToThread({
    required String threadId,
    required String name,
  });

  Future<void> removeFromThread({
    required String threadId,
    required String tagId,
  });
}

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return const _UnboundTagRepository();
});

class _UnboundTagRepository implements TagRepository {
  const _UnboundTagRepository();

  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) {
    return Future.error(_error());
  }

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchTagThreads({
    required String tagId,
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<ThreadTagManagementBootstrap> loadManagement(String threadId) {
    return Future.error(_error());
  }

  @override
  Future<List<TopicTagModel>> search(String query) => Future.error(_error());

  @override
  Future<TopicTagModel> findById(String tagId) => Future.error(_error());

  @override
  Future<TopicTagModel> create(String name) => Future.error(_error());

  @override
  Future<TopicTagModel> addToThread({
    required String threadId,
    required String name,
  }) => Future.error(_error());

  @override
  Future<void> removeFromThread({
    required String threadId,
    required String tagId,
  }) => Future.error(_error());
}

StateError _error() => StateError('标签仓储尚未在应用组合根绑定。');
