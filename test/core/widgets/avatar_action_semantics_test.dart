import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';

void main() {
  testWidgets('头像按实际入口朗读帖内身份，默认个人主页行为保留', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Row(
              children: [
                WenyouAvatarButton(
                  username: '白鸦',
                  visualSize: 32,
                  semanticsLabel: '查看 白鸦 的帖内身份',
                  onTap: () => opened++,
                ),
                WenyouAvatarButton(
                  username: '账号',
                  visualSize: 32,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('查看 账号 的个人主页'), findsOneWidget);
      expect(find.bySemanticsLabel('查看 白鸦 的个人主页'), findsNothing);
      await tester.tap(find.bySemanticsLabel('查看 白鸦 的帖内身份'));
      expect(opened, 1);
    } finally {
      semantics.dispose();
    }
  });
}
