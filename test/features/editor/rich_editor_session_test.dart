import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  testWidgets('正文输入空闲后才编码 Markdown，显式 flush 会立即同步', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      codecDebounce: const Duration(milliseconds: 100),
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    session.controller.replaceText(
      0,
      0,
      '温油',
      const TextSelection.collapsed(offset: 2),
    );
    await tester.pump(const Duration(milliseconds: 99));
    expect(emitted, isEmpty);

    expect(session.flush(), isTrue);
    expect(emitted, ['温油']);
  });

  testWidgets('外部 revision 替换文档时不回写并按要求移动光标', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '旧正文',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    session.scheduleExternalMarkdown(
      markdown: '云端\n正文',
      revision: 2,
      selection: RichEditorSelectionPlacement.end,
    );
    await tester.pump();

    expect(session.controller.document.toPlainText(), '云端\n正文\n');
    expect(session.controller.selection.baseOffset, 5);
    expect(emitted, isEmpty);
    expect(session.isDirty, isFalse);
  });

  testWidgets('图片和表情插入统一处理选区并立即生成 Markdown', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '替换我',
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 3),
      ChangeSource.local,
    );

    session.insertBlockImage(url: 'https://cdn.example.com/image.png');
    expect(emitted.last, contains('![图片](https://cdn.example.com/image.png)'));
    expect(emitted.last, isNot(contains('替换我')));

    session.insertSticker(
      assetId: 'cm12345678901234567890',
      url: 'https://cdn.example.com/sticker.png',
    );
    expect(emitted.last, contains('wenyousite-sticker:v1:'));
  });
}
