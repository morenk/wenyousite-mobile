import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';

abstract interface class PostDiscussionAuthorDirectory {
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(String subthreadId);

  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(String rootPostId);
}

final postDiscussionAuthorDirectoryProvider =
    Provider<PostDiscussionAuthorDirectory>((ref) {
      return const _UnboundPostDiscussionAuthorDirectory();
    });

final postFloorDiscussionAuthorsProvider = FutureProvider.autoDispose
    .family<List<PostDiscussionAuthor>, String>(
      (ref, subthreadId) async {
        ref.watch(sessionScopeProvider);
        return ref
            .watch(postDiscussionAuthorDirectoryProvider)
            .fetchFloorAuthors(subthreadId);
      },
      dependencies: [
        sessionScopeProvider,
        postDiscussionAuthorDirectoryProvider,
      ],
    );

final postReplyDiscussionAuthorsProvider = FutureProvider.autoDispose
    .family<List<PostDiscussionAuthor>, String>(
      (ref, rootPostId) async {
        ref.watch(sessionScopeProvider);
        return ref
            .watch(postDiscussionAuthorDirectoryProvider)
            .fetchReplyAuthors(rootPostId);
      },
      dependencies: [
        sessionScopeProvider,
        postDiscussionAuthorDirectoryProvider,
      ],
    );

class _UnboundPostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  const _UnboundPostDiscussionAuthorDirectory();

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(String subthreadId) {
    return Future.error(StateError('帖子讨论作者目录尚未在应用组合根绑定。'));
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(String rootPostId) {
    return Future.error(StateError('帖子讨论作者目录尚未在应用组合根绑定。'));
  }
}
