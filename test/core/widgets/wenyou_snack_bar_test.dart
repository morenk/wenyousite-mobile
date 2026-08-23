import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

void main() {
  testWidgets('普通提示使用 2.5 秒并自动消失', (tester) async {
    await _pumpLauncher(
      tester,
      onPressed: (context) => showWenyouSnackBar(context, '操作完成'),
    );

    await tester.tap(find.byKey(const Key('show-notice')));
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, wenyouBriefSnackBarDuration);
    expect(snackBar.persist, isFalse);

    await tester.pump(wenyouBriefSnackBarDuration);
    await tester.pumpAndSettle();
    expect(find.text('操作完成'), findsNothing);
  });

  testWidgets('带操作提示使用 4 秒且操作仍可执行', (tester) async {
    var acted = false;
    await _pumpLauncher(
      tester,
      onPressed: (context) => showWenyouSnackBar(
        context,
        '已收藏到默认收藏夹。',
        actionLabel: '修改收藏夹',
        actionKey: const Key('change-folder'),
        onAction: () => acted = true,
      ),
    );

    await tester.tap(find.byKey(const Key('show-notice')));
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, wenyouExtendedSnackBarDuration);
    expect(snackBar.persist, isFalse);

    await tester.tap(find.byKey(const Key('change-folder')));
    await tester.pump();
    expect(acted, isTrue);
  });

  testWidgets('无障碍导航下带操作提示仍在 4 秒后消失', (tester) async {
    await _pumpLauncher(
      tester,
      accessibleNavigation: true,
      onPressed: (context) => showWenyouSnackBar(
        context,
        '已恢复上次的草稿',
        actionLabel: '重新开始',
        onAction: () {},
      ),
    );

    await tester.tap(find.byKey(const Key('show-notice')));
    await tester.pumpAndSettle();
    expect(find.text('已恢复上次的草稿'), findsOneWidget);

    await tester.pump(wenyouExtendedSnackBarDuration);
    await tester.pumpAndSettle();
    expect(find.text('已恢复上次的草稿'), findsNothing);
  });

  testWidgets('新提示替换旧提示且不会留下待显示队列', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  key: const Key('show-first'),
                  onPressed: () => showWenyouSnackBar(context, '第一条提示'),
                  child: const Text('第一条'),
                ),
                TextButton(
                  key: const Key('show-second'),
                  onPressed: () => showWenyouSnackBar(context, '第二条提示'),
                  child: const Text('第二条'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('show-first')));
    await tester.pumpAndSettle();
    expect(find.text('第一条提示'), findsOneWidget);

    await tester.tap(find.byKey(const Key('show-second')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('第一条提示'), findsNothing);
    expect(find.text('第二条提示'), findsOneWidget);

    await tester.pump(wenyouBriefSnackBarDuration);
    await tester.pumpAndSettle();
    expect(find.text('第一条提示'), findsNothing);
    expect(find.text('第二条提示'), findsNothing);
  });
}

Future<void> _pumpLauncher(
  WidgetTester tester, {
  required void Function(BuildContext context) onPressed,
  bool accessibleNavigation = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(accessibleNavigation: accessibleNavigation),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const Key('show-notice'),
            onPressed: () => onPressed(context),
            child: const Text('显示提示'),
          ),
        ),
      ),
    ),
  );
}
