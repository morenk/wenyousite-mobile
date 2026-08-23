import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_controller.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

void main() {
  test('初始并发读取当前主题订阅和玩家候选', () async {
    final repository = _FakeRepository();
    final controller = _controller(repository);
    addTearDown(controller.dispose);

    await _settle();

    expect(controller.state.phase, ThreadSubscriptionPhase.ready);
    expect(controller.state.candidates.single.userId, 'player-1');
    expect(repository.viewerUserId, 'viewer-1');
  });

  test('玩家候选加载失败不阻断官方订阅读取与切换', () async {
    final repository = _FakeRepository(
      candidateFailure: const ApiFailure(
        userMessage: '玩家列表暂时不可用',
        requestId: 'candidate-request-id',
      ),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);

    await _settle();

    expect(controller.state.phase, ThreadSubscriptionPhase.ready);
    expect(controller.state.candidates, isEmpty);
    expect(
      controller.state.candidateFailure?.requestId,
      'candidate-request-id',
    );
    expect(await controller.toggleThread(), isTrue);
    expect(controller.state.threadSubscription?.id, 'official-created');
    expect(
      controller.state.candidateFailure?.requestId,
      'candidate-request-id',
    );
  });

  test('玩家候选悬停时官方订阅先进入可操作状态且写入不会被迟到结果覆盖', () async {
    final candidates = Completer<List<ThreadSubscriptionCandidate>>();
    final repository = _FakeRepository(candidateCompleter: candidates);
    final controller = _controller(repository);
    addTearDown(controller.dispose);

    while (controller.state.phase != ThreadSubscriptionPhase.ready) {
      await _settle();
    }
    expect(controller.state.isLoadingCandidates, isTrue);
    expect(await controller.toggleThread(), isTrue);
    expect(controller.state.threadSubscription?.id, 'official-created');

    candidates.complete(const [
      ThreadSubscriptionCandidate(
        userId: 'player-1',
        username: '骰子猫',
        level: 3,
      ),
    ]);
    await _settle();

    expect(controller.state.isLoadingCandidates, isFalse);
    expect(controller.state.candidates.single.userId, 'player-1');
    expect(controller.state.threadSubscription?.id, 'official-created');
  });

  test('玩家候选失败只重试候选请求并保留官方订阅状态', () async {
    final repository = _FakeRepository(
      candidateFailure: const ApiFailure(userMessage: '玩家列表暂时不可用'),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleThread(), isTrue);
    final subscriptionReads = repository.fetchSubscriptionCalls;
    await controller.retryCandidates();

    expect(repository.fetchSubscriptionCalls, subscriptionReads);
    expect(repository.fetchCandidateCalls, 2);
    expect(controller.state.threadSubscription?.id, 'official-created');
    expect(controller.state.candidateFailure, isNull);
    expect(controller.state.candidates.single.userId, 'player-1');
  });

  test('官方订阅创建与取消使用服务端记录 ID', () async {
    final repository = _FakeRepository();
    final controller = _controller(repository);
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
    final controller = _controller(repository);
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
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleThread(), isFalse);

    expect(controller.state.threadSubscription?.id, 'official-existing');
    expect(
      controller.state.actionFailure?.requestId,
      'subscription-request-id',
    );
  });

  test('创建超时但重新读取已有记录时校准为订阅成功', () async {
    final repository = _FakeRepository(
      subscriptionReads: [
        const [],
        [_record(id: 'official-after-timeout')],
      ],
      failure: _timeoutFailure('timeout-request-id'),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await _settle();

    final future = controller.toggleThread();
    await _settle();
    expect(
      controller.state.actionOutcome,
      anyOf(WriteOutcomeStatus.confirming, isNull),
    );
    expect(await future, isTrue);

    expect(controller.state.threadSubscription?.id, 'official-after-timeout');
    expect(controller.takeSuccessMessage(), '已订阅帖子官方更新。');
    expect(repository.createCalls, 1);
  });

  test('40904 只在重新读取到完全匹配记录后校准为成功', () async {
    final repository = _FakeRepository(
      subscriptionReads: [
        const [],
        [
          _record(id: 'other-player', targetUserId: 'player-1'),
          _record(id: 'official-existing'),
        ],
      ],
      failure: const ApiFailure(
        userMessage: '已订阅',
        httpStatus: 409,
        businessCode: 40904,
        requestId: 'duplicate-request-id',
      ),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleThread(), isTrue);
    expect(controller.state.threadSubscription?.id, 'official-existing');
    expect(repository.fetchSubscriptionCalls, 2);
  });

  test('超时后读取到相反状态时显示暂时无法确定且不宣告失败', () async {
    final repository = _FakeRepository(
      subscriptionReads: const [[], []],
      failure: _timeoutFailure('unknown-request-id'),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleThread(), isFalse);

    expect(controller.state.threadSubscription, isNull);
    expect(controller.state.actionOutcome, WriteOutcomeStatus.indeterminate);
    expect(controller.state.actionFailure, isNull);
    expect(controller.state.actionRequestId, 'unknown-request-id');
    expect(repository.createCalls, 1);
  });

  test('明确权限失败不读取订阅状态进行校准', () async {
    final repository = _FakeRepository(
      failure: const ApiFailure(
        userMessage: '当前账号没有执行这项操作的权限。',
        httpStatus: 403,
        businessCode: 40300,
      ),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.toggleThread(), isFalse);

    expect(controller.state.actionFailure?.businessCode, 40300);
    expect(repository.fetchSubscriptionCalls, 1);
  });

  test('已失效玩家候选不发送创建请求', () async {
    final repository = _FakeRepository();
    final controller = _controller(repository);
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
    this.subscriptionReads,
    this.failure,
    this.candidateFailure,
    this.candidateCompleter,
    this.createCompleter,
  });

  final List<ThreadSubscriptionRecord> subscriptions;
  final List<List<ThreadSubscriptionRecord>>? subscriptionReads;
  final ApiFailure? failure;
  ApiFailure? candidateFailure;
  final Completer<List<ThreadSubscriptionCandidate>>? candidateCompleter;
  final Completer<ThreadSubscriptionRecord>? createCompleter;
  String? viewerUserId;
  int createCalls = 0;
  int fetchSubscriptionCalls = 0;
  int fetchCandidateCalls = 0;
  final List<String> removedIds = [];

  @override
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(
    String threadId,
  ) async {
    final index = fetchSubscriptionCalls++;
    final reads = subscriptionReads;
    if (reads == null || reads.isEmpty) return subscriptions;
    return reads[index.clamp(0, reads.length - 1)];
  }

  @override
  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  }) async {
    fetchCandidateCalls += 1;
    this.viewerUserId = viewerUserId;
    final failure = candidateFailure;
    candidateFailure = null;
    if (failure != null) throw failure;
    if (candidateCompleter != null) return candidateCompleter!.future;
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

ThreadSubscriptionController _controller(_FakeRepository repository) {
  return ThreadSubscriptionController(
    repository,
    'thread-1',
    viewerUserId: 'viewer-1',
  );
}

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

ApiFailure _timeoutFailure(String requestId) {
  return ApiFailure(
    userMessage: '连接超时，请检查网络后重试。',
    requestId: requestId,
    cause: DioException(
      requestOptions: RequestOptions(path: '/subscriptions'),
      type: DioExceptionType.receiveTimeout,
    ),
  );
}
