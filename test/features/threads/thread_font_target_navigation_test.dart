import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  for (final long in [false, true]) {
    testWidgets('自定义字体的深链目标可显现 long=$long', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final fonts = _Service();
      addTearDown(fonts.dispose);
      final target = ThreadFloorModel(
        id: 'font-target',
        floorNumber: 9,
        author: threadDetailPageTestAuthor,
        body: ThreadBodyModel(
          markdown: List.filled(
            long ? 60 : 1,
            '<span data-wenyou-font-v1="wenkai">自定义字体正文 A</span>',
          ).join('\n\n'),
        ),
        createdAt: threadDetailPageTestRecentFixtureTime,
        isDeleted: false,
        replyCount: 0,
        replies: const [],
      );
      final repository = ThreadDetailPageTestFakeThreadDetailRepository(
        postTarget: ThreadPostTargetModel(
          requestedPostId: target.id,
          threadId: 'thread-1',
          subthreadId: 'subthread-2',
          floor: target,
        ),
        sideFloors: [threadDetailPageTestSideFloor, target],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [textFontServiceProvider.overrideWithValue(fonts)],
          child: threadDetailPageTestDetailApp(
            repository,
            targetPostId: target.id,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(fonts.runtime.styles, greaterThan(0));
      expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
      final targetRect = tester.getRect(
        find.byKey(const Key('thread-floor-card-font-target')),
      );
      expect(targetRect.top, inInclusiveRange(0, 800));
      expect(
        find.text('自定义字体正文 A', findRichText: true).first.hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
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
  int styles = 0;
  @override
  TextStyle style(String id, TextStyle base) {
    styles++;
    return base.copyWith(
      fontFamily: 'Roboto',
      fontSize: (base.fontSize ?? 16) * 1.4,
    );
  }
}
