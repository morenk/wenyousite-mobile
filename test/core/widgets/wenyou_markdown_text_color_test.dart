import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    for (final alignment in ['center', 'right']) {
      for (final prefix in ['', '## ', '### ']) {
        testWidgets('整段颜色保留实际字形对齐 $dark/$alignment/$prefix', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: Scaffold(
                body: SizedBox(
                  width: 320,
                  child: WenyouMarkdown(
                    data:
                        '[wenyousite-align-v1-$alignment]: #\n'
                        '$prefix<span data-wenyou-color-v1="#D14343">如何呢</span>',
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final finder = find.byWidgetPredicate(
            (widget) =>
                widget is RichText && widget.text.toPlainText() == '如何呢',
          );
          expect(finder, findsOneWidget);
          final paragraph = tester.renderObject<RenderParagraph>(finder);
          expect(
            paragraph.textAlign,
            alignment == 'center' ? TextAlign.center : TextAlign.end,
          );
          final box = paragraph
              .getBoxesForSelection(
                const TextSelection(baseOffset: 0, extentOffset: 3),
              )
              .single;
          final glyphs = box.toRect().shift(
            paragraph.localToGlobal(Offset.zero),
          );
          final segment = tester.getRect(
            find.byKey(ValueKey('wenyou-markdown-segment-0-$alignment')),
          );
          expect(
            alignment == 'center' ? glyphs.center.dx : glyphs.right,
            closeTo(
              alignment == 'center' ? segment.center.dx : segment.right,
              1,
            ),
          );
          void expectColor(InlineSpan span, TextStyle? inherited) {
            final style = inherited?.merge(span.style) ?? span.style;
            if (span is TextSpan) {
              if (span.text?.isNotEmpty ?? false) {
                expect(style?.color, const Color(0xFFD14343));
              }
              for (final child in span.children ?? <InlineSpan>[]) {
                expectColor(child, style);
              }
            }
          }

          expectColor(paragraph.text, null);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final scale in [1.0, 2.0]) {
    testWidgets('颜色范围与前后文组成同一可跨行段落 scale=$scale', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      const colored = '这是一段足够长的彩色中文正文，前后普通文字和有色文字在同一行开始，超过宽度后自然换行。';
      const plain = '前文 $colored 后文';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: const Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(16),
                  child: WenyouMarkdown(
                    data:
                        '前文 <span data-wenyou-color-v1="#123456">$colored</span> 后文',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final finder = find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == plain,
      );
      expect(finder, findsOneWidget, reason: '颜色范围不能包成不可折行的原子 WidgetSpan');
      final paragraph = tester.renderObject<RenderParagraph>(finder);
      final boxes = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 3, extentOffset: 3 + colored.length),
      );
      expect(boxes.map((box) => box.top).toSet().length, greaterThan(1));
      final before = paragraph
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 1),
          )
          .single;
      expect(boxes.first.top, closeTo(before.top, 0.5));
      expect(boxes.first.bottom, closeTo(before.bottom, 0.5));
      expect(paragraph.text.toPlainText(), isNot(contains('\uFFFC')));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('颜色与已合入段首空格语法共同保留文字', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data: '&#32;&#32;<span data-wenyou-color-v1="#123456">正文</span> 后文',
            enablePlainTextFastPath: false,
          ),
        ),
      ),
    );
    final text = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(WenyouMarkdown),
            matching: find.byType(Text),
          ),
        )
        .where((value) => value.textSpan != null)
        .map((value) => value.textSpan!.toPlainText())
        .join();
    expect(text, '  正文 后文');
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    testWidgets('彩色文字、链接、代码使用原始 RGB ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: const Scaffold(
            body: WenyouMarkdown(
              data:
                  '<span data-wenyou-color-v1="#123456">文字 **粗体** [链接](https://example.com) `代码`</span>',
            ),
          ),
        ),
      );
      final spans = <({String text, TextStyle? style})>[];
      void collect(InlineSpan span, TextStyle? inherited) {
        final style = inherited?.merge(span.style) ?? span.style;
        if (span is TextSpan) {
          if (span.text != null) spans.add((text: span.text!, style: style));
          for (final child in span.children ?? <InlineSpan>[]) {
            collect(child, style);
          }
        }
      }

      for (final widget in tester.widgetList<RichText>(find.byType(RichText))) {
        collect(widget.text, null);
      }
      final coloredText = spans
          .where(
            (s) =>
                s.text.contains('文字') ||
                s.text == '粗体' ||
                s.text == '链接' ||
                s.text == '代码',
          )
          .toList();
      expect(coloredText.map((s) => s.text).join(), contains('文字'));
      expect(coloredText.length, greaterThanOrEqualTo(4), reason: '$spans');
      for (final span in coloredText) {
        expect(span.style?.color, const Color(0xFF123456), reason: span.text);
      }
      expect(spans.map((s) => s.text).join(), isNot(contains('<span')));
      expect(tester.takeException(), isNull);
    });
  }
  for (final dark in [false, true]) {
    testWidgets('320dp 混合彩色长段连续折行、标题列表和可见复制 ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      const text =
          '前文 <span data-wenyou-color-v1="#8B5CF6">这是连续的彩色中文长段，需要正常折行并与前后的默认文字一起排版，**粗体保持**，*斜体保持*，~~删除线保持~~。</span> 后文。';
      const source =
          '## <span data-wenyou-color-v1="#D14343">彩色标题</span>\n\n$text\n\n- <span data-wenyou-color-v1="#25855A">列表也使用原有行高，保留颜色。</span>\n- 默认列表';
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: const Scaffold(
            body: RepaintBoundary(
              key: Key('long-color-reader'),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: WenyouMarkdown(data: source),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final plain = MarkdownClipboardText.project(source);
      expect(plain, contains('前文 这是连续的彩色中文长段'));
      expect(plain, contains('粗体保持，斜体保持，删除线保持。 后文。'));
      expect(plain, isNot(contains('<span')));
      for (final element in find.byType(RichText).evaluate()) {
        final rect = tester.getRect(
          find.byElementPredicate((other) => identical(element, other)),
        );
        expect(rect.right, lessThanOrEqualTo(320));
      }
      await expectLater(
        find.byKey(const Key('long-color-reader')),
        matchesGoldenFile(
          'goldens/markdown_text_color_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
