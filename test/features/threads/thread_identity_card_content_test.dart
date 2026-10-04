import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_card_content.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  Future<void> pumpCard(
    WidgetTester tester, {
    bool enabled = true,
    bool dark = false,
    String? historicalName = '白鸦',
    bool fromPost = false,
    VoidCallback? onMention,
    VoidCallback? onOnlyThisUser,
    VoidCallback? onOpenAccount,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ThreadIdentityCardContent(
                accountName: '小明',
                identityEnabled: enabled,
                fromPost: fromPost,
                historicalName: historicalName,
                currentName: '夜渡',
                onOpenAccount: onOpenAccount ?? () {},
                onMention: onMention,
                onOnlyThisUser: onOnlyThisUser,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('旧楼层卡片区分当时名字、当前名字和真实账号', (tester) async {
    await pumpCard(tester);
    expect(find.text('本条发言身份'), findsOneWidget);
    expect(find.text('白鸦'), findsOneWidget);
    expect(find.text('当前帖内身份：夜渡'), findsOneWidget);
    expect(find.text('站内账号：小明'), findsOneWidget);
  });

  testWidgets('关闭后即使仍有旧属性也不会显示历史或当前角色名', (tester) async {
    await pumpCard(tester, enabled: false);
    expect(find.text('小明'), findsOneWidget);
    expect(find.textContaining('白鸦'), findsNothing);
    expect(find.textContaining('夜渡'), findsNothing);
    expect(find.text('本条发言身份'), findsNothing);
  });

  testWidgets('原身份楼层不套用当前RP身份，仍说明当前资料', (tester) async {
    await pumpCard(tester, historicalName: null, fromPost: true);
    expect(find.text('小明'), findsOneWidget);
    expect(find.text('本条发言身份'), findsOneWidget);
    expect(find.text('当前帖内身份：夜渡'), findsOneWidget);
    expect(find.text('夜渡'), findsNothing);
  });

  testWidgets('三个动作分别交由调用方处理，不根据昵称重新选人', (tester) async {
    final actions = <String>[];
    await pumpCard(
      tester,
      onMention: () => actions.add('mention'),
      onOnlyThisUser: () => actions.add('filter'),
      onOpenAccount: () => actions.add('account'),
    );
    for (final action in ['mention', 'filter', 'open-account']) {
      await tester.tap(find.byKey(Key('thread-identity-$action')));
    }
    expect(actions, ['mention', 'filter', 'account']);
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
        historicalName: '来自遥远群山的白鸦与尚未抵达的漫长旅程',
        onMention: () {},
        onOnlyThisUser: () {},
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/rp_identity_card_320_${dark ? 'dark' : 'light'}.png',
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
        historicalName: '来自遥远群山的白鸦与尚未抵达的漫长旅程',
        onMention: () {},
        onOnlyThisUser: () {},
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('查看站内主页'));
      expect(tester.takeException(), isNull);
    });
  }
}
