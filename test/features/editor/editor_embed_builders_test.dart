import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

import '../../support/foundation_icon_finder.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('编辑态传送门复用 Foundation 表面且保持不可导航原子节点', (tester) async {
    const source =
        '[楼层动态](/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd)';
    final controller = QuillController(
      document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final portal = find.byKey(const Key('editor-internal-reference'));
    expect(portal, findsOneWidget);
    expect(find.text('楼层动态'), findsOneWidget);
    final semantics = tester.getSemantics(portal).getSemanticsData();
    expect(semantics.label, '站内传送门：楼层动态');
    expect(semantics.flagsCollection.isLink, isFalse);
    expect(
      findFoundationIcon(WenyouIconIds.contentInternalReference),
      findsOneWidget,
    );
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), source);
    expect(tester.takeException(), isNull);
  });

  testWidgets('编辑态提及保持透明无图标的原子文字', (tester) async {
    const source = '你好 [@张三](/users/user-zhang) 与 @全体玩家';
    final controller = QuillController(
      document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final mentions = find.byKey(const Key('editor-mention'));
    expect(mentions, findsNWidgets(2));
    expect(find.text('@张三'), findsOneWidget);
    expect(find.text('@全体玩家'), findsOneWidget);
    expect(findFoundationIcon(WenyouIconIds.actionMention), findsNothing);
    for (final text in tester.widgetList<Text>(
      find.descendant(of: mentions, matching: find.byType(Text)),
    )) {
      expect(text.style?.color, WenyouFoundationPalette.brandStrong);
      expect(text.style?.fontWeight, FontWeight.w600);
      expect(text.style?.backgroundColor, Colors.transparent);
    }
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), source);
    expect(tester.takeException(), isNull);
  });

  testWidgets('光标在独占图片行时切换对齐会立即更新编辑画布', (tester) async {
    const url = 'https://cdn.example.com/image.webp';
    final controller = QuillController(
      document: Document.fromDelta(
        MarkdownDeltaCodec.decode('![图片]($url)').delta,
      ),
      selection: const TextSelection.collapsed(offset: 1),
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: QuillEditor(
              controller: controller,
              focusNode: focusNode,
              scrollController: scrollController,
              config: QuillEditorConfig(
                scrollable: false,
                embedBuilders: wenyouEditorEmbedBuilders(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final image = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == '正文图片',
    );
    final semantics = tester.widget<Semantics>(image).properties;
    expect(semantics.image, isTrue);
    expect(semantics.button, isNot(isTrue));
    await tester.tapAt(tester.getTopLeft(image) + const Offset(8, 8));
    await tester.pump();
    expect(controller.selection.extentOffset, 0);
    final imageLineFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains('\uFFFC'),
    );
    RichText imageLine() => tester.widget<RichText>(imageLineFinder);

    expect(imageLine().textAlign, TextAlign.start);
    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.center,
      imageAlignment: true,
    );
    await tester.pump();
    expect(imageLine().textAlign, TextAlign.center);

    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.right,
      imageAlignment: true,
    );
    await tester.pump();
    expect(imageLine().textAlign, TextAlign.end);
    expect(
      MarkdownDeltaCodec.encode(
        controller.document.toDelta(),
        imageAlignment: true,
      ),
      '[wenyousite-align-v1-right]: #\n![图片]($url)',
    );
  });

  testWidgets('编辑态分隔线使用 Foundation 居中短线与圆点', (tester) async {
    const source = '上文\n\n---\n\n下文';
    final controller = QuillController(
      document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final divider = find.byKey(const Key('wenyou-body-divider'));
    final line = find.byKey(const Key('wenyou-body-divider-line'));
    final marker = find.byKey(const Key('wenyou-body-divider-marker'));
    expect(divider, findsOneWidget);
    expect(
      tester.getSize(line).height,
      WenyouElementContract.dividerLineThickness,
    );
    expect(
      tester.getSize(marker),
      const Size.square(WenyouElementContract.dividerMarkerDiameter),
    );
    final lineSurface = tester.widget<ColoredBox>(
      find.descendant(of: line, matching: find.byType(ColoredBox)),
    );
    final markerSurface = tester.widget<DecoratedBox>(
      find.descendant(of: marker, matching: find.byType(DecoratedBox)),
    );
    expect(lineSurface.color, WenyouFoundationPalette.border);
    expect(
      (markerSurface.decoration as BoxDecoration).color,
      WenyouFoundationPalette.brandStrong,
    );
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), source);
    expect(tester.takeException(), isNull);
  });

  testWidgets('编辑态传送门与前后文字保持同行基线', (tester) async {
    const source = '前文 [入口](/threads/cmsewdo0h000x7qv6aa77ll1v) 后文仍在同一行';
    final controller = QuillController(
      document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 120);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('editor-inline-portal-visual'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QuillEditor(
                controller: controller,
                focusNode: focusNode,
                scrollController: scrollController,
                config: QuillEditorConfig(
                  scrollable: false,
                  embedBuilders: wenyouEditorEmbedBuilders(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final portal = find.byKey(const Key('editor-internal-reference'));
    expect(portal, findsOneWidget);
    expect(tester.getSize(portal).width, lessThan(100));
    expect(tester.getSize(portal).height, lessThanOrEqualTo(32));
    expect(tester.getTopLeft(portal).dx, lessThan(120));
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('editor-inline-portal-visual')),
      matchesGoldenFile('goldens/editor_inline_portal_360.png'),
    );
  });

  testWidgets('Quill 混排和换行后的骰子保持正文基线原子节点', (tester) async {
    const firstId = '550e8400-e29b-41d4-a716-446655440000';
    const secondId = '550e8400-e29b-41d4-a716-446655440001';
    const source =
        '第一行文字 [[dice:v1:$firstId:1d20]] 继续叙述\n'
        '第二行文字 [[dice:v1:$secondId:2d6+3]] 仍然同行';
    final controller = QuillController(
      document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    addTearDown(controller.dispose);
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    late BuildContext editorContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('editor-inline-dice-visual'),
            child: Builder(
              builder: (context) {
                editorContext = context;
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: QuillEditor(
                    controller: controller,
                    focusNode: focusNode,
                    scrollController: scrollController,
                    config: QuillEditorConfig(
                      scrollable: false,
                      customStyles: wenyouEditorTextStyles(editorContext),
                      embedBuilders: wenyouEditorEmbedBuilders(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final dice = find.byKey(const Key('editor-dice-inline'));
    expect(dice, findsNWidgets(2));
    expect(find.text('1d20 = ?'), findsOneWidget);
    expect(find.text('2d6+3 = ?'), findsOneWidget);
    for (final element in dice.evaluate()) {
      final finder = find.byElementPredicate(
        (candidate) => candidate == element,
      );
      expect(tester.getSize(finder).height, lessThanOrEqualTo(35));
      final surface = tester.widget<DecoratedBox>(
        find.descendant(of: finder, matching: find.byType(DecoratedBox)),
      );
      final decoration = surface.decoration as BoxDecoration;
      expect(decoration.color, WenyouFoundationPalette.warningSoft);
      expect(
        (decoration.borderRadius! as BorderRadius).topLeft.x,
        closeTo(5.1, 0.001),
      );
    }
    expect(
      tester.widget<Text>(find.text('1d20 = ?')).style?.color,
      WenyouFoundationPalette.warning,
    );
    expect(findFoundationIcon(WenyouIconIds.editorDice), findsNothing);
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), source);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('editor-inline-dice-visual')),
      matchesGoldenFile('goldens/editor_inline_dice_360.png'),
    );
  });
}
