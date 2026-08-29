import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  const nodeId = '550e8400-e29b-41d4-a716-446655440000';
  const diceNode = '[[dice:v1:$nodeId:1d20]]';

  testWidgets('提及与行内代码按 Foundation 元素契约渲染', (tester) async {
    Uri? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '你好 [@张三](/users/user-zhang) 与 @全体玩家，执行 `code`。',
            onInternalLink: (uri) => opened = uri,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(WenyouMentionSurface), findsNWidgets(2));
    expect(find.byType(WenyouMentionLink), findsOneWidget);
    final mentionTexts = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(WenyouMentionSurface),
        matching: find.byType(Text),
      ),
    );
    for (final text in mentionTexts) {
      expect(text.style?.color, WenyouFoundationPalette.brandStrong);
      expect(text.style?.fontWeight, FontWeight.w600);
      expect(text.style?.decoration, TextDecoration.none);
    }
    expect(
      tester.getSize(find.byType(WenyouMentionLink)).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.bySemanticsLabel('查看 @张三 的个人资料'), findsOneWidget);
    await tester.tap(find.text('@张三'));
    await tester.pump();
    expect(opened?.toString(), '/users/user-zhang');

    final inlineCode = find.byType(WenyouInlineCodeSurface);
    expect(inlineCode, findsOneWidget);
    final container = tester.widget<Container>(
      find.descendant(of: inlineCode, matching: find.byType(Container)),
    );
    final codeText = tester.widget<Text>(
      find.descendant(of: inlineCode, matching: find.text('code')),
    );
    final fontSize = codeText.style!.fontSize!;
    expect(fontSize, closeTo(17 * 0.88, 0.001));
    expect(
      (container.padding! as EdgeInsets).horizontal / 2,
      closeTo(fontSize * 0.35, 0.001),
    );
    expect(
      ((container.decoration! as BoxDecoration).borderRadius! as BorderRadius)
          .topLeft
          .x,
      closeTo(fontSize * 0.35, 0.001),
    );
  });

  testWidgets('引用中的斜体行内代码合并外层强调样式', (tester) async {
    const source = '> *`璃氏已勘破长生之妙……青春不老。`*';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(data: source, enablePlainTextFastPath: false),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('wenyou-markdown-plain-text')), findsNothing);
    final inlineCode = find.byType(WenyouInlineCodeSurface);
    expect(inlineCode, findsOneWidget);
    final codeText = tester.widget<Text>(
      find.descendant(of: inlineCode, matching: find.text('璃氏已勘破长生之妙……青春不老。')),
    );
    expect(codeText.style?.fontStyle, FontStyle.italic);
    expect(codeText.style?.fontFamily, 'monospace');
    expect(codeText.style?.backgroundColor, Colors.transparent);
    expect(tester.takeException(), isNull);
  });

  testWidgets('已结算骰子打开安全区明细并只在明细逐项朗读', (tester) async {
    const settledDiceNode = '[[dice:v1:$nodeId:3d6+2]]';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WenyouMarkdown(
            data: '结果 $settledDiceNode',
            diceLabels: {nodeId: '3d6+2 = 13'},
            diceSemantics: {nodeId: '这条旧语义不应覆盖结构化结果'},
            diceDetails: {
              nodeId: WenyouDiceRollDetail(results: [4, 6, 1], total: 13),
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('wenyou-dice-$nodeId')), findsOneWidget);
    expect(find.text('3d6+2 = 13'), findsOneWidget);
    expect(
      find.textContaining('<wenyou-dice', findRichText: true),
      findsNothing,
    );
    expect(find.textContaining('[[dice:', findRichText: true), findsNothing);
    expect(find.textContaining('🎲', findRichText: true), findsNothing);
    final surface = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('wenyou-dice-$nodeId')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = surface.decoration as BoxDecoration;
    expect(decoration.color, WenyouFoundationPalette.accent);
    expect(
      (decoration.borderRadius! as BorderRadius).topLeft.x,
      closeTo(5.1, 0.001),
    );
    final padding = tester.widget<Padding>(
      find.descendant(
        of: find.byKey(const ValueKey('wenyou-dice-$nodeId')),
        matching: find.byType(Padding),
      ),
    );
    final insets = padding.padding.resolve(TextDirection.ltr);
    expect(insets.left, closeTo(5.1, 0.001));
    expect(insets.top, closeTo(0.68, 0.001));
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('wenyou-dice-$nodeId')),
        matching: find.text('3d6+2 = 13'),
      ),
    );
    expect(text.style?.color, WenyouFoundationPalette.onAccent);
    expect(text.style?.height, WenyouElementContract.diceLineHeight);
    final triggerSemantics = tester
        .getSemantics(find.byKey(const ValueKey('wenyou-dice-$nodeId')))
        .getSemanticsData();
    expect(triggerSemantics.label, '骰子 3d6+2，总计 13');
    expect(triggerSemantics.hint, '查看逐骰结果');
    expect(triggerSemantics.flagsCollection.isButton, isTrue);
    expect(triggerSemantics.flagsCollection.isExpanded.toBoolOrNull(), isFalse);
    expect(triggerSemantics.label, isNot(contains('4、6、1')));
    final triggerSize = tester.getSize(
      find.byKey(const ValueKey('wenyou-dice-$nodeId')),
    );
    expect(triggerSize.width, greaterThanOrEqualTo(48));
    expect(triggerSize.height, greaterThanOrEqualTo(48));

    await tester.tap(find.byKey(const ValueKey('wenyou-dice-$nodeId')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('wenyou-dice-detail-sheet')), findsOneWidget);
    expect(find.text('骰子结果'), findsOneWidget);
    expect(find.text('逐骰结果'), findsOneWidget);
    expect(find.bySemanticsLabel('第 1 枚，4 点'), findsOneWidget);
    expect(find.bySemanticsLabel('第 2 枚，6 点'), findsOneWidget);
    expect(find.bySemanticsLabel('第 3 枚，1 点'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('wenyou-dice-subtotal')),
        matching: find.text('11'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('wenyou-dice-modifier')),
        matching: find.text('+2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('wenyou-dice-total')),
        matching: find.text('13'),
      ),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('wenyou-dice-detail-sheet'))).height,
      lessThanOrEqualTo(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            WenyouElementContract.diceDetailMaximumHeightFraction,
      ),
    );

    await tester.tap(find.byKey(const Key('wenyou-dice-detail-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('wenyou-dice-detail-sheet')), findsNothing);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('wenyou-dice-$nodeId')))
          .getSemanticsData()
          .flagsCollection
          .isExpanded
          .toBoolOrNull(),
      isFalse,
    );
  });

  testWidgets('混排和换行后的骰子与正文共享行高与文字基线', (tester) async {
    const secondNodeId = '550e8400-e29b-41d4-a716-446655440001';
    const secondDiceNode = '[[dice:v1:$secondNodeId:2d6+3]]';
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: RepaintBoundary(
            key: Key('markdown-inline-dice-visual'),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: WenyouMarkdown(
                data: '第一行文字 $diceNode 继续叙述\n第二行文字 $secondDiceNode 仍然同行',
                diceLabels: {nodeId: '1d20 = 16', secondNodeId: '2d6+3 = 11'},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final firstDice = find.byKey(const ValueKey('wenyou-dice-$nodeId'));
    final secondDice = find.byKey(const ValueKey('wenyou-dice-$secondNodeId'));
    expect(firstDice, findsOneWidget);
    expect(secondDice, findsOneWidget);
    expect(tester.getSize(firstDice).height, lessThanOrEqualTo(35));
    expect(tester.getSize(secondDice).height, lessThanOrEqualTo(35));
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('markdown-inline-dice-visual')),
      matchesGoldenFile('goldens/markdown_inline_dice_360.png'),
    );
  });

  testWidgets('骰子结果异步到达后更新内联标签', (tester) async {
    Widget app(Map<String, WenyouDiceRollDetail> details) => MaterialApp(
      home: Scaffold(
        body: WenyouMarkdown(data: diceNode, diceDetails: details),
      ),
    );

    await tester.pumpWidget(app(const {}));
    expect(find.text('1d20 = ?'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('wenyou-dice-$nodeId')))
          .getSemanticsData()
          .flagsCollection
          .isButton,
      isFalse,
    );
    await tester.tap(find.byKey(const ValueKey('wenyou-dice-$nodeId')));
    await tester.pump();
    expect(find.byKey(const Key('wenyou-dice-detail-sheet')), findsNothing);
    BoxDecoration decoration() =>
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byKey(const ValueKey('wenyou-dice-$nodeId')),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(decoration().color, WenyouFoundationPalette.warningSoft);
    expect(
      tester.widget<Text>(find.text('1d20 = ?')).style?.color,
      WenyouFoundationPalette.warning,
    );
    await tester.pumpWidget(
      app(const {
        nodeId: WenyouDiceRollDetail(results: [16], total: 16),
      }),
    );
    await tester.pump();

    expect(find.text('1d20 = ?'), findsNothing);
    expect(find.text('1d20 = 16'), findsOneWidget);
    expect(decoration().color, WenyouFoundationPalette.accent);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('wenyou-dice-$nodeId')))
          .getSemanticsData()
          .flagsCollection
          .isButton,
      isTrue,
    );
  });

  testWidgets('长骰池在八成视口内滚动并保留服务端顺序', (tester) async {
    const longNodeId = '550e8400-e29b-41d4-a716-446655440002';
    const longDiceNode = '[[dice:v1:$longNodeId:100d6-2]]';
    final results = List<int>.generate(100, (index) => index % 6 + 1);
    final subtotal = results.fold<int>(0, (sum, value) => sum + value);
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: longDiceNode,
            diceDetails: {
              longNodeId: WenyouDiceRollDetail(
                results: results,
                total: subtotal - 2,
              ),
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('wenyou-dice-$longNodeId')));
    await tester.pumpAndSettle();

    final sheet = find.byKey(const Key('wenyou-dice-detail-sheet'));
    expect(tester.getSize(sheet).height, lessThanOrEqualTo(640 * 0.8));
    expect(find.bySemanticsLabel('第 1 枚，1 点'), findsOneWidget);
    expect(find.bySemanticsLabel('第 100 枚，4 点'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('wenyou-dice-modifier')),
        matching: find.text('−2'),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('wenyou-dice-result-99')),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('wenyou-dice-result-99'))).top,
      lessThan(tester.getRect(sheet).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  test('骰子触发器语义不提前朗读逐骰结果', () {
    expect(
      formatWenyouDiceSemantics(
        notation: '2d6+3',
        results: const [4, 6],
        total: 13,
      ),
      '骰子 2d6+3，总计 13',
    );
  });

  testWidgets('Markdown v3 不支持的表格按可读原文展示', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WenyouMarkdown(data: '| 名称 | 数量 |\n| --- | --- |\n| 骰子 | 2 |'),
        ),
      ),
    );

    expect(find.byType(Table), findsNothing);
    expect(
      find.textContaining('| 名称 | 数量 |', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('| 骰子 | 2 |', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('代码与转义内容中的骰子表达式保持原文', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WenyouMarkdown(
            data:
                '''
$diceNode
`$diceNode`
\\$diceNode
```md
$diceNode
```
''',
            diceLabels: {nodeId: '1d20 = 16'},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('wenyou-dice-$nodeId')), findsOneWidget);
    expect(find.text('1d20 = 16'), findsOneWidget);
  });

  testWidgets('Markdown 站内坐标使用 Foundation 传送门且交给内部导航', (tester) async {
    Uri? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 180,
            child: WenyouMarkdown(
              data:
                  '参见 [很长但不能被截断的设定入口](/threads/cmsewdo0h000x7qv6aa77ll1v)，`[代码](/threads/cmsewdo0h000x7qv6aa77ll1v)`。',
              onInternalLink: (location) => opened = location,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final portal = find.byKey(const ValueKey('markdown-internal-reference-0'));
    expect(portal, findsOneWidget);
    expect(find.byType(WenyouInternalReferenceChip), findsOneWidget);
    expect(tester.getSize(portal).width, lessThanOrEqualTo(180));
    expect(tester.getSize(portal).height, greaterThanOrEqualTo(48));
    final icon = tester.widget<WenyouIcon>(
      find.descendant(of: portal, matching: find.byType(WenyouIcon)),
    );
    expect(icon.semanticId, WenyouIconIds.contentInternalReference);
    expect(find.textContaining('代码', findRichText: true), findsOneWidget);
    expect(
      find.textContaining(
        '/threads/cmsewdo0h000x7qv6aa77ll1v',
        findRichText: true,
      ),
      findsOneWidget,
    );

    await tester.tap(portal);
    expect(opened, Uri.parse('/threads/cmsewdo0h000x7qv6aa77ll1v'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('阅读态短传送门横向收缩并与前后文字自然混排', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 120);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: RepaintBoundary(
            key: Key('markdown-inline-portal-visual'),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: WenyouMarkdown(
                data: '前文 [入口](/threads/cmsewdo0h000x7qv6aa77ll1v) 后文仍在同一行',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final portal = find.byKey(const ValueKey('markdown-internal-reference-0'));
    expect(portal, findsOneWidget);
    expect(tester.getSize(portal).width, lessThan(100));
    expect(tester.getSize(portal).height, greaterThanOrEqualTo(48));
    expect(tester.getTopLeft(portal).dx, lessThan(120));
    final inlineParagraph = tester
        .renderObjectList<RenderParagraph>(find.byType(RichText))
        .singleWhere(
          (paragraph) =>
              paragraph.text.toPlainText().contains('前文') &&
              _widgetSpans(
                paragraph.text,
              ).any((span) => span.child is WenyouInternalReferenceChip),
        );
    final portalSpan = _widgetSpans(
      inlineParagraph.text,
    ).singleWhere((span) => span.child is WenyouInternalReferenceChip);
    expect(portalSpan.alignment, PlaceholderAlignment.baseline);
    expect(portalSpan.baseline, TextBaseline.alphabetic);
    expect(inlineParagraph.text.toPlainText(), contains('后文仍在同一行'));
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('markdown-inline-portal-visual')),
      matchesGoldenFile('goldens/markdown_inline_portal_360.png'),
    );
  });

  testWidgets('360dp 长文保持正文、标题、引用和分隔线的克制阅读层级', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: RepaintBoundary(
            key: Key('markdown-reading-visual'),
            child: ColoredBox(
              color: Color(0xFFFFFFFF),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: WenyouMarkdown(
                  data: '''
## 第一章 · 雨停以前

城门外的雨下了整整三天。她把最后一页信纸折好，沿着旧地图上褪色的河流继续向北。

文字应该让人安静地读下去，而不是被四周的按钮和装饰不断打断。

> “如果下一位旅人读到这里，请替我写完没有抵达的春天。”

### 接力提示

- 保留上一段留下的人物动机
- 从黎明前的钟声继续

---

远处终于传来第一声鸟鸣，故事仍在等待下一位作者。
''',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    final style = markdown.styleSheet!;
    expect(style.p?.fontSize, 17);
    expect(style.p?.height, 1.8);
    expect(style.p?.letterSpacing, closeTo(0.136, 0.001));
    expect(style.h2?.fontSize, closeTo(22.95, 0.001));
    expect(style.h3?.fontSize, closeTo(19.04, 0.001));
    expect(style.blockquote?.height, 1.8);
    expect(style.blockquote?.fontStyle, FontStyle.normal);
    expect(
      style.blockquotePadding,
      const EdgeInsets.symmetric(horizontal: 12.75, vertical: 8.5),
    );
    final quote = style.blockquoteDecoration! as BoxDecoration;
    expect(
      (quote.border! as BorderDirectional).start.width,
      WenyouElementContract.quoteMarkerWidth,
    );
    expect((quote.borderRadius! as BorderRadiusDirectional).topStart.x, 0);
    expect(
      (quote.borderRadius! as BorderRadiusDirectional).topEnd.x,
      WenyouFoundationMobile.radiusCompact,
    );
    final bodyDivider = find.byKey(const Key('wenyou-body-divider'));
    final dividerLine = find.byKey(const Key('wenyou-body-divider-line'));
    final dividerMarker = find.byKey(const Key('wenyou-body-divider-marker'));
    expect(bodyDivider, findsOneWidget);
    expect(
      tester.getSize(bodyDivider).width,
      closeTo(
        tester.getSize(find.byType(MarkdownBody)).width *
            WenyouElementContract.dividerInlineSizeFraction,
        0.01,
      ),
    );
    expect(
      tester.getSize(dividerLine).height,
      WenyouElementContract.dividerLineThickness,
    );
    expect(
      tester.getSize(dividerMarker),
      const Size.square(WenyouElementContract.dividerMarkerDiameter),
    );
    final line = tester.widget<ColoredBox>(
      find.descendant(of: dividerLine, matching: find.byType(ColoredBox)),
    );
    final marker = tester.widget<DecoratedBox>(
      find.descendant(of: dividerMarker, matching: find.byType(DecoratedBox)),
    );
    expect(line.color, WenyouFoundationPalette.border);
    expect(
      (marker.decoration as BoxDecoration).color,
      WenyouFoundationPalette.brandStrong,
    );
    expect(find.bySemanticsLabel('分隔线'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('markdown-reading-visual')),
      matchesGoldenFile('goldens/markdown_reading_360.png'),
    );
  });

  testWidgets('正文图片保持纯净并从原图页按需收藏表情', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    var saveCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '![雾港地图]($url)',
            onSaveImage: (uri) async {
              expect(uri.toString(), url);
              saveCalls += 1;
              return '已添加到表情收藏。';
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final image = find.byKey(const ValueKey('markdown-image-$url'));
    expect(image, findsOneWidget);
    expect(find.byTooltip('添加到表情收藏'), findsNothing);
    expect(find.byKey(const Key('content-image-actions')), findsNothing);
    expect(
      find.ancestor(of: image, matching: find.byType(Stack)),
      findsNothing,
    );

    await tester.tap(image);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(find.text('雾港地图'), findsOneWidget);
    expect(find.byKey(const Key('content-image-actions')), findsOneWidget);
    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    expect(find.text('添加到表情收藏'), findsOneWidget);

    await tester.tap(find.text('添加到表情收藏'));
    await tester.pumpAndSettle();

    expect(saveCalls, 1);
    expect(find.text('已添加到表情收藏。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('纯文本点击回调不吞图片自身交互', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    var textTapCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '点击正文\n\n![雾港地图]($url)',
            onTapText: () => textTapCalls += 1,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('点击正文', findRichText: true));
    await tester.pump();
    expect(textTapCalls, 1);

    await tester.tap(find.byKey(const ValueKey('markdown-image-$url')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(textTapCalls, 1);
  });

  testWidgets('纯文本点击回调不吞链接自身交互', (tester) async {
    var textTapCalls = 0;
    Uri? openedInternalLink;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '[打开主题](/threads/thread-2)',
            onTapText: () => textTapCalls += 1,
            onInternalLink: (uri) => openedInternalLink = uri,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('打开主题', findRichText: true));
    await tester.pump();
    expect(openedInternalLink?.toString(), '/threads/thread-2');
    expect(textTapCalls, 0);
  });

  testWidgets('游客正文图片仍可查看原图且没有收藏入口', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WenyouMarkdown(data: '![雾港地图]($url)')),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('markdown-image-$url')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(find.byKey(const Key('content-image-actions')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('正文图片语义只暴露查看原图且 320 至 600dp 无常驻操作', (tester) async {
    final semantics = tester.ensureSemantics();
    for (final width in const [320.0, 360.0, 400.0, 600.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 640);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouMarkdown(
              data: '![雾港地图](https://cdn.example.com/story-$width.png)',
              onSaveImage: (_) async => '已添加到表情收藏。',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('查看正文图片原图：雾港地图'), findsOneWidget);
      expect(find.byTooltip('添加到表情收藏'), findsNothing);
      expect(find.byTooltip('图片操作'), findsNothing);
      expect(tester.takeException(), isNull);
    }
    semantics.dispose();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  testWidgets('普通正文图片保持内容宽度左对齐且每张独占一行', (tester) async {
    const firstUrl = 'https://cdn.example.com/narrow-first.png';
    const secondUrl = 'https://cdn.example.com/narrow-second.png';
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final width in const [320.0, 360.0, 400.0, 600.0]) {
      tester.view.physicalSize = Size(width, 640);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: WenyouMarkdown(
                  data: '前文![窄图一]($firstUrl)![窄图二]($secondUrl)后文',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final firstRow = find.byKey(
        const ValueKey('markdown-block-image-row-$firstUrl'),
      );
      final secondRow = find.byKey(
        const ValueKey('markdown-block-image-row-$secondUrl'),
      );
      final before = find.text('前文', findRichText: true);
      final after = find.text('后文', findRichText: true);

      expect(firstRow, findsOneWidget);
      expect(secondRow, findsOneWidget);
      expect(tester.getSize(firstRow).width, closeTo(width - 40, 0.01));
      expect(tester.getSize(secondRow).width, closeTo(width - 40, 0.01));
      for (final row in [firstRow, secondRow]) {
        final slot = tester.widget<SizedBox>(row);
        expect(
          (slot.child! as Align).alignment,
          AlignmentDirectional.centerStart,
        );
      }
      expect(
        tester.getBottomLeft(before).dy,
        lessThanOrEqualTo(tester.getTopLeft(firstRow).dy),
      );
      expect(
        tester.getBottomLeft(firstRow).dy,
        lessThanOrEqualTo(tester.getTopLeft(secondRow).dy),
      );
      expect(
        tester.getBottomLeft(secondRow).dy,
        lessThanOrEqualTo(tester.getTopLeft(after).dy),
      );
      final images = tester
          .widgetList<WenyouCachedImage>(find.byType(WenyouCachedImage))
          .toList();
      expect(images, hasLength(2));
      for (final image in images) {
        expect(image.width, isNull);
        expect(image.fit, BoxFit.contain);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('正文内的收藏表情保持原子展示且不伪装成普通插图', (tester) async {
    const url = 'https://cdn.example.com/sticker.gif';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data: '前文![挥手]($url "wenyousite-sticker:asset-1")后文',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('markdown-image-$url')), findsNothing);
    expect(
      find.byKey(const ValueKey('markdown-block-image-row-$url')),
      findsNothing,
    );
    expect(find.byKey(const Key('content-image-viewer')), findsNothing);
    expect(find.bySemanticsLabel('挥手'), findsOneWidget);
    final stickerCenter = tester.getCenter(find.bySemanticsLabel('挥手'));
    expect(
      tester.getCenter(find.text('前文', findRichText: true)).dy,
      closeTo(stickerCenter.dy, 0.01),
    );
    expect(
      tester.getCenter(find.text('后文', findRichText: true)).dy,
      closeTo(stickerCenter.dy, 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Markdown v4 对齐标记按顶层块渲染且不进入可见正文', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data:
                '[wenyousite-align-v1-center]: #\n## 居中标题\n\n'
                '[wenyousite-align-v1-right]: #\n居右正文',
          ),
        ),
      ),
    );
    await tester.pump();

    final centered = tester.widget<MarkdownBody>(
      find.descendant(
        of: find.byKey(const ValueKey('wenyou-markdown-segment-0-center')),
        matching: find.byType(MarkdownBody),
      ),
    );
    final right = tester.widget<MarkdownBody>(
      find.descendant(
        of: find.byKey(const ValueKey('wenyou-markdown-segment-1-right')),
        matching: find.byType(MarkdownBody),
      ),
    );
    expect(centered.styleSheet!.h2Align, WrapAlignment.center);
    expect(right.styleSheet!.textAlign, WrapAlignment.end);
    expect(find.textContaining('wenyousite-align'), findsNothing);
    expect(find.text('居中标题', findRichText: true), findsOneWidget);
    expect(find.text('居右正文', findRichText: true), findsOneWidget);
  });
}

Iterable<WidgetSpan> _widgetSpans(InlineSpan root) sync* {
  if (root case WidgetSpan span) {
    yield span;
  }
  if (root case TextSpan(:final children?)) {
    for (final child in children) {
      yield* _widgetSpans(child);
    }
  }
}
