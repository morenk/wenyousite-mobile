import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final heading in ['##', '###']) {
    for (final separator in ['\n', '\n\n', '\n\n<br />\n\n']) {
      for (final target in [0, 1, 2]) {
        testWidgets(
          '$heading 相邻块与显式空段仅对齐第 $target 块不改垂直间距 separator=$separator',
          (tester) async {
            final blocks = ['前文第一行\n前文第二行', '$heading 标题文字', '后文'];
            Future<List<Rect>> measure(String direction) async {
              final source = [
                for (var index = 0; index < blocks.length; index++)
                  '${direction.isNotEmpty && index == target ? '[wenyousite-align-v1-$direction]: #\n' : ''}${blocks[index]}',
              ].join(separator);
              await tester.pumpWidget(
                MaterialApp(
                  theme: AppTheme.light,
                  home: Scaffold(
                    body: WenyouMarkdown(
                      data: source,
                      enablePlainTextFastPath: false,
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              final texts = tester
                  .widgetList<RichText>(
                    find.descendant(
                      of: find.byType(WenyouMarkdown),
                      matching: find.byType(RichText),
                    ),
                  )
                  .toList();
              expect(
                texts
                    .map((text) => text.text.toPlainText())
                    .join()
                    .replaceAll('\n', ''),
                '前文第一行前文第二行标题文字后文',
              );
              return [
                for (final token in ['前文第一行', '前文第二行', '标题文字', '后文'])
                  (() {
                    final text = texts.singleWhere(
                      (text) => text.text.toPlainText().contains(token),
                    );
                    final start = text.text.toPlainText().indexOf(token);
                    final paragraph = tester.renderObject<RenderParagraph>(
                      find.byWidget(text),
                    );
                    return paragraph
                        .getBoxesForSelection(
                          TextSelection(
                            baseOffset: start,
                            extentOffset: start + token.length,
                          ),
                        )
                        .single
                        .toRect()
                        .shift(paragraph.localToGlobal(Offset.zero));
                  })(),
              ];
            }

            final initial = await measure('');
            for (final direction in ['center', 'right']) {
              final actual = await measure(direction);
              for (var index = 0; index < initial.length; index++) {
                // 独立空段 30.6dp 与文字 strut 的 31px 栅格化相差 0.4px。
                expect(actual[index].top, closeTo(initial[index].top, 0.5));
                expect(
                  actual[index].height,
                  closeTo(initial[index].height, 0.001),
                );
              }
            }
          },
        );
      }
    }
  }
  for (final prefix in ['## ', '### ']) {
    testWidgets('$prefix 行内强调不把标题行高退回正文', (tester) async {
      Future<double> height(String text) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(body: WenyouMarkdown(data: '$prefix$text')),
          ),
        );
        await tester.pumpAndSettle();
        return tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(WenyouMarkdown),
                    matching: find.byType(RichText),
                  )
                  .first,
            )
            .height;
      }

      final plain = await height('标题文字');
      expect(await height('**标题**文字'), plain);
      expect(await height('*标题*文字'), plain);
    });
  }
  for (final prefix in ['', '## ', '### ']) {
    for (final text in [
      '标题文字',
      '**标题**文字',
      '*标题*文字',
      '`标题`文字',
      '<span data-wenyou-color-v1="#FF0000">标题</span>文字',
    ]) {
      testWidgets('$prefix$text 阅读态对齐保留垂直位置', (tester) async {
        Future<List<(String, double, double)>> measure(String marker) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: WenyouMarkdown(
                  data: '前文\n\n$marker$prefix$text\n\n后文',
                  enablePlainTextFastPath: false,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          return tester
              .widgetList<RichText>(
                find.descendant(
                  of: find.byType(WenyouMarkdown),
                  matching: find.byType(RichText),
                ),
              )
              .map((text) {
                final rect = tester.getRect(find.byWidget(text));
                return (text.text.toPlainText(), rect.top, rect.height);
              })
              .toList();
        }

        final initial = await measure('');
        for (final alignment in ['center', 'right']) {
          expect(
            await measure('[wenyousite-align-v1-$alignment]: #\n'),
            initial,
          );
        }
      });
    }
  }
}
