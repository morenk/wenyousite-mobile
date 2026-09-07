import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-editor-newline-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final value in fixture['cases']! as List) {
    final item = value as Map<String, Object?>;
    testWidgets('共享换行 ${item['id']} 打开、保存、重开可见行不变', (tester) async {
      final source = item['markdown']! as String;
      final expectedLines = (item['lines']! as List).cast<String>();
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);

      expect(MarkdownContent.unsupportedLineIndexes(source), isEmpty);
      expect(
        session.controller.document.toPlainText(),
        '${expectedLines.join('\n')}\n',
      );
      expect(await session.flush(), isTrue);
      final saved = MarkdownDeltaCodec.encode(
        session.controller.document.toDelta(),
      );
      expect(saved, source);
      final reopened = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(
        reopened.controller.document.toPlainText(),
        '${expectedLines.join('\n')}\n',
      );
    });
  }

  for (final quote in [false, true]) {
    for (final breaks in [1, 2, 3]) {
      for (final offset in [0, 1, 2]) {
        testWidgets('${quote ? '引用' : '正文'} 第 $offset 字处连续 $breaks 次回车', (
          tester,
        ) async {
          final session = RichEditorSession(
            initialMarkdown: quote ? '> 甲乙' : '甲乙',
            onMarkdownChanged: (_) {},
          );
          addTearDown(session.dispose);
          for (var index = 0; index < breaks; index++) {
            session.controller.replaceText(
              offset + index,
              0,
              '\n',
              TextSelection.collapsed(offset: offset + index + 1),
            );
            await tester.pump();
          }
          final expectedText =
              '甲乙'.substring(0, offset) +
              '\n' * breaks +
              '甲乙'.substring(offset);
          expect(session.controller.document.toPlainText(), '$expectedText\n');
          final expected = expectedText
              .split('\n')
              .map(
                (line) =>
                    '${quote ? '> ' : ''}${line.isEmpty ? '<br />' : line}',
              )
              .join('\n');
          expect(await session.flush(), isTrue);
          expect(
            MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
            expected,
          );
          final reopened = RichEditorSession(
            initialMarkdown: expected,
            onMarkdownChanged: (_) {},
          );
          addTearDown(reopened.dispose);
          expect(reopened.controller.document.toPlainText(), '$expectedText\n');
        });
      }
    }
  }

  for (final source in ['## 甲', '### 甲', '- 甲', '1. 甲']) {
    testWidgets('$source 行末回车保持标题和列表常规操作', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final baseline = QuillController(
        document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
        selection: const TextSelection.collapsed(offset: 1),
      );
      addTearDown(baseline.dispose);
      session.controller.replaceText(
        1,
        0,
        '\n',
        const TextSelection.collapsed(offset: 2),
      );
      await tester.pump();
      baseline.replaceText(
        1,
        0,
        '\n',
        const TextSelection.collapsed(offset: 2),
      );
      final style = session.controller.document.collectStyle(2, 0).attributes;
      expect(style['header'], isNull);
      expect(
        style['list']?.value,
        source.startsWith('-')
            ? 'bullet'
            : source.startsWith('1.')
            ? 'ordered'
            : null,
      );
      if (!source.startsWith('#')) {
        session.controller.replaceText(
          2,
          0,
          '\n',
          const TextSelection.collapsed(offset: 3),
        );
        await tester.pump();
        baseline.replaceText(
          2,
          0,
          '\n',
          const TextSelection.collapsed(offset: 3),
        );
        expect(
          session.controller.document.toPlainText(),
          baseline.document.toPlainText(),
        );
        expect(
          session.controller.document
              .collectStyle(2, 0)
              .attributes['list']
              ?.value,
          baseline.document.collectStyle(2, 0).attributes['list']?.value,
        );
      }
      await session.flush();
    });
  }

  for (final prefix in ['', '> ']) {
    testWidgets('${prefix.isEmpty ? '正文' : '引用'} 回车后继续输入保留粗体', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '$prefix**甲**',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      session.controller.replaceText(
        1,
        0,
        '\n',
        const TextSelection.collapsed(offset: 2),
      );
      session.controller.replaceText(
        2,
        0,
        '乙',
        const TextSelection.collapsed(offset: 3),
      );
      await tester.pump();
      expect(
        session.controller.document
            .collectStyle(2, 1)
            .attributes['bold']
            ?.value,
        isTrue,
      );
      expect(await session.flush(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        '$prefix**甲**\n$prefix**乙**',
      );
    });
  }
}
