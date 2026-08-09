import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_controller.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

void main() {
  test('初始并发读取当前主题订阅和玩家候选', () async {
    final repository = _FakeRepository();
    final controller = ThreadSubscriptionController(repository, _target);
    addTearDown(controller.dispose);

    await _settle();

    expect(controller.state.phase, ThreadSubscriptionPhase.ready);
    expect(controller.state.candidates.single.userId, 'player-1');
    expect(repository.viewerUserId, 'viewer-1');
  });

  test('官方订阅创建与取消使用服务端记录 ID', () async {
    final repository = _FakeRepository();
    final controller = ThreadSubscriptionController(repository, _target);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleThread(), isTrue);
    expect(controller.state.threadSubscription?.id, 'official-created');
    expect(await controller.toggleThread(), isTrue);
    expect(controller.state.threadSubscription, isNull);
    expect(repository.removedIds, ['official-created']);
  });

  test('玩家订阅按目标独立切换并串行化写入', () async {
    final completer = Completer<ThreadSubscriptionRecord>();
    final repository = _FakeRepository(createCompleter: completer);
    final controller = ThreadSubscriptionController(repository, _target);
    addTearDown(controller.dispose);
    await _settle();

    final first = controller.toggleUser('player-1');
    expect(controller.state.isPending, isTrue);
    expect(await controller.toggleThread(), isFalse);
    completer.complete(_record(id: 'player-created', targetUserId: 'player-1'));
    expect(await first, isTrue);

    expect(
      controller.state.userSubscriptionFor('player-1')?.id,
      'player-created',
    );
    expect(await controller.toggleUser('player-1'), isTrue);
    expect(repository.removedIds, ['player-created']);
  });

  test('写失败保留原订阅并透传请求 ID', () async {
    final repository = _FakeRepository(
      subscriptions: [_record(id: 'official-existing')],
      failure: const ApiFailure(
        userMessage: '暂时无法取消',
        requestId: 'subscription-request-id',
      ),
    );
    final controller = ThreadSubscriptionController(repository, _target);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleThread(), isFalse);

    expect(controller.state.threadSubscription?.id, 'official-existing');
    expect(
      controller.state.actionFailure?.requestId,
      'subscription-request-id',
    );
  });

  test('已失效玩家候选不发送创建请求', () async {
    final repository = _FakeRepository();
    final controller = ThreadSubscriptionController(repository, _target);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleUser('missing-player'), isFalse);
    expect(repository.createCalls, 0);
    expect(controller.state.actionFailure?.userMessage, contains('可订阅列表'));
  });
}

class _FakeRepository implements ThreadSubscriptionRepository {
  _FakeRepository({
    this.subscriptions = const [],
    this.failure,
    this.createCompleter,
  });

  final List<ThreadSubscriptionRecord> subscriptions;
  final ApiFailure? failure;
  final Completer<ThreadSubscriptionRecord>? createCompleter;
  String? viewerUserId;
  int createCalls = 0;
  final List<String> removedIds = [];

  @override
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(
    String threadId,
  ) async => subscriptions;

  @override
  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  }) async {
    this.viewerUserId = viewerUserId;
    return const [
      ThreadSubscriptionCandidate(
        userId: 'player-1',
        username: '骰子猫',
        level: 3,
      ),
    ];
  }

  @override
  Future<ThreadSubscriptionRecord> create({
    required String threadId,
    required ThreadSubscriptionType type,
    String? targetUserId,
  }) async {
    createCalls += 1;
    if (failure != null) throw failure!;
    if (createCompleter != null) return createCompleter!.future;
    return _record(
      id: type == ThreadSubscriptionType.thread
          ? 'official-created'
          : 'player-created',
      targetUserId: targetUserId,
    );
  }

  @override
  Future<void> remove(String subscriptionId) async {
    if (failure != null) throw failure!;
    removedIds.add(subscriptionId);
  }
}

const _target = ThreadSubscriptionTarget(
  threadId: 'thread-1',
  viewerUserId: 'viewer-1',
);

ThreadSubscriptionRecord _record({required String id, String? targetUserId}) {
  return ThreadSubscriptionRecord(
    id: id,
    threadId: 'thread-1',
    type: targetUserId == null
        ? ThreadSubscriptionType.thread
        : ThreadSubscriptionType.user,
    targetUserId: targetUserId,
    createdAt: DateTime.utc(2026, 8, 10),
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);
