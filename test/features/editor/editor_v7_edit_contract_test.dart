import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

const _marks = ['bold', 'italic', 'strike', 'link', 'code'];

void main() {
  final contract =
      jsonDecode(
            File(
              'contracts/markdown-editor-roundtrip-v7-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final cases = (contract['editCases'] as List).cast<Map<String, dynamic>>();
  final insertTexts = (contract['inlineInsertTexts'] as List).cast<String>();

  test('完整消费 v7 的 48 条真实编辑和五类中间输入', () {
    expect(contract['version'], 7);
    expect(cases, hasLength(48));
    expect(insertTexts, hasLength(5));
  });

  for (final fixture in cases) {
    final operation = fixture['operation'] as Map<String, dynamic>;
    test('${fixture['id']} 输入、样式、重开与删除恢复', () {
      _exercise(fixture);
    });
    if (operation['offset'] == 1) {
      for (var index = 0; index < insertTexts.length; index++) {
        test('${fixture['id']} 特殊输入 $index', () {
          _exercise(fixture, insertedText: insertTexts[index]);
        });
      }
    }
  }

  for (final (prefix, suffix) in const [
    ('> ', '\n> **后续**'),
    ('', '\n下一行'),
    ('<br />\n[wenyousite-align-v1-center]: #\n## ', '\n<br />\n后文'),
    (
      '',
      '\n<br />\n[wenyousite-align-v1-right]: #\n'
          '![图片](https://cdn.example.com/image.webp)\n<br />',
    ),
  ]) {
    test('真实输入保留引用、软换行或相邻对齐块：$prefix$suffix', () {
      for (final text in insertTexts) {
        final source = '$prefix**甲乙**$suffix';
        final controller = _controller(source);
        try {
          final before = _semanticUnits(controller.document.toDelta());
          final offset = controller.document.toPlainText().indexOf('甲乙') + 1;
          _insert(controller, offset, text, const {'bold': true});
          final expected = [...before]
            ..insertAll(offset, [
              for (final unit in text.codeUnits)
                {
                  'text': unit,
                  'marks': const {'bold': true},
                },
            ]);
          final encoded = MarkdownDeltaCodec.encode(
            controller.document.toDelta(),
            imageAlignment: true,
          );
          final reopened = MarkdownDeltaCodec.decode(
            encoded,
            imageAlignment: true,
          ).delta;
          expect(_semanticUnits(reopened), expected);
          expect(
            MarkdownDeltaCodec.encode(reopened, imageAlignment: true),
            encoded,
          );
          controller.replaceText(
            offset,
            text.length,
            '',
            TextSelection.collapsed(offset: offset),
          );
          expect(_semanticUnits(controller.document.toDelta()), before);
        } finally {
          controller.dispose();
        }
      }
    });
  }
}

void _exercise(Map<String, dynamic> fixture, {String? insertedText}) {
  final source = fixture['markdown'] as String;
  final operation = fixture['operation'] as Map<String, dynamic>;
  final marks = Map<String, dynamic>.from(operation['marks'] as Map);
  final text = insertedText ?? operation['text'] as String;
  final controller = _controller(source);
  try {
    final anchor = operation['anchor'] as String;
    final originalVisible = controller.document.toPlainText();
    expect(originalVisible, '$anchor\n');
    final before = _semanticUnits(controller.document.toDelta());
    for (final unit in before.take(anchor.length)) {
      expect(unit['marks'], marks);
    }
    final offset =
        originalVisible.indexOf(anchor) + (operation['offset'] as int);
    _insert(controller, offset, text, marks);
    final expectedText = insertedText == null
        ? '${fixture['visibleText']}\n'
        : originalVisible.replaceRange(offset, offset, text);
    expect(controller.document.toPlainText(), expectedText);
    final expected = [...before]
      ..insertAll(offset, [
        for (final unit in text.codeUnits) {'text': unit, 'marks': marks},
      ]);
    expect(_semanticUnits(controller.document.toDelta()), expected);
    final encoded = MarkdownDeltaCodec.encode(controller.document.toDelta());
    if (insertedText == null) expect(encoded, fixture['serialized']);
    final reopened = MarkdownDeltaCodec.decode(encoded).delta;
    expect(_semanticUnits(reopened), expected);
    expect(MarkdownDeltaCodec.encode(reopened), encoded);

    controller.replaceText(
      offset,
      text.length,
      '',
      TextSelection.collapsed(offset: offset),
    );
    expect(_semanticUnits(controller.document.toDelta()), before);
    final restored = MarkdownDeltaCodec.encode(controller.document.toDelta());
    expect(_semanticUnits(MarkdownDeltaCodec.decode(restored).delta), before);
    expect(restored, source);
  } finally {
    controller.dispose();
  }
}

LiteralTextQuillController _controller(String markdown) =>
    LiteralTextQuillController(
      document: Document.fromDelta(
        MarkdownDeltaCodec.decode(markdown, imageAlignment: true).delta,
      ),
      selection: const TextSelection.collapsed(offset: 0),
      config: const QuillControllerConfig(),
    );

void _insert(
  LiteralTextQuillController controller,
  int offset,
  String text,
  Map<String, dynamic> marks,
) {
  controller.updateSelection(
    TextSelection.collapsed(offset: offset),
    ChangeSource.local,
  );
  for (final key in _marks) {
    controller.formatSelection(Attribute.fromKeyValue(key, marks[key]));
  }
  // Quill deliberately excludes links from collapsed formatSelection. The
  // fixture explicitly enables them as the pending input style as well.
  controller.toggledStyle = controller.toggledStyle.put(
    Attribute.fromKeyValue('link', marks['link'])!,
  );
  controller.replaceText(
    offset,
    0,
    text,
    TextSelection.collapsed(offset: offset + text.length),
  );
}

List<Map<String, Object?>> _semanticUnits(Delta delta) => [
  for (final op in delta.operations)
    if (op.data is String)
      for (final unit in (op.data as String).codeUnits)
        if (unit == 10)
          {
            'newline': true,
            'block': {
              for (final key in const ['header', 'list', 'blockquote', 'align'])
                if (op.attributes?[key] != null) key: op.attributes![key],
            },
          }
        else
          {
            'text': unit,
            'marks': {
              for (final key in _marks)
                if (op.attributes?[key] != null) key: op.attributes![key],
            },
          }
    else
      {'embed': op.data},
];
