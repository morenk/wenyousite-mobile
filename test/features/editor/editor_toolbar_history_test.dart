import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  for (final sticker in [false, true]) {
    testWidgets(sticker ? '等长表情替换完成后不恢复旧选区' : '工具栏分隔线 fallback 重做恢复最终选区', (
      tester,
    ) async {
      final session = RichEditorSession(
        initialMarkdown: '甲乙',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      controller.updateSelection(
        sticker
            ? const TextSelection(baseOffset: 0, extentOffset: 1)
            : const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouEditorToolbar(
              controller: controller,
              enabled: true,
              onSaveDraft: () async {},
              onInsertImage: () async {},
              onInsertSticker: (selection) async {
                session.insertSticker(
                  selection: selection,
                  assetId: 'cm1234567890123456789012',
                  url: 'https://cdn.example.com/sticker.webp',
                );
              },
              onSubmit: () {},
            ),
          ),
        ),
      );
      if (!sticker) {
        await tester.tap(find.byKey(const Key('editor-more')));
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.byKey(Key(sticker ? 'editor-sticker' : 'editor-horizontal-rule')),
      );
      await tester.pumpAndSettle();
      final expected = TextSelection.collapsed(offset: sticker ? 1 : 4);
      expect(controller.selection, expected);
      final document = controller.document.toDelta().toJson();
      controller.undo();
      controller.redo();
      expect(controller.document.toDelta().toJson(), document);
      expect(controller.selection, expected);
      await tester.pumpWidget(const SizedBox.shrink());
      await session.flush();
    });
  }
}
