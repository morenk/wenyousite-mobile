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

  for (final action in ['取消', '遮罩', '返回']) {
    testWidgets('$action 关闭确认框不执行操作并恢复焦点', (tester) async {
      bool? result;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                focusNode: focus,
                onPressed: () async {
                  result = await showWenyouConfirmationDialog(
                    context: context,
                    title: '确认删除？',
                    message: '删除后无法恢复。',
                    confirmLabel: '删除',
                    tone: WenyouConfirmationTone.destructive,
                  );
                },
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      if (action == '取消') {
        await tester.tap(find.text('取消'));
      } else if (action == '遮罩') {
        await tester.tapAt(const Offset(2, 2));
      } else {
        await tester.binding.handlePopRoute();
      }
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
      expect(focus.hasFocus, isTrue);
    });
  }

  testWidgets('禁止遮罩关闭的嵌套确认保留原导航栈', (tester) async {
    final nested = GlobalKey<NavigatorState>();
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Navigator(
          key: nested,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showWenyouConfirmationDialog(
                    context: context,
                    title: '恢复图片？',
                    confirmLabel: '继续使用',
                    useRootNavigator: false,
                    barrierDismissible: false,
                  );
                },
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(nested.currentState!.canPop(), isTrue);
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(result, isNull);
    await tester.tap(find.text('继续使用'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(nested.currentState!.canPop(), isFalse);
    expect(find.text('打开'), findsOneWidget);
  });
}
