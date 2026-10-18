import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reply_action_bar.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('文字容不下时显示回复图标，恢复宽度后回到文字', (tester) async {
    var replies = 0;
    for (final width in [48.0, 90.0, 200.0]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Center(
                child: SizedBox(
                  width: width,
                  child: WenyouReplyFieldAction(
                    key: const Key('reply'),
                    authenticated: true,
                    onPressed: () => replies++,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        find.byType(WenyouIcon),
        width == 48 ? findsOneWidget : findsNothing,
      );
      expect(find.text('回复一下'), width == 200 ? findsOneWidget : findsNothing);
      expect(find.text('回复'), width == 90 ? findsOneWidget : findsNothing);
      final reply = find.byKey(const Key('reply'));
      expect(tester.getSemantics(reply).label, '回复一下');
      expect(tester.getSize(reply).height, greaterThanOrEqualTo(48));
      await tester.tap(reply);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(replies, 3);
  });
  testWidgets('共享底栏在窄屏大字和系统安全区下保留点击区及框边界', (tester) async {
    for (final width in [320.0, 360.0, 400.0]) {
      for (final inset in [0.0, 16.0, 34.0]) {
        for (final scale in [1.0, 2.0]) {
          for (final actions in [3, 4]) {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, 240);
            tester.view.padding = FakeViewPadding(bottom: inset);
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  bottomNavigationBar: WenyouReplyActionBar(
                    children: [
                      for (var i = 0; i < actions; i++)
                        const SizedBox(width: 48, height: 48),
                      if (actions == 3) const SizedBox(width: 4),
                      Expanded(
                        child: WenyouReplyFieldAction(
                          key: const Key('reply'),
                          fieldKey: const Key('field'),
                          authenticated: true,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            final field = tester.getRect(find.byKey(const Key('field')));
            final reply = tester.getRect(find.byKey(const Key('reply')));
            expect(field.right, closeTo(width - 8, .1));
            expect(field.bottom, lessThanOrEqualTo(240 - inset - 12));
            expect(
              reply.width,
              closeTo(width - 16 - 48 * actions - (actions == 3 ? 4 : 0), .1),
            );
            expect(reply.height, greaterThanOrEqualTo(48));
            expect(tester.takeException(), isNull);

            if (inset == 16) {
              // 本次 Xiaomi 实测圆角170px、density3；不是所有设备的系统保证。
              const radius = 170 / 3;
              final cornerCenter = Offset(width - radius, 240 - radius);
              final delta = field.bottomRight - cornerCenter;
              final distance = math.sqrt(
                delta.dx * delta.dx + delta.dy * delta.dy,
              );
              expect(distance, lessThanOrEqualTo(radius));
            }
          }
        }
      }
    }
    addTearDown(tester.view.reset);
  });
}
