import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_modal_action_menu.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('操作窗口固定居中，暗区不关闭并提供显式关闭按钮', (tester) async {
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
                  label: '复制内容',
                  key: Key('modal-copy'),
                ),
                WenyouPopoverAction(
                  value: 2,
                  icon: WenyouIconIds.editorLink,
                  label: '复制链接',
                  key: Key('modal-link'),
                ),
                WenyouPopoverAction(
                  value: 3,
                  icon: WenyouIconIds.actionDelete,
                  label: '删除',
                  key: Key('modal-delete'),
                ),
                WenyouPopoverAction(
                  value: 4,
                  icon: WenyouIconIds.actionReport,
                  label: '举报',
                  key: Key('modal-report'),
                ),
              ],
              semanticLabel: '楼层操作',
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
    expect(find.text('楼层操作'), findsOneWidget);
    expect(find.byKey(const Key('modal-copy')), findsOneWidget);
    final copy = tester.getRect(find.byKey(const Key('modal-copy')));
    final link = tester.getRect(find.byKey(const Key('modal-link')));
    final delete = tester.getRect(find.byKey(const Key('modal-delete')));
    final report = tester.getRect(find.byKey(const Key('modal-report')));
    expect(copy.size.width, WenyouModalActionMenu.actionWidth);
    expect(copy.size.height, greaterThanOrEqualTo(72));
    expect(copy.top, link.top);
    expect(delete.top, report.top);
    expect(copy.left, delete.left);
    expect(link.left, report.left);

    await expectLater(
      menu,
      matchesGoldenFile('goldens/modal_action_menu_360.png'),
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(menu, findsOneWidget);

    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pump();
    expect(menu, findsNothing);
  });

  testWidgets('五项操作在窄屏和大字体下保持三加二对称排布', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: WenyouModalActionMenu<int>(
            actions: const [
              WenyouPopoverAction(
                value: 1,
                icon: WenyouIconIds.actionCopy,
                label: '复制内容',
                key: Key('large-action-1'),
              ),
              WenyouPopoverAction(
                value: 2,
                icon: WenyouIconIds.editorLink,
                label: '复制链接',
                key: Key('large-action-2'),
              ),
              WenyouPopoverAction(
                value: 3,
                icon: WenyouIconIds.actionEdit,
                label: '编辑',
                key: Key('large-action-3'),
              ),
              WenyouPopoverAction(
                value: 4,
                icon: WenyouIconIds.actionDelete,
                label: '删除',
                key: Key('large-action-4'),
              ),
              WenyouPopoverAction(
                value: 5,
                icon: WenyouIconIds.actionReport,
                label: '举报',
                key: Key('large-action-5'),
              ),
            ],
            semanticLabel: '楼层操作',
            onSelected: (_) {},
            anchorBuilder: (context, handle) => FilledButton(
              key: const Key('large-modal-trigger'),
              onPressed: handle.open,
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('large-modal-trigger')));
    await tester.pump();

    final first = tester.getRect(find.byKey(const Key('large-action-1')));
    final third = tester.getRect(find.byKey(const Key('large-action-3')));
    final fourth = tester.getRect(find.byKey(const Key('large-action-4')));
    final fifth = tester.getRect(find.byKey(const Key('large-action-5')));
    expect(first.top, third.top);
    expect(fourth.top, fifth.top);
    expect((first.left + third.right) / 2, closeTo(160, 0.01));
    expect((fourth.left + fifth.right) / 2, closeTo(160, 0.01));
    expect(tester.takeException(), isNull);
  });
}
