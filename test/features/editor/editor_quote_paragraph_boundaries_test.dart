import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  for (final sample in [
    (source: '> 甲\n>\n> 乙\n>\n>\n> 丙', text: '甲\n乙\n丙\n'),
    (source: '> 甲\n> 乙\n>\n> 丙', text: '甲\n乙\n丙\n'),
  ]) {
    test('引用内部软换行与段落分隔分别保留：${sample.source}', () {
      final document = Document.fromDelta(
        MarkdownDeltaCodec.decode(sample.source).delta,
      );
      addTearDown(document.close);
      expect(document.toPlainText(), sample.text);
      final encoded = MarkdownDeltaCodec.encode(document.toDelta());
      expect(encoded, sample.source);
      expect(md.markdownToHtml(encoded), md.markdownToHtml(sample.source));
    });
  }

  testWidgets('引用段内回车不复制段落边界，退格合并后不残留边界', (tester) async {
    const source = '> 甲乙\n>\n> 丙丁';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.replaceText(
      1,
      0,
      '\n',
      const TextSelection.collapsed(offset: 2),
    );
    expect(await session.flush(), isTrue);
    expect(emitted.last, '> 甲\n> 乙\n>\n> 丙丁');
    controller.replaceText(1, 1, '', const TextSelection.collapsed(offset: 1));
    expect(await session.flush(), isTrue);
    expect(emitted.last, source);
    controller.replaceText(2, 1, '', const TextSelection.collapsed(offset: 2));
    expect(await session.flush(), isTrue);
    expect(emitted.last, '> 甲乙丙丁');
    expect(controller.document.toPlainText(), '甲乙丙丁\n');
  });

  testWidgets('引用段尾回车并输入后保留原有下一段边界', (tester) async {
    const source = '> 甲\n>\n> 乙';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.replaceText(
      1,
      0,
      '\n',
      const TextSelection.collapsed(offset: 2),
    );
    expect(await session.flush(), isTrue);
    controller.replaceText(2, 0, '丙', const TextSelection.collapsed(offset: 3));
    expect(await session.flush(), isTrue);
    final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
    expect(saved, '> 甲\n> 丙\n>\n> 乙');
    session.applyExternalMarkdown(saved);
    expect(controller.document.toPlainText(), '甲\n丙\n乙\n');
    expect(await session.flush(), isTrue);
  });

  testWidgets('取消引用或改为标题后不残留引用分隔', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '> 甲\n>\n> 乙',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
    WenyouEditorFormatPolicy.applyHeading(controller, 2);
    expect(await session.flush(), isTrue);
    expect(emitted.last, '## 甲\n> 乙');
    controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    WenyouEditorFormatPolicy.toggle(controller, Attribute.blockQuote);
    expect(await session.flush(), isTrue);
    expect(emitted.last, '## 甲\n乙');
  });

  testWidgets('引用内回车的撤销和重做同时恢复段落边界', (tester) async {
    const source = '> 甲乙\n>\n> 丙丁';
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    final before = controller.document.toDelta().toJson();
    controller.replaceText(
      1,
      0,
      '\n',
      const TextSelection.collapsed(offset: 2),
    );
    await tester.pump();
    expect(await session.flush(), isTrue);
    controller.undo();
    await tester.pump();
    expect(controller.document.toDelta().toJson(), before);
    expect(await session.flush(), isTrue);
    controller.redo();
    await tester.pump();
    expect(await session.flush(), isTrue);
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '> 甲\n> 乙\n>\n> 丙丁',
    );
  });
}
