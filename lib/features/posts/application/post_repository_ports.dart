import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

abstract interface class PostRepository {
  Future<DiscussionWindow<PostItem>> fetchReplyWindow({
    required String rootPostId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  });

  Future<PostItem> fetchPost(String postId);

  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  });

  Future<PostItem> create(PostCreateInput input);

  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  });

  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
    String? identityToken,
    PostIdentityMode? identityMode,
  });

  Future<void> remove(String postId);

  Future<void> setPinned(String postId, {required bool pinned});
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return const _UnboundPostRepository();
});

class _UnboundPostRepository implements PostRepository {
  const _UnboundPostRepository();

  @override
  Future<DiscussionWindow<PostItem>> fetchReplyWindow({
    required String rootPostId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) => Future.error(_error());

  @override
  Future<PostItem> fetchPost(String postId) => Future.error(_error());

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) {
    return Future.error(_error());
  }

  @override
  Future<PostItem> create(PostCreateInput input) => Future.error(_error());

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) {
    return Future.error(_error());
  }

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
    String? identityToken,
    PostIdentityMode? identityMode,
  }) {
    return Future.error(_error());
  }

  @override
  Future<void> remove(String postId) => Future.error(_error());

  @override
  Future<void> setPinned(String postId, {required bool pinned}) =>
      Future.error(_error());
}

StateError _error() => StateError('帖子仓储尚未在应用组合根绑定。');
