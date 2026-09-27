import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_reply_card.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('嵌套回复保留缩进并共享柔和底色，无左侧线条：${brightness.name}', (tester) async {
      final tokens = brightness == Brightness.light
          ? WenyouThemeTokens.light
          : WenyouThemeTokens.dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          home: const Scaffold(
            body: WenyouDiscussionReplyGroup(
              key: Key('reply-group'),
              child: WenyouDiscussionReplyCard(
                key: Key('reply'),
                semanticsLabel: '小温的回复',
                child: Text('回复正文'),
              ),
            ),
          ),
        ),
      );

      final groupDecoration =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byKey(const Key('reply-group')),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(groupDecoration.border, isNull);
      expect(groupDecoration.color, tokens.softPanel);
      expect(
        tester.getTopLeft(find.byKey(const Key('reply'))).dx -
            tester.getTopLeft(find.byKey(const Key('reply-group'))).dx,
        24,
      );

      final replyMaterial = tester.widget<Material>(
        find.descendant(
          of: find.byKey(const Key('reply')),
          matching: find.byType(Material),
        ),
      );
      expect(replyMaterial.color, Colors.transparent);
      expect(replyMaterial.shape, isNull);
      expect(
        tester.getSize(find.byKey(const Key('reply'))).height,
        greaterThanOrEqualTo(tokens.minimumTouchTarget),
      );
    });
  }
}
