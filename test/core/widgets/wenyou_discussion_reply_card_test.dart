import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_reply_card.dart';

void main() {
  testWidgets('嵌套回复共享左侧引导线且单条回复不再绘制卡片', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
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
    final groupBorder = groupDecoration.border! as Border;
    expect(groupBorder.left.width, 2);
    expect(groupBorder.left.color, WenyouThemeTokens.light.border);

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
      greaterThanOrEqualTo(WenyouThemeTokens.light.minimumTouchTarget),
    );
  });
}
