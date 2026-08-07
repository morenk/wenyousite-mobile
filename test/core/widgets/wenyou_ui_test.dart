import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

void main() {
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
