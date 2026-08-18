import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';

void main() {
  testWidgets('管理态主题标签同样使用中性井号样式', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WenyouTagChip(name: '太空歌剧')),
      ),
    );

    expect(find.text('#太空歌剧'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    final chip = tester.widget<InputChip>(find.byType(InputChip));
    expect(chip.backgroundColor, Colors.transparent);
    expect(chip.side?.color, WenyouFoundationPalette.border);
    final label = tester.widget<Text>(find.text('#太空歌剧'));
    expect(label.style?.fontWeight, FontWeight.w500);
    expect(label.style?.color, WenyouFoundationPalette.mutedForeground);
  });
}
