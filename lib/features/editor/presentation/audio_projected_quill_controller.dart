// ignore_for_file: experimental_member_use
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/editor/quill_document_range.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

/// 视图转换属于触发编辑的同一个 Quill 事务，不另建撤销记录。
class AudioProjectedQuillController extends LiteralTextQuillController {
  AudioProjectedQuillController({
    required super.document,
    required super.selection,
    required super.config,
    required this.audios,
  });
  final Map<String, MediaAudio> Function() audios;
  bool _projecting = false;
  final _audioPointers = <int>{};

  void beginAudioPointer(int pointer) => _audioPointers.add(pointer);
  void endAudioPointer(int pointer) =>
      scheduleMicrotask(() => _audioPointers.remove(pointer));

  // Quill 的透明双击／长拖选择会穿过 embed。媒体操作期间保留原输入点；
  // 卡片自身的选块命令显式走父实现，不把后续键盘编辑禁掉。
  @override
  void updateSelection(TextSelection textSelection, ChangeSource source) {
    if (_audioPointers.isEmpty || _projecting) {
      super.updateSelection(textSelection, source);
    }
  }

  void selectAudio(TextSelection textSelection) =>
      super.updateSelection(textSelection, ChangeSource.local);

  void projectAudio({ChangeSource source = ChangeSource.remote}) {
    if (_projecting) return;
    _projecting = true;
    try {
      if (source == ChangeSource.remote) {
        projectDocumentView(
          (delta) => MarkdownAudioEmbed.project(delta, audios()),
        );
        return;
      }
      final before = document.toDelta();
      final patch = before.diff(MarkdownAudioEmbed.project(before, audios()));
      if (patch.isEmpty) return;
      final selected = selection;
      super.compose(
        patch,
        selected.copyWith(
          baseOffset: patch.transformPosition(selected.baseOffset),
          extentOffset: patch.transformPosition(selected.extentOffset),
        ),
        source,
      );
    } finally {
      _projecting = false;
    }
  }

  @override
  void compose(Delta delta, TextSelection textSelection, ChangeSource source) =>
      runEditCommand(() {
        super.compose(delta, textSelection, source);
        projectAudio(source: source);
      });

  @override
  void replaceText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool shouldNotifyListeners = true,
  }) {
    if (!isQuillDocumentRangeValid(
      document,
      index,
      len,
      includeTerminalNewline: true,
    )) {
      return;
    }
    runEditCommand(() {
      super.replaceText(
        index,
        len,
        data,
        textSelection,
        ignoreFocus: ignoreFocus,
        shouldNotifyListeners: shouldNotifyListeners,
      );
      projectAudio(source: ChangeSource.local);
    });
  }

  @override
  void formatText(
    int index,
    int len,
    Attribute? attribute, {
    bool shouldNotifyListeners = true,
  }) => runEditCommand(() {
    super.formatText(
      index,
      len,
      attribute,
      shouldNotifyListeners: shouldNotifyListeners,
    );
    projectAudio(source: ChangeSource.local);
  });

  @override
  void undo() {
    super.undo();
    projectAudio();
  }

  @override
  void redo() {
    super.redo();
    projectAudio();
  }
}
