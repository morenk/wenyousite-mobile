import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_item_divider.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_unread_indicator.dart';

void main() {
  testWidgets('内容条目分隔线比正文分割线更深且保持 24dp 节奏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouContentItemDivider(key: Key('content-divider')),
        ),
      ),
    );

    final divider = tester.widget<Divider>(
      find.descendant(
        of: find.byKey(const Key('content-divider')),
        matching: find.byType(Divider),
      ),
    );
    expect(divider.height, WenyouThemeTokens.light.space24);
    expect(divider.thickness, 1);
    expect(divider.color, WenyouFoundationPalette.input);
    expect(divider.color, isNot(WenyouFoundationPalette.border));
  });

  testWidgets('未读点与计数遵循 danger 色和 99+ 上限', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              WenyouUnreadDot(key: Key('unread-dot')),
              WenyouUnreadCountBadge(
                key: Key('unread-zero'),
                count: 0,
                child: SizedBox(key: Key('badge-child')),
              ),
              WenyouUnreadCountBadge(key: Key('unread-99'), count: 99),
              WenyouUnreadCountBadge(key: Key('unread-100'), count: 100),
            ],
          ),
        ),
      ),
    );

    final dotDecoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byKey(const Key('unread-dot')),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(dotDecoration.color, WenyouFoundationPalette.destructive);
    expect(
      tester.getSize(find.byKey(const Key('unread-dot'))),
      const Size(8, 8),
    );

    expect(find.byKey(const Key('badge-child')), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.text('99'), findsOneWidget);
    expect(
      find.text(WenyouElementContract.unreadMaximumDisplay),
      findsOneWidget,
    );

    for (final key in [const Key('unread-99'), const Key('unread-100')]) {
      final badge = tester.widget<Badge>(
        find.descendant(of: find.byKey(key), matching: find.byType(Badge)),
      );
      expect(badge.backgroundColor, WenyouFoundationPalette.destructive);
      expect(badge.textColor, WenyouFoundationPalette.onDestructive);
      expect(badge.largeSize, WenyouElementContract.unreadCountHeight);
      expect(
        badge.textStyle?.fontSize,
        WenyouElementContract.unreadCountFontSize,
      );
      expect(badge.textStyle?.fontWeight, FontWeight.w700);
    }
  });
}
