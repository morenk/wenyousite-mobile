import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/settings/presentation/diagnostic_settings_page.dart';

void main() {
  testWidgets('窄屏与两倍文字能复制、关闭发送和清除记录', (tester) async {
    final previous = FailureDiagnostics.instance;
    final diagnostics = FailureDiagnostics();
    FailureDiagnostics.instance = diagnostics;
    addTearDown(() => FailureDiagnostics.instance = previous);
    diagnostics.capture(StateError('private-body'));
    await diagnostics.settled;
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const DiagnosticSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WenyouSettingsTypography), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('复制问题详情').hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('复制问题详情'));
    await tester.pumpAndSettle();
    expect(copied, contains(diagnostics.records.single.id));
    expect(copied, isNot(contains('private-body')));
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byType(Switch).hitTestable(),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(diagnostics.automaticSending, false);
    await tester.scrollUntilVisible(
      find.text('清除本机记录').hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('清除本机记录'));
    await tester.pumpAndSettle();
    expect(diagnostics.records, isEmpty);
  });
}
