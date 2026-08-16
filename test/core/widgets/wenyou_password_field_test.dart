import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_password_field.dart';

void main() {
  testWidgets('密码字段默认隐藏并可切换可见状态', (tester) async {
    final controller = TextEditingController(text: 'secret123');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouPasswordField(
            textFieldKey: const Key('password-input'),
            controller: controller,
            label: '密码',
            enabled: true,
          ),
        ),
      ),
    );

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('显示密码'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isFalse,
    );
    expect(find.byTooltip('隐藏密码'), findsOneWidget);
  });
}
