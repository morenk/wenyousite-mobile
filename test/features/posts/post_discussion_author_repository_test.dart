import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/posts/data/post_discussion_author_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';

void main() {
  test('讨论作者目录只保留楼主、协作者和玩家，并按角色与加入时间排序', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadMembersFindAll(threadId: 'thread-1'),
    ).thenAnswer((_) async => _membersResponse());

    final authors = await ApiPostDiscussionAuthorDirectory(
      api,
    ).fetchAuthors('thread-1');

    expect(authors.map((author) => author.userId), [
      'owner',
      'collaborator',
      'player-early',
      'player-late',
    ]);
    expect(authors.map((author) => author.role), [
      PostDiscussionAuthorRole.owner,
      PostDiscussionAuthorRole.collaborator,
      PostDiscussionAuthorRole.player,
      PostDiscussionAuthorRole.player,
    ]);
    expect(authors.any((author) => author.userId == 'participant'), isFalse);
    verify(() => api.threadMembersFindAll(threadId: 'thread-1')).called(1);
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

Response<ThreadMembersFindAll200Response> _membersResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/members'),
    data: ThreadMembersFindAll200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          _member(
            userId: 'participant',
            username: '普通参与者',
            role: ThreadMemberResponseDtoRoleEnum.PARTICIPANT,
            playerMarked: false,
            joinedAt: DateTime.utc(2026, 8, 1),
          ),
          _member(
            userId: 'player-late',
            username: '玩家乙',
            role: ThreadMemberResponseDtoRoleEnum.PARTICIPANT,
            playerMarked: true,
            joinedAt: DateTime.utc(2026, 8, 5),
          ),
          _member(
            userId: 'collaborator',
            username: '协作者',
            role: ThreadMemberResponseDtoRoleEnum.COLLABORATOR,
            playerMarked: false,
            joinedAt: DateTime.utc(2026, 8, 4),
          ),
          _member(
            userId: 'owner',
            username: '楼主',
            role: ThreadMemberResponseDtoRoleEnum.OWNER,
            playerMarked: false,
            joinedAt: DateTime.utc(2026, 8, 6),
          ),
          _member(
            userId: 'player-early',
            username: '玩家甲',
            role: ThreadMemberResponseDtoRoleEnum.PARTICIPANT,
            playerMarked: true,
            joinedAt: DateTime.utc(2026, 8, 2),
          ),
        ]),
    ),
  );
}

ThreadMemberResponseDto _member({
  required String userId,
  required String username,
  required ThreadMemberResponseDtoRoleEnum role,
  required bool playerMarked,
  required DateTime joinedAt,
}) {
  return ThreadMemberResponseDto(
    (member) => member
      ..id = 'member-$userId'
      ..threadId = 'thread-1'
      ..userId = userId
      ..role = role
      ..playerMarked = playerMarked
      ..joinedAt = joinedAt
      ..user.update(
        (user) => user
          ..id = userId
          ..username = username
          ..level = 1,
      ),
  );
}
