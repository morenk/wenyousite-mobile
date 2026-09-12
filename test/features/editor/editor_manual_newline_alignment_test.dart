import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
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
  final cases = fixture['editCases']! as List;

  test('使用已交接的 newline v1 revision 2 全部真实输入', () {
    expect(fixture['version'], 1);
    expect(fixture['revision'], 2);
    expect(cases, hasLength(27));
  });

  for (final raw in cases) {
    final item = raw as Map<String, Object?>;
    testWidgets('手动换行 ${item['id']} 的保存、方向、续写和重开', (tester) async {
      final operation = item['operation']! as Map<String, Object?>;
      final session = RichEditorSession(
        initialMarkdown: item['markdown']! as String,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final anchor = operation['anchor']! as String;
      final anchorOffset = session.controller.document.toPlainText().indexOf(
        anchor,
      );
      expect(anchorOffset, greaterThanOrEqualTo(0));
      final offset = anchorOffset + (operation['offset']! as int);
      final count = operation['enterCount']! as int;
      session.controller.updateSelection(
        TextSelection.collapsed(offset: offset),
        ChangeSource.local,
      );
      for (var index = 0; index < count; index++) {
        session.controller.replaceText(
          offset + index,
          0,
          '\n',
          TextSelection.collapsed(offset: offset + index + 1),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(
          session.controller.selection,
          TextSelection.collapsed(offset: offset + index + 1),
        );
      }

      final expectedText = (item['lines']! as List).cast<String>().join('\n');
      final expectedDirections = (item['lineAlignments']! as List)
          .cast<String>();
      expect(session.controller.document.toPlainText(), '$expectedText\n');
      expect(
        _directions(session.controller.document.toDelta()),
        expectedDirections,
      );
      expect(await session.flush(), isTrue);
      final saved = MarkdownDeltaCodec.encode(
        session.controller.document.toDelta(),
      );
      expect(saved, item['serialized']);
      final reopened = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(reopened.controller.document.toPlainText(), '$expectedText\n');
      expect(
        _directions(reopened.controller.document.toDelta()),
        expectedDirections,
      );

      final continuation = offset + count;
      reopened.controller.updateSelection(
        TextSelection.collapsed(offset: continuation),
        ChangeSource.local,
      );
      reopened.controller.replaceText(
        continuation,
        0,
        '续',
        TextSelection.collapsed(offset: continuation + 1),
      );
      await tester.pump(const Duration(milliseconds: 150));
      final continuedText =
          '${expectedText.substring(0, continuation)}续${expectedText.substring(continuation)}';
      expect(reopened.controller.document.toPlainText(), '$continuedText\n');
      expect(
        _directions(reopened.controller.document.toDelta()),
        expectedDirections,
      );
      expect(await reopened.flush(), isTrue);
      final continued = MarkdownDeltaCodec.decode(
        MarkdownDeltaCodec.encode(reopened.controller.document.toDelta()),
      );
      expect(
        Document.fromDelta(continued.delta).toPlainText(),
        '$continuedText\n',
      );
      expect(_directions(continued.delta), expectedDirections);
    });
  }
}

List<String> _directions(Delta delta) => [
  for (final operation in delta.operations)
    if (operation.data case final String value)
      for (final character in value.codeUnits)
        if (character == 10)
          operation.attributes?['align'] as String? ?? 'left',
];
