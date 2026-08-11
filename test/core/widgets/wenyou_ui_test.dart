import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

void main() {
  testWidgets('常驻输入入口在 360dp 下保留页面边距与 48dp 命中区', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: WenyouComposerDock(
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
      matching: find.byType(OutlinedButton),
    );
    expect(tester.getSize(button).height, 48);
    expect(tester.getTopLeft(button).dx, 12);
    expect(tester.getBottomRight(button).dx, 348);

    await tester.tap(find.text('发表评论…'));
    expect(pressed, isTrue);
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
