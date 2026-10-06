import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_invitation_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';

void main() {
  test('已加入预览重新核验旧链接404时清空预览并进入失败终态', () async {
    final repository = _FakeInvitationRepository(
      previewValue: _preview(alreadyJoined: true),
    );
    final controller = ThreadInvitationAccessController(
      'Abcd_1234-efGh56',
      repository,
    );
    addTearDown(controller.dispose);
    await _settle();
    expect(controller.state.preview?.alreadyJoined, isTrue);
    repository.previewFailure = const ApiFailure(
      httpStatus: 404,
      businessCode: 40408,
    );
    await controller.load();
    expect(controller.state.phase, ThreadInvitationAccessPhase.failed);
    expect(controller.state.preview, isNull);
  });

  test('取得链接成功后保留可手动复制的当前链接', () async {
    final repository = _FakeInvitationRepository();
    final controller = ThreadInviteLinkController('thread-1', repository);
    addTearDown(controller.dispose);

    final link = await controller.ensure();

    expect(repository.ensureCalls, 1);
    expect(link?.token, 'Abcd_1234-efGh56');
    expect(controller.state.link, same(link));
    expect(controller.state.failure, isNull);
  });

  test('重新取得链接失败时清空可能过期链接并保留请求 ID', () async {
    final repository = _FakeInvitationRepository();
    final controller = ThreadInviteLinkController('thread-1', repository);
    addTearDown(controller.dispose);
    await controller.ensure();
    repository.ensureFailure = const ApiFailure(
      userMessage: '生成失败',
      requestId: 'invite-request-id',
    );

    expect(await controller.ensure(), isNull);

    expect(controller.state.link, isNull);
    expect(controller.state.failure?.requestId, 'invite-request-id');
  });

  test('已加入成员不会重复调用加入端点', () async {
    final repository = _FakeInvitationRepository(
      previewValue: _preview(alreadyJoined: true),
    );
    final controller = ThreadInvitationAccessController(
      'Abcd_1234-efGh56',
      repository,
    );
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.join(), isNull);
    expect(repository.joinCalls, 0);
  });

  test('加入失败保留预览与请求 ID，重试成功后切换已加入事实', () async {
    final repository = _FakeInvitationRepository(
      joinFailure: const ApiFailure(
        userMessage: '加入暂时没有完成。',
        requestId: 'join-request-id',
      ),
    );
    final controller = ThreadInvitationAccessController(
      'Abcd_1234-efGh56',
      repository,
    );
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.join(), isNull);
    expect(controller.state.preview?.threadId, 'thread-1');
    expect(controller.state.joinFailure?.requestId, 'join-request-id');

    repository.joinFailure = null;
    final result = await controller.join();
    expect(result?.threadId, 'thread-1');
    expect(controller.state.preview?.alreadyJoined, isTrue);
  });

  test('连续加载邀请只采用最后一次预览结果', () async {
    final first = Completer<ThreadInvitationPreview>();
    final second = Completer<ThreadInvitationPreview>();
    final repository = _QueuedPreviewRepository([first.future, second.future]);
    final controller = ThreadInvitationAccessController(
      'Abcd_1234-efGh56',
      repository,
    );
    addTearDown(controller.dispose);
    await _settle();

    final refresh = controller.load();
    second.complete(_preview(title: '最新邀请'));
    await refresh;
    first.complete(_preview(title: '过期邀请'));
    await _settle();

    expect(controller.state.preview?.title, '最新邀请');
  });
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeInvitationRepository implements ThreadInvitationRepository {
  _FakeInvitationRepository({
    ThreadInvitationPreview? previewValue,
    this.joinFailure,
  }) : previewValue = previewValue ?? _preview();

  final ThreadInvitationPreview previewValue;
  ApiFailure? ensureFailure;
  ApiFailure? resetFailure;
  ApiFailure? previewFailure;
  ApiFailure? joinFailure;
  int ensureCalls = 0;
  int resetCalls = 0;
  int joinCalls = 0;

  @override
  Future<ThreadInvitationLink> ensureLink(String threadId) async {
    ensureCalls += 1;
    if (ensureFailure != null) throw ensureFailure!;
    return _link;
  }

  @override
  Future<ThreadInvitationLink> resetLink(String threadId) async {
    resetCalls += 1;
    if (resetFailure != null) throw resetFailure!;
    return _link;
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) async {
    joinCalls += 1;
    if (joinFailure != null) throw joinFailure!;
    return const ThreadInvitationJoinResult(
      memberId: 'member-1',
      threadId: 'thread-1',
      threadTitle: '星海密谈',
      userId: 'user-1',
    );
  }

  @override
  Future<ThreadInvitationPreview> preview(String token) async {
    if (previewFailure != null) throw previewFailure!;
    return previewValue;
  }
}

class _QueuedPreviewRepository implements ThreadInvitationRepository {
  _QueuedPreviewRepository(this.previews);

  final List<Future<ThreadInvitationPreview>> previews;
  var index = 0;

  @override
  Future<ThreadInvitationPreview> preview(String token) {
    return previews[index++];
  }

  @override
  Future<ThreadInvitationLink> ensureLink(String threadId) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadInvitationLink> resetLink(String threadId) =>
      ensureLink(threadId);

  @override
  Future<ThreadInvitationJoinResult> join(String token) {
    throw UnimplementedError();
  }
}

final _link = ThreadInvitationLink(
  id: 'invite-1',
  threadId: 'thread-1',
  token: 'Abcd_1234-efGh56',
  url: Uri.parse('https://wenyou.site/join/Abcd_1234-efGh56'),
  createdAt: DateTime.utc(2026, 8, 10),
);

ThreadInvitationPreview _preview({
  String title = '星海密谈',
  bool alreadyJoined = false,
}) {
  return ThreadInvitationPreview(
    threadId: 'thread-1',
    title: title,
    categorySlug: 'RPG',
    status: ThreadInvitationStatus.recruiting,
    ownerId: 'owner-1',
    ownerName: '楼主',
    memberCount: 8,
    createdAt: DateTime.utc(2026, 8, 9),
    alreadyJoined: alreadyJoined,
  );
}
