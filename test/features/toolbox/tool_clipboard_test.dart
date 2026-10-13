import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

void main() {
  testWidgets('复制成功短提示，连续复制不排队并保持字面空白', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ToolResult(text: '  甲\n  ')),
      ),
    );
    await tester.tap(find.byKey(const Key('tool-copy')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('复制成功'), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).duration,
      const Duration(milliseconds: 1500),
    );
    await tester.tap(find.byKey(const Key('tool-copy')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('复制成功'), findsOneWidget);
    expect(copied, ['  甲\n  ', '  甲\n  ']);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('复制成功'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('复制成功'), findsNothing);
  });
  testWidgets('剪贴板写失败不报成功，并可长按恢复', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          throw PlatformException(code: 'denied');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ToolResult(text: '甲')),
      ),
    );
    await tester.tap(find.byKey(const Key('tool-copy')));
    await tester.pumpAndSettle();
    expect(find.text('复制成功'), findsNothing);
    expect(find.text('复制失败，请长按选择文字'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });
}
