import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';

abstract interface class PostDiscussionAuthorDirectory {
  Future<List<PostDiscussionAuthor>> fetchAuthors(String threadId);
}

final postDiscussionAuthorDirectoryProvider =
    Provider<PostDiscussionAuthorDirectory>((ref) {
      return const _UnboundPostDiscussionAuthorDirectory();
    });

final postDiscussionAuthorsProvider = FutureProvider.autoDispose
    .family<List<PostDiscussionAuthor>, String>(
      (ref, threadId) async {
        ref.watch(sessionScopeProvider);
        return ref
            .watch(postDiscussionAuthorDirectoryProvider)
            .fetchAuthors(threadId);
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
  Future<List<PostDiscussionAuthor>> fetchAuthors(String threadId) {
    return Future.error(StateError('帖子讨论作者目录尚未在应用组合根绑定。'));
  }
}
