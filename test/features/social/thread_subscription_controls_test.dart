import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_subscription_controls.dart';

void main() {
  testWidgets('游客与自动接收更新的管理者不加载或显示订阅控件', (tester) async {
    final guestRepository = _FakeRepository();
    await tester.pumpWidget(_guestApp(guestRepository));
    expect(find.byKey(const Key('thread-subscription-official')), findsNothing);
    expect(guestRepository.loadCalls, 0);

    final managerRepository = _FakeRepository();
    final managerContainer = await _authenticatedContainer(managerRepository);
    addTearDown(managerContainer.dispose);
    await tester.pumpWidget(_app(managerContainer, hasAutomaticUpdates: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-subscription-official')), findsNothing);
    expect(managerRepository.loadCalls, 0);
  });

  testWidgets('登录普通用户可切换官方更新并打开玩家订阅面板', (tester) async {
    final repository = _FakeRepository();
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('订阅官方更新'), findsOneWidget);
    expect(find.text('玩家发言 0/1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-subscription-official')));
    await tester.pumpAndSettle();
    expect(find.text('已订阅官方更新'), findsOneWidget);
    expect(find.text('已订阅主题官方更新。'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subscription-players')));
    await tester.pumpAndSettle();
    expect(find.text('骰子猫'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('thread-subscription-user-player-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('取消订阅'), findsOneWidget);
    expect(repository.createdTargets, [null, 'player-1']);
  });

  testWidgets('切换账号或退出会话时关闭旧账号的玩家订阅面板', (tester) async {
    final repository = _FakeRepository();
    final container = await _authenticatedContainer(
      repository,
      userId: 'account-a',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(repository.candidateViewerUserIds, ['account-a']);
    await tester.tap(find.byKey(const Key('thread-subscription-players')));
    await tester.pumpAndSettle();
    expect(find.text('订阅玩家发言'), findsOneWidget);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('account-b'));
    await tester.pump();
    expect(find.text('订阅玩家发言'), findsNothing);
    await tester.pumpAndSettle();
    expect(repository.candidateViewerUserIds, ['account-a', 'account-b']);
    expect(repository.createdTargets, isEmpty);

    await tester.tap(find.byKey(const Key('thread-subscription-players')));
    await tester.pumpAndSettle();
    expect(find.text('订阅玩家发言'), findsOneWidget);

    await container.read(sessionControllerProvider.notifier).logoutLocally();
    await tester.pump();
    expect(find.text('订阅玩家发言'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-subscription-official')), findsNothing);
    expect(repository.createdTargets, isEmpty);
  });

  testWidgets('切号后立即打开新路由只关闭旧订阅面板并保留新路由', (tester) async {
    final repository = _FakeRepository();
    final container = await _authenticatedContainer(
      repository,
      userId: 'account-a',
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container, navigatorKey: navigatorKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subscription-players')));
    await tester.pumpAndSettle();
    expect(find.text('订阅玩家发言'), findsOneWidget);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('account-b'));
    unawaited(
      navigatorKey.currentState!.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('新账号页面')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('新账号页面'), findsOneWidget);
    expect(find.text('订阅玩家发言'), findsNothing);
  });

  testWidgets('账号 A 的订阅状态不会被账号 B 复用', (tester) async {
    final repository = _FakeRepository();
    final container = await _authenticatedContainer(
      repository,
      userId: 'account-a',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subscription-official')));
    await tester.pumpAndSettle();
    expect(find.text('已订阅官方更新'), findsOneWidget);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('account-b'));
    await tester.pumpAndSettle();

    expect(find.text('订阅官方更新'), findsOneWidget);
    expect(find.text('已订阅官方更新'), findsNothing);
    expect(repository.candidateViewerUserIds, ['account-a', 'account-b']);
  });

  testWidgets('账号 A 的迟到订阅写入不会污染账号 B', (tester) async {
    final delayedCreate = Completer<ThreadSubscriptionRecord>();
    final repository = _FakeRepository(createCompleter: delayedCreate);
    final container = await _authenticatedContainer(
      repository,
      userId: 'account-a',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subscription-official')));
    await tester.pump();
    expect(repository.createCalls, 1);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('account-b'));
    await tester.pumpAndSettle();
    delayedCreate.complete(
      ThreadSubscriptionRecord(
        id: 'account-a-official',
        threadId: 'thread-1',
        type: ThreadSubscriptionType.thread,
        createdAt: DateTime.utc(2026, 8, 10),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('订阅官方更新'), findsOneWidget);
    expect(find.text('已订阅官方更新'), findsNothing);
    expect(find.text('已订阅主题官方更新。'), findsNothing);
    expect(repository.candidateViewerUserIds, ['account-a', 'account-b']);
  });

  testWidgets('订阅加载失败提供重试并显示请求 ID', (tester) async {
    final loadFailureRepository = _FakeRepository(failLoad: true);
    final loadContainer = await _authenticatedContainer(loadFailureRepository);
    addTearDown(loadContainer.dispose);
    await tester.pumpWidget(_app(loadContainer));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-subscription-retry')), findsOneWidget);
    expect(find.text('问题编号：load-request-id'), findsOneWidget);
  });

  testWidgets('玩家列表失败时官方订阅仍可操作并提供独立重试', (tester) async {
    final repository = _FakeRepository(failCandidates: true);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('订阅官方更新'), findsOneWidget);
    expect(find.text('玩家列表加载失败'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-subscription-official')));
    await tester.pumpAndSettle();
    expect(find.text('已订阅官方更新'), findsOneWidget);

    await tester.tap(find.byKey(const Key('thread-subscription-players')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-subscription-candidates-retry')),
      findsOneWidget,
    );
    expect(find.text('玩家列表暂时不可用'), findsOneWidget);
  });

  testWidgets('订阅写入失败保留旧状态并显示请求 ID', (tester) async {
    final writeFailureRepository = _FakeRepository(failWrite: true);
    final writeContainer = await _authenticatedContainer(
      writeFailureRepository,
    );
    addTearDown(writeContainer.dispose);
    await tester.pumpWidget(_app(writeContainer));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-subscription-official')));
    await tester.pumpAndSettle();
    expect(find.text('订阅官方更新'), findsOneWidget);
    expect(find.text('问题编号：write-request-id'), findsOneWidget);
  });

  testWidgets('订阅结果无法确认时使用中性提示并只提供刷新查看', (tester) async {
    final repository = _FakeRepository(uncertainWrite: true);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subscription-official')));
    await tester.pumpAndSettle();

    expect(find.text('订阅结果暂时无法确定，请稍后刷新查看。'), findsOneWidget);
    expect(find.text('问题编号：uncertain-request-id'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-subscription-refresh-result')),
      findsOneWidget,
    );
    expect(find.textContaining('客户端'), findsNothing);
    expect(find.textContaining('服务端'), findsNothing);
    expect(find.textContaining('HTTP'), findsNothing);
    expect(find.textContaining('错误码'), findsNothing);
    final banner = tester.widget<WenyouStatusBanner>(
      find.descendant(
        of: find.byKey(const Key('thread-subscription-indeterminate')),
        matching: find.byType(WenyouStatusBanner),
      ),
    );
    expect(banner.tone, WenyouStatusTone.neutral);
    expect(repository.createCalls, 1);

    await tester.tap(
      find.byKey(const Key('thread-subscription-refresh-result')),
    );
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(repository.loadCalls, 3);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 订阅控件与玩家面板无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 620);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final container = await _authenticatedContainer(_FakeRepository());
      addTearDown(container.dispose);
      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('thread-subscription-players')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _guestApp(ThreadSubscriptionRepository repository) {
  return ProviderScope(
    overrides: [
      threadSubscriptionRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: ThreadSubscriptionControls(
          threadId: 'thread-1',
          hasAutomaticUpdates: false,
        ),
      ),
    ),
  );
}

Widget _app(
  ProviderContainer container, {
  bool hasAutomaticUpdates = false,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.light,
      home: Scaffold(
        body: ThreadSubscriptionControls(
          threadId: 'thread-1',
          hasAutomaticUpdates: hasAutomaticUpdates,
        ),
      ),
    ),
  );
}

Future<ProviderContainer> _authenticatedContainer(
  ThreadSubscriptionRepository repository, {
  String userId = 'viewer-1',
}) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      threadSubscriptionRepositoryProvider.overrideWithValue(repository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokensFor(userId));
  return container;
}

class _FakeRepository implements ThreadSubscriptionRepository {
  _FakeRepository({
    this.failLoad = false,
    this.failCandidates = false,
    this.failWrite = false,
    this.uncertainWrite = false,
    this.createCompleter,
  });

  final bool failLoad;
  final bool failCandidates;
  final bool failWrite;
  final bool uncertainWrite;
  final Completer<ThreadSubscriptionRecord>? createCompleter;
  int loadCalls = 0;
  int createCalls = 0;
  final List<String?> createdTargets = [];
  final List<String?> candidateViewerUserIds = [];

  @override
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(
    String threadId,
  ) async {
    loadCalls += 1;
    if (failLoad) {
      throw const ApiFailure(
        userMessage: '订阅状态加载失败',
        requestId: 'load-request-id',
      );
    }
    return [];
  }

  @override
  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  }) async {
    candidateViewerUserIds.add(viewerUserId);
    if (failCandidates) {
      throw const ApiFailure(userMessage: '玩家列表暂时不可用');
    }
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
    if (uncertainWrite) {
      throw ApiFailure(
        userMessage: '连接超时，请检查网络后重试。',
        requestId: 'uncertain-request-id',
        cause: DioException(
          requestOptions: RequestOptions(path: '/subscriptions'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
    }
    if (failWrite) {
      throw const ApiFailure(
        userMessage: '订阅写入失败',
        requestId: 'write-request-id',
      );
    }
    createdTargets.add(targetUserId);
    if (createCompleter != null) return createCompleter!.future;
    return ThreadSubscriptionRecord(
      id: targetUserId == null ? 'official-1' : 'user-1',
      threadId: threadId,
      type: type,
      targetUserId: targetUserId,
      createdAt: DateTime.utc(2026, 8, 10),
    );
  }

  @override
  Future<void> remove(String subscriptionId) async {}
}

SessionTokens _tokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-token-$userId',
  );
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      _tokensFor('viewer-1');
}
