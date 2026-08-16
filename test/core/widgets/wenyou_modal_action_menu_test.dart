import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_modal_action_menu.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('操作窗口固定居中并可点击暗区关闭', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: WenyouModalActionMenu<int>(
              actions: const [
                WenyouPopoverAction(
                  value: 1,
                  icon: WenyouIconIds.actionCopy,
                  label: '复制',
                  key: Key('modal-copy'),
                ),
                WenyouPopoverAction(
                  value: 2,
                  icon: WenyouIconIds.actionReply,
                  label: '回复',
                  key: Key('modal-reply'),
                ),
              ],
              onSelected: (_) {},
              anchorBuilder: (context, handle) => FilledButton(
                key: const Key('modal-trigger'),
                onPressed: handle.open,
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('modal-trigger')));
    await tester.pump();

    final menu = find.byKey(const Key('wenyou-modal-action-menu'));
    expect(menu, findsOneWidget);
    expect(tester.getCenter(menu), const Offset(180, 380));
    expect(find.byKey(const Key('modal-copy')), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(menu, findsNothing);
  });
}
