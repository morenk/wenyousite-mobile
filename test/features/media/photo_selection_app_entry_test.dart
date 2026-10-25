import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'photo_selection_app_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDeterministicTestFonts);
  const photos = MethodChannel('com.fluttercandies/photo_manager');
  final permissionRequests = <MethodCall>[];
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    permissionRequests.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(photos, (call) async {
          if (call.method == 'requestPermissionExtend') {
            permissionRequests.add(call);
            return 1;
          }
          throw StateError('Unexpected photo method: ${call.method}');
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(photos, null),
  );

  for (final avatar in [false, true]) {
    for (final duringSelection in [false, true]) {
      testWidgets(
        '真实WenyouApp生产装配：${avatar ? '头像' : '主题图片'}，首次inset在图库${duringSelection ? '打开中' : '关闭后'}到达',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(390, 900);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final fixture = PhotoEntryAppFixture();
          addTearDown(fixture.dispose);
          await fixture.pump(tester, avatar ? '/me/edit' : '/compose/thread');
          expect(permissionRequests, isEmpty, reason: '启动及进入页面不申请照片权限');
          final button = avatar
              ? find.byKey(const Key('me-avatar-change'))
              : find.byTooltip('图片');
          if (!avatar) {
            expect(
              tester
                  .widget<IconButton>(
                    find.byWidgetPredicate(
                      (widget) =>
                          widget is IconButton && widget.tooltip == '图片',
                    ),
                  )
                  .onPressed,
              isNotNull,
              reason: find
                  .byType(Text)
                  .evaluate()
                  .map((element) => (element.widget as Text).data)
                  .whereType<String>()
                  .join(' | '),
            );
          }
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(find.byType(PhotoSelectionPage), findsOneWidget);
          expect(permissionRequests, hasLength(1));
          if (duringSelection) {
            await photoEntryKeyboardTarget(tester, 0);
            expect(find.byType(PhotoSelectionPage), findsOneWidget);
            await photoEntryKeyboardTarget(tester, 280);
            await photoEntryKeyboardTarget(tester, 0);
            expect(find.byType(PhotoSelectionPage), findsOneWidget);
            expect(permissionRequests, hasLength(1));
          }
          await tester.tap(find.byTooltip('取消选择'));
          await tester.pumpAndSettle();
          expect(find.byType(PhotoSelectionPage), findsNothing);
          if (!duringSelection) await photoEntryKeyboardTarget(tester, 0);
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(
            (
              find.byType(PhotoSelectionPage).evaluate().length,
              permissionRequests.length,
              fixture.container
                      .read(photoSelectionCoordinatorProvider)
                      .presenter !=
                  null,
            ),
            (1, 2, true),
            reason: '首次inset同步不能让真实入口静默取消，图库打开才请求权限',
          );
          await tester.tap(find.byTooltip('取消选择'));
          await tester.pumpAndSettle();
          // 取消后还能再次打开，不能遗留永久busy。
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(find.byType(PhotoSelectionPage), findsOneWidget);
          expect(permissionRequests, hasLength(3));
          await tester.tap(find.byTooltip('取消选择'));
          await tester.pumpAndSettle();
          fixture.expectNoWrites();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          fixture.dispose();
          await tester.pumpAndSettle();
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );
    }
  }
}
