import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';

export 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart'
    show PostDiscussionAuthorDirectory, postDiscussionAuthorDirectoryProvider;

class ApiPostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  ApiPostDiscussionAuthorDirectory(this._threadsApi);

  final ThreadsApi _threadsApi;

  @override
  Future<List<PostDiscussionAuthor>> fetchAuthors(String threadId) async {
    try {
      final envelope = (await _threadsApi.threadMembersFindAll(
        threadId: threadId,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '作者列表加载失败，请稍后重试。');
      }
      final authors =
          envelope.data
              .map(_mapAuthor)
              .whereType<PostDiscussionAuthor>()
              .toList(growable: false)
            ..sort(_compareAuthors);
      return List.unmodifiable(authors);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  PostDiscussionAuthor? _mapAuthor(ThreadMemberResponseDto member) {
    final role = switch (member.role) {
      ThreadMemberResponseDtoRoleEnum.OWNER => PostDiscussionAuthorRole.owner,
      ThreadMemberResponseDtoRoleEnum.COLLABORATOR =>
        PostDiscussionAuthorRole.collaborator,
      ThreadMemberResponseDtoRoleEnum.PARTICIPANT when member.playerMarked =>
        PostDiscussionAuthorRole.player,
      _ => null,
    };
    if (role == null) return null;
    return PostDiscussionAuthor(
      userId: member.userId,
      username: member.user.username,
      avatarUrl: member.user.avatar,
      role: role,
      joinedAt: member.joinedAt,
    );
  }

  int _compareAuthors(PostDiscussionAuthor left, PostDiscussionAuthor right) {
    final roleOrder = left.role.index.compareTo(right.role.index);
    if (roleOrder != 0) return roleOrder;
    final joinedOrder = left.joinedAt.compareTo(right.joinedAt);
    if (joinedOrder != 0) return joinedOrder;
    return left.userId.compareTo(right.userId);
  }
}

final apiPostDiscussionAuthorDirectoryProvider =
    Provider<PostDiscussionAuthorDirectory>((ref) {
      return ApiPostDiscussionAuthorDirectory(
        ref.watch(wenyouApiProvider).getThreadsApi(),
      );
    });
