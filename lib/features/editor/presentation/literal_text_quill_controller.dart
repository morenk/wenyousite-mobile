// ignore_for_file: experimental_member_use
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_paste.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_document_alignment.dart';

/// Marks literal source at the exact offset before async changes can race.
class LiteralTextQuillController extends QuillController {
  LiteralTextQuillController({
    required super.document,
    required super.selection,
    required super.config,
  });

  @override
  Style getSelectionStyle() {
    final selected = super.getSelectionStyle();
    if (!selection.isCollapsed ||
        toggledStyle.attributes.containsKey(Attribute.header.key)) {
      return selected;
    }
    // Quill 在行首收集样式时会排除标题；空标题重开后仍应显示真实行样式。
    final line = document.queryChild(selection.start).node;
    final header = line is Line
        ? line.style.attributes[Attribute.header.key]
        : null;
    return header == null ? selected : selected.put(header);
  }

  @override
  void replaceText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool shouldNotifyListeners = true,
  }) {
    final before = document.toDelta();
    final preservesLink =
        toggledStyle.attributes[Attribute.link.key]?.value != null ||
        document.collectStyle(index, 0).attributes[Attribute.link.key]?.value !=
            null;
    if (data == ' ' && len == 0 && index > 0) {
      final left = document.collectStyle(index - 1, 1).attributes;
      final right = document.collectStyle(index, 1).attributes;
      for (final entry in left.entries) {
        if (entry.value.isInline &&
            entry.value.value != right[entry.key]?.value &&
            !toggledStyle.attributes.containsKey(entry.key)) {
          toggledStyle = toggledStyle.put(Attribute.clone(entry.value, null));
        }
      }
    }
    final internalReference = data is String
        ? WenyouEditorClipboardPastePlanner.internalReferenceDelta(
            data,
            len == 0 ? '' : document.getPlainText(index, len),
          )
        : null;
    final effectiveData =
        internalReference ?? _plainNewline(data, index) ?? data;
    final effectiveSelection = internalReference == null
        ? textSelection
        : TextSelection.collapsed(offset: index + 1);
    if (_containsEmbed(effectiveData)) {
      // Quill applies pending inline toolbar styles to every replacement,
      // including embeds. Protocol nodes must remain attribute-free so the
      // Markdown codec can persist them without weakening its fail-closed
      // validation.
      toggledStyle = const Style();
    }
    super.replaceText(
      index,
      len,
      effectiveData,
      effectiveSelection,
      ignoreFocus: ignoreFocus,
      shouldNotifyListeners: shouldNotifyListeners,
    );
    final insertedLength = switch (effectiveData) {
      String value => value.length,
      Delta value => MarkdownDeltaLineMetadata.documentLength(value),
      Embeddable() => 1,
      _ => 0,
    };
    final sourceSeparatorPatch = MarkdownDeltaLineMetadata.sourceSeparatorPatch(
      before: before,
      after: document.toDelta(),
      index: index,
      replacedLength: len,
      insertedLength: insertedLength,
      insertedDelta: effectiveData is Delta ? effectiveData : null,
    );
    if (sourceSeparatorPatch.isNotEmpty) {
      document.compose(sourceSeparatorPatch, ChangeSource.local);
    }
    repairEditorTrailingNewlineAlignment(
      controller: this,
      before: before,
      insertedData: effectiveData,
      replacedLength: len,
      selection: effectiveSelection,
    );
    if (effectiveData is! String || effectiveData.isEmpty) return;

    final formatting = Delta();
    var formattingOffset = 0;
    var sourceOffset = 0;
    while (sourceOffset < effectiveData.length) {
      final newline = effectiveData.indexOf('\n', sourceOffset);
      final end = newline < 0 ? effectiveData.length : newline;
      if (end > sourceOffset) {
        final start = index + sourceOffset;
        if (start > formattingOffset) {
          formatting.retain(start - formattingOffset);
        }
        formatting.retain(end - sourceOffset, {
          MarkdownDeltaCodec.literalTextAttribute: true,
          // Literal typing must not acquire Quill's automatically detected
          // links. Existing links and explicitly enabled input marks survive.
          if (!preservesLink) Attribute.link.key: null,
        });
        formattingOffset = start + end - sourceOffset;
      }
      if (newline < 0) break;
      sourceOffset = newline + 1;
    }
    if (formatting.isNotEmpty) {
      document.compose(formatting, ChangeSource.local);
    }
  }

  static bool _containsEmbed(Object? data) => switch (data) {
    Embeddable() => true,
    Delta value => value.operations.any(
      (operation) => operation.isInsert && operation.data is Map,
    ),
    _ => false,
  };

  Object? _plainNewline(Object? data, int index) {
    if (data != '\n') return null;
    final line = document.queryChild(index).node;
    final attributes = line is Line
        ? line.style.attributes
        : document.collectStyle(index, 0).attributes;
    if (attributes.containsKey('header') ||
        attributes.containsKey('list') ||
        attributes.containsKey('code-block') ||
        attributes.containsKey('indent')) {
      return null;
    }
    // Quill's string insertion exits an empty quote/aligned line without
    // inserting anything. An explicit Delta keeps the user's Enter literal.
    return Delta()..insert('\n', {
      if (attributes['blockquote']?.value == true) 'blockquote': true,
      if (attributes['align']?.value case final String alignment)
        'align': alignment,
    });
  }
}
