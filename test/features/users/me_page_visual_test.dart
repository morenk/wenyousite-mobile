import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/profile_cover_fixture.dart';
import 'me_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final visual in const [
    (width: 360.0, scale: 1.0, dark: false, name: '360_light'),
    (width: 360.0, scale: 1.0, dark: true, name: '360_dark'),
    (width: 320.0, scale: 2.0, dark: false, name: '320_2x'),
  ]) {
    testWidgets('个人中心资料、工具和内容分层 ${visual.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(visual.width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await cacheProfileCover(tester);
      final container = await mePageTestAuthenticatedContainer(
        MePageTestFakeMeProfileRepository(
          initialProfile: mePageTestProfileWithCover(),
        ),
        stickersEnabled: true,
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: visual.dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(visual.scale)),
              child: child!,
            ),
            home: const RepaintBoundary(key: Key('me-visual'), child: MePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('温柔测试员 的主页背景图'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final bio = tester.getRect(find.text('一起写故事。'));
      final name = tester.getRect(find.text('温柔测试员').first);
      expect(find.byKey(const Key('me-profile-edit')), findsNothing);
      expect(find.text('编辑资料'), findsNothing);
      final balance = tester.getRect(find.byKey(const Key('me-open-balance')));
      final experience = tester.getRect(find.text('150 / 200 经验'));
      final progress = tester.getRect(find.byType(LinearProgressIndicator));
      expect(progress.center.dy, closeTo(experience.center.dy, 1));
      expect(progress.left, closeTo(bio.left, 1));
      expect(experience.right, closeTo(balance.right, 1));
      expect(experience.left - progress.right, closeTo(8, 1));
      expect(experience.top - bio.bottom, inInclusiveRange(8, 12));
      if (visual.scale == 1) {
        final avatar = tester.getRect(
          find.byKey(const ValueKey('profile-avatar-温柔测试员')),
        );
        expect(name.top - avatar.bottom, inInclusiveRange(8, 16));
      }
      expect(bio.top, greaterThanOrEqualTo(name.bottom + 12));
      expect(find.byKey(const Key('me-open-edit-profile')), findsNothing);
      final tools = find.byKey(const Key('me-personal-tools'));
      final header = tester.getRect(find.byKey(const Key('me-profile-header')));
      final toolsRect = tester.getRect(tools);
      expect(toolsRect.left, closeTo(header.left, 1));
      expect(toolsRect.right, closeTo(header.right, 1));
      expect(toolsRect.top, closeTo(header.bottom, 1));
      expect(
        tester.getRect(find.byKey(const Key('me-content-tabs'))).top,
        closeTo(toolsRect.bottom, 1),
      );
      await expectLater(
        find.byKey(const Key('me-visual')),
        matchesGoldenFile('goldens/me_page_${visual.name}.png'),
      );
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(find.text('主题').hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const Key('me-content-tabs'))).top,
        closeTo(tester.getRect(find.byType(AppBar)).bottom, 0.1),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
