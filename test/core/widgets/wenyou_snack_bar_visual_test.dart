import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('局部主题缺少消息样式时仍使用 Foundation 面板', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showWenyouSnackBar(context, '已保存'),
              child: const Text('显示'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('显示'));
    await tester.pumpAndSettle();
    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.backgroundColor, WenyouThemeTokens.light.panel);
    expect(snack.behavior, SnackBarBehavior.floating);
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(SnackBar),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, WenyouThemeTokens.light.panel);
    expect(
      (material.shape! as RoundedRectangleBorder).side.color,
      WenyouThemeTokens.light.border,
    );
  });

  for (final dark in [false, true]) {
    for (final large in [false, true]) {
      final name = '${dark ? 'dark' : 'light'}_${large ? 'large' : 'regular'}';
      testWidgets('悬浮消息 $name：完整文字、操作与导航和键盘互不遮挡', (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final theme = dark ? AppTheme.dark : AppTheme.light;
        debugDisableShadows = false;
        addTearDown(() => debugDisableShadows = true);
        final message = large ? '操作失败，请检查网络连接后重试。你的内容已保留。' : '今日签到获得 3 升温油。';
        var retried = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(large ? 2 : 1),
                viewInsets: EdgeInsets.only(bottom: large ? 240 : 0),
              ),
              child: child!,
            ),
            home: Scaffold(
              appBar: AppBar(title: const Text('温油站')),
              bottomNavigationBar: NavigationBar(
                key: const Key('navigation'),
                onDestinationSelected: (_) {},
                destinations: const [
                  NavigationDestination(
                    icon: WenyouIcon(WenyouIconIds.navigationHome),
                    label: '首页',
                  ),
                  NavigationDestination(
                    icon: WenyouIcon(WenyouIconIds.navigationMoments),
                    label: '动态',
                  ),
                  NavigationDestination(
                    icon: WenyouIcon(WenyouIconIds.navigationMessages),
                    label: '消息',
                  ),
                  NavigationDestination(
                    icon: WenyouIcon(WenyouIconIds.navigationProfile),
                    label: '我的',
                  ),
                ],
              ),
              body: Builder(
                builder: (context) => Center(
                  child: TextButton(
                    key: const Key('show'),
                    onPressed: () => showWenyouSnackBar(
                      context,
                      message,
                      tone: large
                          ? WenyouSnackBarTone.error
                          : WenyouSnackBarTone.success,
                      actionLabel: large ? '重新尝试' : null,
                      onAction: large ? () => retried = true : null,
                      actionKey: const Key('retry'),
                    ),
                    child: const Text('显示消息'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('show')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final snackRect = tester.getRect(find.byType(SnackBar));
        final textRect = tester.getRect(find.text(message));
        expect(textRect.left, greaterThanOrEqualTo(snackRect.left));
        expect(textRect.right, lessThanOrEqualTo(snackRect.right));
        expect(textRect.bottom, lessThanOrEqualTo(snackRect.bottom));
        expect(textRect.width, greaterThan(220));
        if (large) {
          expect(
            tester.getRect(find.byKey(const Key('retry'))).top,
            greaterThanOrEqualTo(textRect.bottom),
          );
        }
        expect(
          snackRect.bottom,
          lessThanOrEqualTo(
            large
                ? 560
                : tester.getTopLeft(find.byKey(const Key('navigation'))).dy,
          ),
        );
        final tokens = dark ? WenyouThemeTokens.dark : WenyouThemeTokens.light;
        expect(theme.snackBarTheme.backgroundColor, tokens.panel);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/snack_bar_$name.png'),
        );
        debugDisableShadows = true;
        if (large) {
          await tester.tap(find.byKey(const Key('retry')));
          await tester.pump();
          expect(retried, isTrue);
        }
      });
    }
  }

  testWidgets('普通提示使用信息语义图标，减少动态效果时仍可读', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showWenyouSnackBar(context, '已恢复上次的草稿'),
              child: const Text('显示'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('显示'));
    await tester.pumpAndSettle();
    expect(find.text('已恢复上次的草稿'), findsOneWidget);
    expect(
      tester.widget<WenyouIcon>(find.byType(WenyouIcon)).semanticId,
      WenyouIconIds.statusInfo,
    );
  });
}
