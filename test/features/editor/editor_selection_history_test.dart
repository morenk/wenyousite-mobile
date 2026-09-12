import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  testWidgets('分隔线命令的重做恢复命令最终光标', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '甲乙',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    session.insertHorizontalRule();
    final inserted = controller.document.toDelta().toJson();
    expect(controller.selection, const TextSelection.collapsed(offset: 4));
    controller.undo();
    expect(controller.document.toPlainText(), '甲乙\n');
    expect(controller.selection, const TextSelection.collapsed(offset: 1));
    controller.redo();
    expect(controller.document.toDelta().toJson(), inserted);
    expect(controller.selection, const TextSelection.collapsed(offset: 4));
    await session.flush();
  });

  testWidgets('原生合并输入使用首个起点和最后终点恢复选区', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '甲乙',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    controller.replaceText(1, 0, '新', const TextSelection.collapsed(offset: 2));
    controller.replaceText(2, 0, '再', const TextSelection.collapsed(offset: 3));
    expect(controller.document.history.stack.undo, hasLength(1));
    controller.undo();
    expect(controller.document.toPlainText(), '甲乙\n');
    expect(controller.selection, const TextSelection.collapsed(offset: 1));
    controller.redo();
    expect(controller.document.toPlainText(), '甲新再乙\n');
    expect(controller.selection, const TextSelection.collapsed(offset: 3));
    await session.flush();
  });

  testWidgets('替换撤销保留反向选区，新编辑使 redo 失效', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '甲乙丙',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    const original = TextSelection(baseOffset: 2, extentOffset: 0);
    controller.updateSelection(original, ChangeSource.local);
    controller.replaceText(0, 2, '新', const TextSelection.collapsed(offset: 1));
    controller.undo();
    expect(controller.selection, original);
    expect(controller.document.toPlainText(), '甲乙丙\n');
    controller.replaceText(0, 2, '另', const TextSelection.collapsed(offset: 1));
    expect(controller.hasRedo, isFalse);
    controller.redo();
    expect(controller.document.toPlainText(), '另丙\n');
    expect(controller.selection, const TextSelection.collapsed(offset: 1));
    await session.flush();
  });

  testWidgets('恢复另一份正文不会复用上一文档的历史选区', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '旧的长正文',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.updateSelection(
      const TextSelection.collapsed(offset: 5),
      ChangeSource.local,
    );
    controller.replaceText(5, 0, '旧', const TextSelection.collapsed(offset: 6));
    session.applyExternalMarkdown('新');
    controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    controller.replaceText(1, 0, '文', const TextSelection.collapsed(offset: 2));
    controller.undo();
    expect(controller.document.toPlainText(), '新\n');
    expect(controller.selection, const TextSelection.collapsed(offset: 1));
    controller.redo();
    expect(controller.selection, const TextSelection.collapsed(offset: 2));
    await session.flush();
  });
}
