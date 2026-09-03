// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

const _inlineKeys = ['bold', 'italic', 'strike', 'link', 'code'];

void main() {
  final styles = <Map<String, dynamic>>[
    <String, dynamic>{},
    for (var mask = 1; mask < 16; mask++)
      {
        if (mask & 1 != 0) 'bold': true,
        if (mask & 2 != 0) 'italic': true,
        if (mask & 4 != 0) 'strike': true,
        if (mask & 8 != 0) 'link': 'https://wenyou.site/help',
      },
    {'code': true},
    {'link': 'https://wenyou.site/other'},
  ];

  testWidgets('所有行内样式边界插入空格时只保留两侧共有格式', (tester) async {
    for (final leading in styles) {
      for (final trailing in styles) {
        final session = _session(leading, trailing);
        session.controller
          ..updateSelection(
            const TextSelection.collapsed(offset: 1),
            ChangeSource.local,
          )
          ..replaceText(1, 0, ' ', const TextSelection.collapsed(offset: 2));

        final attributes = session.controller.document
            .collectStyle(1, 1)
            .attributes;
        final actual = <String, dynamic>{
          for (final key in _inlineKeys)
            if (attributes[key] != null) key: attributes[key]!.value,
        };
        final expected = <String, dynamic>{
          for (final entry in leading.entries)
            if (trailing[entry.key] == entry.value) entry.key: entry.value,
        };
        expect(actual, expected, reason: '$leading -> $trailing');
        expect(await session.flush(), isTrue, reason: '$leading -> $trailing');
        session.dispose();
      }
    }
  });

  testWidgets('边界处手动开启的行内样式优先于自动继承规则', (tester) async {
    final session = _session(const {'bold': true}, const {'italic': true});
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    WenyouEditorFormatPolicy.toggle(session.controller, Attribute.inlineCode);
    session.controller.replaceText(
      1,
      0,
      ' ',
      const TextSelection.collapsed(offset: 2),
    );

    final attributes = session.controller.document
        .collectStyle(1, 1)
        .attributes;
    expect(attributes[Attribute.inlineCode.key]?.value, isTrue);
    for (final key in const ['bold', 'italic', 'strike', 'link']) {
      expect(attributes, isNot(contains(key)));
    }
    session.dispose();
  });
}

RichEditorSession _session(
  Map<String, dynamic> leading,
  Map<String, dynamic> trailing,
) {
  final session = RichEditorSession(
    initialMarkdown: '甲乙',
    onMarkdownChanged: (_) {},
  );
  final formatting = Delta()
    ..retain(1, leading)
    ..retain(1, trailing);
  if (leading.isNotEmpty || trailing.isNotEmpty) {
    session.controller.compose(
      formatting,
      session.controller.selection,
      ChangeSource.local,
    );
  }
  return session;
}
