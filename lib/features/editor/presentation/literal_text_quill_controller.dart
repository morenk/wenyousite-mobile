// ignore_for_file: experimental_member_use
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_paragraph_boundaries.dart';
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
    if (!selection.isCollapsed) return selected;
    final actual = _actualLineStyle(selection.start);
    if (actual == null) return selected;
    // Quill 空行会沿前文收集样式；行内续写可以继承，块归属必须来自当前行。
    // 工具栏状态、格式切换和回车共用该事实，不再逐种格式修补空状态。
    return Style.attr({
      for (final entry in selected.attributes.entries)
        if (entry.value.scope != AttributeScope.block) entry.key: entry.value,
      for (final entry in actual.attributes.entries)
        if (entry.value.scope == AttributeScope.block) entry.key: entry.value,
    }).mergeAll(
      Style.attr({
        for (final entry in toggledStyle.attributes.entries)
          if (entry.value.scope == AttributeScope.block) entry.key: entry.value,
      }),
    );
  }

  Style? _actualLineStyle(int position) {
    final line = document.queryChild(position).node;
    if (line is! Line) return null;
    final parent = line.parent;
    return parent is Block ? parent.style.mergeAll(line.style) : line.style;
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
    final newline = _plainNewline(data, index);
    final effectiveData = internalReference ?? newline ?? data;
    final continuationStyle = newline != null && keepStyleOnNewLine
        ? Style.attr(
            Map.fromEntries(
              getSelectionStyle().attributes.entries.where(
                (entry) =>
                    entry.value.isInline && entry.key != Attribute.link.key,
              ),
            ),
          )
        : null;
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
    if (newline != null && effectiveSelection != null) {
      // 显式换行 Delta 不经过插入规则，不应再次使用 Quill 的位置补偿。
      updateSelection(effectiveSelection, ChangeSource.local);
    }
    if (effectiveData is Delta &&
        effectiveData.operations.any(
          (operation) =>
              operation.attributes?[MarkdownDeltaLineMetadata
                  .sourceSeparatorAttribute] ==
              true,
        )) {
      final current = document.toDelta();
      final patch = current.diff(MarkdownParagraphBoundaries.collapse(current));
      if (patch.isNotEmpty) {
        // Delta 替换已包含准确插入长度，使用调用方的插入终点，避免
        // Quill 再把整个片段当成一个 embed 计算位置偏移。
        final intended = effectiveSelection ?? selection;
        final adjusted = intended.copyWith(
          baseOffset: patch.transformPosition(intended.baseOffset),
          extentOffset: patch.transformPosition(intended.extentOffset),
        );
        document.compose(patch, ChangeSource.local);
        updateSelection(adjusted, ChangeSource.local);
      }
    }
    if (effectiveData is Delta &&
        effectiveData.operations.length == 1 &&
        effectiveData.operations.single.attributes?[MarkdownParagraphBoundaries
                .key] ==
            1) {
      if (MarkdownParagraphBoundaries.range(before, index)?.start == index) {
        _resetNewParagraphAlignment(index);
      }
      _resetNewParagraphAlignment(index + insertedLength);
    }
    repairEditorTrailingNewlineAlignment(
      controller: this,
      before: before,
      insertedData: effectiveData,
      replacedLength: len,
      selection: effectiveSelection,
    );
    if (continuationStyle != null) toggledStyle = continuationStyle;
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
    final attributes =
        (_actualLineStyle(index) ?? document.collectStyle(index, 0)).attributes;
    if (attributes.containsKey('header') ||
        attributes.containsKey('list') ||
        attributes.containsKey('code-block') ||
        attributes.containsKey('indent')) {
      return null;
    }
    // Quill's string insertion exits an empty quote/aligned line without
    // inserting anything. An explicit Delta keeps the user's Enter literal.
    final startsParagraph =
        attributes['blockquote']?.value != true &&
        !HardwareKeyboard.instance.isShiftPressed;
    final range = MarkdownParagraphBoundaries.range(document.toDelta(), index);
    return Delta()..insert('\n', {
      if (attributes['blockquote']?.value == true) 'blockquote': true,
      if (startsParagraph) MarkdownParagraphBoundaries.key: 1,
      if ((!startsParagraph || range?.start != index) &&
          attributes['align']?.value != null)
        'align': attributes['align']!.value,
    });
  }

  void _resetNewParagraphAlignment(int position) {
    final delta = document.toDelta();
    final range = MarkdownParagraphBoundaries.range(delta, position);
    if (range == null) return;
    final patch = Delta();
    var offset = 0;
    var patched = 0;
    for (final operation in delta.operations) {
      if (operation.data case final String text) {
        for (var index = 0; index < text.length; index++) {
          final at = offset + index;
          if (text[index] == '\n' &&
              at >= range.start &&
              at < range.end &&
              operation.attributes?['align'] != null) {
            if (at > patched) patch.retain(at - patched);
            patch.retain(1, {'align': null});
            patched = at + 1;
          }
        }
      }
      offset += operation.length!;
    }
    if (patch.isNotEmpty) document.compose(patch, ChangeSource.local);
  }
}
