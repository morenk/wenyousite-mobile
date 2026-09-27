import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';

void main() {
  testWidgets('分页 footer 区分加载、失败、继续和结束', (tester) async {
    Future<void> pump({
      required bool hasMore,
      required bool loading,
      ApiFailure? failure,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouPaginationFooter(
              hasMore: hasMore,
              isLoading: loading,
              failure: failure,
              onLoadMore: () {},
            ),
          ),
        ),
      );
    }

    await pump(hasMore: true, loading: false);
    expect(find.text('加载更多'), findsOneWidget);
    await pump(hasMore: true, loading: true);
    expect(find.text('正在加载更多'), findsOneWidget);
    await pump(
      hasMore: true,
      loading: false,
      failure: const ApiFailure(userMessage: '加载失败'),
    );
    expect(find.text('加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    await pump(hasMore: false, loading: false);
    expect(find.text('已经到底了'), findsNothing);
  });

  testWidgets('隐藏结束提示不占空间，失败期间只允许显式重试', (tester) async {
    var retries = 0;
    Future<void> pump({bool loading = false, ApiFailure? failure}) =>
        tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: Center(
                child: WenyouPaginationFooter(
                  hasMore: false,
                  isLoading: loading,
                  failure: failure,
                  onLoadMore: () => retries++,
                ),
              ),
            ),
          ),
        );
    await pump();
    expect(tester.getSize(find.byType(WenyouPaginationFooter)).height, 0);
    expect(find.text('已经到底了'), findsNothing);
    const failure = ApiFailure(userMessage: '加载失败');
    await pump(failure: failure);
    expect(retries, 0);
    await tester.tap(find.text('重试'));
    expect(retries, 1);
    await pump(failure: failure, loading: true);
    await tester.tap(find.text('重试'));
    expect(retries, 1);
  });

  testWidgets('窄屏放大字号仍完整呈现分页加载提示', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const SizedBox(
              width: 150,
              child: WenyouLoadMoreControl(
                hasMore: true,
                isLoading: true,
                onLoadMore: null,
                loadingLabel: '正在加载更多讨论内容',
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('正在加载更多讨论内容'), findsOneWidget);
  });
}
