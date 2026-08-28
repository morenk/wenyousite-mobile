import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';

class WenyouEditorClipboardPastePlan {
  const WenyouEditorClipboardPastePlan({
    required this.delta,
    required this.replacementEnd,
  });

  final Delta delta;
  final int replacementEnd;
}

/// Resolves clipboard precedence and adapts complete blocks to the current
/// Quill line without leaking source-only Markdown separators into content.
class WenyouEditorClipboardPastePlanner {
  WenyouEditorClipboardPastePlanner._();

  static String? normalizeText(String? value) {
    if (value == null) return null;
    return value
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp('[\u2028\u2029]'), '\n')
        .replaceAll(
          RegExp('[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F]'),
          '',
        );
  }

  static WenyouEditorClipboardPastePlan? resolve({
    required String? clipboardText,
    required String? clipboardHtml,
    required String? marker,
    required Object? scope,
    required WenyouEditorClipboardStore store,
    required WenyouSiteClipboardParser siteParser,
    required String selectedText,
    required Delta document,
    required String documentPlainText,
    required int start,
    required int end,
  }) {
    final resolution = clipboardText == null
        ? const WenyouEditorClipboardResolution.noMatch()
        : store.resolve(clipboardText, marker: marker, scope: scope);
    var insert = resolution.delta;
    if (insert == null && !resolution.usePlainText) {
      insert = siteParser.parse(clipboardHtml);
      if (insert == null && clipboardText != null) {
        insert = internalReferenceDelta(clipboardText, selectedText);
      }
    }
    if (insert == null && (clipboardText == null || clipboardText.isEmpty)) {
      return null;
    }

    var delta =
        insert ??
        (Delta()..insert(clipboardText!, {
          MarkdownDeltaCodec.literalTextAttribute: true,
        }));
    var replacementEnd = end;
    final isStructuredBlock = insert != null && _endsWithNewline(insert);
    if (isStructuredBlock) {
      delta = _prepareStructuredBlockPaste(
        insert,
        document: document,
        plainText: documentPlainText,
        start: start,
        end: end,
      );
      if (replacementEnd < documentPlainText.length &&
          documentPlainText[replacementEnd] == '\n') {
        replacementEnd += 1;
      }
    }
    return WenyouEditorClipboardPastePlan(
      delta: delta,
      replacementEnd: replacementEnd,
    );
  }

  static Delta? internalReferenceDelta(
    String clipboardText,
    String selectedText,
  ) {
    final paste = resolveInternalReferencePaste(
      clipboardText: clipboardText,
      selectedText: selectedText,
    );
    if (paste == null) return null;
    return Delta()..insert({
      MarkdownDeltaCodec.internalReferenceEmbed: {
        'version': 1,
        'label': paste.label,
        'location': paste.reference.location.toString(),
      },
    });
  }

  static bool _endsWithNewline(Delta delta) {
    if (delta.operations.isEmpty) return false;
    final data = delta.operations.last.data;
    return data is String && data.endsWith('\n');
  }

  static Delta _prepareStructuredBlockPaste(
    Delta fragment, {
    required Delta document,
    required String plainText,
    required int start,
    required int end,
  }) {
    final output = Delta();
    final hasLeftText = start > 0 && plainText[start - 1] != '\n';
    final hasRightText = end < plainText.length && plainText[end] != '\n';
    if (hasLeftText) {
      final lineAttributes = _lineAttributesAt(document, start);
      output.insert('\n', lineAttributes.isEmpty ? null : lineAttributes);
      output.insert('\n', {
        MarkdownDeltaLineMetadata.sourceSeparatorAttribute: true,
      });
    }
    for (final operation in fragment.operations) {
      final attributes = Map<String, dynamic>.from(
        operation.attributes ?? const {},
      )..remove(MarkdownDeltaCodec.sourceBreakAttribute);
      output.insert(operation.data, attributes.isEmpty ? null : attributes);
    }
    if (hasRightText) {
      output.insert('\n', {
        MarkdownDeltaLineMetadata.sourceSeparatorAttribute: true,
      });
    }
    return output;
  }

  static Map<String, dynamic> _lineAttributesAt(Delta document, int offset) {
    var documentOffset = 0;
    for (final operation in document.operations) {
      final data = operation.data;
      if (data is String) {
        for (var index = 0; index < data.length; index++) {
          if (data[index] == '\n' && documentOffset + index >= offset) {
            final source = operation.attributes ?? const <String, dynamic>{};
            return {
              for (final key in const [
                'header',
                'list',
                'blockquote',
                'indent',
                MarkdownDeltaCodec.literalLineAttribute,
              ])
                if (source.containsKey(key)) key: source[key],
            };
          }
        }
      }
      documentOffset += operation.length!;
    }
    return const {};
  }
}
