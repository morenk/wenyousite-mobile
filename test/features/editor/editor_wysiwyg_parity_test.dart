import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_rich_text_style_spec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('编辑态和发布态消费同一正文视觉规格', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 1700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = _controller();
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);
    late WenyouRichTextStyleSpec spec;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            spec = WenyouRichTextStyleSpec.resolve(context);
            return Scaffold(
              body: _ParityBody(
                controller: controller,
                focusNode: focusNode,
                scrollController: scrollController,
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
    final editorStyles = editor.config.customStyles!;
    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    final readingStyles = markdown.styleSheet!;

    expect(editorStyles.paragraph?.style, spec.body);
    expect(readingStyles.p, spec.body);
    expect(editorStyles.h2?.style, spec.h2);
    expect(readingStyles.h2, spec.h2);
    expect(editorStyles.h3?.style, spec.h3);
    expect(readingStyles.h3, spec.h3);
    expect(editorStyles.bold, spec.strong);
    expect(readingStyles.strong, spec.strong);
    expect(editorStyles.link, spec.link);
    expect(readingStyles.a, spec.link);
    expect(editorStyles.quote?.style, spec.quote);
    expect(readingStyles.blockquote, spec.quote);
    expect(editorStyles.quote?.decoration, spec.quoteDecoration);
    expect(readingStyles.blockquoteDecoration, spec.quoteDecoration);
    expect(readingStyles.listBullet, spec.listMarker);
    expect(
      readingStyles.horizontalRuleDecoration,
      spec.horizontalRuleDecoration,
    );
    for (final bullet in tester.widgetList<QuillBulletPoint>(
      find.byType(QuillBulletPoint),
    )) {
      expect(bullet.style.color, spec.listMarker.color);
    }
    for (final number in tester.widgetList<QuillNumberPoint>(
      find.byType(QuillNumberPoint),
    )) {
      expect(number.style.color, spec.listMarker.color);
    }
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      _wysiwygMarkdown,
    );
    expect(tester.takeException(), isNull);
  });

  for (final scenario in const [
    (name: '360_light', width: 360.0, height: 1700.0, dark: false, scale: 1.0),
    (name: '360_dark', width: 360.0, height: 1700.0, dark: true, scale: 1.0),
    (name: '600_light', width: 600.0, height: 1500.0, dark: false, scale: 1.0),
    (
      name: '360_text_2x',
      width: 360.0,
      height: 2900.0,
      dark: false,
      scale: 2.0,
    ),
  ]) {
    testWidgets('${scenario.name} 编辑态与发布态配对视觉基线', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(scenario.width, scenario.height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final controller = _controller();
      final focusNode = FocusNode();
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      addTearDown(scrollController.dispose);
      final theme = scenario.dark ? AppTheme.dark : AppTheme.light;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scenario.scale)),
              child: Scaffold(
                body: RepaintBoundary(
                  key: const Key('editor-reading-parity-visual'),
                  child: ColoredBox(
                    color: theme.scaffoldBackgroundColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: _ParityBody(
                        controller: controller,
                        focusNode: focusNode,
                        scrollController: scrollController,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('editor-reading-parity-visual')),
        matchesGoldenFile('goldens/editor_wysiwyg_${scenario.name}.png'),
      );
    });
  }
}

class _ParityBody extends StatelessWidget {
  const _ParityBody({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('编辑态', style: labelStyle),
        const SizedBox(height: 8),
        QuillEditor(
          controller: controller,
          focusNode: focusNode,
          scrollController: scrollController,
          config: QuillEditorConfig(
            scrollable: false,
            padding: EdgeInsets.zero,
            customStyles: wenyouEditorTextStyles(context),
            // Flutter Quill 尚未稳定开放自定义块前导渲染入口。
            // ignore: experimental_member_use
            customLeadingBlockBuilder: wenyouEditorLeadingBlockBuilder(context),
            embedBuilders: wenyouEditorEmbedBuilders(),
          ),
        ),
        const SizedBox(height: 24),
        Text('发布态', style: labelStyle),
        const SizedBox(height: 8),
        const WenyouMarkdown(
          data: _wysiwygMarkdown,
          enablePlainTextFastPath: false,
        ),
      ],
    );
  }
}

QuillController _controller() => QuillController(
  document: Document.fromDelta(
    MarkdownDeltaCodec.decode(_wysiwygMarkdown).delta,
  ),
  selection: const TextSelection.collapsed(offset: 0),
);

const _wysiwygMarkdown = '''## 二级标题

正文包含 **粗体**、*斜体*、~~删除线~~、[安全链接](https://wenyou.site/help) 和 `inline_code`。

> 引用里也有 **重点内容**。

### 三级标题

- 无序项目
  - 二级项目
    - 三级项目
- [@旅人](/users/user-one) 与 [入口](/threads/cmsewdo0h000x7qv6aa77ll1v)

1. 有序项目
2. [[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]

---

分隔线后的普通正文。''';
