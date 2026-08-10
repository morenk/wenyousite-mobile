import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/application/mention_candidates_controller.dart';
import 'package:wenyousite_mobile/features/editor/data/mention_candidate_repository.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';

void main() {
  test('输入检测只接受边界后的用户名查询', () {
    expect(
      detectActiveMentionQuery('你好 @温油', 6),
      const ActiveMentionQuery(start: 3, end: 6, query: '温油'),
    );
    expect(detectActiveMentionQuery('mail@example', 12), isNull);
    expect(detectActiveMentionQuery(r'\@转义', 4), isNull);
    expect(detectActiveMentionQuery('@包含 空格', 6), isNull);
    expect(detectActiveMentionQuery('@', 1)?.query, isEmpty);
  });

  test('后输入查询结果优先，过期响应不会覆盖当前候选', () async {
    final first = Completer<MentionCandidatesResult>();
    final second = Completer<MentionCandidatesResult>();
    final repository = _FakeRepository(
      onFind: (_, query) => query == 'a' ? first.future : second.future,
    );
    final controller = MentionCandidatesController(repository, 'thread-1');
    addTearDown(controller.dispose);

    final firstSearch = controller.search('a');
    final secondSearch = controller.search('ab');
    second.complete(_result('user-new', '新候选'));
    await secondSearch;
    first.complete(_result('user-old', '旧候选'));
    await firstSearch;

    expect(controller.state.phase, MentionCandidatesPhase.ready);
    expect(controller.state.query, 'ab');
    expect(controller.state.result.users.single.id, 'user-new');
  });

  test('失败保留请求 ID 并按原关键词重试', () async {
    var attempts = 0;
    final repository = _FakeRepository(
      onFind: (_, query) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ApiFailure(
            userMessage: '候选失败',
            requestId: 'mention-request-id',
          );
        }
        return _result('user-1', '候选用户');
      },
    );
    final controller = MentionCandidatesController(repository, 'thread-1');
    addTearDown(controller.dispose);

    await controller.search('候');
    expect(controller.state.phase, MentionCandidatesPhase.failed);
    expect(controller.state.failure?.requestId, 'mention-request-id');

    await controller.retry();
    expect(controller.state.phase, MentionCandidatesPhase.ready);
    expect(controller.state.query, '候');
    expect(attempts, 2);
  });

  test('相同已完成查询复用当前结果，显式重试才重新请求', () async {
    final repository = _FakeRepository();
    final controller = MentionCandidatesController(repository, 'thread-1');
    addTearDown(controller.dispose);

    await controller.search('温');
    await controller.search('温');
    expect(repository.calls, 1);

    await controller.search('温', force: true);
    expect(repository.calls, 2);
  });
}

class _FakeRepository implements MentionCandidateRepository {
  _FakeRepository({this.onFind});

  final Future<MentionCandidatesResult> Function(String threadId, String query)?
  onFind;
  int calls = 0;

  @override
  Future<MentionCandidatesResult> findCandidates({
    required String threadId,
    required String query,
  }) async {
    calls += 1;
    return onFind?.call(threadId, query) ?? _result('user-1', '温油用户');
  }
}

MentionCandidatesResult _result(String id, String username) {
  return MentionCandidatesResult(
    users: [
      MentionCandidate(
        id: id,
        username: username,
        relation: MentionCandidateRelation.following,
      ),
    ],
    canMentionAllPlayers: false,
  );
}
