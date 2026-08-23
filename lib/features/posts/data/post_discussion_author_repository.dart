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
  ApiPostDiscussionAuthorDirectory(this._postsApi);

  final PostsApi _postsApi;

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async {
    try {
      final envelope = (await _postsApi.postsFindFloorAuthors(
        subthreadId: subthreadId,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '作者列表加载失败，请稍后重试。');
      }
      return _mapAuthors(envelope.data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async {
    try {
      final envelope = (await _postsApi.postsFindReplyAuthors(
        id: rootPostId,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '作者列表加载失败，请稍后重试。');
      }
      return _mapAuthors(envelope.data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  List<PostDiscussionAuthor> _mapAuthors(
    Iterable<DiscussionAuthorResponseDto> values,
  ) => List.unmodifiable(
    values.map(_mapAuthor).whereType<PostDiscussionAuthor>(),
  );

  PostDiscussionAuthor? _mapAuthor(DiscussionAuthorResponseDto author) {
    final role = switch (author.role) {
      DiscussionAuthorResponseDtoRoleEnum.OWNER =>
        PostDiscussionAuthorRole.owner,
      DiscussionAuthorResponseDtoRoleEnum.COLLABORATOR =>
        PostDiscussionAuthorRole.collaborator,
      DiscussionAuthorResponseDtoRoleEnum.PARTICIPANT
          when author.playerMarked =>
        PostDiscussionAuthorRole.player,
      _ => null,
    };
    if (role == null) return null;
    return PostDiscussionAuthor(
      userId: author.id,
      username: author.username,
      avatarUrl: author.avatar,
      role: role,
    );
  }
}

final apiPostDiscussionAuthorDirectoryProvider =
    Provider<PostDiscussionAuthorDirectory>((ref) {
      return ApiPostDiscussionAuthorDirectory(
        ref.watch(wenyouApiProvider).getPostsApi(),
      );
    });
