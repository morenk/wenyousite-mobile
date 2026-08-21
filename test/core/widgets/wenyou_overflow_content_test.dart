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

  testWidgets('可展开正文收起后恢复锚点且内容身份变化会重置状态', (tester) async {
    final content = ValueNotifier((id: 'first', height: 260.0));
    addTearDown(content.dispose);

    await tester.pumpWidget(
      _testApp(
        SingleChildScrollView(
          child: ValueListenableBuilder<({double height, String id})>(
            valueListenable: content,
            builder: (context, value, child) => WenyouCollapsibleContent(
              key: const Key('collapsible'),
              contentIdentity: value.id,
              triggerHeight: 200,
              collapsedHeight: 120,
              fadeColor: Theme.of(context).colorScheme.surface,
              actionKey: const Key('collapsible-action'),
              collapsedKey: const Key('collapsible-collapsed'),
              child: SizedBox(height: value.height),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('collapsible-collapsed')), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('collapsible'))).height, 120);
    expect(find.text('展开全文'), findsOneWidget);

    await tester.tap(find.byKey(const Key('collapsible-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('collapsible-collapsed')), findsNothing);
    expect(find.text('收起'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('collapsible'))).height,
      greaterThan(260),
    );

    content.value = (id: 'second', height: 260.0);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('collapsible-collapsed')), findsOneWidget);
    expect(find.text('展开全文'), findsOneWidget);

    content.value = (id: 'short', height: 180.0);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('collapsible-collapsed')), findsNothing);
    expect(find.byKey(const Key('collapsible-action')), findsNothing);
    expect(tester.getSize(find.byKey(const Key('collapsible'))).height, 180);
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
