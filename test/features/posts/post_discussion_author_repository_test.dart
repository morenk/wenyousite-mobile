import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/posts/data/post_discussion_author_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';

void main() {
  test('主楼作者目录按子贴读取并保持服务端顺序', () async {
    final api = _MockPostsApi();
    when(
      () => api.postsFindFloorAuthors(subthreadId: 'subthread-1'),
    ).thenAnswer((_) async => _floorAuthorsResponse());

    final authors = await ApiPostDiscussionAuthorDirectory(
      api,
    ).fetchFloorAuthors('subthread-1');

    expect(authors.map((author) => author.userId), [
      'owner',
      'collaborator',
      'player',
    ]);
    expect(authors.map((author) => author.role), [
      PostDiscussionAuthorRole.owner,
      PostDiscussionAuthorRole.collaborator,
      PostDiscussionAuthorRole.player,
    ]);
    expect(authors.any((author) => author.userId == 'participant'), isFalse);
    verify(
      () => api.postsFindFloorAuthors(subthreadId: 'subthread-1'),
    ).called(1);
  });

  test('独立回复作者目录按根楼层读取', () async {
    final api = _MockPostsApi();
    when(
      () => api.postsFindReplyAuthors(id: 'root-1'),
    ).thenAnswer((_) async => _replyAuthorsResponse());

    final authors = await ApiPostDiscussionAuthorDirectory(
      api,
    ).fetchReplyAuthors('root-1');

    expect(authors.single.userId, 'reply-author');
    expect(authors.single.username, '回复者');
    expect(authors.single.avatarUrl, 'https://cdn.example/avatar.png');
    expect(authors.single.role, PostDiscussionAuthorRole.player);
    verify(() => api.postsFindReplyAuthors(id: 'root-1')).called(1);
  });
}

class _MockPostsApi extends Mock implements PostsApi {}

Response<PostsFindFloorAuthors200Response> _floorAuthorsResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/subthreads/subthread-1/posts/authors',
    ),
    data: PostsFindFloorAuthors200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          _author(
            id: 'owner',
            username: '楼主',
            role: DiscussionAuthorResponseDtoRoleEnum.OWNER,
          ),
          _author(
            id: 'collaborator',
            username: '协作者',
            role: DiscussionAuthorResponseDtoRoleEnum.COLLABORATOR,
          ),
          _author(
            id: 'player',
            username: '玩家',
            role: DiscussionAuthorResponseDtoRoleEnum.PARTICIPANT,
            playerMarked: true,
          ),
          _author(
            id: 'participant',
            username: '普通参与者',
            role: DiscussionAuthorResponseDtoRoleEnum.PARTICIPANT,
          ),
        ]),
    ),
  );
}

Response<PostsFindReplyAuthors200Response> _replyAuthorsResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/posts/root-1/replies/authors',
    ),
    data: PostsFindReplyAuthors200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.add(
          _author(
            id: 'reply-author',
            username: '回复者',
            avatar: 'https://cdn.example/avatar.png',
            role: DiscussionAuthorResponseDtoRoleEnum.PARTICIPANT,
            playerMarked: true,
          ),
        ),
    ),
  );
}

DiscussionAuthorResponseDto _author({
  required String id,
  required String username,
  required DiscussionAuthorResponseDtoRoleEnum role,
  String? avatar,
  bool playerMarked = false,
}) {
  return DiscussionAuthorResponseDto(
    (author) => author
      ..id = id
      ..username = username
      ..avatar = avatar
      ..level = 1
      ..role = role
      ..playerMarked = playerMarked,
  );
}
