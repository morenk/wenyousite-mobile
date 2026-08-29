import 'package:flutter_quill/quill_delta.dart';

/// Keeps source-only Markdown separators distinct from editable blank lines.
///
/// These attributes exist only in the in-memory Quill document. Persisted
/// content continues to use standalone `<br />` lines for visible empties.
class MarkdownDeltaLineMetadata {
  MarkdownDeltaLineMetadata._();

  static const emptyKey = 'wenyou_empty_paragraph';
  static const sourceBreakKey = 'wenyou_source_break';
  static const literalLineKey = 'wenyou_literal_line';
  static const sourceSeparatorAttribute = 'wenyou_source_separator';

  static const _blockAttributes = {
    'header',
    'list',
    'blockquote',
    'indent',
    'align',
  };

  static int documentLength(Delta delta) => delta.operations.fold(
    0,
    (length, operation) => length + operation.length!,
  );

  /// Returns a copy whose line metadata is safe for Markdown serialization.
  ///
  /// A raw source separator remains an ordinary empty Markdown line. Every
  /// other plain empty Quill line is an intentional protocol paragraph. The
  /// final Quill newline is treated as the document terminator by position,
  /// so an inherited source-break attribute cannot swallow earlier newlines.
  static Delta prepareForEncoding(Delta source) {
    final output = Delta();
    final totalLength = documentLength(source);
    var documentOffset = 0;
    var lineHasContent = false;

    for (final operation in source.operations) {
      final data = operation.data;
      if (data is! String) {
        output.insert(data, operation.attributes);
        documentOffset += operation.length!;
        lineHasContent = true;
        continue;
      }

      var segmentStart = 0;
      for (var index = 0; index < data.length; index++) {
        if (data[index] != '\n') continue;
        if (index > segmentStart) {
          final segment = data.substring(segmentStart, index);
          output.insert(segment, _textAttributes(operation.attributes));
          documentOffset += segment.length;
          lineHasContent = true;
        }

        final isFinalNewline = documentOffset == totalLength - 1;
        output.insert(
          '\n',
          _newlineAttributes(
            operation.attributes,
            lineHasContent: lineHasContent,
            isOnlyDocumentLine: totalLength == 1 && isFinalNewline,
            isFinalNewline: isFinalNewline,
          ),
        );
        documentOffset += 1;
        lineHasContent = false;
        segmentStart = index + 1;
      }

      if (segmentStart < data.length) {
        final segment = data.substring(segmentStart);
        output.insert(segment, _textAttributes(operation.attributes));
        documentOffset += segment.length;
        lineHasContent = true;
      }
    }
    return output;
  }

  /// Removes source-separator attributes copied by Quill onto newly inserted
  /// newlines while preserving separators that survived the replacement.
  static Delta sourceSeparatorPatch({
    required Delta before,
    required Delta after,
    required int index,
    required int replacedLength,
    required int insertedLength,
    Delta? insertedDelta,
  }) {
    final allowedOffsets = <int>{};
    final replacedEnd = index + replacedLength;
    final shift = insertedLength - replacedLength;
    for (final offset in _sourceSeparatorOffsets(before)) {
      if (offset < index) {
        allowedOffsets.add(offset);
      } else if (offset >= replacedEnd) {
        allowedOffsets.add(offset + shift);
      }
    }
    if (insertedDelta != null) {
      for (final offset in _sourceSeparatorOffsets(insertedDelta)) {
        allowedOffsets.add(index + offset);
      }
    }

    final patch = Delta();
    var patchOffset = 0;
    var documentOffset = 0;
    var lineHasContent = false;
    for (final operation in after.operations) {
      final data = operation.data;
      if (data is! String) {
        documentOffset += operation.length!;
        lineHasContent = true;
        continue;
      }
      for (var dataIndex = 0; dataIndex < data.length; dataIndex++) {
        if (data[dataIndex] != '\n') {
          documentOffset += 1;
          lineHasContent = true;
          continue;
        }
        final hasSeparator =
            operation.attributes?[sourceSeparatorAttribute] == true;
        final shouldHaveSeparator =
            !lineHasContent && allowedOffsets.contains(documentOffset);
        if (hasSeparator != shouldHaveSeparator) {
          if (documentOffset > patchOffset) {
            patch.retain(documentOffset - patchOffset);
          }
          patch.retain(1, {
            sourceSeparatorAttribute: shouldHaveSeparator ? true : null,
          });
          patchOffset = documentOffset + 1;
        }
        documentOffset += 1;
        lineHasContent = false;
      }
    }
    return patch;
  }

  static Map<String, dynamic>? _textAttributes(Map<String, dynamic>? source) {
    if (source == null || source.isEmpty) return null;
    final attributes = Map<String, dynamic>.from(source)
      ..remove(sourceSeparatorAttribute)
      ..remove(emptyKey)
      ..remove(sourceBreakKey);
    return attributes.isEmpty ? null : attributes;
  }

  static Map<String, dynamic>? _newlineAttributes(
    Map<String, dynamic>? source, {
    required bool lineHasContent,
    required bool isOnlyDocumentLine,
    required bool isFinalNewline,
  }) {
    final attributes = Map<String, dynamic>.from(source ?? const {})
      ..remove(sourceSeparatorAttribute);
    final isSourceSeparator =
        source?[sourceSeparatorAttribute] == true && !lineHasContent;
    final onlyPendingAlignment =
        !lineHasContent &&
        isFinalNewline &&
        attributes.keys
            .where(_blockAttributes.contains)
            .every((key) => key == 'align');
    if (onlyPendingAlignment) attributes.remove('align');
    final hasBlockStyle =
        attributes.keys.any(_blockAttributes.contains) ||
        attributes[literalLineKey] == true;

    if (lineHasContent ||
        isOnlyDocumentLine ||
        isSourceSeparator ||
        hasBlockStyle) {
      attributes.remove(emptyKey);
    } else {
      attributes[emptyKey] = true;
    }
    if (isFinalNewline) {
      attributes[sourceBreakKey] = false;
    } else {
      attributes.remove(sourceBreakKey);
    }
    return attributes.isEmpty ? null : attributes;
  }

  static Set<int> _sourceSeparatorOffsets(Delta delta) {
    final offsets = <int>{};
    var documentOffset = 0;
    for (final operation in delta.operations) {
      final data = operation.data;
      if (data is String &&
          operation.attributes?[sourceSeparatorAttribute] == true) {
        for (var index = 0; index < data.length; index++) {
          if (data[index] == '\n') offsets.add(documentOffset + index);
        }
      }
      documentOffset += operation.length!;
    }
    return offsets;
  }
}
