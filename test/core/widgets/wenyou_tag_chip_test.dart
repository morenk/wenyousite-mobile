import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';

void main() {
  testWidgets('只读主题标签复用 Foundation 纯文字呈现', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WenyouTagChip(name: '太空歌剧')),
      ),
    );

    expect(find.text('#太空歌剧'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(InputChip), findsNothing);
    expect(find.byType(WenyouTagLink), findsOneWidget);
    final label = tester.widget<Text>(find.text('#太空歌剧'));
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.color, WenyouFoundationPalette.brandStrong);
  });

  testWidgets('管理态可移除标签保留明确编辑控件', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouTagChip(
            name: '太空歌剧',
            deleteTooltip: '移除标签',
            onDeleted: () {},
          ),
        ),
      ),
    );

    final chip = tester.widget<InputChip>(find.byType(InputChip));
    expect(chip.backgroundColor, WenyouFoundationPalette.surface);
    expect(chip.side?.color, WenyouFoundationPalette.border);
    final label = tester.widget<Text>(find.text('#太空歌剧'));
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.color, WenyouFoundationPalette.brandStrong);
  });
}
