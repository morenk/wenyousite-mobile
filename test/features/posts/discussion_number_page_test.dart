import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import '../../support/deterministic_test_fonts.dart';
import '../threads/thread_detail_page_collaboration_repositories.dart';
import '../threads/thread_detail_page_detail_repository.dart';
import 'post_replies_page_discussion_fixtures.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final narrow in [false, true]) {
    for (final replies in [false, true]) {
      testWidgets('${replies ? '回复' : '主楼'}真实页面按编号定位并返回 narrow=$narrow', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(narrow ? 320 : 360, 800);
        tester.platformDispatcher.textScaleFactorTestValue = narrow ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        ProviderContainer? postContainer;
        final posts = _Posts();
        final floors = _Floors();
        if (replies) {
          final container = await postRepliesPageTestPostContainer(posts);
          postContainer = container;
          addTearDown(container.dispose);
          await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
        } else {
          await tester.pumpWidget(threadDetailPageTestDetailApp(floors));
        }
        await tester.pumpAndSettle();
        final prefix = replies ? 'post-reply-' : 'thread-floor-card-';
        final first = find.byKey(Key('${prefix}2'));
        await tester.scrollUntilVisible(
          first,
          250,
          scrollable: find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    widget.axisDirection == AxisDirection.down,
              )
              .first,
        );
        await tester.ensureVisible(first);
        await tester.pumpAndSettle();
        final before = tester.getTopLeft(first).dy;
        final capsule = find.byKey(const Key('discussion-position-button'));
        if (capsule.evaluate().isNotEmpty) {
          await tester.tap(capsule);
        } else {
          await tester.tap(
            find.byKey(
              Key(replies ? 'post-replies-count' : 'thread-floors-count'),
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(find.text(replies ? '跳转到回复' : '跳转到楼层'), findsOneWidget);
        expect(find.text('最早'), findsNothing);
        expect(find.text('中间'), findsNothing);
        expect(find.text('最新'), findsNothing);
        await tester.enterText(
          find.byKey(const Key('discussion-number-input')),
          '5000',
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('discussion-number-submit')));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('${prefix}5000')), findsOneWidget);
        expect(find.byKey(const Key('discussion-number-input')), findsNothing);
        final requests = replies ? posts.targets : floors.targets;
        expect(requests.where((id) => id == '5000').length, 1);
        if (replies) {
          await tester.drag(
            find.byKey(const Key('post-replies-list')),
            const Offset(0, -95),
          );
          await tester.pumpAndSettle();
          final reading = tester
              .widget<ReadingProgressViewport>(
                find.byType(ReadingProgressViewport),
              )
              .controller;
          final bookmark = reading.captureBookmark()!;
          await postContainer!
              .read(
                postDiscussionControllerProvider((
                  rootPostId: 'root',
                  focusedReplyId: null,
                )).notifier,
              )
              .loadAdjacent(before: true);
          await tester.pumpAndSettle();
          expect(reading.captureBookmark()!.id, bookmark.id);
          expect(
            reading.captureBookmark()!.offset,
            closeTo(bookmark.offset, 1),
          );
        }
        expect(find.text('回到刚才'), findsOneWidget);
        await tester.tap(find.text('回到刚才'));
        await tester.pumpAndSettle();
        expect(first, findsOneWidget);
        expect((tester.getTopLeft(first).dy - before).abs(), lessThan(2));
        // 删除后再次输入原编号：面板原位报错，现有窗口和阅读位置保持。
        posts.unavailableNumber = 5000;
        floors.unavailableNumber = 5000;
        await tester.tap(find.byKey(const Key('discussion-position-button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('discussion-number-input')),
          '5000',
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('discussion-number-submit')));
        await tester.pumpAndSettle();
        expect(find.text('该编号已不可见'), findsOneWidget);
        expect(
          find.byKey(const Key('discussion-number-input')),
          findsOneWidget,
        );
        expect(first, findsOneWidget);
        await tester.tap(find.byTooltip(replies ? '关闭跳转到回复' : '关闭跳转到楼层'));
        await tester.pumpAndSettle();
        expect((tester.getTopLeft(first).dy - before).abs(), lessThan(2));
        expect(tester.takeException(), isNull);
      });
    }
  }
}

List<int> _numbers(int? target) => List.generate(
  20,
  (index) => (target == null || target < 20 ? 1 : target - 5) + index,
);

class _Posts extends PostRepliesPageTestFakePostRepository {
  final targets = <String>[];
  int? unavailableNumber;
  @override
  Future<DiscussionWindow<PostItem>> fetchReplyWindow({
    required String rootPostId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) async {
    final target = number ?? (postId == null ? null : int.parse(postId));
    if (target != null) targets.add('$target');
    if (target != null && target == unavailableNumber) {
      throw const ApiFailure(userMessage: '该编号已不可见', httpStatus: 404);
    }
    return DiscussionWindow(
      items:
          (cursor == null
                  ? _numbers(target)
                  : List.generate(20, (index) => int.parse(cursor) + index))
              .map(
                (n) => PostItem(
                  id: '$n',
                  threadId: 'thread',
                  subthreadId: 'subthread',
                  author: postRepliesPageTestAuthor,
                  content: '回复 $n\n正文第二行\n第三行',
                  version: 1,
                  createdAt: postRepliesPageTestRootCreatedAt,
                  updatedAt: postRepliesPageTestRootCreatedAt,
                  isBody: false,
                  isDeleted: false,
                  replyNumber: n,
                  parentPostId: 'root',
                ),
              )
              .toList(),
      total: 10000,
      maxNumber: 10000,
      targetId: target?.toString(),
      targetNumber: target,
      beforeCursor: target != null && target > 20 ? '${target - 25}' : null,
    );
  }
}

class _Floors extends ThreadDetailPageTestFakeThreadDetailRepository {
  final targets = <String>[];
  int? unavailableNumber;
  @override
  Future<DiscussionWindow<ThreadFloorModel>> fetchFloorWindow({
    required String subthreadId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    final target = number ?? (postId == null ? null : int.parse(postId));
    if (target != null) targets.add('$target');
    if (target != null && target == unavailableNumber) {
      throw const ApiFailure(userMessage: '该编号已不可见', httpStatus: 404);
    }
    return DiscussionWindow(
      items: _numbers(target)
          .map(
            (n) => ThreadFloorModel(
              id: '$n',
              floorNumber: n,
              author: threadDetailPageTestAuthor,
              body: ThreadBodyModel(markdown: '楼层 $n\n正文第二行\n第三行'),
              createdAt: threadDetailPageTestRecentFixtureTime,
              isDeleted: false,
              replyCount: 0,
              replies: const [],
            ),
          )
          .toList(),
      total: 10000,
      maxNumber: 10000,
      targetId: target?.toString(),
      targetNumber: target,
    );
  }
}
