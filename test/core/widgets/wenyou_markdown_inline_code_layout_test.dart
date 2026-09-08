import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/foundation_test_fonts.dart';

// 负责人反馈的 #6 楼原文，仅保留触发排版问题的正文。
const reportedInlineCodeMarkdown =
    '> 123\n123\n<br />\n`123`\n123\n<br />\n~~123~~\n`123`';

void main() {
  setUpAll(loadFoundationTestFonts);

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('反馈原文行内代码前后换行回到行首 dark=$dark scale=$scale', (tester) async {
        await _pumpMarkdown(
          tester,
          reportedInlineCodeMarkdown,
          dark: dark,
          scale: scale,
        );
        final code = find.byType(WenyouInlineCodeSurface);
        expect(code, findsNWidgets(2));
        final ordinary = _textRects(tester, '123', outsideCode: true);
        expect(ordinary, hasLength(4));
        final firstCode = tester.getRect(code.at(0));
        final lastCode = tester.getRect(code.at(1));
        expect(ordinary[2].left, closeTo(firstCode.left, 0.5));
        expect(ordinary[2].top, greaterThan(firstCode.top));
        expect(lastCode.left, closeTo(ordinary[3].left, 0.5));
        expect(lastCode.top, greaterThan(ordinary[3].top));
        expect(tester.takeException(), isNull);
        if (dark && scale == 1) {
          await expectLater(
            find.byKey(const Key('inline-code-layout-visual')),
            matchesGoldenFile('goldens/markdown_inline_code_360_dark.png'),
          );
        }
      });
    }
  }

  testWidgets('同一行的行内代码与前后正文共享文字基线', (tester) async {
    await _pumpMarkdown(tester, '甲`123`乙');
    final code = find.byType(WenyouInlineCodeSurface);
    final codeText = find.descendant(of: code, matching: find.byType(RichText));
    final parentText = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().contains('甲'),
    );
    expect(parentText, findsOneWidget);
    final codeBox = tester.renderObject<RenderParagraph>(codeText);
    final parentBox = tester.renderObject<RenderParagraph>(parentText);
    double baseline(RenderParagraph box) =>
        box.localToGlobal(Offset.zero).dy +
        box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
    // 引擎对占位符高度取整，允许半个逻辑像素的基线舍入。
    expect(baseline(codeBox), closeTo(baseline(parentBox), 0.5));
    final before = _textRects(tester, '甲').single;
    final after = _textRects(tester, '乙').single;
    expect(before.top, closeTo(after.top, 0.01));
    expect(before.right, lessThanOrEqualTo(tester.getRect(code).left));
    expect(after.left, greaterThanOrEqualTo(tester.getRect(code).right - 0.01));
  });

  testWidgets('行尾代码按剩余宽度换行且后文跟随代码', (tester) async {
    await _pumpMarkdown(tester, '${'甲' * 16}`123456`乙');
    final codeRect = tester.getRect(find.byType(WenyouInlineCodeSurface));
    final before = _textRects(tester, '甲');
    final after = _textRects(tester, '乙').single;
    expect(codeRect.top, greaterThan(before.first.top));
    expect(codeRect.left, closeTo(before.first.left, 0.5));
    expect(after.left, greaterThanOrEqualTo(codeRect.right));
    expect(after.top, lessThan(codeRect.bottom));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpMarkdown(
  WidgetTester tester,
  String source, {
  bool dark = false,
  double scale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 1000);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: RepaintBoundary(
              key: const Key('inline-code-layout-visual'),
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: WenyouMarkdown(data: source),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<Rect> _textRects(
  WidgetTester tester,
  String text, {
  bool outsideCode = false,
}) {
  final rectangles = <Rect>[];
  for (final element in find.byType(RichText).evaluate()) {
    final finder = find.byWidget(element.widget);
    if (outsideCode &&
        find
            .ancestor(
              of: finder,
              matching: find.byType(WenyouInlineCodeSurface),
            )
            .evaluate()
            .isNotEmpty) {
      continue;
    }
    final paragraph = element.renderObject! as RenderParagraph;
    for (final match in RegExp(
      RegExp.escape(text),
    ).allMatches(paragraph.text.toPlainText())) {
      rectangles.addAll(
        paragraph
            .getBoxesForSelection(
              TextSelection(baseOffset: match.start, extentOffset: match.end),
            )
            .map(
              (box) => box.toRect().shift(paragraph.localToGlobal(Offset.zero)),
            ),
      );
    }
  }
  return rectangles;
}
