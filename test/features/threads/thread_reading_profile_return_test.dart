import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import '../../../integration_test/reading_profile_fixture.dart';
import '../../support/deterministic_test_fonts.dart';
import '../moments/moment_animation_fixture.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('合成长短楼层跳转后返回点击前的阅读位置', (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1200, 2608);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final root = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
      ],
    );
    addTearDown(root.dispose);
    final repository = ReadingProfileRepository(
      'https://synthetic.invalid/still',
    );
    await MomentAnimationFixture.run(tester, (_) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: root,
          child: threadDetailPageTestDetailApp(repository),
        ),
      );
      await _frames(tester, 1000);
      final viewport = find.byType(ReadingProgressViewport);
      final reading = tester
          .widget<ReadingProgressViewport>(viewport)
          .controller;
      await tester.fling(viewport, const Offset(0, -650), 1100);
      await _frames(tester, 1200);
      await tester.tap(find.byKey(const Key('discussion-position-button')));
      await _frames(tester, 300);
      await tester.enterText(
        find.byKey(const Key('discussion-number-input')),
        '46',
      );
      await _frames(tester, 600);
      final before = reading.captureBookmark()!;
      await tester.tap(find.byKey(const Key('discussion-number-submit')));
      await _frames(tester, 3000);
      expect(find.byKey(const Key('thread-floor-card-46')), findsOneWidget);
      await tester.tap(find.text('回到刚才'));
      await _frames(tester, 350);
      await _frames(tester, 5000);
      final returned = reading.captureBookmark()!;
      expect(returned.id, before.id);
      expect(returned.offset, closeTo(before.offset, 2));
      expect(tester.takeException(), isNull);
    }, resources: {'sentinel': Uint8List(0)});
  });
}

Future<void> _frames(WidgetTester tester, int milliseconds) async {
  for (var elapsed = 0; elapsed < milliseconds; elapsed += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}
