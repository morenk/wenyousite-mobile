import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_cache_invalidation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

void main() {
  testWidgets('登录会话就绪后只签到一次且仅本次领取展示提示', (tester) async {
    final repository = _WidgetWalletRepository();
    final invalidatedUserIds = <String?>[];
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        walletRepositoryProvider.overrideWithValue(repository),
        profileCacheInvalidatorProvider.overrideWithValue(
          invalidatedUserIds.add,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokens('user-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DailyCheckInBootstrap(child: Scaffold(body: Text('内容页'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.checkInCalls, 1);
    expect(invalidatedUserIds, ['user-1']);
    expect(find.textContaining('今日签到获得 3 升温油'), findsOneWidget);
    await tester.pump();
    expect(repository.checkInCalls, 1);
  });

  testWidgets('加油弹窗校验输入并只确认本次加油金额', (tester) async {
    final repository = _WidgetWalletRepository();
    final invalidatedUserIds = <String?>[];
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        walletRepositoryProvider.overrideWithValue(repository),
        profileCacheInvalidatorProvider.overrideWithValue(
          invalidatedUserIds.add,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokens('sender-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: WenyouTipButton(
              target: TipTarget.user(id: 'recipient-1'),
              recipientName: '作者',
              returnTo: '/users/recipient-1',
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('加油'));
    await tester.pumpAndSettle();
    expect(find.textContaining('平台保留'), findsNothing);
    expect(find.textContaining('85%'), findsNothing);
    await tester.enterText(find.byKey(const Key('tip-amount')), '1');
    await tester.tap(find.byKey(const Key('tip-submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('最低投入 2 升'), findsOneWidget);
    expect(repository.tipCalls, 0);

    await tester.enterText(find.byKey(const Key('tip-amount')), '10');
    await tester.tap(find.byKey(const Key('tip-submit')));
    await tester.pumpAndSettle();
    expect(repository.tipCalls, 1);
    expect(repository.lastAmount, '10');
    expect(invalidatedUserIds, ['recipient-1']);
    expect(find.text('已加油 10 升'), findsOneWidget);
    expect(find.textContaining('对方到账'), findsNothing);
  });
}

class _WidgetWalletRepository extends Fake implements WalletRepository {
  var checkInCalls = 0;
  var tipCalls = 0;
  String? lastAmount;

  @override
  Future<DailyCheckInResult> checkIn() async {
    checkInCalls += 1;
    return const DailyCheckInResult(
      claimedNow: true,
      date: '2026-08-10',
      rewardAmount: '3',
      experienceAwarded: 2,
      balance: '13',
      progression: WalletProgression(
        level: 2,
        experience: 12,
        currentLevelExperience: 2,
        nextLevelExperience: 20,
      ),
    );
  }

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) async {
    tipCalls += 1;
    lastAmount = amount;
    return const TipResult(
      transactionId: 'transaction-tip',
      grossAmount: '10',
      recipientAmount: '8',
      platformAmount: '2',
      balance: '12',
      recipientTipTotal: '18',
      recipientTipCount: 2,
    );
  }
}

SessionTokens _tokens(String userId) {
  final payload = base64Url
      .encode(utf8.encode('{"sub":"$userId"}'))
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-token',
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
