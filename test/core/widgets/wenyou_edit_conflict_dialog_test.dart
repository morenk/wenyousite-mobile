import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_edit_conflict_dialog.dart';

void main() {
  for (final label in ['最新版', '我的内容', '继续编辑', '返回']) {
    testWidgets('冲突选择只返回类型化结果：$label', (tester) async {
      WenyouEditConflictChoice? result;
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showWenyouEditConflictDialog(
                    context: context,
                    title: '已有更新',
                    message: '选择要继续使用的内容。',
                    useLatestLabel: '最新版',
                    keepCurrentLabel: '我的内容',
                    continueEditingLabel: '继续编辑',
                  );
                  completed = true;
                },
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(completed, isFalse);
      if (label == '返回') {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.text(label));
      }
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(result, switch (label) {
        '最新版' => WenyouEditConflictChoice.useLatest,
        '我的内容' => WenyouEditConflictChoice.keepCurrent,
        _ => null,
      });
    });
  }
}
