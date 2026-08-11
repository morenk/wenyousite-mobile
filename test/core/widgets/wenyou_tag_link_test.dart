import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';

void main() {
  testWidgets('阅读态标签是无卡片外观的可点击井号文本', (tester) async {
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
    expect(
      tester.getSize(find.byType(WenyouTagLink)).height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.text('#太空歌剧'));
    expect(tapped, isTrue);
  });
}
