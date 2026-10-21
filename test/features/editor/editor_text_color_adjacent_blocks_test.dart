import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/text_color_assertions.dart';

// 相邻块矩阵扩展第19楼原文；该反馈的编辑差异已确认为默认恢复未发布草稿。
void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('实际56字符草稿保留一个空段和一个红色H2，保存原样且阅读不重复', (tester) async {
    const source = '<br />\n## <span data-wenyou-color-v1="#D14343">杀！</span>';
    expect(source.length, 56);
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    expect(session.controller.document.toPlainText(), '\n杀！\n');
    final delta = session.controller.document.toDelta();
    expect(delta.operations.first.data, '\n');
    expect(
      delta.operations.first.attributes?[MarkdownDeltaCodec
          .emptyParagraphAttribute],
      true,
    );
    expect(_visibleRows(delta), [
      (text: '杀！', header: 2, color: '#D14343', bold: false),
    ]);
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, source);
    expect(MarkdownDeltaCodec.encode(delta), source);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WenyouMarkdown(data: source)),
      ),
    );
    await tester.pumpAndSettle();
    final empty = find.byKey(
      const ValueKey('wenyou-markdown-empty-paragraph-0'),
    );
    expect(empty, findsOneWidget);
    final text = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == '杀！',
    );
    expect(text, findsOneWidget);
    expect(
      tester.getRect(empty).bottom,
      lessThanOrEqualTo(tester.getRect(text).top),
    );
    final styles = <TextStyle>[];
    void collect(InlineSpan span, [TextStyle? inherited]) {
      final style = inherited?.merge(span.style) ?? span.style;
      if (span is TextSpan) {
        if (span.text?.isNotEmpty ?? false) styles.add(style!);
        for (final child in span.children ?? <InlineSpan>[]) {
          collect(child, style);
        }
      }
    }

    collect(tester.widget<RichText>(text).text);
    expect(styles, isNotEmpty);
    for (final style in styles) {
      expect(style.color, const Color(0xFFD14343));
      expect(style.fontSize, greaterThan(17));
    }
    expect(tester.takeException(), isNull);
  });
  for (final first in [0, 2, 3]) {
    for (final second in [0, 2, 3]) {
      test('连续彩色块 $first → $second 保留两行、字号和完整文字', () async {
        for (final separator in ['\n', '\n\n']) {
          for (final alignment in WenyouTextAlignment.values) {
            for (final bold in [false, true]) {
              final source = [
                _block(first, bold, alignment),
                _block(second, false, alignment),
              ].join(separator);
              final decoded = MarkdownDeltaCodec.decode(source);
              expect(_visibleRows(decoded.delta), [
                (text: '杀！', header: first, color: '#D14343', bold: bold),
                (text: '杀！', header: second, color: '#D14343', bold: false),
              ], reason: source);
              final reader = MarkdownAlignmentContract.renderSegments(source)
                  .expand((s) => colorReaderUnits(colorReaderNodes(s.markdown)))
                  .whereType<Map<String, Object>>();
              expect(
                reader
                    .map((unit) => unit['text'])
                    .where((text) => text != '\n')
                    .join(),
                '杀！杀！',
                reason: source,
              );
              final session = RichEditorSession(
                initialMarkdown: source,
                onMarkdownChanged: (_) {},
              );
              expect(session.isSourceProtected, isFalse, reason: source);
              expect(
                session.controller.document
                    .toPlainText()
                    .split('\n')
                    .where((line) => line.isNotEmpty),
                ['杀！', '杀！'],
                reason: source,
              );
              expect(
                await session.flush(),
                isTrue,
                reason: '$source\n${session.codecFailure}',
              );
              final reopened = RichEditorSession(
                initialMarkdown: session.localMarkdown,
                onMarkdownChanged: (_) {},
              );
              expect(
                _visibleRows(reopened.controller.document.toDelta()),
                _visibleRows(decoded.delta),
                reason: source,
              );
              expect(await reopened.flush(), isTrue, reason: source);
              reopened.dispose();
              session.dispose();
            }
          }
        }
      });
    }
  }

  test('由真实 Quill 文档生成小字行与大字行，保存后仍保留两行', () async {
    for (final firstHeader in [0, 3]) {
      for (final alignment in [
        Attribute.leftAlignment,
        Attribute.centerAlignment,
        Attribute.rightAlignment,
      ]) {
        final session = RichEditorSession(
          initialMarkdown: '',
          onMarkdownChanged: (_) {},
        );
        session.controller.replaceText(0, 0, '杀！\n杀！', null);
        if (firstHeader != 0) session.controller.formatText(0, 2, Attribute.h3);
        session.controller.formatText(3, 2, Attribute.h2);
        session.controller.formatText(0, 5, alignment);
        session.controller.formatText(0, 2, ColorAttribute('#D14343'));
        session.controller.formatText(3, 2, ColorAttribute('#D14343'));
        final expected = [
          (text: '杀！', header: firstHeader, color: '#D14343', bold: false),
          (text: '杀！', header: 2, color: '#D14343', bold: false),
        ];
        expect(_visibleRows(session.controller.document.toDelta()), expected);
        expect(await session.flush(), isTrue, reason: session.codecFailure);
        final reopened = RichEditorSession(
          initialMarkdown: session.localMarkdown,
          onMarkdownChanged: (_) {},
        );
        expect(
          _visibleRows(reopened.controller.document.toDelta()),
          expected,
          reason: session.localMarkdown,
        );
        reopened.dispose();
        session.dispose();
      }
    }
  });
}

String _block(int header, bool bold, WenyouTextAlignment alignment) {
  final marker = MarkdownAlignmentContract.markerFor(alignment);
  final prefix = header == 0 ? '' : '${'#' * header} ';
  final text = bold ? '**杀！**' : '杀！';
  return '${marker.isEmpty ? '' : '$marker\n'}$prefix<span data-wenyou-color-v1="#D14343">$text</span>';
}

List<({String text, int header, String? color, bool bold})> _visibleRows(
  Delta delta,
) {
  final rows = <({String text, int header, String? color, bool bold})>[];
  var text = '';
  String? color;
  var bold = false;
  for (final operation in delta.operations) {
    final data = operation.data;
    if (data is! String) continue;
    final pieces = data.split('\n');
    for (var i = 0; i < pieces.length; i++) {
      if (pieces[i].isNotEmpty) {
        text += pieces[i];
        color = operation.attributes?['color'] as String?;
        bold = operation.attributes?['bold'] == true;
      }
      if (i < pieces.length - 1) {
        if (text.isNotEmpty) {
          rows.add((
            text: text,
            header: operation.attributes?['header'] as int? ?? 0,
            color: color,
            bold: bold,
          ));
        }
        text = '';
        color = null;
        bold = false;
      }
    }
  }
  return rows;
}
