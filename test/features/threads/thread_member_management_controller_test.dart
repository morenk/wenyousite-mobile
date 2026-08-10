import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_member_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_member_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

void main() {
  test('切换玩家标记只替换目标成员', () async {
    final repository = _FakeRepository(bootstrap: _bootstrap());
    final controller = ThreadMemberManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    final target = controller.state.bootstrap!.members.last;
    expect(await controller.togglePlayer(target), isTrue);

    expect(repository.playerValues, [true]);
    expect(controller.state.bootstrap!.members.first.role, _owner.role);
    expect(controller.state.bootstrap!.members.last.playerMarked, isTrue);
    expect(controller.state.pendingUserId, isNull);
  });

  test('楼主二次动作可任命和移除协作者', () async {
    final repository = _FakeRepository(bootstrap: _bootstrap());
    final controller = ThreadMemberManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    final participant = controller.state.bootstrap!.members.last;
    expect(await controller.toggleCollaborator(participant), isTrue);
    expect(repository.roles, [ThreadMemberManagementRole.collaborator]);
    final collaborator = controller.state.bootstrap!.members.last;
    expect(collaborator.role, ThreadMemberManagementRole.collaborator);
    expect(await controller.toggleCollaborator(collaborator), isTrue);
    expect(repository.roles.last, ThreadMemberManagementRole.participant);
  });

  test('协作者不能从客户端任免协作者', () async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(actorIsOwner: false),
    );
    final controller = ThreadMemberManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(
      await controller.toggleCollaborator(
        controller.state.bootstrap!.members.last,
      ),
      isFalse,
    );
    expect(repository.updateCalls, 0);
  });

  test('成员更新失败保留旧列表与请求 ID', () async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      updateFailure: const ApiFailure(
        userMessage: '更新失败',
        requestId: 'member-request-id',
      ),
    );
    final controller = ThreadMemberManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(
      await controller.togglePlayer(controller.state.bootstrap!.members.last),
      isFalse,
    );
    expect(controller.state.bootstrap!.members.last.playerMarked, isFalse);
    expect(controller.state.failure?.requestId, 'member-request-id');
    expect(controller.state.isUpdating, isFalse);
  });

  test('退出玩家身份成功与失败状态可恢复', () async {
    final successRepository = _FakeRepository(bootstrap: _bootstrap());
    final success = ThreadPlayerExitController('thread-1', successRepository);
    addTearDown(success.dispose);
    expect(await success.exit(), isTrue);
    expect(successRepository.exitCalls, 1);
    expect(success.state.failure, isNull);

    final failed = ThreadPlayerExitController(
      'thread-1',
      _FakeRepository(
        bootstrap: _bootstrap(),
        exitFailure: const ApiFailure(
          userMessage: '退出失败',
          requestId: 'exit-id',
        ),
      ),
    );
    addTearDown(failed.dispose);
    expect(await failed.exit(), isFalse);
    expect(failed.state.isSubmitting, isFalse);
    expect(failed.state.failure?.requestId, 'exit-id');
  });

  test('连续刷新只采用最后一次成员列表结果', () async {
    final first = Completer<ThreadMemberManagementBootstrap>();
    final second = Completer<ThreadMemberManagementBootstrap>();
    final controller = ThreadMemberManagementController(
      'thread-1',
      _QueuedLoadRepository([first.future, second.future]),
    );
    addTearDown(controller.dispose);
    await _settle();

    final refresh = controller.load();
    second.complete(_bootstrap(threadTitle: '最新成员列表'));
    await refresh;
    first.complete(_bootstrap(threadTitle: '过期成员列表'));
    await _settle();

    expect(controller.state.bootstrap?.threadTitle, '最新成员列表');
  });
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeRepository implements ThreadMemberManagementRepository {
  _FakeRepository({
    required this.bootstrap,
    this.updateFailure,
    this.exitFailure,
  });

  final ThreadMemberManagementBootstrap bootstrap;
  final ApiFailure? updateFailure;
  final ApiFailure? exitFailure;
  int updateCalls = 0;
  int exitCalls = 0;
  final List<bool> playerValues = [];
  final List<ThreadMemberManagementRole> roles = [];

  @override
  Future<void> exitPlayer(String threadId) async {
    exitCalls += 1;
    if (exitFailure != null) throw exitFailure!;
  }

  @override
  Future<ThreadMemberManagementBootstrap> load(String threadId) async {
    return bootstrap;
  }

  @override
  Future<ThreadMemberManagementMember> updateMember({
    required String threadId,
    required String userId,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  }) async {
    updateCalls += 1;
    if (updateFailure != null) throw updateFailure!;
    if (role != null) roles.add(role);
    if (playerMarked != null) playerValues.add(playerMarked);
    final current = bootstrap.members.firstWhere(
      (member) => member.userId == userId,
    );
    return ThreadMemberManagementMember(
      id: current.id,
      userId: current.userId,
      username: current.username,
      level: current.level,
      role: role ?? current.role,
      playerMarked: playerMarked ?? current.playerMarked,
      joinedAt: current.joinedAt,
    );
  }
}

class _QueuedLoadRepository implements ThreadMemberManagementRepository {
  _QueuedLoadRepository(this.loads);

  final List<Future<ThreadMemberManagementBootstrap>> loads;
  var index = 0;

  @override
  Future<ThreadMemberManagementBootstrap> load(String threadId) {
    return loads[index++];
  }

  @override
  Future<void> exitPlayer(String threadId) => throw UnimplementedError();

  @override
  Future<ThreadMemberManagementMember> updateMember({
    required String threadId,
    required String userId,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  }) => throw UnimplementedError();
}

ThreadMemberManagementBootstrap _bootstrap({
  bool actorIsOwner = true,
  String threadTitle = '星海旅团',
}) {
  return ThreadMemberManagementBootstrap(
    threadId: 'thread-1',
    threadTitle: threadTitle,
    actorIsOwner: actorIsOwner,
    members: [_owner, _participant],
  );
}

final _joinedAt = DateTime.utc(2026, 8, 10);

final _owner = ThreadMemberManagementMember(
  id: 'member-owner',
  userId: 'owner-1',
  username: '楼主',
  level: 3,
  role: ThreadMemberManagementRole.owner,
  playerMarked: false,
  joinedAt: _joinedAt,
);

final _participant = ThreadMemberManagementMember(
  id: 'member-player',
  userId: 'player-1',
  username: '玩家甲',
  level: 2,
  role: ThreadMemberManagementRole.participant,
  playerMarked: false,
  joinedAt: _joinedAt,
);
