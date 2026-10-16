import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

typedef EditorTextColorSelection = ({bool enabled, bool mixed, String? color});

/// 颜色只属于已选普通文字；换行、协议原子节点不参加颜色计算和修改。
abstract final class EditorTextColorPolicy {
  static EditorTextColorSelection selection(QuillController controller) {
    final ranges = _ranges(controller.document.toDelta(), controller.selection);
    if (ranges.isEmpty) return (enabled: false, mixed: false, color: null);
    final colors = ranges.map((range) => range.color).toSet();
    return (
      enabled: true,
      mixed: colors.length > 1,
      color: colors.length == 1 ? colors.single : null,
    );
  }

  static bool apply(
    QuillController controller,
    TextSelection selection,
    String? color,
  ) {
    if (color != null && !RegExp(r'^#[0-9A-F]{6}$').hasMatch(color)) {
      throw ArgumentError.value(color, 'color', '需要六位 RGB');
    }
    final ranges = _ranges(controller.document.toDelta(), selection);
    final patch = Delta();
    var offset = 0;
    for (final range in ranges) {
      if (range.color == color) continue;
      patch
        ..retain(range.start - offset)
        ..retain(range.end - range.start, {'color': color});
      offset = range.end;
    }
    if (patch.isEmpty) {
      if (ranges.isNotEmpty && controller is LiteralTextQuillController) {
        controller.useDefaultColorForTyping();
      }
      return false;
    }
    // 与前后输入断开原生时间合并；多段颜色由一个 Delta 形成一个撤销步骤。
    controller.document.history.lastRecorded = 0;
    controller.compose(patch, selection, ChangeSource.local);
    controller.document.history.lastRecorded = 0;
    if (controller is LiteralTextQuillController) {
      controller.useDefaultColorForTyping();
    }
    return true;
  }

  static List<({int start, int end, String? color})> _ranges(
    Delta delta,
    TextSelection selection,
  ) {
    if (!selection.isValid || selection.isCollapsed) return const [];
    final result = <({int start, int end, String? color})>[];
    var offset = 0;
    for (final operation in delta.operations) {
      final length = operation.length!;
      final data = operation.data;
      if (data is String) {
        final start = (selection.start - offset).clamp(0, length);
        final end = (selection.end - offset).clamp(start, length);
        var cursor = start;
        while (cursor < end) {
          final newline = data.indexOf('\n', cursor);
          final stop = newline < 0 || newline >= end ? end : newline;
          if (stop > cursor) {
            result.add((
              start: offset + cursor,
              end: offset + stop,
              color: operation.attributes?['color'] as String?,
            ));
          }
          cursor = stop + 1;
        }
      }
      offset += length;
    }
    return result;
  }
}
