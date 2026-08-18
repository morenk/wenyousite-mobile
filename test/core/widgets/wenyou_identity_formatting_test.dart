import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';

void main() {
  test('头像首字符跳过空白和常见账号前缀', () {
    expect(wenyouAvatarInitial('  @温油'), '温');
    expect(wenyouAvatarInitial('_alice'), 'A');
    expect(wenyouAvatarInitial('   '), isNull);
  });

  testWidgets('具名头像回退字符，停用身份回退不可用图标', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Row(
          children: [
            WenyouAvatar(username: '温油', size: 40),
            WenyouAvatar(username: '停用用户', size: 40, unavailable: true),
          ],
        ),
      ),
    );

    expect(find.text('温'), findsOneWidget);
    expect(find.text('停'), findsNothing);
    expect(find.byKey(const Key('avatar-initial')), findsOneWidget);
  });

  testWidgets('短时间可见文本同时暴露完整时间 Semantics', (tester) async {
    final value = DateTime(2026, 8, 19, 9, 5);
    final now = DateTime(2026, 8, 19, 10, 5);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouTimeText(
            value: value,
            reference: now,
            semanticsPrefix: '发布时间：',
          ),
        ),
      ),
    );

    expect(find.text('1 小时前'), findsOneWidget);
    expect(find.bySemanticsLabel('发布时间：2026-08-19 09:05'), findsOneWidget);
  });
}
