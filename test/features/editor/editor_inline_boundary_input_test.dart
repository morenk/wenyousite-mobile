// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  testWidgets('行内代码与粗体之间输入空格时空格保持无格式', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '`代码`**粗体**',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller
      ..updateSelection(
        const TextSelection.collapsed(offset: 2),
        ChangeSource.local,
      )
      ..replaceText(2, 0, ' ', const TextSelection.collapsed(offset: 3));

    expect(await session.flush(), isTrue);
    expect(emitted.last, '`代码` **粗体**');
  });
}
