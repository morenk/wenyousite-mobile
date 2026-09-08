import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  for (final level in [2, 3]) {
    testWidgets('空 H$level 回车保留原 Quill 退出标题行为', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      WenyouEditorFormatPolicy.applyHeading(session.controller, level);
      final baseline = QuillController(
        document: Document.fromDelta(session.controller.document.toDelta()),
        selection: const TextSelection.collapsed(offset: 0),
      );
      addTearDown(baseline.dispose);
      baseline.replaceText(
        0,
        0,
        '\n',
        const TextSelection.collapsed(offset: 1),
      );
      session.controller.replaceText(
        0,
        0,
        '\n',
        const TextSelection.collapsed(offset: 1),
      );
      await tester.pump();
      expect(
        session.controller.document.toPlainText(),
        baseline.document.toPlainText(),
      );
      expect(
        session.controller.getSelectionStyle().attributes['header']?.value,
        isNull,
      );
      expect(await session.flush(), isTrue);
    });

    testWidgets('空正文通过工具栏选择 H$level 后可保存、续写及重开', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: QuillEditor.basic(controller: session.controller),
                ),
                WenyouEditorToolbar(
                  controller: session.controller,
                  editorFocusNode: session.focusNode,
                  enabled: true,
                  onInsertImage: () async {},
                  onInsertSticker: (_) async {},
                  onSaveDraft: () async {},
                  onSubmit: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('editor-heading')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('H$level'));
      await tester.pumpAndSettle();

      expect(session.codecFailure, isNull);
      expect(await session.flush(), isTrue);
      expect(session.controller.document.toPlainText(), '\n');
      expect(
        session.controller.getSelectionStyle().attributes['header']?.value,
        level,
      );
      final emptyMarkdown = MarkdownDeltaCodec.encode(
        session.controller.document.toDelta(),
      );
      final reading = md.Document().parseLines(emptyMarkdown.split('\n'));
      expect((reading.single as md.Element).tag, 'h$level');
      expect(reading.single.textContent, isEmpty);
      final reopened = RichEditorSession(
        initialMarkdown: emptyMarkdown,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(reopened.controller.document.toPlainText(), '\n');
      expect(
        reopened.controller.getSelectionStyle().attributes['header']?.value,
        level,
      );

      session.controller.replaceText(
        0,
        0,
        '标题',
        const TextSelection.collapsed(offset: 2),
      );
      await tester.pumpAndSettle();
      expect(await session.flush(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        '${'#' * level} 标题',
      );
      final saved = RichEditorSession(
        initialMarkdown: '${'#' * level} 标题',
        onMarkdownChanged: (_) {},
      );
      addTearDown(saved.dispose);
      expect(saved.controller.document.toPlainText(), '标题\n');
      expect(
        saved.controller.getSelectionStyle().attributes['header']?.value,
        level,
      );
    });

    testWidgets('H$level 删除全部文字后保留空标题，再切回正文不报错', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '${'#' * level} 标题',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      session.controller.replaceText(
        0,
        2,
        '',
        const TextSelection.collapsed(offset: 0),
      );
      await tester.pump();
      expect(await session.flush(), isTrue);
      expect(session.controller.document.toPlainText(), '\n');
      expect(
        session.controller.getSelectionStyle().attributes['header']?.value,
        level,
      );
      WenyouEditorFormatPolicy.applyHeading(session.controller, 0);
      expect(await session.flush(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        '',
      );
    });

    for (final suffix in ['', ' ', '\t']) {
      test('H$level 空标题 ${suffix.codeUnits} 与独立 Markdown 阅读结构一致', () {
        final source = '${'#' * level}$suffix';
        final reader = md.Document().parseLines([source]).single as md.Element;
        expect(reader.tag, 'h$level');
        expect(reader.textContent, isEmpty);
        final decoded = MarkdownDeltaCodec.decode(source);
        expect(
          decoded.delta.toJson(),
          contains(containsPair('attributes', containsPair('header', level))),
        );
        expect(
          decoded.editorDocument.blocks.single,
          isA<MarkdownHeadingBlock>(),
        );
        expect(
          (decoded.editorDocument.blocks.single as MarkdownHeadingBlock)
              .content,
          isEmpty,
        );
      });
    }
  }
}
