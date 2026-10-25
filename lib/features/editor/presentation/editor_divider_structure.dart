import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

/// 在输入事务内维持分隔线的块边界；不在保存时修剪或丢弃内容。
void preserveEditorDividerBlocks(QuillController controller) {
  final before = controller.document.toDelta();
  final after = normalizeEditorDividerBlocks(before);
  if (identical(before, after)) return;
  final patch = before.diff(after);
  if (patch.isEmpty) return;
  final selection = controller.selection;
  controller.document.compose(patch, ChangeSource.local);
  controller.updateSelection(
    selection.copyWith(
      baseOffset: patch.transformPosition(selection.baseOffset),
      extentOffset: patch.transformPosition(selection.extentOffset),
    ),
    ChangeSource.local,
  );
}

/// 粘贴预检与实际输入共用块边界规则，验证最终可编辑结构。
Delta normalizeEditorDividerBlocks(Delta before) {
  if (!before.operations.any(_isDivider)) return before;
  final after = Delta();
  var line = Delta();
  void finishLine(Map<String, dynamic>? attributes) {
    if (!line.operations.any(_isDivider)) {
      for (final op in line.operations) {
        after.insert(op.data, op.attributes);
      }
      after.insert('\n', attributes);
      line = Delta();
      return;
    }
    var hasContent = false;
    var afterDivider = false;
    for (var index = 0; index < line.operations.length; index++) {
      final op = line.operations[index];
      if (_isDivider(op)) {
        // 新插入边界只继承块样式，不复制原行末的隐藏段落分隔计数。
        if (hasContent) after.insert('\n', _newBoundaryAttributes(attributes));
        after.insert(op.data);
        final isLast = index == line.operations.length - 1;
        after.insert('\n', isLast ? _dividerAttributes(attributes) : null);
        hasContent = false;
        afterDivider = true;
      } else {
        after.insert(op.data, op.attributes);
        hasContent = true;
        afterDivider = false;
      }
    }
    if (!afterDivider) after.insert('\n', attributes);
    line = Delta();
  }

  for (final op in before.operations) {
    final value = op.data;
    if (value is! String) {
      line.insert(value, op.attributes);
      continue;
    }
    final parts = value.split('\n');
    for (var index = 0; index < parts.length; index++) {
      if (parts[index].isNotEmpty) line.insert(parts[index], op.attributes);
      if (index < parts.length - 1) finishLine(op.attributes);
    }
  }
  for (final op in line.operations) {
    after.insert(op.data, op.attributes);
  }
  return after;
}

bool _isDivider(Operation operation) =>
    operation.data is Map &&
    (operation.data as Map).containsKey(MarkdownDeltaCodec.horizontalRuleEmbed);

Map<String, dynamic>? _newBoundaryAttributes(Map<String, dynamic>? attributes) {
  if (attributes == null) return null;
  final block = {
    for (final entry in attributes.entries)
      if (const {
        'header',
        'list',
        'blockquote',
        'indent',
        'align',
      }.contains(entry.key))
        entry.key: entry.value,
  };
  return block.isEmpty ? null : block;
}

Map<String, dynamic>? _dividerAttributes(Map<String, dynamic>? attributes) {
  if (attributes == null) return null;
  final safe = Map<String, dynamic>.from(attributes)
    ..removeWhere(
      (key, _) => const {
        'header',
        'list',
        'blockquote',
        'indent',
        'align',
        'bold',
        'italic',
        'strike',
        'code',
        'link',
        'color',
        'font',
      }.contains(key),
    );
  return safe.isEmpty ? null : safe;
}
