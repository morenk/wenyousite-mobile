import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('阅读态恢复 Web 同源粗斜体且不显示定界符或空格', (tester) async {
    const cases = [
      (
        source: '选择你的DeerSeek模型：**【注意注意！并不是真的AI！DeerSeek就是我！】**DeerSeek v4 pro',
        visible: '选择你的DeerSeek模型：【注意注意！并不是真的AI！DeerSeek就是我！】DeerSeek v4 pro',
        formatted: '【注意注意！并不是真的AI！DeerSeek就是我！】',
        bold: true,
        italic: false,
        strike: false,
      ),
      (
        source: '前*（斜体）*后',
        visible: '前（斜体）后',
        formatted: '（斜体）',
        bold: false,
        italic: true,
        strike: false,
      ),
      (
        source: '前***【粗斜体】***后',
        visible: '前【粗斜体】后',
        formatted: '【粗斜体】',
        bold: true,
        italic: true,
        strike: false,
      ),
      (
        source: '前~~【删除】~~后',
        visible: '前【删除】后',
        formatted: '【删除】',
        bold: false,
        italic: false,
        strike: true,
      ),
      (
        source: '前__【粗体】__后',
        visible: '前【粗体】后',
        formatted: '【粗体】',
        bold: true,
        italic: false,
        strike: false,
      ),
      (
        source: '前**🚨注意🚨**后',
        visible: '前🚨注意🚨后',
        formatted: '🚨注意🚨',
        bold: true,
        italic: false,
        strike: false,
      ),
    ];

    for (final fixture in cases) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouMarkdown(
              data: fixture.source,
              enablePlainTextFastPath: false,
            ),
          ),
        ),
      );
      await tester.pump();

      final paragraph = tester
          .renderObjectList<RenderParagraph>(find.byType(RichText))
          .singleWhere(
            (candidate) => candidate.text.toPlainText() == fixture.visible,
          );
      final run = _resolvedRuns(
        paragraph.text,
      ).singleWhere((candidate) => candidate.text == fixture.formatted);

      expect(paragraph.text.toPlainText(), fixture.visible);
      expect(run.style.fontWeight == FontWeight.w700, fixture.bold);
      expect(run.style.fontStyle == FontStyle.italic, fixture.italic);
      expect(
        run.style.decoration?.contains(TextDecoration.lineThrough) ?? false,
        fixture.strike,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('阅读态不恢复转义、畸形、代码和链接中的字面定界符', (tester) async {
    const source = r'''前\**【字面】**后

前** 【空白】**后

foo_bar_baz

x****【四星】****y

`前**【代码】**后`

[前**【链接】**后](https://example.com)''';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(data: source, enablePlainTextFastPath: false),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('前**【字面】**后', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('前** 【空白】**后', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('foo_bar_baz', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('x****【四星】****y', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(WenyouInlineCodeSurface), findsOneWidget);
    expect(find.text('前**【代码】**后'), findsOneWidget);
    expect(
      find.textContaining('前**【链接】**后', findRichText: true),
      findsOneWidget,
    );
    expect(_allResolvedRuns(tester).where(_hasEmphasisStyle), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('阅读态恢复粗体尾随空格并保留相邻行内代码', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data: '**粗体 **`代码`',
            enablePlainTextFastPath: false,
          ),
        ),
      ),
    );
    await tester.pump();

    final bold = _allResolvedRuns(
      tester,
    ).singleWhere((run) => run.text == '粗体');
    expect(bold.style.fontWeight, FontWeight.w700);
    expect(find.byType(WenyouInlineCodeSurface), findsOneWidget);
    expect(find.text('代码'), findsOneWidget);
    expect(find.textContaining('**', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Iterable<({String text, TextStyle style})> _allResolvedRuns(
  WidgetTester tester,
) sync* {
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    yield* _resolvedRuns(richText.text);
  }
}

Iterable<({String text, TextStyle style})> _resolvedRuns(
  InlineSpan span, [
  TextStyle inherited = const TextStyle(),
]) sync* {
  if (span case TextSpan(:final text, :final style, :final children)) {
    final resolved = inherited.merge(style);
    if (text?.isNotEmpty == true) yield (text: text!, style: resolved);
    if (children != null) {
      for (final child in children) {
        yield* _resolvedRuns(child, resolved);
      }
    }
  }
}

bool _hasEmphasisStyle(({String text, TextStyle style}) run) =>
    run.style.fontWeight == FontWeight.w700 ||
    run.style.fontStyle == FontStyle.italic ||
    (run.style.decoration?.contains(TextDecoration.lineThrough) ?? false);
