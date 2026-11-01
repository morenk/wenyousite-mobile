import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_link_style.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/reading_text_style_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  const rgb = Color(0xFFD14343);
  const combinations = [
    '**TEXT**',
    '*TEXT*',
    '~~TEXT~~',
    '**~~*TEXT*~~**',
    '[TEXT](https://example.com)',
    '[**TEXT**](https://example.com)',
    '**[TEXT](https://example.com)**',
    '[~~*TEXT*~~](https://example.com)',
    '`TEXT`',
    '**`TEXT`**',
    '~~*`TEXT`*~~',
    '[`TEXT`](https://example.com)',
  ];
  for (final dark in [false, true]) {
    for (final size in [14.0, 19.0]) {
      for (final scope in ['font', 'color', 'both']) {
        testWidgets('字体与颜色保留强调、链接及代码组合 $dark/$size/$scope', (tester) async {
          for (final template in combinations) {
            final font = scope != 'color';
            final color = scope != 'font';
            final attrs = [
              if (font)
                'data-wenyou-font-v2="tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"',
              if (color) 'data-wenyou-color-v1="#D14343"',
            ].join(' ');
            await pump(
              tester,
              [
                WenyouMarkdown(
                  data: template.replaceAll('TEXT', '原样'),
                  bodyFontSize: size,
                ),
                WenyouMarkdown(
                  data:
                      '<span $attrs>${template.replaceAll('TEXT', '组合')}</span>',
                  bodyFontSize: size,
                  enableTextFonts: true,
                ),
              ],
              dark: dark,
              scale: dark ? 2 : 1,
            );
            final original = leafStyle(tester, '原样');
            final combined = leafStyle(tester, '组合');
            expect(combined.fontSize, original.fontSize, reason: template);
            expect(combined.height, original.height, reason: template);
            expect(combined.fontWeight, original.fontWeight, reason: template);
            expect(combined.fontStyle, original.fontStyle, reason: template);
            expect(
              combined.letterSpacing,
              original.letterSpacing,
              reason: template,
            );
            final decorations = <TextDecoration>[
              if (template.contains('~~')) TextDecoration.lineThrough,
              if (template.contains('https:')) TextDecoration.underline,
            ];
            expect(
              combined.decoration,
              decorations.isEmpty
                  ? TextDecoration.none
                  : TextDecoration.combine(decorations),
              reason: template,
            );
            expect(
              combined.color,
              color ? rgb : original.color,
              reason: template,
            );
            if (font) expect(combined.fontFamily, 'Roboto', reason: template);
            if (template.contains('https:')) {
              expect(
                combined.decorationColor,
                color
                    ? rgb
                    : wenyouContentLinkStyle(
                        tester.element(find.byType(WenyouMarkdown).first),
                      ).decorationColor,
                reason: template,
              );
            }
            expect(tester.takeException(), isNull, reason: template);
          }
        });
      }
    }
  }
  for (final prefix in ['## ', '### ', '> ', '- ']) {
    testWidgets('块内着色代码沿用普通代码排版 $prefix', (tester) async {
      await pump(tester, [
        WenyouMarkdown(data: '$prefix**`原样`**', bodyFontSize: 19),
        WenyouMarkdown(
          data: '$prefix<span data-wenyou-color-v1="#D14343">**`组合`**</span>',
          bodyFontSize: 19,
        ),
      ], scale: 2);
      final original = leafStyle(tester, '原样');
      final combined = leafStyle(tester, '组合');
      expect(combined.fontSize, original.fontSize);
      expect(combined.height, original.height);
      expect(combined.fontWeight, original.fontWeight);
      expect(combined.color, rgb);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('禁用自定义字体仍保留链接样式与显式颜色', (tester) async {
    await pump(tester, const [
      WenyouMarkdown(data: '[原样](https://example.com)'),
      WenyouMarkdown(
        data:
            '<span data-wenyou-font-v1="wenkai">[组合](https://example.com)</span>',
      ),
    ]);
    final original = leafStyle(tester, '原样');
    final combined = leafStyle(tester, '组合');
    expect(combined.color, original.color);
    expect(combined.fontWeight, original.fontWeight);
    expect(combined.decorationColor, original.decorationColor);
  });
}
