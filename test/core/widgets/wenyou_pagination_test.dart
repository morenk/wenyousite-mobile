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
    expect(find.text('已经到底了'), findsOneWidget);
  });
}
