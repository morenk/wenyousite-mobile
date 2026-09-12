import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';

import 'thread_detail_page_test_support.dart';

void main() {
  testWidgets('自动预取只显示进度，失败才显示重试', (tester) async {
    var retries = 0;
    Future<void> pump(ThreadDetailState state) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ThreadFloorsFooter(state: state, onLoadMore: () => retries++),
        ),
      ),
    );
    final loading = ThreadDetailState(
      floors: [threadDetailPageTestMainFloor],
      hasMore: true,
      isLoadingMore: true,
      isPrefetchingFloors: true,
    );
    await pump(loading);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await pump(
      loading.copyWith(
        isLoadingMore: false,
        isPrefetchingFloors: false,
        transientFailure: const ApiFailure(userMessage: '分页失败'),
        retryAction: ThreadDetailRetryAction.loadMore,
      ),
    );
    await tester.tap(find.byKey(const Key('thread-detail-transient-retry')));
    expect(retries, 1);
    await pump(
      loading.copyWith(
        isLoadingMore: false,
        isPrefetchingFloors: false,
        transientFailure: const ApiFailure(userMessage: '统计读取失败'),
        retryAction: ThreadDetailRetryAction.refresh,
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  testWidgets('主题不可见不提供无效重试，临时失败可以恢复', (tester) async {
    var retries = 0;
    for (final status in [404, 503]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ThreadDetailFatalState(
              failure: ApiFailure(userMessage: '请求失败', httpStatus: status),
              onRetry: () => retries++,
            ),
          ),
        ),
      );
      final retry = find.byKey(const Key('thread-detail-retry'));
      if (status == 404) {
        expect(retry, findsNothing);
      } else {
        await tester.tap(retry);
        expect(retries, 1);
      }
    }
  });
}
