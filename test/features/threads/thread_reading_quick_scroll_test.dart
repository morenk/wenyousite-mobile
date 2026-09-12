import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import '../../support/foundation_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  final floors = [
    for (var i = 0; i < 60; i++)
      ThreadFloorModel(
        id: 'quick-floor-$i',
        floorNumber: 100 + i,
        author: threadDetailPageTestAuthor,
        body: ThreadBodyModel(
          markdown: List.filled(
            i == 20 ? 150 : 3,
            '第 $i 层正文内容，保留正常阅读与回复。',
          ).join('\n\n'),
        ),
        createdAt: threadDetailPageTestRecentFixtureTime,
        isDeleted: false,
        replyCount: 0,
        replies: const [],
      ),
  ];

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('主题 $width dp 快翻保持底部操作，首尾可达且切子贴收起', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = ThreadDetailPageTestFakeThreadDetailRepository(
        mainFloors: floors,
      );
      const visualKey = Key('quick-scroll-thread-visual');
      await tester.pumpWidget(
        RepaintBoundary(
          key: visualKey,
          child: threadDetailPageTestDetailRouterApp(repository),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .getRect(find.byKey(const Key('reading-quick-scroll-toggle')))
            .left,
        greaterThanOrEqualTo(
          tester.getRect(find.byKey(const Key('thread-detail-latest'))).right,
        ),
      );
      await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
      await tester.pumpAndSettle();
      final bar = tester.getRect(
        find.byKey(const Key('reading-quick-scroll-rail')),
      );
      final actions = tester.getRect(
        find.byKey(const Key('thread-detail-bottom-bar')),
      );
      expect(bar.bottom, lessThanOrEqualTo(actions.top));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(visualKey),
        matchesGoldenFile('goldens/thread_quick_scroll_${width.toInt()}.png'),
      );
      final quick = tester
          .widget<ReadingQuickScrollAction>(
            find.byType(ReadingQuickScrollAction),
          )
          .controller;
      final thumb = find.byKey(const Key('reading-quick-scroll-slider'));
      final grabbed = tester.getRect(thumb);
      final drag = await tester.startGesture(grabbed.center);
      await drag.moveBy(const Offset(0, 60));
      await tester.pumpAndSettle();
      expect(tester.getRect(thumb).top, closeTo(grabbed.top + 60, 1));
      await drag.up();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reading-quick-scroll-slider')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reading-quick-scroll-end')));
      await tester.pumpAndSettle();
      expect(quick.scrollController.position.extentAfter, lessThanOrEqualTo(1));
      expect(quick.edgeFailed, isFalse);
      await tester.tap(find.byKey(const Key('reading-quick-scroll-slider')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reading-quick-scroll-start')));
      await tester.pumpAndSettle();
      expect(quick.scrollController.offset, 0);
      await tester.tap(find.byKey(const Key('thread-subthread-next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reading-quick-scroll-rail')), findsNothing);
      expect(find.text('支线正文'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('首次进入长首楼子贴，快翻到中间不会提前抵达讨论底部', (tester) async {
    final longFirstFloor = ThreadFloorModel(
      id: 'cold-long-first-floor',
      floorNumber: 99,
      author: threadDetailPageTestAuthor,
      body: ThreadBodyModel(
        markdown: List.filled(300, '首次阅读的超长楼层正文。').join('\n\n'),
      ),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          mainFloors: [longFirstFloor, ...floors],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
    await tester.pumpAndSettle();
    final quick = tester
        .widget<ReadingQuickScrollAction>(find.byType(ReadingQuickScrollAction))
        .controller;
    quick.beginDrag(0.5);
    await tester.pumpAndSettle();
    expect(quick.scrollController.position.extentAfter, greaterThan(500));
    expect(quick.fraction, 0.5);
    quick.endDrag(0.5);
    await tester.pumpAndSettle();
    expect(quick.fraction, closeTo(0.5, 0.03));
    expect(tester.takeException(), isNull);
  });

  testWidgets('快翻取消迟到深链，不被旧目标重新拉回', (tester) async {
    final pending = Completer<ThreadPostTargetModel>();
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          mainFloors: floors,
          postTargetFuture: pending.future,
        ),
        targetPostId: 'floor-target',
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
    await tester.pumpAndSettle();
    final quick = tester
        .widget<ReadingQuickScrollAction>(find.byType(ReadingQuickScrollAction))
        .controller;
    quick.beginDrag(0.2);
    quick.endDrag(0.2);
    await tester.pumpAndSettle();
    final offset = quick.scrollController.offset;
    pending.complete(
      ThreadPostTargetModel(
        requestedPostId: 'floor-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-2',
        floor: threadDetailPageTestTargetFloor,
      ),
    );
    await tester.pumpAndSettle();
    expect(quick.scrollController.offset, closeTo(offset, 1));
    expect(find.text('支线正文'), findsNothing);
  });
}
