import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

import '../../support/foundation_icon_finder.dart';
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
            icon: WenyouIconIds.metricComments,
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

  testWidgets('固定阅读操作不会随滚动隐藏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          floatingActionButtonAnimator:
              FloatingActionButtonAnimator.noAnimation,
          floatingActionButton: const Icon(
            Icons.edit_rounded,
            key: Key('reading-action'),
          ),
          body: ListView(
            key: const Key('reading-list'),
            children: const [SizedBox(height: 1600)],
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

  testWidgets('编辑器发送按钮区分可发送、禁用和发送中状态', (tester) async {
    Widget buildButton({required bool enabled, required bool loading}) {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: WenyouComposerSubmitButton(
              enabled: enabled,
              loading: loading,
              label: '发送',
              onPressed: () {},
            ),
          ),
        ),
      );
    }

    Future<void> expectColors({
      required Color background,
      required Color foreground,
    }) async {
      final button = tester.widget<IconButton>(find.byType(IconButton));
      final style = button.style!;
      expect(style.backgroundColor!.resolve(<WidgetState>{}), background);
      expect(style.foregroundColor!.resolve(<WidgetState>{}), foreground);
    }

    await tester.pumpWidget(buildButton(enabled: true, loading: false));
    await expectColors(
      background: WenyouThemeTokens.light.brandForeground,
      foreground: WenyouThemeTokens.light.panel,
    );

    await tester.pumpWidget(buildButton(enabled: false, loading: false));
    await expectColors(
      background: WenyouThemeTokens.light.border,
      foreground: WenyouThemeTokens.light.mutedText,
    );

    await tester.pumpWidget(buildButton(enabled: false, loading: true));
    await expectColors(
      background: WenyouThemeTokens.light.brandForeground,
      foreground: WenyouThemeTokens.light.panel,
    );
    expect(find.bySemanticsLabel('发送，处理中'), findsOneWidget);
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

    expect(findFoundationIcon(WenyouIconIds.statusError), findsOneWidget);
    expect(find.text('暂时无法提交'), findsOneWidget);
    expect(find.text('请求 ID：request-id'), findsOneWidget);
  });

  testWidgets('失败提示统一从 ApiFailure 展示信息和请求 ID', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouFailureBanner(
            failure: ApiFailure(
              userMessage: '加载没有完成',
              requestId: 'failure-request-id',
            ),
          ),
        ),
      ),
    );

    expect(find.text('加载没有完成'), findsOneWidget);
    expect(find.text('请求 ID：failure-request-id'), findsOneWidget);
    expect(findFoundationIcon(WenyouIconIds.statusError), findsOneWidget);
  });
}
