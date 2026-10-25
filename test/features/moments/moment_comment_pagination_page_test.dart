import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';

import 'moment_comment_pagination_test_support.dart';

void main() {
  testWidgets('一级评论无加载更多按钮，短内容自动补足且到底停止', (tester) async {
    final repository = CommentPaginationRepository();
    repository.onComments = (request) => request.cursor == null
        ? commentPage(['first'], cursor: 'next')
        : commentPage(['second']);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('加载更多评论'), findsNothing);
    expect(find.byKey(const Key('moment-comments-load-more')), findsNothing);
    expect(repository.requests.map((e) => e.cursor), [null, 'next']);
    expect(find.text('评论 second'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(2));
  });

  testWidgets('远离底部不因缓存预布局续页，向下滚动后自动加载一次', (tester) async {
    _phone(tester);
    final repository = CommentPaginationRepository();
    final pending = Completer<CursorPage<MomentRootComment>>();
    repository.onComments = (request) => request.cursor == null
        ? commentPage(
            List.generate(9, (i) => 'first-$i'),
            cursor: 'next',
            lines: 6,
          )
        : pending.future;
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    final scroll = _scroll(tester);
    expect(scroll.position.extentAfter, greaterThan(480));
    expect(repository.requests, hasLength(1));
    expect(find.byKey(const Key('moment-comments-load-more')), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(1));
    scroll.jumpTo(scroll.position.maxScrollExtent - 300);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.requests.map((e) => e.cursor), [null, 'next']);
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('正在加载评论'), findsOneWidget);
    expect(repository.requests, hasLength(2));
    pending.complete(commentPage(['last']));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(2));
  });

  testWidgets('分页失败不随滚动重试，仅重试按钮恢复并保留现有评论', (tester) async {
    final repository = CommentPaginationRepository();
    var fail = true;
    repository.onComments = (request) {
      if (request.cursor == null) return commentPage(['first'], cursor: 'next');
      if (fail) throw const ApiFailure(userMessage: '评论加载失败');
      return commentPage(['second']);
    };
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('评论 first'), findsOneWidget);
    expect(find.byKey(const Key('moment-comments-retry')), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(2));
    fail = false;
    await tester.ensureVisible(find.byKey(const Key('moment-comments-retry')));
    await tester.tap(find.byKey(const Key('moment-comments-retry')));
    await tester.pumpAndSettle();
    expect(repository.requests.map((e) => e.cursor), [null, 'next', 'next']);
    expect(find.text('评论 second'), findsOneWidget);
    expect(find.byKey(const Key('moment-comments-retry')), findsNothing);
  });

  testWidgets('一级续页不触发楼中楼，楼中楼仍需手动展开', (tester) async {
    final repository = CommentPaginationRepository();
    repository.onComments = (request) => request.cursor == null
        ? CursorPage(
            items: [paginationComment('root', replyCount: 1)],
            cursor: 'next',
            hasMore: true,
          )
        : commentPage(['second']);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(2));
    expect(repository.replyCalls, 0);
    expect(find.text('展开楼中楼（1 条）'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-replies-root')));
    await tester.pumpAndSettle();
    expect(repository.replyCalls, 1);
    expect(find.text('楼中楼回复'), findsOneWidget);
  });

  testWidgets('缺失游标由展示层提示加载失败，明确重试首页后恢复自动续页', (tester) async {
    final repository = CommentPaginationRepository();
    repository.onComments = (_) =>
        CursorPage(items: [paginationComment('first')], hasMore: true);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('当前内容暂时无法显示，请重新加载。'), findsOneWidget);
    expect(find.textContaining('MOMENT_COMMENTS_CURSOR_MISSING'), findsNothing);
    expect(find.byKey(const Key('moment-comments-retry')), findsOneWidget);
    expect(repository.requests.map((e) => e.cursor), [null]);
    repository.onComments = (request) => request.cursor == null
        ? commentPage(['fresh'], cursor: 'next')
        : commentPage(['second']);
    await tester.ensureVisible(find.byKey(const Key('moment-comments-retry')));
    await tester.tap(find.byKey(const Key('moment-comments-retry')));
    await tester.pumpAndSettle();
    expect(repository.requests.map((e) => e.cursor), [null, null, 'next']);
    expect(find.text('评论 fresh'), findsOneWidget);
    expect(find.text('评论 second'), findsOneWidget);
    expect(find.byKey(const Key('moment-comments-retry')), findsNothing);
  });

  testWidgets('自动追加后深链保持目标开头，手动阅读后不拉回', (tester) async {
    _phone(tester);
    final repository = CommentPaginationRepository();
    final target = paginationComment('target', lines: 28);
    repository.target = MomentCommentContext(root: target, target: target);
    final pending = Completer<CursorPage<MomentRootComment>>();
    repository.onComments = (request) => request.cursor == null
        ? CursorPage(items: [target], cursor: 'next', hasMore: true)
        : pending.future;
    await tester.pumpWidget(_app(repository, targetCommentId: 'target'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final scroll = _scroll(tester);
    final frame = find.byKey(const ValueKey('target-frame-target'));
    expect(
      tester.getTopLeft(frame).dy,
      closeTo(tester.getTopLeft(find.byType(CustomScrollView)).dy, 1),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pump(const Duration(seconds: 1));
    final before = scroll.offset;
    pending.complete(commentPage(['second'], lines: 8));
    await tester.pumpAndSettle();
    expect(scroll.offset, closeTo(before, 1));
    expect(repository.requests, hasLength(2));
  });

  testWidgets('空评论首页无按钮且不启动分页', (tester) async {
    final repository = CommentPaginationRepository();
    repository.onComments = (_) => commentPage([]);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('还没有评论'), findsOneWidget);
    expect(find.text('正在加载评论'), findsNothing);
    expect(repository.requests, hasLength(1));
  });

  testWidgets('长列表顶部排序失败立即反馈，滚动不会续用旧游标', (tester) async {
    _phone(tester);
    final repository = CommentPaginationRepository();
    repository.onComments = (_) => commentPage(
      List.generate(9, (i) => 'first-$i'),
      cursor: 'next',
      lines: 6,
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    repository.onComments = (_) =>
        throw const ApiFailure(userMessage: '评论排序加载失败');
    await tester.tap(find.byKey(const Key('moment-comments-order')));
    await tester.pumpAndSettle();
    final feedback = find.text('评论排序加载失败').hitTestable();
    expect(feedback, findsOneWidget);
    expect(tester.getBottomLeft(feedback).dy, lessThanOrEqualTo(640));
    final scroll = _scroll(tester);
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(2));
  });

  testWidgets('短页成功后下一游标持续失效也只自动恢复一轮', (tester) async {
    final repository = CommentPaginationRepository();
    repository.onComments = (request) {
      if (request.cursor == null) return commentPage(['first'], cursor: 'A');
      if (request.cursor == 'A') return commentPage(['second'], cursor: 'B');
      throw const ApiFailure(businessCode: 40007, userMessage: '评论加载失败');
    };
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(repository.requests.map((e) => e.cursor), [
      null,
      'A',
      'B',
      null,
      'A',
      'B',
    ]);
    expect(find.byKey(const Key('moment-comments-retry')), findsOneWidget);
    expect(find.text('内容已有更新，请刷新后重试。'), findsOneWidget);
    expect(
      find.textContaining('MOMENT_COMMENTS_CURSOR_RECOVERY_EXHAUSTED'),
      findsNothing,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(6));
  });
}

void _phone(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 640);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

ScrollController _scroll(WidgetTester tester) => tester
    .widget<ReadingProgressViewport>(find.byType(ReadingProgressViewport))
    .controller
    .scrollController;

Widget _app(
  CommentPaginationRepository repository, {
  String? targetCommentId,
}) => ProviderScope(
  overrides: [momentRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: MomentDetailPage(
      momentId: 'moment-1',
      targetCommentId: targetCommentId,
    ),
  ),
);
