import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final input = File(
    'test/fixtures/editor/web-font-exports-r5.json',
  ).readAsBytesSync();
  final cases = (jsonDecode(utf8.decode(input)) as List)
      .cast<Map<String, Object?>>();
  final results = <Object>[];
  test('历史Web交接完整性：97份真实Milkdown产物、29个历史ID', () {
    expect(
      sha256.convert(input).toString(),
      '8e91a8e32b0dc0c108807f76ac279f9f79b5caf5cc55b62734b62f717d1ca3d6',
    );
    expect(cases, hasLength(97));
    expect(
      cases.map((c) => c['fontId']).whereType<String>().toSet(),
      MarkdownTextFont.ids,
    );
  });
  for (var index = 0; index < cases.length; index++) {
    final entry = cases[index];
    test('Web→Mobile编辑、撤销、保存、重开：${entry['caseId'] ?? index}', () async {
      final saved = entry['saved']! as String;
      final paragraphs = saved.split('\n\n');
      // 预期来自Web输出的独立阅读解析，不由待测Codec反推。
      final expected = [
        for (final paragraph in paragraphs)
          ...colorReaderUnits(colorReaderNodes(paragraph)),
      ];
      final session = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      expect(colorDeltaUnits(session.controller.document.toDelta()), expected);
      final initialPlain = session.controller.document.toPlainText();
      expect(initialPlain.split('\n').length - 1, paragraphs.length);
      if (entry['fontId'] case final String id) {
        final marks = {'font': id, 'color': '#D14343'};
        final catalogExpected = colorExpectedUnits([
          ('春风 "引号" 中文😀 Aa', {...marks, 'bold': true}),
          (' ', marks),
          ('斜体', {...marks, 'italic': true}),
          (' ', marks),
          ('链接', {...marks, 'link': 'https://example.com'}),
          ('あいうえお アイウエオ é 0123 ‘引号’', {'font': id, 'color': '#2563EB'}),
        ]);
        expect(expected, catalogExpected);
        expect(
          initialPlain,
          '春风 "引号" 中文😀 Aa 斜体 链接\nあいうえお アイウエオ é 0123 ‘引号’\n',
        );
        expect(initialPlain.replaceAll('\n', ''), entry['plainText']);
      }
      session.controller.document.history.clear();
      session.controller.replaceText(
        0,
        0,
        '测',
        const TextSelection.collapsed(offset: 1),
      );
      expect(session.controller.document.toPlainText(), '测$initialPlain');
      expect(await session.flush(), isTrue);
      session.controller.undo();
      expect(session.controller.document.toPlainText(), initialPlain);
      expect(await session.flush(), isTrue);
      final exported = session.localMarkdown;
      final reopened = RichEditorSession(
        initialMarkdown: exported,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(reopened.controller.document.toPlainText(), initialPlain);
      expect(colorDeltaUnits(reopened.controller.document.toDelta()), expected);
      expect([
        for (final paragraph in exported.split('\n\n'))
          ...colorReaderUnits(colorReaderNodes(paragraph)),
      ], expected);
      results.add({
        'caseIndex': index,
        'caseId': entry['caseId'],
        'fontId': entry['fontId'],
        'source': saved,
        'saved': exported,
        'plainText': initialPlain,
        'visibleUnits': expected,
        'delta': reopened.controller.document.toDelta().toJson(),
      });
    });
  }
  tearDownAll(() {
    const output = String.fromEnvironment('FONT_INTEROP_OUTPUT');
    if (output.isNotEmpty && results.length == cases.length) {
      File(output).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'format': 'wenyou-web-mobile-font-roundtrip-v1',
          'sourceSha256': const String.fromEnvironment('FONT_SOURCE_SHA'),
          'webArtifactSha256': sha256.convert(input).toString(),
          'cases': results,
        }),
      );
    }
  });
}
