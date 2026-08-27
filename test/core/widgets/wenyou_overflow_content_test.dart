import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_overflow_content.dart';

void main() {
  testWidgets('独立入口按真实布局高度越过边界时出现并随内容恢复', (tester) async {
    final height = ValueNotifier(200.0);
    addTearDown(height.dispose);
    var pressed = false;

    await tester.pumpWidget(
      _testApp(
        ValueListenableBuilder<double>(
          valueListenable: height,
          builder: (context, value, child) => WenyouOverflowDestination(
            key: const Key('destination'),
            maxHeight: 200,
            forceAction: false,
            fadeColor: Theme.of(context).colorScheme.surface,
            collapsedKey: const Key('destination-collapsed'),
            action: WenyouOverflowAction(
              key: const Key('destination-action'),
              label: '展开全部 1 条回复',
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: () => pressed = true,
            ),
            child: SizedBox(height: value),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('destination-action')), findsNothing);
    expect(find.byKey(const Key('destination-collapsed')), findsNothing);
    expect(tester.getSize(find.byKey(const Key('destination'))).height, 200);

    height.value = 201;
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('destination-action')), findsOneWidget);
    expect(find.byKey(const Key('destination-collapsed')), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('destination'))).height, 200);
    await tester.tap(find.byKey(const Key('destination-action')));
    expect(pressed, isTrue);

    height.value = 199;
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('destination-action')), findsNothing);
    expect(find.byKey(const Key('destination-collapsed')), findsNothing);
    expect(tester.getSize(find.byKey(const Key('destination'))).height, 199);
  });

  testWidgets('存在未预览条目时短内容仍只提供一次独立入口', (tester) async {
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) => WenyouOverflowDestination(
            maxHeight: 200,
            forceAction: true,
            fadeColor: Theme.of(context).colorScheme.surface,
            collapsedKey: const Key('forced-collapsed'),
            action: WenyouOverflowAction(
              key: const Key('forced-action'),
              label: '展开全部 6 条回复',
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: () {},
            ),
            child: const SizedBox(height: 80),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('forced-action')), findsOneWidget);
    expect(find.byKey(const Key('forced-collapsed')), findsNothing);
    expect(find.text('展开全部 6 条回复'), findsOneWidget);
  });

}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  );
}
