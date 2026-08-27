import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';

void main() {
  testWidgets('确认对话框返回选择并为危险动作使用 error 色', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showWenyouConfirmationDialog(
                context: context,
                title: '删除内容？',
                message: '删除后无法恢复。',
                confirmLabel: '删除',
                confirmKey: const Key('confirm'),
                tone: WenyouConfirmationTone.destructive,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('confirm')),
    );
    expect(
      button.style?.backgroundColor?.resolve({}),
      AppTheme.light.colorScheme.error,
    );
    await tester.tap(find.byKey(const Key('confirm')));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
