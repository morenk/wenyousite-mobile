import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_number_sheet.dart';
import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  Future<void> open(
    WidgetTester tester, {
    required Future<void> Function(int, bool Function()) onLocate,
    bool dark = false,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDiscussionNumberSheet(
                context: context,
                replies: true,
                currentNumber: 128,
                maxNumber: 10000,
                onLocate: onLocate,
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
  }

  testWidgets('面板只保留数字定位，空输入不提交且不抢键盘', (tester) async {
    final calls = <int>[];
    await open(tester, onLocate: (number, _) async => calls.add(number));
    expect(find.text('跳转到回复'), findsOneWidget);
    expect(find.text('当前 #128 · 编号至 #10000'), findsOneWidget);
    expect(find.text('最早'), findsNothing);
    expect(find.text('中间'), findsNothing);
    expect(find.text('最新'), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.tap(find.byKey(const Key('discussion-number-submit')));
    expect(calls, isEmpty);
    await tester.enterText(find.byType(TextField), '5000');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();
    expect(calls, [5000]);
    expect(find.text('跳转到回复'), findsNothing);
  });

  testWidgets('错误内联保留编号，进行中不重复提交', (tester) async {
    final pending = Completer<void>();
    var calls = 0;
    await open(
      tester,
      onLocate: (_, _) {
        calls++;
        return pending.future;
      },
    );
    await tester.enterText(find.byType(TextField), '10001');
    await tester.pump();
    await tester.tap(find.byKey(const Key('discussion-number-submit')));
    await tester.pump();
    expect(find.text('请输入 1 至 10000 之间的编号'), findsOneWidget);
    expect(calls, 0);
    await tester.enterText(find.byType(TextField), '8000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('discussion-number-submit')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('discussion-number-submit')));
    expect(calls, 1);
    pending.completeError(const ApiFailure(userMessage: '该回复已不可见'));
    await tester.pumpAndSettle();
    expect(find.text('该回复已不可见'), findsOneWidget);
    expect(find.text('8000'), findsOneWidget);
  });

  testWidgets('取消后重开时旧请求不关闭新面板或污染输入', (tester) async {
    final pending = Completer<void>();
    var accepted = 0;
    await open(
      tester,
      onLocate: (_, active) async {
        await pending.future;
        if (active()) accepted++;
      },
    );
    await tester.enterText(find.byType(TextField), '9000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('discussion-number-submit')));
    await tester.pump();
    await tester.tap(find.byTooltip('关闭跳转到回复'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '128');
    pending.complete();
    await tester.pumpAndSettle();
    expect(accepted, 0);
    expect(find.text('跳转到回复'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
  });

  testWidgets('关闭退场尚未dispose时，晚响应也不能应用或再次pop', (tester) async {
    final pending = Completer<void>();
    var accepted = 0;
    await open(
      tester,
      onLocate: (_, active) async {
        await pending.future;
        if (active()) accepted++;
      },
    );
    await tester.enterText(find.byType(TextField), '9000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('discussion-number-submit')));
    await tester.pump();
    await tester.tap(find.byTooltip('关闭跳转到回复'));
    // 故意不等待退场动画；State 此刻仍然 mounted。
    pending.complete();
    await tester.pump();
    expect(accepted, 0);
    await tester.pumpAndSettle();
    expect(find.text('打开').hitTestable(), findsOneWidget);
    expect(find.text('跳转到回复'), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets('320dp / 2倍字体 ${dark ? "深色" : "浅色"} 无溢出', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester, dark: dark, textScale: 2, onLocate: (_, _) async {});
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/discussion_number_${dark ? 'dark' : 'light'}_320.png',
        ),
      );
      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();
      await tester.tap(find.byKey(const Key('discussion-number-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('请输入 1 至 10000 之间的编号'), findsOneWidget);
    });
  }
}
