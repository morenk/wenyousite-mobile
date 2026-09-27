import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/local_image_marker.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_submission_guard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

const _first = UploadedEditorImage(
  mediaId: 'ready-first',
  url: 'https://cdn.example.com/first.webp',
);
const _second = UploadedEditorImage(
  mediaId: 'ready-second',
  url: 'https://cdn.example.com/second.webp',
);

void main() {
  testWidgets('待完成正文图片可以继续输入，乱序完成保持插入顺序与选区', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '开头',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    session.insertLocalImage('first');
    session.insertLocalImage('second');
    final insertion = session.controller.selection.extentOffset;
    session.controller.replaceText(
      insertion,
      0,
      '继续输入',
      TextSelection.collapsed(offset: insertion + 4),
    );
    await session.flush();
    expect(session.controller.readOnly, isFalse);
    expect(session.localMarkdown, contains('继续输入'));
    expect(emitted, isEmpty);
    const selection = TextSelection(baseOffset: 0, extentOffset: 2);
    session.controller.updateSelection(selection, ChangeSource.local);

    session.resolveLocalImage('second', _second);
    await session.flush();
    expect(session.localImageIds, {'first'});
    expect(session.controller.selection, selection);
    expect(emitted, isEmpty);
    session.resolveLocalImage('first', _first);
    expect(await session.flush(), isTrue);
    expect(session.controller.selection, selection);
    expect(session.localImageIds, isEmpty);
    expect(emitted.last, contains('继续输入'));
    expect(
      emitted.last.indexOf(_first.url),
      lessThan(emitted.last.indexOf(_second.url)),
    );
    expect(emitted.last, isNot(contains(localImageMarkerPrefix)));
    expect(
      () => MarkdownSubmissionGuard.validate(emitted.last),
      returnsNormally,
    );
  });

  testWidgets('仅图片的正文在完成前不通知业务控制器，完成后得到可发布正文', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.insertLocalImage('first');
    expect(await session.flush(), isTrue);
    expect(session.localImageIds, {'first'});
    expect(emitted, isEmpty);
    expect(
      () => MarkdownSubmissionGuard.validate(session.localMarkdown),
      throwsException,
    );

    session.resolveLocalImage('first', _first);
    expect(await session.flush(), isTrue);
    // 独立图片下方保留可继续输入的空段；该段沿用既有 Markdown 空行语义。
    expect(emitted.single, contains('![图片](${_first.url})'));
    expect(emitted.single, isNot(contains(localImageMarkerPrefix)));
    expect(
      () => MarkdownSubmissionGuard.validate(emitted.single),
      returnsNormally,
    );
    expect(session.codecFailure, isNull);
  });

  testWidgets('用户移除图片后，迟到完成不能重新插入图片或改动正文', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '保留文字',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    session.insertLocalImage('removed');
    await session.flush();
    session.removeLocalImage('removed');
    await session.flush();
    final before = session.controller.document.toDelta().toJson();
    final selection = session.controller.selection;
    session.resolveLocalImage('removed', _first);
    await session.flush();
    expect(session.controller.document.toDelta().toJson(), before);
    expect(session.controller.selection, selection);
    expect(session.localMarkdown, contains('保留文字'));
    expect(session.localMarkdown, isNot(contains(_first.url)));
    expect(session.localImageIds, isEmpty);
  });

  testWidgets('移除待完成图片可撤销和重做，恢复的节点仍使用原稳定标识', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '正文',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    session.insertLocalImage('undoable');
    await session.flush();
    session.controller.document.history.clear();
    final before = session.controller.document.toDelta().toJson();
    session.removeLocalImage('undoable');
    await session.flush();
    expect(session.localImageIds, isEmpty);
    expect(session.controller.hasUndo, isTrue);
    session.controller.undo();
    await session.flush();
    expect(session.controller.document.toDelta().toJson(), before);
    expect(session.localImageIds, {'undoable'});
    session.controller.redo();
    await session.flush();
    expect(session.localImageIds, isEmpty);
  });

  for (final cut in [false, true]) {
    testWidgets('${cut ? '剪切' : '复制'}混合正文不会向系统剪贴板写入本机占位', (tester) async {
      final writes = <String>[];
      final session = RichEditorSession(
        initialMarkdown: '正文',
        clipboardStore: WenyouEditorClipboardStore(),
        onMarkdownChanged: (_) {},
        writeClipboardText: (text) async => writes.add(text),
      );
      addTearDown(session.dispose);
      session.insertLocalImage('private-attachment');
      await session.flush();
      session.controller.updateSelection(
        TextSelection(
          baseOffset: 0,
          extentOffset: session.controller.document.length - 1,
        ),
        ChangeSource.local,
      );
      expect(await session.copySelection(cut: cut), isTrue);
      expect(writes.single, contains('正文'));
      expect(writes.single, isNot(contains(localImageMarkerPrefix)));
      expect(writes.single, isNot(contains('private-attachment')));
      if (cut) expect(session.localImageIds, isEmpty);
    });
  }

  testWidgets('待完成图片不能绕过其他非法链接的最终保存校验', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '链接',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    session.insertLocalImage('first');
    session.controller.formatText(
      0,
      2,
      Attribute.fromKeyValue('link', 'javascript:alert(1)'),
    );
    await session.flush();
    expect(emitted, isEmpty);
    session.resolveLocalImage('first', _first);
    expect(await session.flush(), isFalse);
    expect(emitted, isEmpty);
    expect(session.codecFailure, isNotNull);
    await tester.pump(const Duration(milliseconds: 250));
  });
}
