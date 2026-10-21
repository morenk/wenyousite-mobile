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

  /// 远端元数据只改变音频的视图表示。把原生历史每个端点投影到同一
  /// 表示后重建差值，既不增加撤销步，也不把收缩前的偏移留在旧栈。
  void projectView(QuillController controller, Delta Function(Delta) project) {
    _syncDocument(controller.document);
    final document = controller.document;
    final before = document.toDelta();
    final projected = project(before);
    final patch = before.diff(projected);
    if (patch.isEmpty) return;
    final history = document.history;
    final mappings = HashMap<Delta, _Selections>.identity();

    List<Delta> transformStack(List<Delta> entries, {required bool undo}) {
      var current = before;
      var currentProjected = projected;
      final transformed = <Delta>[];
      for (final entry in entries.reversed) {
        final next = current.compose(entry);
        final nextProjected = project(next);
        final replacement = currentProjected.diff(nextProjected);
        if (replacement.isNotEmpty) {
          transformed.add(replacement);
          final saved = _selections[entry];
          if (saved != null) {
            final currentPatch = current.diff(currentProjected);
            final nextPatch = next.diff(nextProjected);
            mappings[replacement] = _Selections(
              _projectSelection(
                saved.before,
                undo ? nextPatch : currentPatch,
                undo ? nextProjected.length : currentProjected.length,
              ),
              _projectSelection(
                saved.after,
                undo ? currentPatch : nextPatch,
                undo ? currentProjected.length : nextProjected.length,
              ),
            );
          }
        }
        current = next;
        currentProjected = nextProjected;
      }
      return transformed.reversed.toList();
    }

    // 所有计算先完成；投影失败不能留下半更新的正文、历史或选区映射。
    final undo = transformStack(history.stack.undo, undo: true);
    final redo = transformStack(history.stack.redo, undo: false);
    final selected = _projectSelection(
      controller.selection,
      patch,
      projected.length,
    );
    final ignored = history.ignoreChange;
    history.ignoreChange = true;
    try {
      document.compose(patch, ChangeSource.remote);
    } finally {
      history.ignoreChange = ignored;
    }
    history.stack.undo
      ..clear()
      ..addAll(undo);
    history.stack.redo
      ..clear()
      ..addAll(redo);
    history.lastRecorded = 0;
    _selections
      ..clear()
      ..addAll(mappings);
    controller.updateSelection(selected, ChangeSource.remote);
  }

  static TextSelection _projectSelection(
    TextSelection selection,
    Delta patch,
    int length,
  ) => selection.copyWith(
    baseOffset: patch
        .transformPosition(selection.baseOffset)
        .clamp(0, length - 1),
    extentOffset: patch
        .transformPosition(selection.extentOffset)
        .clamp(0, length - 1),
  );

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
