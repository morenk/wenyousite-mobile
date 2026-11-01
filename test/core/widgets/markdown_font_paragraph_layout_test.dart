import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/deterministic_test_fonts.dart';

class _Runtime extends TextFontRuntime {
  _Runtime()
    : super(
        cache: TextFontCache(Directory.systemTemp),
        download: (_) async => throw StateError('离线测试不下载字体'),
      );

  @override
  Future<void> ensure(String id, String text) async {}

  @override
  TextStyle style(String id, TextStyle base) =>
      base.copyWith(fontFamily: 'Roboto');
}

class _Service extends TextFontService {
  _Service() : super(WenyouApi());
  final runtime = _Runtime();

  @override
  Future<TextFontRuntime> load() async => runtime;
}

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final (version, font) in [
    (1, 'wenkai'),
    (2, 'tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
  ]) {
    String span(String text) =>
        '<span data-wenyou-font-v$version="$font">$text</span>';

    for (final alignment in ['center', 'right']) {
      testWidgets('字体 v$version 与连续同行传送门保留 $alignment 对齐和行距', (tester) async {
        const portal = '[入口](/threads/cmsewdo0h000x7qv6aa77ll1v)';
        await _pump(
          tester,
          '[wenyousite-align-v1-$alignment]: #\n'
          '${span('甲')} $portal\n${span('乙')} $portal',
        );
        final paragraph = _paragraph(tester, '甲 \uFFFC\n乙 \uFFFC');
        expect(
          paragraph.textAlign,
          alignment == 'center' ? TextAlign.center : TextAlign.end,
        );
        Rect line(int start, int end) => paragraph
            .getBoxesForSelection(
              TextSelection(baseOffset: start, extentOffset: end),
            )
            .map((box) => box.toRect())
            .reduce((a, b) => a.expandToInclude(b))
            .shift(paragraph.localToGlobal(Offset.zero));
        final first = line(0, 3);
        final second = line(4, 7);
        expect(second.top - first.top, closeTo(17 * 1.8, 1));
        expect(
          alignment == 'center' ? first.center.dx : first.right,
          closeTo(alignment == 'center' ? 160 : 320, 1),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('字体 v$version 的回车和连续空行留在同一文字段落中', (tester) async {
      await _pump(tester, '${span('哈哈哈')}\n<br />\n<br />\n${span('姐姐')}');
      final paragraph = _paragraph(tester, '哈哈哈\n\n\n姐姐');
      final first = _glyph(paragraph, 0, 3);
      final last = _glyph(paragraph, 6, 8);
      // 引擎按物理像素舍入每行高度，允许三行累计的舍入误差。
      expect(last.top - first.top, closeTo(3 * 17 * 1.8, 1.5));
      expect(last.left, closeTo(first.left, 0.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('字体 v$version 与普通前后文连续折行且保留空格', (tester) async {
      const styled = '这是一段足够长的自定义字体正文，应该与前后文字共享折行和基线。';
      const plain = '前文 $styled 后文';
      await _pump(tester, '前文 ${span(styled)} 后文');
      final paragraph = _paragraph(tester, plain);
      final boxes = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 3, extentOffset: 3 + styled.length),
      );
      expect(boxes.map((box) => box.top).toSet().length, greaterThan(1));
      expect(boxes.first.top, closeTo(_glyph(paragraph, 0, 1).top, 1));
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final prefix in ['', '## ', '> ', '- ']) {
        testWidgets('混合字体的块归属与样式 $dark/$scale/$prefix', (tester) async {
          const version = 'tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
          await _pump(
            tester,
            '$prefix前 <span data-wenyou-font-v1="wenkai" '
            'data-wenyou-color-v1="#D14343">**甲**</span> '
            '<span data-wenyou-font-v2="$version">*乙*</span> 后',
            dark: dark,
            scale: scale,
          );
          final paragraph = _paragraph(tester, '前 甲 乙 后');
          final runs = <String, TextStyle>{};
          void visit(InlineSpan span, TextStyle inherited) {
            final style = inherited.merge(span.style);
            if (span is TextSpan) {
              if (span.text != null) runs[span.text!] = style;
              for (final child in span.children ?? <InlineSpan>[]) {
                visit(child, style);
              }
            }
          }

          visit(paragraph.text, const TextStyle());
          expect(runs['甲']!.color, const Color(0xFFD14343));
          expect(runs['甲']!.fontWeight, FontWeight.bold);
          expect(runs['乙']!.fontStyle, FontStyle.italic);
          expect(runs['甲']!.fontFamily, 'Roboto');
          expect(runs['乙']!.fontFamily, 'Roboto');
          expect(runs[' 后']!.color, isNot(const Color(0xFFD14343)));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final separator in ['\n', '\n<br />\n', '\n<br />\n<br />\n']) {
    testWidgets('两侧自定义字体保留换行 ${separator.replaceAll('\n', r'\n')}', (
      tester,
    ) async {
      final breaks = '\n'.allMatches(separator).length;
      await _pump(
        tester,
        '<span data-wenyou-font-v1="wenkai">甲</span>$separator'
        '<span data-wenyou-font-v1="zhuque">乙</span>',
      );
      final paragraph = _paragraph(tester, '甲${'\n' * breaks}乙');
      final first = _glyph(paragraph, 0, 1);
      final last = _glyph(paragraph, breaks + 1, breaks + 2);
      expect(last.top - first.top, closeTo(breaks * 17 * 1.8, 1.5));
    });
  }
}

Future<void> _pump(
  WidgetTester tester,
  String source, {
  bool dark = false,
  double scale = 1,
}) async {
  final service = _Service();
  addTearDown(service.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [textFontServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(scale),
            size: const Size(320, 800),
          ),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: WenyouMarkdown(data: source, enableTextFonts: true),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

RenderParagraph _paragraph(WidgetTester tester, String text) {
  final finder = find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText() == text,
  );
  expect(
    finder,
    findsOneWidget,
    reason:
        '字体、正文与换行必须共享一个文字布局；实际文字：'
        '${tester.widgetList<RichText>(find.byType(RichText)).map((text) => text.text.toPlainText()).toList()}',
  );
  return tester.renderObject<RenderParagraph>(finder);
}

Rect _glyph(RenderParagraph paragraph, int start, int end) => paragraph
    .getBoxesForSelection(TextSelection(baseOffset: start, extentOffset: end))
    .single
    .toRect();
