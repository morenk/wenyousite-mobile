import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';

void main() {
  testWidgets('阅读态标签使用中性描边并保留独立命中区', (tester) async {
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
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final states = <WidgetState>{};
    expect(
      button.style?.foregroundColor?.resolve(states),
      WenyouFoundationPalette.mutedForeground,
    );
    expect(button.style?.backgroundColor?.resolve(states), Colors.transparent);
    expect(
      button.style?.side?.resolve(states)?.color,
      WenyouFoundationPalette.border,
    );
    expect(
      tester.getSize(find.byType(WenyouTagLink)).height,
      greaterThanOrEqualTo(48),
    );

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
    expect(tester.getSize(find.byType(WenyouTagLink)).height, lessThan(48));
    final text = tester.widget<Text>(find.text('#太空歌剧'));
    expect(text.style?.fontWeight, FontWeight.w500);
    expect(text.style?.color, WenyouFoundationPalette.mutedForeground);
  });
}
