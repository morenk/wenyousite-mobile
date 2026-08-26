import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';

void main() {
  testWidgets('阅读态标签使用无气泡文字入口并保留移动端命中区', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouTagLink(name: '太空歌剧', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('#太空歌剧'), findsOneWidget);
    expect(find.byType(InputChip), findsNothing);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    final button = tester.widget<TextButton>(find.byType(TextButton));
    final states = <WidgetState>{};
    expect(
      button.style?.foregroundColor?.resolve(states),
      WenyouFoundationPalette.mutedForeground,
    );
    expect(button.style?.backgroundColor?.resolve(states), Colors.transparent);
    expect(button.style?.side?.resolve(states), isNull);
    expect(button.style?.minimumSize?.resolve(states), const Size(48, 48));
    expect(
      button.style?.padding?.resolve(states),
      const EdgeInsets.symmetric(horizontal: 4),
    );
    expect(button.style?.tapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(tester.getSize(find.byType(WenyouTagLink)).height, 48);

    await tester.tap(find.text('#太空歌剧'));
    expect(tapped, isTrue);
  });

  testWidgets('非交互标签保持内容尺寸且不伪装按钮', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouTagLink(name: '太空歌剧', onPressed: null),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(
      find.descendant(
        of: find.byType(WenyouTagLink),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
    expect(tester.getSize(find.byType(WenyouTagLink)).height, lessThan(32));
    final text = tester.widget<Text>(find.text('#太空歌剧'));
    expect(text.style?.fontSize, 12);
    expect(text.style?.fontWeight, FontWeight.w500);
    expect(text.style?.color, WenyouFoundationPalette.mutedForeground);
  });
}
