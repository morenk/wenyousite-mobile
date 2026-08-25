import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(DebugDiagnosticBuffer.instance.clear);

  test('现场诊断编译开关默认关闭', () {
    expect(wenyouFieldDiagnosticsEnabled, isFalse);
  });

  test('异常诊断只保留类型与堆栈而不复制异常消息', () {
    DebugDiagnosticBuffer.instance.recordFlutterError(
      FlutterErrorDetails(
        exception: StateError('正文或 token-secret 不得进入诊断'),
        library: 'widgets test',
        stack: StackTrace.fromString('#0 safe_stack (debug_test.dart:1:1)'),
      ),
    );

    final text = DebugDiagnosticBuffer.instance.exportText();
    expect(text, contains('flutter_error'));
    expect(text, contains('StateError'));
    expect(text, contains('safe_stack'));
    expect(text, isNot(contains('token-secret')));
    expect(text, isNot(contains('正文或')));
  });

  testWidgets('Debug 悬浮入口展示并一键复制窗口与渲染诊断', (tester) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
    DebugDiagnosticBuffer.instance.record('post_render', {
      'event': 'post_detail_render_result',
      'deviceModel': 'HONOR Magic8',
      'failureStage': 'layout',
    });

    await tester.pumpWidget(
      MaterialApp(
        // Match the production MaterialApp.builder placement: the diagnostic
        // panel is a sibling of Navigator's Overlay, not its descendant.
        builder: (context, child) => WenyouDebugDiagnosticOverlay(
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Scaffold(body: Text('正文占位')),
      ),
    );

    expect(find.byKey(const Key('debug-diagnostic-open')), findsOneWidget);
    await tester.tap(find.byKey(const Key('debug-diagnostic-open')));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('debug-diagnostic-panel')), findsOneWidget);
    expect(find.text('现场诊断（Debug）'), findsOneWidget);
    expect(
      (tester.widget<SelectableText>(
        find.byKey(const Key('debug-diagnostic-text')),
      )).data,
      allOf(contains('post_render'), contains('window_metrics')),
    );

    await tester.tap(find.byKey(const Key('debug-diagnostic-copy')));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(copiedText, isNotNull);
    expect(copiedText, contains('HONOR Magic8'));
    expect(copiedText, contains('rawViewPaddingPhysical'));
    expect(find.text('已复制，可直接粘贴发送'), findsOneWidget);
  });
}
