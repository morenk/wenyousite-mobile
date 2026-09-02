import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

void main() {
  const segmentAlignments = ['left', 'center', 'right', 'center'];
  const source =
      '左对齐正文\n\n'
      '[wenyousite-align-v1-center]: #\n## 居中标题\n\n'
      '[wenyousite-align-v1-right]: #\n### 居右标题\n\n'
      '[wenyousite-align-v1-center]: #\n'
      '多物理行第一行，包含中文、emoji 🎲 与 Arabic العربية\n'
      '多物理行第二行，继续验证自动换行';

  for (final width in const [320.0, 360.0, 400.0, 600.0]) {
    for (final scale in const [1.0, 2.0]) {
      testWidgets('$width dp / ${scale}x 下左中右混排无溢出且样式精确', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1000);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: width == 360 ? AppTheme.dark : AppTheme.light,
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: const Scaffold(body: WenyouMarkdown(data: source)),
              ),
            ),
          ),
        );
        await tester.pump();

        final left = _body(tester, 0, 'left');
        final centerHeading = _body(tester, 1, 'center');
        final rightHeading = _body(tester, 2, 'right');
        final centerParagraph = _body(tester, 3, 'center');
        expect(left.styleSheet!.textAlign, WrapAlignment.start);
        expect(centerHeading.styleSheet!.h2Align, WrapAlignment.center);
        expect(rightHeading.styleSheet!.h3Align, WrapAlignment.end);
        expect(centerParagraph.styleSheet!.textAlign, WrapAlignment.center);

        for (var index = 0; index < 4; index++) {
          final segment = find.byKey(
            ValueKey(
              'wenyou-markdown-segment-$index-'
              '${segmentAlignments[index]}',
            ),
          );
          expect(tester.getSize(segment).width, width);
        }
        expect(find.textContaining('wenyousite-align'), findsNothing);
        expect(find.text('左对齐正文', findRichText: true), findsOneWidget);
        expect(find.text('居中标题', findRichText: true), findsOneWidget);
        expect(find.text('居右标题', findRichText: true), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('连续同方向块仍保持独立 Markdown 块与可见顺序', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data:
                '[wenyousite-align-v1-center]: #\n第一段\n\n'
                '[wenyousite-align-v1-center]: #\n## 第二段\n\n'
                '[wenyousite-align-v1-right]: #\n第三段',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      _body(tester, 0, 'center').styleSheet!.textAlign,
      WrapAlignment.center,
    );
    expect(
      _body(tester, 1, 'center').styleSheet!.h2Align,
      WrapAlignment.center,
    );
    expect(_body(tester, 2, 'right').styleSheet!.textAlign, WrapAlignment.end);
    expect(find.text('第一段', findRichText: true), findsOneWidget);
    expect(find.text('第二段', findRichText: true), findsOneWidget);
    expect(find.text('第三段', findRichText: true), findsOneWidget);
  });

  testWidgets('发布态短文本实际几何位置分别落在左、中、右', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data:
                '左侧短句\n\n'
                '[wenyousite-align-v1-center]: #\n居中短句\n\n'
                '[wenyousite-align-v1-right]: #\n居右短句',
          ),
        ),
      ),
    );
    await tester.pump();

    final leftSegment = tester.getRect(
      find.byKey(const ValueKey('wenyou-markdown-segment-0-left')),
    );
    final centerSegment = tester.getRect(
      find.byKey(const ValueKey('wenyou-markdown-segment-1-center')),
    );
    final rightSegment = tester.getRect(
      find.byKey(const ValueKey('wenyou-markdown-segment-2-right')),
    );
    final leftFinder = find.text('左侧短句', findRichText: true);
    final centerFinder = find.text('居中短句', findRichText: true);
    final rightFinder = find.text('居右短句', findRichText: true);
    final leftText = tester.getRect(leftFinder);
    final centerText = tester.getRect(centerFinder);
    final rightText = tester.getRect(rightFinder);
    final leftGlyphs = _glyphRect(tester, leftFinder, '左侧短句'.length);
    final centerGlyphs = _glyphRect(tester, centerFinder, '居中短句'.length);
    final rightGlyphs = _glyphRect(tester, rightFinder, '居右短句'.length);

    expect(leftText.left, closeTo(leftSegment.left, 1));
    expect(centerText.center.dx, closeTo(centerSegment.center.dx, 1));
    expect(rightText.right, closeTo(rightSegment.right, 1));
    expect(leftGlyphs.left, closeTo(leftSegment.left, 1));
    expect(centerGlyphs.center.dx, closeTo(centerSegment.center.dx, 1));
    expect(rightGlyphs.right, closeTo(rightSegment.right, 1));
    expect(tester.widget<RichText>(leftFinder).textAlign, TextAlign.start);
    expect(tester.widget<RichText>(centerFinder).textAlign, TextAlign.center);
    expect(tester.widget<RichText>(rightFinder).textAlign, TextAlign.end);
  });

  testWidgets('Markdown v5 独立图片块按 marker 设置实际容器方向', (tester) async {
    const url = 'https://cdn.example.com/image.webp';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data:
                '[wenyousite-align-v1-right]: #\n'
                '![图片]($url)',
          ),
        ),
      ),
    );
    await tester.pump();

    final row = tester.widget<SizedBox>(
      find.byKey(const ValueKey('markdown-block-image-row-$url')),
    );
    expect((row.child! as Align).alignment, AlignmentDirectional.centerEnd);
    expect(
      find.textContaining('wenyousite-align-v1-right', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('非法保留 marker 必须作为可见正文降级，不能静默隐藏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(data: '[wenyousite-align-v1-center_alt]: #\n正文'),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('wenyousite-align-v1-center_alt', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('正文', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

MarkdownBody _body(WidgetTester tester, int index, String alignment) =>
    tester.widget<MarkdownBody>(
      find.descendant(
        of: find.byKey(ValueKey('wenyou-markdown-segment-$index-$alignment')),
        matching: find.byType(MarkdownBody),
      ),
    );

Rect _glyphRect(WidgetTester tester, Finder finder, int textLength) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: textLength),
  );
  expect(boxes, isNotEmpty);
  Rect? result;
  for (final box in boxes) {
    final local = box.toRect();
    final global = Rect.fromPoints(
      paragraph.localToGlobal(local.topLeft),
      paragraph.localToGlobal(local.bottomRight),
    );
    result = result?.expandToInclude(global) ?? global;
  }
  return result!;
}
