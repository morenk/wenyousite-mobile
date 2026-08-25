import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/data/mention_candidate_repository.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';

void main() {
  test('候选查询只映射服务端授权的关注用户与标记玩家', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersMentionCandidates(threadId: 'thread-1', q: '温'),
    ).thenAnswer(
      (_) async => _response(
        users: [
          _candidate(
            id: 'user-following',
            username: '温柔朋友',
            relation: MentionCandidateDtoRelationEnum.FOLLOWING,
          ),
          _candidate(
            id: 'user-player',
            username: '温油玩家',
            relation: MentionCandidateDtoRelationEnum.PLAYER,
          ),
        ],
        canMentionAllPlayers: true,
      ),
    );
    final result = await ApiMentionCandidateRepository(
      api,
    ).findCandidates(threadId: ' thread-1 ', query: '温');

    expect(result.canMentionAllPlayers, isTrue);
    expect(result.users.map((item) => item.id), [
      'user-following',
      'user-player',
    ]);
    expect(result.users.first.relation, MentionCandidateRelation.following);
    expect(result.users.last.relation, MentionCandidateRelation.player);
    verify(
      () => api.usersMentionCandidates(threadId: 'thread-1', q: '温'),
    ).called(1);
    verifyNever(() => api.usersSearch(q: any(named: 'q')));
  });

  test('关系外全站用户不进入候选且不会触发全站用户搜索', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersMentionCandidates(threadId: 'thread-1', q: '玛利亚'),
    ).thenAnswer((_) async => _response(users: []));

    final result = await ApiMentionCandidateRepository(
      api,
    ).findCandidates(threadId: 'thread-1', query: ' 玛利亚 ');

    expect(result.users, isEmpty);
    verify(
      () => api.usersMentionCandidates(threadId: 'thread-1', q: '玛利亚'),
    ).called(1);
    verifyNever(() => api.usersSearch(q: any(named: 'q')));
  });

  test('空关键词省略 q，重复、未知关系或不能安全编码的候选被过滤', () async {
    final api = _MockUsersApi();
    when(() => api.usersMentionCandidates(threadId: 'thread-1')).thenAnswer(
      (_) async => _response(
        users: [
          _candidate(
            id: 'user-1',
            username: '玩家甲',
            relation: MentionCandidateDtoRelationEnum.PLAYER,
          ),
          _candidate(
            id: 'user-1',
            username: '玩家甲',
            relation: MentionCandidateDtoRelationEnum.FOLLOWING,
          ),
          _candidate(
            id: 'bad/id',
            username: '危险用户',
            relation: MentionCandidateDtoRelationEnum.PLAYER,
          ),
          _candidate(
            id: 'user-unknown',
            username: '未知关系',
            relation: MentionCandidateDtoRelationEnum.unknownDefaultOpenApi,
          ),
        ],
      ),
    );

    final result = await ApiMentionCandidateRepository(
      api,
    ).findCandidates(threadId: 'thread-1', query: '');

    expect(result.users.single.id, 'user-1');
    verify(() => api.usersMentionCandidates(threadId: 'thread-1')).called(1);
  });

  test('空响应和 Dio 错误不会伪装为空候选', () async {
    final api = _MockUsersApi();
    when(() => api.usersMentionCandidates(threadId: 'thread-1')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(
          path: '/api/v1/users/mention-candidates',
        ),
      ),
    );

    await expectLater(
      ApiMentionCandidateRepository(
        api,
      ).findCandidates(threadId: 'thread-1', query: ''),
      throwsA(isA<ApiFailure>()),
    );

    when(() => api.usersMentionCandidates(threadId: 'thread-2')).thenThrow(
      DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/users/mention-candidates',
        ),
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      ApiMentionCandidateRepository(
        api,
      ).findCandidates(threadId: 'thread-2', query: ''),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('无法连接'),
        ),
      ),
    );
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

MentionCandidateDto _candidate({
  required String id,
  required String username,
  required MentionCandidateDtoRelationEnum relation,
}) {
  return MentionCandidateDto(
    (builder) => builder
      ..id = id
      ..username = username
      ..avatar = null
      ..relation = relation,
  );
}

Response<UsersMentionCandidates200Response> _response({
  required List<MentionCandidateDto> users,
  bool canMentionAllPlayers = false,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/mention-candidates'),
    data: UsersMentionCandidates200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..users = ListBuilder(users)
            ..canMentionAllPlayers = canMentionAllPlayers,
        ),
    ),
  );
}
