import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_page.dart';

void main() {
  testWidgets('钱包页展示精确大整数以及签到、支出和收入业务含义', (tester) async {
    await tester.pumpWidget(_walletApp(_WalletPageRepository()));
    await tester.pumpAndSettle();

    expect(find.text('9,007,199,254,740,993 升'), findsOneWidget);
    expect(find.text('120 升'), findsOneWidget);
    expect(find.text('每日在线签到'), findsOneWidget);
    expect(find.text('投入给「测试主题帖」'), findsOneWidget);
    expect(find.text('投入者 的投入'), findsOneWidget);
    expect(find.text('−10 升'), findsOneWidget);
    expect(find.text('+8 升'), findsOneWidget);
    expect(find.textContaining('实际到账 8 升'), findsOneWidget);

    final balance = tester.widget<Text>(find.text('9,007,199,254,740,993 升'));
    expect(
      balance.style!.fontSize,
      WenyouFoundationTypography.mobileSizes['pageTitle'],
    );
    expect(balance.style!.fontFamily, WenyouFoundationTypography.utility);
    final unit = (balance.textSpan! as TextSpan).children!.single as TextSpan;
    expect(
      unit.style!.fontSize,
      WenyouFoundationTypography.mobileSizes['compactBody'],
    );
  });

  testWidgets('余额局部失败不遮挡流水并可独立重试', (tester) async {
    final repository = _WalletPageRepository(failSummaryOnce: true);
    await tester.pumpWidget(_walletApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('钱包余额加载失败'), findsOneWidget);
    expect(find.text('每日在线签到'), findsOneWidget);
    await tester.tap(find.byKey(const Key('wallet-summary-retry')));
    await tester.pumpAndSettle();
    expect(find.text('9,007,199,254,740,993 升'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 钱包长金额和流水无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_walletApp(_WalletPageRepository()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('我的温油'), findsOneWidget);
    });
  }

  testWidgets('320dp 与 2 倍字体下完整余额无布局溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_walletApp(_WalletPageRepository(), textScale: 2));
    await tester.pumpAndSettle();

    expect(find.text('9,007,199,254,740,993 升'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _walletApp(WalletRepository repository, {double textScale = 1}) {
  return ProviderScope(
    overrides: [walletRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const WalletPage(),
    ),
  );
}

class _WalletPageRepository extends Fake implements WalletRepository {
  _WalletPageRepository({this.failSummaryOnce = false});

  final bool failSummaryOnce;
  var summaryCalls = 0;

  @override
  Future<WalletSummary> fetchWallet() async {
    summaryCalls += 1;
    if (failSummaryOnce && summaryCalls == 1) {
      throw const ApiFailure(
        userMessage: '余额加载失败',
        requestId: 'wallet-request-id',
      );
    }
    return const WalletSummary(
      balance: '9007199254740993',
      receivedTipTotal: '120',
      receivedTipCount: 4,
    );
  }

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) async {
    return CursorPage(
      items: [_daily(), _expense(), _income()],
      cursor: null,
      hasMore: false,
    );
  }
}

WalletTransaction _daily() => WalletTransaction(
  id: 'daily',
  type: WalletTransactionType.dailyCheckIn,
  direction: WalletTransactionDirection.income,
  amount: '3',
  grossAmount: '3',
  recipientAmount: '3',
  platformAmount: '0',
  balanceAfter: '13',
  target: const WalletTransactionTarget(type: WalletTargetType.none),
  createdAt: DateTime.utc(2026, 8, 10, 1, 2),
);

WalletTransaction _expense() => WalletTransaction(
  id: 'expense',
  type: WalletTransactionType.tip,
  direction: WalletTransactionDirection.expense,
  amount: '10',
  grossAmount: '10',
  recipientAmount: '8',
  platformAmount: '2',
  balanceAfter: '3',
  counterparty: const WalletCounterparty(
    id: 'owner-1',
    username: '作者',
    level: 2,
  ),
  target: const WalletTransactionTarget(
    type: WalletTargetType.thread,
    id: 'thread-1',
    title: '测试主题帖',
  ),
  createdAt: DateTime.utc(2026, 8, 10, 2, 3),
);

WalletTransaction _income() => WalletTransaction(
  id: 'income',
  type: WalletTransactionType.tip,
  direction: WalletTransactionDirection.income,
  amount: '8',
  grossAmount: '10',
  recipientAmount: '8',
  platformAmount: '2',
  balanceAfter: '21',
  counterparty: const WalletCounterparty(
    id: 'sender-1',
    username: '投入者',
    level: 1,
  ),
  target: const WalletTransactionTarget(
    type: WalletTargetType.user,
    id: 'user-1',
  ),
  createdAt: DateTime.utc(2026, 8, 10, 3, 4),
);
