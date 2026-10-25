import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final private in [false, true]) {
    for (final single in [false, true]) {
      for (final font in [false, true]) {
        testWidgets('成员精准楼层定位 private=$private single=$single font=$font', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(360, 800);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final fonts = _Service();
          addTearDown(fonts.dispose);
          final target = ThreadFloorModel(
            id: 'private-target',
            floorNumber: 9,
            author: threadDetailPageTestAuthor,
            body: ThreadBodyModel(
              markdown: font
                  ? '<span data-wenyou-font-v1="wenkai">目标正文</span>'
                  : '目标正文',
            ),
            createdAt: threadDetailPageTestRecentFixtureTime,
            isDeleted: false,
            replyCount: 0,
            replies: const [],
          );
          final detail = threadDetailPageTestCopyThreadDetail(
            threadDetailPageTestDetail,
            subthreads: single
                ? [threadDetailPageTestDetail.subthreads.last]
                : threadDetailPageTestDetail.subthreads,
            isPrivate: private,
            isCurrentUserPlayer: true,
            isCurrentUserOwner: false,
            currentUserId: 'member-1',
          );
          final repository = ThreadDetailPageTestFakeThreadDetailRepository(
            detail: detail,
            postTarget: ThreadPostTargetModel(
              requestedPostId: target.id,
              threadId: detail.id,
              subthreadId: 'subthread-2',
              floor: target,
            ),
            sideFloors: [threadDetailPageTestSideFloor, target],
          );
          await tester.pumpWidget(
            await threadDetailPageTestAuthenticatedDetailApp(
              repository,
              userId: 'member-1',
              targetPostId: target.id,
              extraOverrides: [
                textFontServiceProvider.overrideWithValue(fonts),
              ],
            ),
          );
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 10),
          );
          expect(
            find.byKey(const Key('discussion-target-cover')),
            findsNothing,
          );
          expect(
            find.text('目标正文', findRichText: true).hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
  for (final private in [false, true]) {
    for (final font in [false, true]) {
      testWidgets('楼主长子贴正文后的目标定位 private=$private font=$font', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final fonts = _Service();
        addTearDown(fonts.dispose);
        final target = ThreadFloorModel(
          id: 'owner-target',
          floorNumber: 9,
          author: threadDetailPageTestAuthor,
          body: const ThreadBodyModel(markdown: '楼主目标正文'),
          createdAt: threadDetailPageTestRecentFixtureTime,
          isDeleted: false,
          replyCount: 0,
          replies: const [],
        );
        final detail = threadDetailPageTestCopyThreadDetail(
          threadDetailPageTestManagerDetail,
          isPrivate: private,
          isCurrentUserOwner: true,
          currentUserId: 'user-1',
          subthreads: [
            ThreadSubthreadModel(
              id: 'subthread-1',
              title: '主线',
              sortOrder: 1,
              postCount: 2,
              postingPolicyLabel: '参与者发言',
              body: ThreadBodyModel(
                postId: 'body-1',
                version: 5,
                markdown: List.filled(
                  60,
                  font
                      ? '<span data-wenyou-font-v1="wenkai">长篇正文测试内容</span>'
                      : '长篇正文测试内容',
                ).join('\n\n'),
              ),
            ),
          ],
        );
        final repository = ThreadDetailPageTestFakeThreadDetailRepository(
          detail: detail,
          postTarget: ThreadPostTargetModel(
            requestedPostId: target.id,
            threadId: detail.id,
            subthreadId: 'subthread-1',
            floor: target,
          ),
          mainFloors: [threadDetailPageTestMainFloor, target],
        );
        await tester.pumpWidget(
          await threadDetailPageTestAuthenticatedDetailApp(
            repository,
            userId: 'user-1',
            targetPostId: target.id,
            extraOverrides: [textFontServiceProvider.overrideWithValue(fonts)],
          ),
        );
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 10),
        );
        expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
        expect(
          find.text('楼主目标正文', findRichText: true).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

class _Service extends TextFontService {
  _Service() : super(WenyouApi(), observePlatform: false);
  final runtime = _Runtime();
  @override
  Future<TextFontRuntime> load() async => runtime;
}

class _Runtime extends TextFontRuntime {
  _Runtime()
    : super(
        cache: TextFontCache(Directory.systemTemp),
        download: (_) async => throw StateError('不应联网'),
      );
  @override
  TextStyle style(String id, TextStyle base) => base.copyWith(
    fontFamily: 'Roboto',
    fontSize: (base.fontSize ?? 16) * 1.4,
  );
}
