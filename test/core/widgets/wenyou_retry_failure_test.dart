import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_page_failure_state.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('权限提示保留，重新加载标签只触发原读取回调', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      _app(
        WenyouRetryFailure(
          panel: true,
          title: '成员列表加载失败',
          failure: const ApiFailure(
            userMessage: '请检查管理权限后重试。',
            reason: FailureReason.permissionDenied,
            recoveryAction: FailureRecoveryAction.login,
          ),
          retryLabel: '重新加载',
          onRetry: () => retries++,
        ),
      ),
    );
    expect(find.text('请检查管理权限后重试。'), findsOneWidget);
    expect(find.text('去登录'), findsNothing);
    expect(find.byType(OutlinedButton), findsOneWidget);
    await tester.tap(find.text('重新加载'));
    expect(retries, 1);
  });

  testWidgets('取消不留下错误面板或整页占位', (tester) async {
    const failure = ApiFailure(reason: FailureReason.cancelled);
    for (final child in [
      WenyouRetryFailure(panel: true, failure: failure, onRetry: () {}),
      WenyouPageFailureState(title: '加载失败', failure: failure, onRetry: () {}),
    ]) {
      await tester.pumpWidget(_app(Center(child: child)));
      expect(find.byType(WenyouPanel), findsNothing);
      expect(find.byType(WenyouPageBody), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    }
  });

  for (final width in [320, 360]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        final name = '${width}_${dark ? 'dark' : 'light'}_${scale.toInt()}x';
        testWidgets('失败与分页 $name 文案、语义及触控无溢出', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width.toDouble(), 1000);
          addTearDown(tester.view.reset);
          final semantics = tester.ensureSemantics();
          var retries = 0;
          const failure = ApiFailure(
            userMessage: '加载失败，请稍后重试。',
            requestId: 'failure-preview-20261018',
            source: FailureSource.service,
          );
          await tester.pumpWidget(
            _app(
              SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    WenyouRetryFailure(
                      panel: true,
                      title: '主题列表加载失败',
                      failure: failure,
                      retryKey: const Key('page-retry'),
                      onRetry: () => retries++,
                    ),
                    const SizedBox(height: 16),
                    WenyouPaginationFooter(
                      hasMore: true,
                      isLoading: false,
                      failure: failure,
                      retryKey: const Key('inline-retry'),
                      retryLabel: '重试加载更多',
                      onLoadMore: () => retries++,
                    ),
                  ],
                ),
              ),
              dark: dark,
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.textContaining('问题编号：failure-preview-20261018'),
            findsNWidgets(2),
          );
          expect(find.bySemanticsLabel('重试加载更多'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(
            find.byKey(const Key('preview')),
            matchesGoldenFile('goldens/retry_failure_$name.png'),
          );
          await tester.tap(find.byKey(const Key('page-retry')));
          await tester.ensureVisible(find.byKey(const Key('inline-retry')));
          await tester.tap(find.byKey(const Key('inline-retry')));
          expect(retries, 2);
          semantics.dispose();
        });
      }
    }
  }
}

Widget _app(Widget child, {bool dark = false, double scale = 1}) => MaterialApp(
  theme: dark ? AppTheme.dark : AppTheme.light,
  home: RepaintBoundary(
    key: const Key('preview'),
    child: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: child,
      ),
    ),
  ),
);
