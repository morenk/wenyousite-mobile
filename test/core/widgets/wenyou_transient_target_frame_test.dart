import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_visibility.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_transient_target_frame.dart';

void main() {
  testWidgets('定位提示从揭开后开始计时，遮罩期间没有提前高亮', (tester) async {
    Widget app(bool visible) => MaterialApp(
      theme: AppTheme.light,
      home: DiscussionTargetVisibility(
        visible: visible,
        child: const WenyouTransientTargetFrame(
          targetId: 'covered-target',
          child: SizedBox(width: 100, height: 60),
        ),
      ),
    );
    Color borderColor() =>
        (tester
                    .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                    .decoration!
                as BoxDecoration)
            .border!
            .top
            .color;

    await tester.pumpWidget(app(false));
    await tester.pump(const Duration(seconds: 6));
    expect(borderColor(), Colors.transparent);
    await tester.pumpWidget(app(true));
    expect(borderColor(), WenyouFoundationPalette.primary);
    await tester.pump(const Duration(milliseconds: 1199));
    expect(borderColor(), WenyouFoundationPalette.primary);
    await tester.pump(const Duration(milliseconds: 1));
    expect(borderColor(), Colors.transparent);
  });

  testWidgets('目标只显示淡粉边框并在停留后淡出且同目标不重放', (tester) async {
    const key = ValueKey('frame');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WenyouTransientTargetFrame(
          key: key,
          targetId: 'post-1',
          child: SizedBox(width: 100, height: 60),
        ),
      ),
    );

    var frame = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    var decoration = frame.decoration! as BoxDecoration;
    expect(decoration.color, isNull);
    expect(decoration.border!.top.width, 1);
    expect(decoration.border!.top.color, WenyouFoundationPalette.primary);

    await tester.pump(const Duration(milliseconds: 1200));
    frame = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    decoration = frame.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
    expect(frame.duration, WenyouFoundationMotion.slow);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WenyouTransientTargetFrame(
          key: key,
          targetId: 'post-1',
          child: SizedBox(width: 100, height: 60),
        ),
      ),
    );
    frame = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    decoration = frame.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
  });

  testWidgets('减少动态效果时边框直接移除', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const WenyouTransientTargetFrame(
            targetId: 'post-1',
            child: SizedBox(width: 100, height: 60),
          ),
        ),
      ),
    );

    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration,
      Duration.zero,
    );
  });
}
