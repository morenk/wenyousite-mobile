import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

typedef EditorTextColorSelection = ({bool enabled, bool mixed, String? color});

/// 范围只改变普通文字；有效光标设置待输入色，换行和原子不着色。
abstract final class EditorTextColorPolicy {
  static EditorTextColorSelection selection(QuillController controller) {
    if (controller.readOnly ||
        (controller is LiteralTextQuillController &&
            !controller.textColorInputEnabled) ||
        !_valid(controller, controller.selection)) {
      return (enabled: false, mixed: false, color: null);
    }
    if (controller.selection.isCollapsed) {
      return (
        enabled:
            controller is! LiteralTextQuillController ||
            controller.textColorInputEnabled,
        mixed: false,
        color: controller is LiteralTextQuillController
            ? controller.typingColor
            : controller.getSelectionStyle().attributes['color']?.value
                  as String?,
      );
    }
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
    if (controller.readOnly ||
        (controller is LiteralTextQuillController &&
            !controller.textColorInputEnabled) ||
        !_valid(controller, selection)) {
      return false;
    }
    if (selection.isCollapsed) {
      if (controller is LiteralTextQuillController) {
        if (!controller.textColorInputEnabled) return false;
        controller.useColorForTyping(color);
      } else {
        controller.formatText(
          selection.start,
          0,
          Attribute.clone(Attribute.color, color),
        );
      }
      return true;
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

  static bool _valid(QuillController controller, TextSelection selection) =>
      selection.isValid && selection.end < controller.document.length;

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
