import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/reading_text_style_test_support.dart';

// 非线性曲线专门区分“先缩放字号再乘行高”和“缩放整个行高”。
class _NonlinearScaler extends TextScaler {
  const _NonlinearScaler();
  @override
  double scale(double fontSize) =>
      fontSize < 20 ? fontSize * 1.8 : fontSize * 1.3;
  @override
  double get textScaleFactor => 1.8;
}

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final size in [14.0, 17.0, 19.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('独立空段按正文字号与行高缩放 $size/$scale', (tester) async {
        await pump(tester, [
          WenyouMarkdown(
            data: '## 甲\n<br />\n<br />\n## 乙',
            bodyFontSize: size,
            bodyHeight: 1.6,
          ),
        ], scale: scale);
        for (final index in [0, 1]) {
          expect(
            tester
                .getSize(
                  find.byKey(
                    ValueKey('wenyou-markdown-empty-paragraph-$index'),
                  ),
                )
                .height,
            closeTo(size * scale * 1.6, .01),
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('独立空段遵循非线性系统字号曲线', (tester) async {
    await pump(tester, const [
      WenyouMarkdown(data: '## 甲\n<br />\n## 乙'),
    ], textScaler: const _NonlinearScaler());
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('wenyou-markdown-empty-paragraph-0')),
          )
          .height,
      closeTo(17 * 1.8 * 1.8, .01),
    );
  });
  for (final dark in [false, true]) {
    testWidgets('长传送门窄屏折行且各阅读器字形一致 dark=$dark', (tester) async {
      const label = '这是很长的站内传送门名称需要折行';
      const source = '前文 [$label](/threads/cmsewdo0h000x7qv6aa77ll1v) 后文';
      await pump(
        tester,
        const [
          WenyouMarkdown(key: Key('markdown'), data: source),
          WenyouInternalReferenceText(
            key: Key('plain'),
            content: source,
            style: TextStyle(
              fontSize: 17,
              height: 1.8,
              letterSpacing: 17 * .008,
            ),
          ),
        ],
        scale: 2,
        dark: dark,
      );
      final labels = tester
          .renderObjectList<RenderParagraph>(
            find.byWidgetPredicate(
              (w) => w is RichText && w.text.toPlainText() == label,
            ),
          )
          .toList();
      expect(labels, hasLength(2));
      Rect glyph(RenderParagraph paragraph) {
        final box = paragraph
            .getBoxesForSelection(
              const TextSelection(baseOffset: 0, extentOffset: 1),
            )
            .single
            .toRect();
        return Rect.fromPoints(
          paragraph.localToGlobal(box.topLeft),
          paragraph.localToGlobal(box.bottomRight),
        );
      }

      expect(glyph(labels[0]).height, closeTo(glyph(labels[1]).height, .01));
      for (final paragraph in labels) {
        final boxes = paragraph.getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: label.length),
        );
        expect(boxes.length, greaterThan(1));
        final topLeft = paragraph.localToGlobal(Offset.zero);
        final bottomRight = paragraph.localToGlobal(
          paragraph.size.bottomRight(Offset.zero),
        );
        expect(topLeft.dx, greaterThanOrEqualTo(0));
        expect(bottomRight.dx, lessThanOrEqualTo(320));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
