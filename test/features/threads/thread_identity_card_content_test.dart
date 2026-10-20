import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_card_content.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_summary.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  Future<void> pumpCard(
    WidgetTester tester, {
    bool enabled = true,
    bool dark = false,
    String accountName = '小明',
    String? historicalName = '白夜',
    String? currentName = '夜渡',
    bool fromPost = false,
    VoidCallback? onOpenAccount,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showWenyouSheet<void>(
                context: context,
                builder: (_) => WenyouSheetBody(
                  title: '帖内身份',
                  showHeader: false,
                  slivers: [
                    SliverToBoxAdapter(
                      child: ThreadIdentityCardContent(
                        accountName: accountName,
                        identityEnabled: enabled,
                        fromPost: fromPost,
                        historicalName: historicalName,
                        currentName: currentName,
                        roleLabel: '楼主',
                        onOpenAccount: onOpenAccount ?? () {},
                      ),
                    ),
                  ],
                ),
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
  }

  testWidgets('旧楼层卡片保留当时名字和真实账号，不追加当前角色对照行', (tester) async {
    await pumpCard(tester);
    expect(find.text('本条发言身份'), findsNothing);
    expect(find.text('白夜'), findsOneWidget);
    expect(find.text('现为'), findsNothing);
    expect(find.text('夜渡'), findsNothing);
    expect(find.text('小明'), findsOneWidget);
    expect(find.text('楼主'), findsOneWidget);
    expect(find.text('站内账号：小明'), findsNothing);
    expect(
      tester
          .getBottomLeft(find.byKey(const Key('thread-identity-open-account')))
          .dy,
      lessThan(tester.getTopLeft(find.text('白夜')).dy),
    );
  });

  testWidgets('无顶部标题与X，外部点击、下滑、系统返回和无障碍均可关闭', (tester) async {
    final handle = tester.ensureSemantics();
    for (final method in ['outside', 'drag', 'back', 'semantics']) {
      await pumpCard(tester);
      expect(find.text('帖内身份'), findsOneWidget);
      expect(find.byTooltip('关闭帖内身份'), findsNothing);
      switch (method) {
        case 'outside':
          await tester.tapAt(const Offset(8, 8));
        case 'drag':
          await tester.flingFrom(
            tester.getTopLeft(find.byType(BottomSheet)) + const Offset(160, 16),
            const Offset(0, 600),
            1200,
          );
        case 'back':
          await tester.binding.handlePopRoute();
        case 'semantics':
          final node = tester.getSemantics(
            find.byKey(const Key('wenyou-sheet-dismiss')),
          );
          expect(
            node.getSemanticsData().hasAction(SemanticsAction.dismiss),
            isTrue,
          );
          node.owner!.performAction(node.id, SemanticsAction.dismiss);
      }
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing, reason: method);
    }
    handle.dispose();
  });

  testWidgets('关闭后即使仍有旧属性也不会显示历史或当前角色名', (tester) async {
    await pumpCard(tester, enabled: false);
    expect(find.text('小明'), findsOneWidget);
    expect(find.textContaining('白夜'), findsNothing);
    expect(find.textContaining('夜渡'), findsNothing);
    expect(find.text('本条发言身份'), findsNothing);
  });

  testWidgets('原身份楼层只显示账号行，不追加当前RP身份', (tester) async {
    await pumpCard(tester, historicalName: null, fromPost: true);
    expect(find.text('小明'), findsOneWidget);
    expect(find.text('本条发言身份'), findsNothing);
    expect(find.text('现为'), findsNothing);
    expect(find.text('夜渡'), findsNothing);
  });

  testWidgets('只从账号行进主页，没有独立按钮；触屏和键盘指向真实账号', (tester) async {
    final actions = <String>[];
    await pumpCard(tester, onOpenAccount: () => actions.add('account'));
    expect(find.text('提及'), findsNothing);
    expect(find.text('只看此人'), findsNothing);
    expect(find.text('查看站内主页'), findsNothing);
    final account = find.byKey(const Key('thread-identity-open-account'));
    expect(tester.getSize(account).height, greaterThanOrEqualTo(48));
    await tester.tap(find.descendant(of: account, matching: find.text('小明')));
    final semantics = tester.ensureSemantics();
    await tester.pump();
    expect(find.bySemanticsLabel('查看 小明 的个人主页'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('查看 小明 的个人主页')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    Focus.of(
      tester.element(find.descendant(of: account, matching: find.text('小明'))),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(actions, ['account', 'account']);
    semantics.dispose();
  });

  testWidgets('改头像或清除后仍只保留历史头像与账号行', (tester) async {
    for (final currentName in ['白夜', null]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ThreadIdentityCardContent(
              accountName: '小明',
              accountAvatarUrl: 'https://example.invalid/account.png',
              identityEnabled: true,
              fromPost: true,
              historicalName: '白夜',
              historicalAvatarUrl: 'https://example.invalid/old.png',
              currentName: currentName,
              currentAvatarUrl: 'https://example.invalid/current.png',
              onOpenAccount: () {},
            ),
          ),
        ),
      );
      final summaries = tester
          .widgetList<ThreadIdentitySummary>(find.byType(ThreadIdentitySummary))
          .toList();
      expect(summaries, hasLength(2));
      expect(summaries.first.avatarUrl, 'https://example.invalid/account.png');
      expect(summaries[1].avatarUrl, 'https://example.invalid/old.png');
      expect(summaries.first.label, isNull);
      expect(find.text('当前使用站内资料'), findsNothing);
      expect(find.text('小明'), findsOneWidget);
    }
  });

  for (final dark in [false, true]) {
    testWidgets('身份卡窄屏视觉候选 ${dark ? 'dark' : 'light'}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await pumpCard(
        tester,
        dark: dark,
        fromPost: true,
        historicalName: '来自群山的白夜与尚未抵达的漫长旅程以及新的故事',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(BottomSheet),
        matchesGoldenFile(
          'goldens/rp_identity_card_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
      expect(find.byTooltip('关闭帖内身份'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await pumpCard(
        tester,
        dark: dark,
        fromPost: true,
        accountName: '玛利亚',
        historicalName: '白夜',
        currentName: null,
      );
      await expectLater(
        find.byType(BottomSheet),
        matchesGoldenFile(
          'goldens/rp_identity_card_cleared_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
    });
    testWidgets('320dp 双倍字号长昵称可换行 ${dark ? 'dark' : 'light'}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpCard(
        tester,
        dark: dark,
        historicalName: '来自群山的白夜与尚未抵达的漫长旅程以及新的故事',
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(
        find.byKey(const Key('thread-identity-open-account')),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
