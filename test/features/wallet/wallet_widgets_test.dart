import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

void main() {
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
    expect(find.byKey(const Key('tip-amount')), findsNothing);
    expect(
      tester
          .widget<Semantics>(
            find
                .ancestor(
                  of: find.byKey(const Key('tip-amount-2')),
                  matching: find.byType(Semantics),
                )
                .first,
          )
          .properties
          .selected,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('tip-amount-other')));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('tip-amount')))
          .controller
          ?.text,
      isEmpty,
    );
    expect(find.text('确认加油'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('tip-amount')), '1');
    await tester.pump();
    expect(find.text('确认加油 1 升'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tip-submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('最低投入 2 升'), findsOneWidget);
    expect(repository.tipCalls, 0);

    await tester.tap(find.byKey(const Key('tip-amount-10')));
    await tester.tap(find.byKey(const Key('tip-submit')));
    await tester.pumpAndSettle();
    expect(repository.tipCalls, 1);
    expect(repository.lastAmount, '10');
    expect(invalidatedUserIds, ['recipient-1']);
    expect(find.text('已加油 10 升'), findsOneWidget);
    expect(find.textContaining('对方到账'), findsNothing);
  });

  testWidgets('加油提交中系统返回不关闭弹窗或重复发起请求', (tester) async {
    final repository = _PendingTipWalletRepository();
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(_tipApp(container));
    await tester.tap(find.text('加油'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tip-amount-10')));
    await tester.tap(find.byKey(const Key('tip-submit')));
    await tester.pump();

    expect(repository.requests, hasLength(1));
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('tip-submit')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('为作者加油'), findsOneWidget);
    expect(repository.requests, hasLength(1));

    repository.pending.complete(_tipResult);
    await tester.pumpAndSettle();
    expect(find.text('已加油 10 升'), findsOneWidget);
  });

  testWidgets('不明确失败后以同金额重试复用 clientRequestId', (tester) async {
    final repository = _RetryTipWalletRepository();
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(_tipApp(container));
    await tester.tap(find.text('加油'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tip-amount-10')));
    await tester.tap(find.byKey(const Key('tip-submit')));
    await tester.pumpAndSettle();

    expect(find.text('加油失败，请重试。'), findsOneWidget);
    expect(repository.requests, hasLength(1));

    await tester.tap(find.byKey(const Key('tip-submit')));
    await tester.pumpAndSettle();

    expect(repository.requests, hasLength(2));
    expect(repository.requests[1].$1, repository.requests[0].$1);
    expect(repository.requests[1].$2, repository.requests[0].$2);
    expect(find.text('已加油 10 升'), findsOneWidget);
  });
}

Future<ProviderContainer> _authenticatedContainer(
  WalletRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      walletRepositoryProvider.overrideWithValue(repository),
      profileCacheInvalidatorProvider.overrideWithValue((_) {}),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens('sender-1'));
  return container;
}

Widget _tipApp(ProviderContainer container) {
  return UncontrolledProviderScope(
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
  );
}

const _tipResult = TipResult(
  transactionId: 'transaction-tip',
  grossAmount: '10',
  recipientAmount: '8',
  platformAmount: '2',
  balance: '12',
  recipientTipTotal: '18',
  recipientTipCount: 2,
);

class _PendingTipWalletRepository extends Fake implements WalletRepository {
  final pending = Completer<TipResult>();
  final requests = <(String, String)>[];

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) {
    requests.add((amount, clientRequestId));
    return pending.future;
  }
}

class _RetryTipWalletRepository extends Fake implements WalletRepository {
  final requests = <(String, String)>[];

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) async {
    requests.add((amount, clientRequestId));
    if (requests.length == 1) {
      throw const ApiFailure(userMessage: '加油失败，请重试。');
    }
    return _tipResult;
  }
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
