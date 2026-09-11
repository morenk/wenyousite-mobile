import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reorder_feedback.dart';

void main() {
  testWidgets('代理抬起与落下仅更新绘制层，行内容不按帧重建', (tester) async {
    final animation = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 250),
    );
    addTearDown(animation.dispose);
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Center(
          child: SizedBox(
            width: 360,
            height: 72,
            child: WenyouReorderFeedback(
              animation: animation,
              child: Builder(
                builder: (_) {
                  builds++;
                  return const Text('剧情区');
                },
              ),
            ),
          ),
        ),
      ),
    );
    expect(builds, 1);
    unawaited(animation.forward());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final model = find.descendant(
      of: find.byType(WenyouReorderFeedback),
      matching: find.byType(PhysicalModel),
    );
    final rising = tester.widget<PhysicalModel>(model).elevation;
    expect(rising, greaterThan(0));
    expect(rising, lessThan(4));
    await tester.pumpAndSettle();
    expect(tester.widget<PhysicalModel>(model).elevation, 4);
    final scale = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(WenyouReorderFeedback),
            matching: find.byType(Transform),
          ),
        )
        .map((widget) => widget.transform.entry(0, 0))
        .reduce((a, b) => a > b ? a : b);
    expect(scale, greaterThan(1));
    expect(scale, lessThan(1.02));
    unawaited(animation.reverse());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.widget<PhysicalModel>(model).elevation, lessThan(4));
    await tester.pumpAndSettle();
    expect(tester.widget<PhysicalModel>(model).elevation, 0);
    expect(builds, 1);
  });

  testWidgets('减少动态效果取消共享缩放、偏移及阴影', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(
            child: SizedBox(
              width: 64,
              height: 64,
              child: WenyouReorderFeedback(lifted: true, child: Text('表情')),
            ),
          ),
        ),
      ),
    );
    final root = find.byType(WenyouReorderFeedback);
    expect(
      tester
          .widget<PhysicalModel>(
            find.descendant(of: root, matching: find.byType(PhysicalModel)),
          )
          .elevation,
      0,
    );
    for (final transform in tester.widgetList<Transform>(
      find.descendant(of: root, matching: find.byType(Transform)),
    )) {
      expect(transform.transform.isIdentity(), isTrue);
    }
  });
}
