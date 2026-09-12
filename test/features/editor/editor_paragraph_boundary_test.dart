import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  testWidgets('旧软换行同段排版，手动回车后剩余软行组成独立段', (tester) async {
    final session = _session('[wenyousite-align-v1-center]: #\n甲乙\n丙丁');
    final controller = session.controller;
    controller.updateSelection(
      const TextSelection.collapsed(offset: 3),
      ChangeSource.local,
    );
    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.right,
    );
    expect(_saved(session), '[wenyousite-align-v1-right]: #\n甲乙\n丙丁');
    _enter(session, 1);
    await tester.pump();
    expect(controller.document.toPlainText(), '甲\n乙\n丙丁\n');
    expect(_saved(session), '[wenyousite-align-v1-right]: #\n甲\n\n乙\n丙丁');
    controller.updateSelection(
      const TextSelection.collapsed(offset: 4),
      ChangeSource.local,
    );
    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.center,
    );
    expect(
      _saved(session),
      '[wenyousite-align-v1-right]: #\n甲\n\n[wenyousite-align-v1-center]: #\n乙\n丙丁',
    );
    expect(await session.flush(), isTrue);
  });

  testWidgets('Shift+Enter 不复制相邻段边界且保留同段对齐', (tester) async {
    final session = _session('[wenyousite-align-v1-center]: #\n甲乙\n\n丙');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    _enter(session, 1);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(session.controller.document.toPlainText(), '甲\n乙\n丙\n');
    expect(_saved(session), '[wenyousite-align-v1-center]: #\n甲\n乙\n\n丙');
    expect(await session.flush(), isTrue);
  });

  testWidgets('独立正文段边界可单步撤销重做，删除边界后可安全保存', (tester) async {
    final session = _session('[wenyousite-align-v1-center]: #\n甲乙');
    _enter(session, 1);
    await tester.pump();
    expect(_saved(session), '[wenyousite-align-v1-center]: #\n甲\n\n乙');
    session.controller.undo();
    await tester.pump();
    expect(_saved(session), '[wenyousite-align-v1-center]: #\n甲乙');
    session.controller.redo();
    await tester.pump();
    expect(_saved(session), '[wenyousite-align-v1-center]: #\n甲\n\n乙');
    session.controller.replaceText(
      1,
      1,
      '',
      const TextSelection.collapsed(offset: 1),
    );
    await tester.pump();
    expect(session.controller.document.toPlainText(), '甲乙\n');
    expect(await session.flush(), isTrue);
    expect(
      Document.fromDelta(
        MarkdownDeltaCodec.decode(_saved(session)).delta,
      ).toPlainText(),
      '甲乙\n',
    );
  });

  testWidgets('回车仅恢复排版方向，粗体斜体删除线继续输入保留', (tester) async {
    final session = _session('[wenyousite-align-v1-right]: #\n**甲**');
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    session.controller.formatSelection(Attribute.italic);
    session.controller.formatSelection(Attribute.strikeThrough);
    _enter(session, 1);
    session.controller.replaceText(
      2,
      0,
      '乙',
      const TextSelection.collapsed(offset: 3),
    );
    await tester.pump();
    final marks = session.controller.document.collectStyle(2, 1).attributes;
    expect(marks['bold']?.value, isTrue);
    expect(marks['italic']?.value, isTrue);
    expect(marks['strike']?.value, isTrue);
    expect(
      WenyouEditorFormatPolicy.alignmentSelection(session.controller).alignment,
      WenyouTextAlignment.left,
    );
    expect(await session.flush(), isTrue);
    final reopened = _session(_saved(session));
    expect(reopened.controller.document.toPlainText(), '甲\n乙\n');
    final reopenedMarks = reopened.controller.document
        .collectStyle(2, 1)
        .attributes;
    for (final key in ['bold', 'italic', 'strike']) {
      expect(reopenedMarks[key]?.value, isTrue);
    }
  });
}

RichEditorSession _session(String markdown) {
  final session = RichEditorSession(
    initialMarkdown: markdown,
    onMarkdownChanged: (_) {},
  );
  addTearDown(session.dispose);
  return session;
}

void _enter(RichEditorSession session, int offset) {
  if (session.controller.selection != TextSelection.collapsed(offset: offset)) {
    session.controller.updateSelection(
      TextSelection.collapsed(offset: offset),
      ChangeSource.local,
    );
  }
  session.controller.replaceText(
    offset,
    0,
    '\n',
    TextSelection.collapsed(offset: offset + 1),
  );
}

String _saved(RichEditorSession session) =>
    MarkdownDeltaCodec.encode(session.controller.document.toDelta());
