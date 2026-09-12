import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import '../../support/foundation_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  for (final viaLatest in [false, true]) {
    testWidgets('${viaLatest ? '最新发言' : '通知／传送门坐标'}长楼层从吸顶栏下方开头显示', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      // 本地原场景复验可传入负责人提供的原始 Markdown，不将正文提交入库。
      const originalPath = String.fromEnvironment('FLOOR_REPRO_FILE');
      final markdown = originalPath.isEmpty
          ? List.generate(
              90,
              (index) => '第 $index 段：很长的楼层正文，阅读必须从作者信息和开头开始。',
            ).join('\n\n')
          : File(originalPath).readAsStringSync();
      final floor = ThreadFloorModel(
        id: 'floor-target',
        floorNumber: 7,
        author: threadDetailPageTestAuthor,
        body: ThreadBodyModel(markdown: markdown),
        createdAt: threadDetailPageTestRecentFixtureTime,
        isDeleted: false,
        replyCount: 0,
        replies: const [],
      );
      final repository = ThreadDetailPageTestFakeThreadDetailRepository(
        postTarget: ThreadPostTargetModel(
          requestedPostId: floor.id,
          threadId: 'thread-1',
          subthreadId: 'subthread-2',
          floor: floor,
        ),
      );
      await tester.pumpWidget(
        threadDetailPageTestDetailRouterApp(
          repository,
          initialLocation: viaLatest
              ? '/threads/thread-1'
              : '/threads/thread-1?post=${floor.id}',
        ),
      );
      await tester.pumpAndSettle();
      if (viaLatest) {
        await tester.tap(find.byKey(const Key('thread-detail-latest')));
        await tester.pumpAndSettle();
        expect(repository.latestThreadIds, ['thread-1']);
      }

      final target = find.byKey(const Key('thread-floor-card-floor-target'));
      final scrollRect = tester.getRect(find.byType(CustomScrollView));
      final header = tester.widget<SliverPersistentHeader>(
        find.byType(SliverPersistentHeader),
      );
      expect(tester.getRect(target).height, greaterThan(scrollRect.height));
      expect(
        tester.getRect(target).top,
        closeTo(scrollRect.top + header.delegate.minExtent, 1),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
