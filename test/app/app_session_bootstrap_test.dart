import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_session_bootstrap.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('日活经验已领取时只提示温油并刷新资料，重复签到不再提示', (tester) async {
    var claimedNow = true;
    final repository = _CheckInRepository(
      (_) async => _result(
        date: '2026-09-03',
        claimedNow: claimedNow,
        experienceAwarded: 0,
      ),
    );
    final invalidated = <String?>[];
    final container = await _authenticatedContainer(repository, invalidated);
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);
    final now = DateTime.utc(2026, 9, 3, 2);
    await tester.pumpWidget(_app(container, now: () => now));
    await _settle(tester);
    expect(find.text('今日签到获得 3 升温油。'), findsOneWidget);
    expect(find.textContaining('0 经验'), findsNothing);
    expect(invalidated, ['user-1']);

    await tester.pumpWidget(const SizedBox.shrink());
    claimedNow = false;
    await tester.pumpWidget(_app(container, now: () => now));
    await _settle(tester);
    expect(repository.checkInCalls, 2);
    expect(find.textContaining('今日签到获得'), findsNothing);
    expect(invalidated, ['user-1', 'user-1']);
  });

  testWidgets('登录后签到一次且同日重建与恢复不重复请求', (tester) async {
    final repository = _CheckInRepository(
      (_) async => _result(date: '2026-09-03', claimedNow: true),
    );
    final invalidatedUserIds = <String?>[];
    final container = await _authenticatedContainer(
      repository,
      invalidatedUserIds,
    );
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);
    final now = DateTime.utc(2026, 9, 3, 2);

    await tester.pumpWidget(_app(container, now: () => now, childLabel: '内容页'));
    await _settle(tester);

    expect(repository.checkInCalls, 1);
    expect(invalidatedUserIds, ['user-1']);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);

    await tester.pumpWidget(
      _app(container, now: () => now, childLabel: '重建后的内容页'),
    );
    await _settle(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _settle(tester);

    expect(repository.checkInCalls, 1);
  });

  testWidgets('应用保持前台时在北京时间零点后自动签到', (tester) async {
    var now = DateTime.utc(2026, 9, 2, 15, 59, 58);
    final repository = _CheckInRepository((call) async {
      return call == 1
          ? _result(date: '2026-09-02', claimedNow: false)
          : _result(date: '2026-09-03', claimedNow: true);
    });
    final invalidatedUserIds = <String?>[];
    final container = await _authenticatedContainer(
      repository,
      invalidatedUserIds,
    );
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);

    await tester.pumpWidget(_app(container, now: () => now));
    await _settle(tester);
    expect(repository.checkInCalls, 1);

    now = DateTime.utc(2026, 9, 2, 16, 0, 1);
    await tester.pump(const Duration(seconds: 3));
    await _settle(tester);

    expect(repository.checkInCalls, 2);
    expect(invalidatedUserIds, ['user-1', 'user-1']);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);
  });

  testWidgets('后台跨日时暂停计时并在恢复前台后补签', (tester) async {
    var now = DateTime.utc(2026, 9, 2, 15, 59, 58);
    final repository = _CheckInRepository((call) async {
      return call == 1
          ? _result(date: '2026-09-02', claimedNow: false)
          : _result(date: '2026-09-03', claimedNow: true);
    });
    final container = await _authenticatedContainer(repository, []);
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);

    await tester.pumpWidget(_app(container, now: () => now));
    await _settle(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    now = DateTime.utc(2026, 9, 2, 16, 0, 3);
    await tester.pump(const Duration(seconds: 10));
    expect(repository.checkInCalls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _settle(tester);

    expect(repository.checkInCalls, 2);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);
  });

  testWidgets('临时失败按退避补试并遵守 Retry-After', (tester) async {
    final repository = _CheckInRepository((call) async {
      if (call == 1) {
        throw const ApiFailure(
          source: FailureSource.expected,
          reason: FailureReason.unauthenticated,
          businessCode: 40101,
        );
      }
      if (call == 2) {
        throw const ApiFailure(
          source: FailureSource.expected,
          reason: FailureReason.rateLimited,
          retryAfter: Duration(seconds: 40),
        );
      }
      return _result(date: '2026-09-03', claimedNow: true);
    });
    final container = await _authenticatedContainer(repository, []);
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);

    await tester.pumpWidget(
      _app(
        container,
        now: () => DateTime.utc(2026, 9, 3, 2),
        retryJitter: () => Duration.zero,
      ),
    );
    await _settle(tester);
    expect(repository.checkInCalls, 1);

    await tester.pump(const Duration(seconds: 4, milliseconds: 999));
    expect(repository.checkInCalls, 1);
    await tester.pump(const Duration(milliseconds: 1));
    await _settle(tester);
    expect(repository.checkInCalls, 2);

    await tester.pump(const Duration(seconds: 39, milliseconds: 999));
    expect(repository.checkInCalls, 2);
    await tester.pump(const Duration(milliseconds: 1));
    await _settle(tester);

    expect(repository.checkInCalls, 3);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);
  });

  testWidgets('补试耗尽后停止并在下次恢复前台时重新尝试', (tester) async {
    final repository = _CheckInRepository((call) async {
      if (call <= 3) {
        throw const ApiFailure(
          source: FailureSource.network,
          reason: FailureReason.timeout,
        );
      }
      return _result(date: '2026-09-03', claimedNow: true);
    });
    final container = await _authenticatedContainer(repository, []);
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);

    await tester.pumpWidget(
      _app(
        container,
        now: () => DateTime.utc(2026, 9, 3, 2),
        retryJitter: () => Duration.zero,
      ),
    );
    await _settle(tester);
    await tester.pump(const Duration(seconds: 5));
    await _settle(tester);
    await tester.pump(const Duration(seconds: 30));
    await _settle(tester);
    await tester.pump(const Duration(minutes: 5));
    expect(repository.checkInCalls, 3);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _settle(tester);

    expect(repository.checkInCalls, 4);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);
  });

  testWidgets('权限失败不会在前台自动补试', (tester) async {
    final repository = _CheckInRepository(
      (_) => Future.error(
        const ApiFailure(
          source: FailureSource.expected,
          reason: FailureReason.permissionDenied,
          businessCode: 40107,
        ),
      ),
    );
    final container = await _authenticatedContainer(repository, []);
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);

    await tester.pumpWidget(
      _app(
        container,
        now: () => DateTime.utc(2026, 9, 3, 2),
        retryJitter: () => Duration.zero,
      ),
    );
    await _settle(tester);
    await tester.pump(const Duration(minutes: 5));

    expect(repository.checkInCalls, 1);
    expect(find.textContaining('签到失败'), findsNothing);
  });

  testWidgets('跨日发生在请求途中时合并为一次后续签到', (tester) async {
    var now = DateTime.utc(2026, 9, 2, 15, 59, 58);
    final first = Completer<DailyCheckInResult>();
    final repository = _CheckInRepository((call) {
      if (call == 1) return first.future;
      return Future.value(_result(date: '2026-09-03', claimedNow: true));
    });
    final container = await _authenticatedContainer(repository, []);
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);

    await tester.pumpWidget(_app(container, now: () => now));
    await _settle(tester);
    expect(repository.checkInCalls, 1);

    now = DateTime.utc(2026, 9, 2, 16, 0, 1);
    await tester.pump(const Duration(seconds: 3));
    expect(repository.checkInCalls, 1);
    first.complete(_result(date: '2026-09-02', claimedNow: false));
    await _settle(tester);

    expect(repository.checkInCalls, 2);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);
  });

  testWidgets('切号后丢弃旧账号迟到结果并为新账号签到', (tester) async {
    final first = Completer<DailyCheckInResult>();
    final repository = _CheckInRepository((call) {
      if (call == 1) return first.future;
      return Future.value(_result(date: '2026-09-03', claimedNow: true));
    });
    final invalidatedUserIds = <String?>[];
    final container = await _authenticatedContainer(
      repository,
      invalidatedUserIds,
    );
    addTearDown(container.dispose);
    _restoreResumedLifecycle(tester);

    await tester.pumpWidget(
      _app(container, now: () => DateTime.utc(2026, 9, 3, 2)),
    );
    await _settle(tester);
    expect(repository.checkInCalls, 1);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokens('user-2'));
    await tester.pump();
    first.complete(_result(date: '2026-09-03', claimedNow: true, reward: '1'));
    await _settle(tester);

    expect(repository.checkInCalls, 2);
    expect(invalidatedUserIds, ['user-2']);
    expect(find.textContaining('今日签到获得 1 升温油'), findsNothing);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);
  });
}

Future<ProviderContainer> _authenticatedContainer(
  WalletRepository repository,
  List<String?> invalidatedUserIds,
) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      walletRepositoryProvider.overrideWithValue(repository),
      profileCacheInvalidatorProvider.overrideWithValue(invalidatedUserIds.add),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens('user-1'));
  return container;
}

Widget _app(
  ProviderContainer container, {
  required DateTime Function() now,
  Duration Function()? retryJitter,
  String childLabel = '内容页',
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      home: AppSessionBootstrap(
        now: now,
        retryJitter: retryJitter,
        child: Scaffold(body: Text(childLabel)),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var index = 0; index < 8; index++) {
    await tester.pump();
  }
}

void _restoreResumedLifecycle(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  addTearDown(() {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
}

DailyCheckInResult _result({
  required String date,
  required bool claimedNow,
  String reward = '3',
  int experienceAwarded = 2,
}) {
  return DailyCheckInResult(
    claimedNow: claimedNow,
    date: date,
    rewardAmount: reward,
    experienceAwarded: experienceAwarded,
    balance: '13',
    progression: const WalletProgression(
      level: 2,
      experience: 12,
      currentLevelExperience: 2,
      nextLevelExperience: 20,
    ),
  );
}

class _CheckInRepository extends Fake implements WalletRepository {
  _CheckInRepository(this._handler);

  final Future<DailyCheckInResult> Function(int call) _handler;
  int checkInCalls = 0;

  @override
  Future<DailyCheckInResult> checkIn() {
    checkInCalls += 1;
    return _handler(checkInCalls);
  }
}

SessionTokens _tokens(String userId) {
  final payload = base64Url
      .encode(utf8.encode('{"sub":"$userId"}'))
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-$userId',
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
      throw UnimplementedError();
}
