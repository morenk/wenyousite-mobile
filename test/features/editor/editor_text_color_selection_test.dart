import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

void main() {
  LiteralTextQuillController controller(Delta delta, TextSelection selection) {
    final result = LiteralTextQuillController(
      document: Document.fromDelta(delta),
      selection: selection,
      config: const QuillControllerConfig(),
    );
    addTearDown(result.dispose);
    return result;
  }

  test('跨段跳过原子和换行，保留格式与反向选区，单步撤销重做', () {
    final before = Delta()
      ..insert('中文😀', {'bold': true})
      ..insert('\n')
      ..insert({
        'wenyou_mention': {'kind': 'user', 'id': 'x'},
      })
      ..insert('尾巴', {'code': true})
      ..insert('\n');
    const selection = TextSelection(baseOffset: 8, extentOffset: 0);
    final editor = controller(before, selection);
    expect(EditorTextColorPolicy.apply(editor, selection, '#123456'), isTrue);
    final operations = editor.document.toDelta().operations;
    expect(operations.first.attributes, {'bold': true, 'color': '#123456'});
    expect(operations[1].attributes, isNull);
    expect(operations[2].attributes, isNull);
    expect(operations[3].attributes, {'code': true, 'color': '#123456'});
    expect(editor.selection, selection);
    editor.undo();
    expect(editor.document.toDelta(), before);
    expect(editor.selection, selection);
    editor.redo();
    expect(
      editor.document.toDelta().operations.first.attributes?['color'],
      '#123456',
    );
    expect(editor.selection, selection);
  });

  test('混合颜色没有错误预选，默认只移除颜色', () {
    final editor = controller(
      Delta()
        ..insert('红', {'color': '#FF0000', 'italic': true})
        ..insert('蓝', {'color': '#0000FF', 'strike': true})
        ..insert('\n'),
      const TextSelection(baseOffset: 0, extentOffset: 2),
    );
    expect(EditorTextColorPolicy.selection(editor), (
      enabled: true,
      mixed: true,
      color: null,
    ));
    EditorTextColorPolicy.apply(editor, editor.selection, null);
    expect(editor.document.toDelta().operations[0].attributes, {
      'italic': true,
    });
    expect(editor.document.toDelta().operations[1].attributes, {
      'strike': true,
    });
  });

  test('空选区和只有原子或换行不可改色', () {
    final editor = controller(
      Delta()
        ..insert({
          'wenyou_mention': {'id': 'x'},
        })
        ..insert('\n'),
      const TextSelection.collapsed(offset: 0),
    );
    expect(EditorTextColorPolicy.selection(editor).enabled, isFalse);
    editor.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 2),
      ChangeSource.local,
    );
    expect(EditorTextColorPolicy.selection(editor).enabled, isFalse);
    expect(
      EditorTextColorPolicy.apply(editor, editor.selection, '#000000'),
      isFalse,
    );
  });
  test('真实提及、骰子、图片与传送门Delta不吸收颜色', () {
    const source =
        '普通 [@用户](/users/c111111111111111111111111) '
        '[传送门](/threads/c111111111111111111111111) '
        '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d6]] '
        '![图片](https://example.com/a.png) 尾巴';
    final before = MarkdownDeltaCodec.decode(source).delta;
    final editor = controller(
      before,
      TextSelection(baseOffset: 0, extentOffset: before.length - 1),
    );
    final atoms = before.operations.where((op) => op.data is Map).toList();
    expect(atoms.length, greaterThanOrEqualTo(3));
    EditorTextColorPolicy.apply(editor, editor.selection, '#112233');
    final after = editor.document.toDelta();
    expect(
      after.operations.where((op) => op.data is Map).map((op) => op.data),
      atoms.map((op) => op.data),
    );
    expect(
      after.operations
          .where((op) => op.data is Map)
          .every((op) => op.attributes?['color'] == null),
      isTrue,
    );
    expect(MarkdownDeltaCodec.encode(after), contains('data-wenyou-color-v1'));
  });

  test('改色与邻近输入不合并，后续输入不继承颜色', () {
    final editor = controller(
      Delta()..insert('甲\n'),
      const TextSelection.collapsed(offset: 1),
    );
    editor.replaceText(1, 0, '乙', const TextSelection.collapsed(offset: 2));
    const selected = TextSelection(baseOffset: 0, extentOffset: 2);
    editor.updateSelection(selected, ChangeSource.local);
    EditorTextColorPolicy.apply(editor, selected, '#123456');
    editor.undo();
    expect(editor.document.toPlainText(), '甲乙\n');
    expect(
      editor.document.toDelta().operations.first.attributes?['color'],
      isNull,
    );
    editor.redo();
    editor.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    editor.replaceText(2, 0, '丙', const TextSelection.collapsed(offset: 3));
    expect(
      editor.document.collectStyle(2, 1).attributes['color']?.value,
      isNull,
    );
    expect(
      editor.document.collectStyle(0, 1).attributes['color']?.value,
      '#123456',
    );
  });
}
