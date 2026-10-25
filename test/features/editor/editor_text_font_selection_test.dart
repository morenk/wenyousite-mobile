import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';

void main() {
  test('跨段选择跳过换行与原子，保留颜色和粗体，一次撤销', () {
    final delta = Delta()
      ..insert('甲', {'bold': true, 'color': '#D14343'})
      ..insert('\n')
      ..insert({'image': 'image.png'})
      ..insert('乙\n');
    final controller = QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection(baseOffset: 0, extentOffset: 4),
    );
    addTearDown(controller.dispose);
    expect(
      EditorTextFontPolicy.apply(controller, controller.selection, 'wenkai'),
      isTrue,
    );
    final ops = controller.document.toDelta().operations;
    expect(ops.first.attributes, containsPair('font', 'wenkai'));
    expect(ops.first.attributes, containsPair('color', '#D14343'));
    expect(
      ops
          .where((op) => op.data is! String || op.data == '\n')
          .every((op) => op.attributes?['font'] == null),
      isTrue,
    );
    controller.undo();
    expect(controller.document.toDelta(), delta);
  });
  test('默认字体仅移除 font，光标设置输入样式且未知 ID 拒绝', () {
    final controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('甲', {'font': 'wenkai', 'italic': true})
          ..insert('\n'),
      ),
      selection: const TextSelection(baseOffset: 0, extentOffset: 1),
    );
    addTearDown(controller.dispose);
    expect(
      EditorTextFontPolicy.apply(controller, controller.selection, null),
      isTrue,
    );
    expect(controller.document.toDelta().first.attributes, {'italic': true});
    expect(
      EditorTextFontPolicy.apply(
        controller,
        const TextSelection.collapsed(offset: 0),
        'wenkai',
      ),
      isTrue,
    );
    expect(
      () =>
          EditorTextFontPolicy.apply(controller, controller.selection, 'Arial'),
      throwsArgumentError,
    );
  });
}
