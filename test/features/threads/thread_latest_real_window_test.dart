import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final fixture =
      jsonDecode(
            File(
              'test/fixtures/thread_latest_long_window.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  final floors = [
    for (final value in fixture['floors']! as List)
      ThreadFloorModel(
        id: 'sample-floor-${(value as Map)['number']}',
        floorNumber: value['number'] as int,
        author: threadDetailPageTestAuthor,
        body: ThreadBodyModel(markdown: value['content'] as String),
        createdAt: threadDetailPageTestRecentFixtureTime,
        isDeleted: false,
        replyCount: value['replyCount'] as int,
        replies: [
          for (final (index, reply) in (value['replies'] as List).indexed)
            ThreadReplyModel(
              id: 'sample-reply-${value['number']}-$index',
              author: threadDetailPageTestAuthor,
              body: ThreadBodyModel(
                markdown: (reply as Map)['content'] as String,
              ),
              createdAt: threadDetailPageTestRecentFixtureTime,
              isDeleted: false,
            ),
        ],
      ),
  ];
  final original = threadDetailPageTestDetail;
  final detail = ThreadDetailModel(
    id: original.id,
    title: original.title,
    owner: original.owner,
    status: original.status,
    isPrivate: false,
    isPinned: false,
    viewCount: 1,
    likeCount: 0,
    tipTotal: '0',
    memberCount: 8,
    playerCount: 6,
    postCount: 104,
    tags: const [],
    defaultSubthreadId: 'subthread-1',
    subthreads: [
      for (var i = 1; i <= 4; i++)
        ThreadSubthreadModel(
          id: 'subthread-$i',
          title: '子贴 $i',
          sortOrder: i - 1,
          postCount: i == 3 ? 79 : 1,
          postingPolicyLabel: '参与者',
          body: ThreadBodyModel(
            markdown: i == 3 ? fixture['body']! as String : '初始子贴正文',
          ),
        ),
    ],
    createdAt: original.createdAt,
    updatedAt: original.updatedAt,
  );

  for (final (physicalSize, ratio, scale) in [
    (const Size(360, 640), 1.0, 1.0),
    (const Size(393, 851), 1.0, 1.3),
    (const Size(360, 480), 1.0, 2.0),
    (const Size(1256, 2760), 3.5, 1.0),
  ]) {
    final viewport = physicalSize / ratio;
    testWidgets('原帖长短楼层窗口在 $viewport/$scale 从最新入口揭开末尾第22楼', (tester) async {
      tester.view.devicePixelRatio = ratio;
      tester.view.physicalSize = physicalSize;
      if (ratio == 3.5) {
        tester.view.padding = const FakeViewPadding(top: 119, bottom: 78);
        tester.view.viewPadding = const FakeViewPadding(top: 119, bottom: 78);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
      }
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final repository = _RealWindowRepository(detail, floors);
      await tester.pumpWidget(threadDetailPageTestDetailRouterApp(repository));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('thread-detail-latest')));
      await tester.pumpAndSettle();
      // 覆盖定时稳定等待，而不是把无新帧误认作定位成功。
      for (var frame = 0; frame < 80; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find
            .byKey(const Key('discussion-target-cover'))
            .evaluate()
            .isEmpty) {
          break;
        }
      }
      expect(repository.latestThreadIds, ['thread-1']);
      expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
      final target = find.byKey(const Key('thread-floor-card-sample-floor-22'));
      expect(target, findsOneWidget);
      final rect = tester.getRect(target);
      expect(rect.top, lessThan(viewport.height));
      expect(rect.bottom, greaterThan(56));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

class _RealWindowRepository
    extends ThreadDetailPageTestFakeThreadDetailRepository {
  _RealWindowRepository(ThreadDetailModel detail, this.floors)
    : super(
        detail: detail,
        sideFloors: floors,
        latestPost: ThreadLatestPostModel(
          id: floors.last.id,
          threadId: 'thread-1',
          subthreadId: 'subthread-3',
          createdAt: threadDetailPageTestRecentFixtureTime,
        ),
        postTarget: ThreadPostTargetModel(
          requestedPostId: floors.last.id,
          threadId: 'thread-1',
          subthreadId: 'subthread-3',
          floor: floors.last,
        ),
      );

  final List<ThreadFloorModel> floors;

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
    if (subthreadId != 'subthread-3') {
      return super.fetchFloorWindow(
        subthreadId: subthreadId,
        number: number,
        postId: postId,
        cursor: cursor,
        limit: limit,
        order: order,
        authorId: authorId,
      );
    }
    return DiscussionWindow(
      items: floors,
      total: 21,
      maxNumber: 22,
      targetId: postId == null ? null : floors.last.id,
      targetNumber: postId == null ? null : 22,
      beforeCursor: 'sample-before',
    );
  }
}
