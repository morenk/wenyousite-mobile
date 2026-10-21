import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('反馈竖排诗首行与第二行均保留 24 个普通空格', (tester) async {
    // 取负责人反馈原帖的前两行；正文缩进保存为 24 个 &#32;。
    final encodedIndent = '&#32;' * 24;
    final indent = ' ' * 24;
    await _pumpMarkdown(
      tester,
      '$encodedIndent低  举  疑  床\n$encodedIndent头  头  是  前',
    );

    final text = _paragraphText(tester);
    expect(text, '$indent低  举  疑  床\n$indent头  头  是  前');
    final lines = text.split('\n');
    expect(lines, hasLength(2));
    expect(lines.first.substring(0, 24), indent);
    expect(lines[1].substring(0, 24), indent);
  });

  for (final fixture in <({String label, String source, String visible})>[
    (label: '普通空格', source: '  首行\n  次行', visible: '  首行\n  次行'),
    (
      label: '十六进制空格实体',
      source: '&#x20;&#X0020;首行\n&#32;&#032;次行',
      visible: '  首行\n  次行',
    ),
    (
      label: '全角空格与 NBSP',
      source: '\u3000\u00a0首行\n\u3000\u00a0次行',
      visible: '\u3000\u00a0首行\n\u3000\u00a0次行',
    ),
    (
      label: '反斜杠转义实体保持字面内容',
      source: r'\&#32;\&#x20;正文',
      visible: '&#32;&#x20;正文',
    ),
  ]) {
    testWidgets('段首${fixture.label}', (tester) async {
      await _pumpMarkdown(tester, fixture.source);
      expect(_paragraphText(tester), fixture.visible);
    });
  }

  testWidgets('行内代码里的空格实体不被阅读缩进解码', (tester) async {
    await _pumpMarkdown(tester, '`&#32;&#x20;代码`');

    final code = find.byType(WenyouInlineCodeSurface);
    expect(code, findsOneWidget);
    expect(
      find.descendant(of: code, matching: find.text('&#32;&#x20;代码')),
      findsOneWidget,
    );
  });

  testWidgets('围栏代码里的缩进与实体保留原文', (tester) async {
    await _pumpMarkdown(tester, '```text\n  &#32;&#x20;代码\n```');

    final texts = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(WenyouMarkdown),
        matching: find.byType(Text),
      ),
    );
    expect(
      texts.map((text) => text.textSpan?.toPlainText() ?? text.data ?? ''),
      contains('  &#32;&#x20;代码'),
    );
  });
}

Future<void> _pumpMarkdown(WidgetTester tester, String source) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: WenyouMarkdown(data: source, enablePlainTextFastPath: false),
      ),
    ),
  );
  await tester.pump();
  expect(tester.takeException(), isNull);
}

String _paragraphText(WidgetTester tester) {
  final paragraphs = tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(WenyouMarkdown),
          matching: find.byType(Text),
        ),
      )
      .where((text) => text.textSpan != null);
  expect(paragraphs, hasLength(1));
  return paragraphs.single.textSpan!.toPlainText();
}
