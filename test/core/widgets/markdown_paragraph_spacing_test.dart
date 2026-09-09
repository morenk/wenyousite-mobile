import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  for (final fast in [true, false]) {
    for (final prefix in [
      '',
      '[wenyousite-align-v1-center]: #\n',
      '[wenyousite-align-v1-right]: #\n',
    ]) {
      testWidgets('正文相邻段不增加行距，真空行占一行 fast=$fast $prefix', (tester) async {
        await _pump(tester, '甲\n乙', fast: fast);
        final lineHeight = _glyph(tester, '乙').top - _glyph(tester, '甲').top;
        expect(lineHeight, greaterThan(20));
        await _pump(tester, '$prefix甲\n\n乙', fast: fast);
        expect(
          _glyph(tester, '乙').top - _glyph(tester, '甲').top,
          closeTo(lineHeight, .5),
        );
        if (prefix.isNotEmpty) {
          expect(
            _glyph(tester, '甲').left,
            greaterThan(_glyph(tester, '乙').left + 80),
          );
        }
        await _pump(tester, '$prefix甲\n<br />\n乙', fast: fast);
        expect(
          _glyph(tester, '乙').top - _glyph(tester, '甲').top,
          closeTo(lineHeight * 2, .5),
        );
        await _pump(tester, '$prefix**甲**\n\n*乙*', fast: fast);
        expect(
          _glyph(tester, '乙').top - _glyph(tester, '甲').top,
          closeTo(lineHeight, .5),
        );
      });
    }
  }

  testWidgets('自动折行的长正文始终整段居右', (tester) async {
    await _pump(tester, '[wenyousite-align-v1-right]: #\n${'长正文' * 12}终');
    final paragraph = tester.allRenderObjects
        .whereType<RenderParagraph>()
        .toSet()
        .singleWhere((p) => p.text.toPlainText().contains('终'));
    expect(paragraph.textAlign, TextAlign.end);
    expect(paragraph.textDirection, TextDirection.ltr);
    final first = _glyph(tester, '长');
    final last = _glyph(tester, '终');
    expect(last.top, greaterThan(first.top));
    expect(
      last.right,
      closeTo(paragraph.localToGlobal(Offset(paragraph.size.width, 0)).dx, 1),
    );
  });
}

Future<void> _pump(WidgetTester tester, String data, {bool fast = true}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 240,
            child: WenyouMarkdown(data: data, enablePlainTextFastPath: fast),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Rect _glyph(WidgetTester tester, String text) {
  final paragraph = tester.allRenderObjects
      .whereType<RenderParagraph>()
      .toSet()
      .singleWhere((p) => p.text.toPlainText().contains(text));
  final offset = paragraph.text.toPlainText().indexOf(text);
  return paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: offset, extentOffset: offset + text.length),
      )
      .first
      .toRect()
      .shift(paragraph.localToGlobal(Offset.zero));
}
