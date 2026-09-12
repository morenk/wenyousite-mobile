import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

/// 选区附着于 Quill 原生历史条目；不复制正文或自建正文撤销栈。
class EditorSelectionHistory {
  final _selections = HashMap<Delta, _Selections>.identity();
  Document? _document;
  int _depth = 0;

  void record(QuillController controller, void Function() action) {
    if (_depth > 0) {
      action();
      return;
    }
    _syncDocument(controller.document);
    final document = controller.document;
    final stack = document.history.stack.undo;
    final previous = stack.isEmpty ? null : stack.last;
    final before = controller.selection;
    _depth++;
    try {
      action();
    } finally {
      _depth--;
      if (identical(document, controller.document)) {
        final current = stack.isEmpty ? null : stack.last;
        if (current != null && !identical(current, previous)) {
          final merged =
              previous != null &&
              !stack.any((entry) => identical(entry, previous));
          // 未经 Controller 的外部历史无法证明原选区，保留原生恢复策略。
          final original = merged ? _selections[previous]?.before : before;
          if (original != null) {
            _selections[current] = _Selections(original, controller.selection);
          }
        }
        _prune(document);
      } else {
        _syncDocument(controller.document);
      }
    }
  }

  void restore(
    QuillController controller,
    void Function() action, {
    required bool undo,
  }) {
    _syncDocument(controller.document);
    final history = controller.document.history;
    final source = undo ? history.stack.undo : history.stack.redo;
    final target = undo ? history.stack.redo : history.stack.undo;
    final selection = source.isEmpty ? null : _selections[source.last];
    action();
    if (selection != null && target.isNotEmpty) {
      _selections[target.last] = selection;
      final desired = undo ? selection.before : selection.after;
      final end = controller.document.length - 1;
      controller.updateSelection(
        desired.copyWith(
          baseOffset: desired.baseOffset.clamp(0, end),
          extentOffset: desired.extentOffset.clamp(0, end),
        ),
        ChangeSource.local,
      );
    }
    _prune(controller.document);
  }

  void _syncDocument(Document document) {
    if (identical(_document, document)) return;
    _document = document;
    _selections.clear();
  }

  void _prune(Document document) {
    final retained = HashSet<Delta>.identity()
      ..addAll(document.history.stack.undo)
      ..addAll(document.history.stack.redo);
    _selections.removeWhere((entry, _) => !retained.contains(entry));
  }
}

class _Selections {
  const _Selections(this.before, this.after);
  final TextSelection before;
  final TextSelection after;
}
