import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> insertToolbarLink(
  WidgetTester tester,
  String label,
  String url,
) async {
  await tester.tap(find.byKey(const Key('editor-more')));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('链接'));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextField, '显示文字'), label);
  await tester.enterText(find.widgetWithText(TextField, '链接地址'), url);
  await tester.tap(find.byKey(const Key('editor-link-insert')));
  await tester.pumpAndSettle();
}
