import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

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
    for (final element in dice.evaluate()) {
      final finder = find.byElementPredicate(
        (candidate) => candidate == element,
      );
      expect(tester.getSize(finder).height, lessThanOrEqualTo(32));
    }
    expect(find.byIcon(Icons.casino_rounded), findsNothing);
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), source);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('editor-inline-dice-visual')),
      matchesGoldenFile('goldens/editor_inline_dice_360.png'),
    );
  });
}
