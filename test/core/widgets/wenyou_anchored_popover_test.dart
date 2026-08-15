import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('五项保持单行，第六项换行且浮层不越过窄屏安全边界', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    int? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouAnchoredActionBubble<int>(
              actions: [
                for (var index = 0; index < 6; index++)
                  WenyouPopoverAction(
                    value: index,
                    icon: WenyouIconIds.actionCopy,
                    label: '操作${index + 1}',
                    key: ValueKey('popover-action-$index'),
                  ),
              ],
              onSelected: (value) => selected = value,
              anchorBuilder: (context, handle) => FilledButton(
                key: const Key('popover-trigger'),
                onPressed: handle.toggle,
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('popover-trigger')));
    await tester.pump();

    final first = tester.getRect(
      find.byKey(const ValueKey('popover-action-0')),
    );
    final fifth = tester.getRect(
      find.byKey(const ValueKey('popover-action-4')),
    );
    final sixth = tester.getRect(
      find.byKey(const ValueKey('popover-action-5')),
    );
    expect(first.top, fifth.top);
    expect(sixth.top, greaterThan(first.top));
    expect(first.left, greaterThanOrEqualTo(8));
    expect(fifth.right, lessThanOrEqualTo(312));

    await tester.tap(find.byKey(const ValueKey('popover-action-0')));
    await tester.pump();
    expect(selected, 0);
    expect(find.byKey(const ValueKey('popover-action-0')), findsNothing);
  });

  testWidgets('打开输入框旁浮层不会抢走当前输入焦点，系统返回可收起', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextField(key: const Key('focused-field'), focusNode: focusNode),
              WenyouAnchoredActionBubble<int>(
                actions: const [
                  WenyouPopoverAction(
                    value: 1,
                    icon: WenyouIconIds.actionCopy,
                    label: '复制',
                    key: Key('focus-popover-action'),
                  ),
                ],
                onSelected: (_) {},
                anchorBuilder: (context, handle) => IconButton(
                  key: const Key('focus-popover-trigger'),
                  onPressed: handle.toggle,
                  icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('focused-field')));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.byKey(const Key('focus-popover-trigger')));
    await tester.pump();
    expect(find.byKey(const Key('focus-popover-action')), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('focus-popover-action')), findsNothing);
    expect(focusNode.hasFocus, isTrue);
  });
}
