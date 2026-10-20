import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_page.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final themeCase in [
    (name: 'light', mode: ThemeMode.light),
    (name: 'dark', mode: ThemeMode.dark),
  ]) {
    for (final width in [320.0, 360.0, 400.0]) {
      testWidgets('$width dp 油卡${themeCase.name}视觉候选', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _walletApp(
            _WalletPageRepository(
              balance: '1250',
              // 截图固定本地显示时间，不让 runner 时区改变文字像素。
              // 普通业务夹具仍保留 UTC，下面单独验证转本地的页面语义。
              transactions: [
                _daily(createdAt: DateTime(2026, 8, 10, 9, 2)),
                _expense(createdAt: DateTime(2026, 8, 10, 10, 3)),
                _income(createdAt: DateTime(2026, 8, 10, 11, 4)),
              ],
            ),
            themeMode: themeCase.mode,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final time in ['09:02', '10:03', '11:04']) {
          expect(find.text('2026-08-10 $time'), findsOneWidget);
        }
        await expectLater(
          find.byType(Scaffold).first,
          matchesGoldenFile(
            'goldens/wallet_${width.toInt()}_${themeCase.name}.png',
          ),
        );
      });
    }
  }

  testWidgets('钱包流水将 UTC 时间转为本地时分', (tester) async {
    await tester.pumpWidget(
      _walletApp(
        _WalletPageRepository(
          transactions: [
            _daily(createdAt: DateTime(2026, 8, 10, 9, 2).toUtc()),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2026-08-10 09:02'), findsOneWidget);
  });

  testWidgets('千条钱包流水保持惰性布局并可到达分页入口', (tester) async {
    await tester.pumpWidget(_walletApp(_WalletPageRepository(longList: true)));
    await tester.pumpAndSettle();
    Finder rows() => find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'wallet-transaction-lazy-',
          ),
    );
    expect(rows().evaluate().length, lessThan(20));
    expect(
      find.byKey(const ValueKey('wallet-transaction-lazy-999')),
      findsNothing,
    );
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    for (var attempt = 0; attempt < 5; attempt++) {
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
    }
    expect(
      find.byKey(const ValueKey('wallet-transaction-lazy-999')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('wallet-transaction-lazy-0')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('wallet-load-more')).hitTestable(),
      findsOneWidget,
    );
    expect(rows().evaluate().length, lessThan(20));
    expect(tester.takeException(), isNull);
  });

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
    expect(
      balance.style!.fontFamily,
      AppTheme.light.textTheme.wenyouMetricValue.fontFamily,
    );
    expect(
      balance.style!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
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

    expect(find.text('温油余额加载失败'), findsOneWidget);
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
      expect(find.text('油卡'), findsOneWidget);
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

  testWidgets('320dp 大字长流水金额完整换行且保留精确余额与日期', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      _walletApp(
        _WalletPageRepository(
          balance: '1250',
          transactions: [_largeTransaction()],
        ),
        textScale: 2,
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();
    const amountLabel = '−9,223,372,036,854,775,807 升';
    final amount = find.text(amountLabel.replaceAll(',', ',\u200b'));
    await tester.ensureVisible(amount);
    await tester.pumpAndSettle();
    expect(amount, findsOneWidget);
    expect(
      find.text('余额 9,223,372,036,854,775,807 升'.replaceAll(',', ',\u200b')),
      findsOneWidget,
    );
    expect(find.text('2026-08-10 10:03'), findsOneWidget);
    expect(tester.widget<Text>(amount).maxLines, isNull);
    expect(tester.widget<Text>(amount).semanticsLabel, amountLabel);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/wallet_320_dark_large_amount.png'),
    );
  });

  testWidgets('流水刷新失败保留旧记录并能独立重试', (tester) async {
    final repository = _WalletPageRepository(failTransactionsOnRefresh: true);
    await tester.pumpWidget(_walletApp(repository));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WalletPage)),
    );
    await container
        .read(walletControllerProvider('authenticated-session').notifier)
        .refresh();
    await tester.pumpAndSettle();
    expect(find.text('每日在线签到'), findsOneWidget);
    expect(find.text('收支记录刷新失败，当前仍显示上次结果。'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('wallet-transactions-refresh-retry')),
    );
    await tester.tap(
      find.byKey(const Key('wallet-transactions-refresh-retry')),
    );
    await tester.pumpAndSettle();
    expect(repository.transactionCalls, 3);
    expect(repository.summaryCalls, 2);
    expect(find.text('收支记录刷新失败，当前仍显示上次结果。'), findsNothing);
  });

  testWidgets('合并展示后签到失败仍保留独立重试和余额', (tester) async {
    final repository = _WalletPageRepository(failCheckIn: true);
    await tester.pumpWidget(_walletApp(repository));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WalletPage)),
    );
    final controller = container.read(dailyCheckInControllerProvider.notifier);
    await controller.checkIn('2026-08-10');
    await tester.pumpAndSettle();
    expect(find.text('9,007,199,254,740,993 升'), findsOneWidget);
    await tester.tap(find.byKey(const Key('wallet-check-in-retry')));
    await tester.pumpAndSettle();
    expect(controller.state.retryRevision, 1);
    expect(repository.checkInCalls, 1);
  });

  testWidgets('收支记录继续导航至原目标', (tester) async {
    final router = GoRouter(
      initialLocation: '/wallet',
      routes: [
        GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
        GoRoute(
          path: AppRouteLocations.thread('thread-1'),
          builder: (_, _) => const Scaffold(body: Text('目标主题')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(
            _WalletPageRepository(balance: '1250'),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('投入给「测试主题帖」'));
    await tester.pumpAndSettle();
    expect(find.text('目标主题'), findsOneWidget);
  });
}

Widget _walletApp(
  WalletRepository repository, {
  double textScale = 1,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: [walletRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
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
  _WalletPageRepository({
    this.failSummaryOnce = false,
    this.longList = false,
    this.balance = '9007199254740993',
    this.transactions,
    this.failTransactionsOnRefresh = false,
    this.failCheckIn = false,
  });

  final bool failSummaryOnce;
  final bool longList;
  final String balance;
  final List<WalletTransaction>? transactions;
  var summaryCalls = 0;
  final bool failTransactionsOnRefresh;
  final bool failCheckIn;
  var transactionCalls = 0;
  var checkInCalls = 0;

  @override
  Future<DailyCheckInResult> checkIn() async {
    checkInCalls++;
    if (failCheckIn) {
      throw const ApiFailure(
        userMessage: '网络不可用',
        reason: FailureReason.offline,
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<WalletSummary> fetchWallet() async {
    summaryCalls += 1;
    if (failSummaryOnce && summaryCalls == 1) {
      throw const ApiFailure(
        userMessage: '余额加载失败',
        requestId: 'wallet-request-id',
      );
    }
    return WalletSummary(
      balance: balance,
      receivedTipTotal: '120',
      receivedTipCount: 4,
    );
  }

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) async {
    transactionCalls++;
    if (failTransactionsOnRefresh && transactionCalls == 2) {
      throw const ApiFailure(userMessage: '加载失败');
    }
    return CursorPage(
      items:
          transactions ??
          (longList
              ? List.generate(1000, (index) => _daily(id: 'lazy-$index'))
              : [_daily(), _expense(), _income()]),
      cursor: longList ? 'opaque' : null,
      hasMore: longList,
    );
  }
}

WalletTransaction _largeTransaction() => WalletTransaction(
  id: 'large',
  type: WalletTransactionType.tip,
  direction: WalletTransactionDirection.expense,
  amount: '9223372036854775807',
  grossAmount: '9223372036854775807',
  recipientAmount: '9223372036854775805',
  platformAmount: '2',
  balanceAfter: '9223372036854775807',
  target: const WalletTransactionTarget(
    type: WalletTargetType.thread,
    id: 'thread-1',
    title: '很长的主题帖标题用于验证窄屏流水',
  ),
  createdAt: DateTime(2026, 8, 10, 10, 3),
);

WalletTransaction _daily({String id = 'daily', DateTime? createdAt}) =>
    WalletTransaction(
      id: id,
      type: WalletTransactionType.dailyCheckIn,
      direction: WalletTransactionDirection.income,
      amount: '3',
      grossAmount: '3',
      recipientAmount: '3',
      platformAmount: '0',
      balanceAfter: '13',
      target: const WalletTransactionTarget(type: WalletTargetType.none),
      createdAt: createdAt ?? DateTime.utc(2026, 8, 10, 1, 2),
    );

WalletTransaction _expense({DateTime? createdAt}) => WalletTransaction(
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
  createdAt: createdAt ?? DateTime.utc(2026, 8, 10, 2, 3),
);

WalletTransaction _income({DateTime? createdAt}) => WalletTransaction(
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
  createdAt: createdAt ?? DateTime.utc(2026, 8, 10, 3, 4),
);
