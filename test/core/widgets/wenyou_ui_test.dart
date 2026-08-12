import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('纵向内容宽度只由可用空间和最大宽度决定', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: WenyouConstrainedWidth(
              child: ColoredBox(
                key: Key('full-width-content'),
                color: Colors.pink,
                child: Text('短'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('full-width-content'))).width,
      336,
    );

    tester.view.physicalSize = const Size(900, 240);
    await tester.pump();
    expect(
      tester.getSize(find.byKey(const Key('full-width-content'))).width,
      600,
    );
  });

  testWidgets('悬浮输入入口不压缩正文并保留 48dp 命中区', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          key: const Key('composer-action-visual'),
          body: const SizedBox.expand(key: Key('reading-body')),
          floatingActionButton: WenyouComposerAction(
            key: const Key('composer-dock'),
            label: '发表评论…',
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    final dock = find.byKey(const Key('composer-dock'));
    final button = find.descendant(
      of: dock,
      matching: find.byType(FilledButton),
    );
    expect(tester.getSize(button).height, 48);
    expect(tester.getSize(button).width, lessThan(200));
    expect(tester.getBottomRight(button).dx, 344);
    expect(tester.getSize(find.byKey(const Key('reading-body'))).height, 240);

    await expectLater(
      find.byKey(const Key('composer-action-visual')),
      matchesGoldenFile('goldens/composer_action_360.png'),
    );

    await tester.tap(find.text('发表评论…'));
    expect(pressed, isTrue);
  });

  testWidgets('无障碍导航开启时阅读操作不会随滚动隐藏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: WenyouReadingChrome(
            builder: (context, actionsVisible) => Scaffold(
              floatingActionButton: actionsVisible
                  ? const Icon(Icons.edit_rounded, key: Key('reading-action'))
                  : null,
              body: ListView(
                key: const Key('reading-list'),
                children: const [SizedBox(height: 1600)],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const Key('reading-list')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reading-action')), findsOneWidget);
  });

  testWidgets('异步主按钮在默认和加载状态都保持 48dp', (tester) async {
    Widget buildButton({required bool isLoading}) {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: WenyouAsyncPrimaryButton(
                label: '提交',
                isLoading: isLoading,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildButton(isLoading: false));
    expect(tester.getSize(find.byType(FilledButton)).height, 48);
    expect(find.text('提交'), findsOneWidget);

    await tester.pumpWidget(buildButton(isLoading: true));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getSize(find.byType(FilledButton)).height, 48);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('状态提示同时展示图标、信息和请求 ID', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouStatusBanner(
            message: '暂时无法提交',
            detail: '请求 ID：request-id',
            tone: WenyouStatusTone.error,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.text('暂时无法提交'), findsOneWidget);
    expect(find.text('请求 ID：request-id'), findsOneWidget);
  });
}
