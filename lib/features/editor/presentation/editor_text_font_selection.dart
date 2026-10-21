import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';

/// 一个选择操作对应一次撤销；行结束和原子节点始终不携带字体属性。
abstract final class EditorTextFontPolicy {
  static ({String? font, bool mixed}) selection(QuillController controller) {
    final range = controller.selection;
    if (!range.isValid || range.isCollapsed) {
      return (
        font:
            controller.getSelectionStyle().attributes['font']?.value as String?,
        mixed: false,
      );
    }
    final fonts = <String?>{};
    var offset = 0;
    for (final op in controller.document.toDelta().operations) {
      final data = op.data;
      if (data is String) {
        final start = (range.start - offset).clamp(0, data.length);
        final end = (range.end - offset).clamp(start, data.length);
        if (data.substring(start, end).replaceAll('\n', '').isNotEmpty) {
          fonts.add(op.attributes?['font'] as String?);
        }
      }
      offset += op.length!;
      if (offset >= range.end) break;
    }
    return (
      font: fonts.length == 1 ? fonts.single : null,
      mixed: fonts.length > 1,
    );
  }

  static bool apply(
    QuillController controller,
    TextSelection selection,
    String? font,
  ) {
    if (font != null && !MarkdownTextFont.accepts(font)) {
      throw ArgumentError.value(font, 'font');
    }
    if (controller.readOnly ||
        !selection.isValid ||
        selection.isCollapsed ||
        selection.end >= controller.document.length) {
      return false;
    }
    final patch = Delta();
    var offset = 0;
    var retained = 0;
    for (final op in controller.document.toDelta().operations) {
      final text = op.data;
      if (text is String && op.attributes?['font'] != font) {
        final start = (selection.start - offset).clamp(0, text.length);
        final end = (selection.end - offset).clamp(start, text.length);
        var cursor = start;
        while (cursor < end) {
          final newline = text.indexOf('\n', cursor);
          final stop = newline < 0 || newline >= end ? end : newline;
          if (stop > cursor) {
            patch
              ..retain(offset + cursor - retained)
              ..retain(stop - cursor, {'font': font});
            retained = offset + stop;
          }
          cursor = stop + 1;
        }
      }
      offset += op.length!;
    }
    if (patch.isEmpty) return false;
    controller.document.history.lastRecorded = 0;
    controller.compose(patch, selection, ChangeSource.local);
    controller.document.history.lastRecorded = 0;
    return true;
  }
}
