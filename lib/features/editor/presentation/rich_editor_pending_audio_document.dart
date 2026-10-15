import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/local_audio_marker.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_paragraph_boundaries.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

extension RichEditorPendingAudioDocument on RichEditorSession {
  Set<String> get localAudioIds => {
    for (final operation in controller.document.toDelta().toList())
      if (operation.attributes?['link'] case final String url)
        if (url.startsWith(localAudioMarkerPrefix))
          url.substring(localAudioMarkerPrefix.length),
  };

  void insertLocalAudio(String id) {
    if (controller.readOnly) return;
    final document = controller.document;
    final text = document.toPlainText();
    final start = controller.selection.start.clamp(0, document.length - 1);
    final end = controller.selection.end.clamp(start, document.length - 1);
    final change = Delta()..retain(start);
    if (end > start) change.delete(end - start);
    // 显式独立段落；前后文字与旧软换行不能吞掉这条音频。
    if (start > 0 && text[start - 1] != '\n') {
      change.insert('\n', {MarkdownParagraphBoundaries.key: 1});
    }
    change.insert('音频', {'link': '$localAudioMarkerPrefix$id'});
    if (text[end] != '\n') {
      change.insert('\n', {MarkdownParagraphBoundaries.key: 1});
    } else {
      change.retain(1, {
        MarkdownParagraphBoundaries.key: 1,
        'header': null,
        'list': null,
        'blockquote': null,
        'indent': null,
      });
    }
    controller.runEditCommand(
      () =>
          controller.compose(change, controller.selection, ChangeSource.local),
    );
    // 插入点恰好在旧段首时，给前一个正文换行补段落边界。
    if (start > 0 && text[start - 1] == '\n') {
      controller.compose(
        Delta()
          ..retain(start - 1)
          ..retain(1, {MarkdownParagraphBoundaries.key: 1}),
        controller.selection,
        ChangeSource.local,
      );
    }
    unawaited(flush());
  }

  void resolveLocalAudio(String id, MediaAudio audio) {
    replaceMediaAudios({...mediaAudios, audio.sourceUrl: audio});
    _replaceAudioLink(id, audio.sourceUrl, ChangeSource.remote);
  }

  void removeLocalAudio(String id) => controller.runEditCommand(
    () => _replaceAudioLink(id, null, ChangeSource.local),
  );

  void _replaceAudioLink(String id, String? url, ChangeSource source) {
    final change = Delta();
    var changed = false;
    var offset = 0;
    var selection = controller.selection;
    for (final operation in controller.document.toDelta().toList()) {
      final length = operation.length ?? 0;
      if (operation.attributes?['link'] == '$localAudioMarkerPrefix$id') {
        changed = true;
        if (url != null) {
          change.retain(length, {'link': url});
        } else {
          change.delete(length);
          int adjusted(int value) => value <= offset
              ? value
              : value - (value - offset).clamp(0, length);
          selection = TextSelection(
            baseOffset: adjusted(selection.baseOffset),
            extentOffset: adjusted(selection.extentOffset),
          );
        }
      } else {
        change.retain(length);
      }
      offset += length;
    }
    if (changed) controller.compose(change, selection, source);
  }
}
