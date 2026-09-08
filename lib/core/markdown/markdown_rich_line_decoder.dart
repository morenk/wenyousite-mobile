import 'package:flutter/foundation.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

class MarkdownRichLine {
  const MarkdownRichLine({required this.spans, required this.lineAttributes});

  final List<MarkdownRichSpan> spans;
  final Map<String, dynamic> lineAttributes;

  bool semanticallyEquivalentTo(MarkdownRichLine other) {
    if (!mapEquals(lineAttributes, other.lineAttributes)) return false;
    final left = _mergedSpans(spans);
    final right = _mergedSpans(other.spans);
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      final a = left[index];
      final b = right[index];
      if (a.text != b.text ||
          !mapEquals(a.attributes, b.attributes) ||
          a.internalReference?.label != b.internalReference?.label ||
          a.internalReference?.reference.location.toString() !=
              b.internalReference?.reference.location.toString()) {
        return false;
      }
    }
    return true;
  }

  static List<MarkdownRichSpan> _mergedSpans(List<MarkdownRichSpan> spans) {
    final result = <MarkdownRichSpan>[];
    for (final span in spans) {
      if (span.internalReference == null &&
          result.isNotEmpty &&
          result.last.internalReference == null &&
          mapEquals(result.last.attributes, span.attributes)) {
        final last = result.removeLast();
        result.add(MarkdownRichSpan(last.text + span.text, span.attributes));
      } else {
        result.add(span);
      }
    }
    return result;
  }
}

class MarkdownRichSpan {
  const MarkdownRichSpan(this.text, this.attributes) : internalReference = null;

  const MarkdownRichSpan.internalReference(this.internalReference)
    : text = '',
      attributes = null;

  final String text;
  final Map<String, dynamic>? attributes;
  final InternalReferencePortal? internalReference;
}

/// Parses the deliberately small Markdown subset supported by the editor.
///
/// The result is independent from Quill. The Delta adapter remains responsible
/// for proving that canonical serialization preserves the full semantics.
class MarkdownRichLineDecoder {
  MarkdownRichLineDecoder._();

  /// Maps CommonMark list markers accepted by the reader to the editor's
  /// canonical markers without changing ordinary paragraph text.
  static String canonicalizeReaderBlockPrefix(String source) {
    final heading = RegExp(
      r'^(#{2,3})[\t ]+(.+?)[\t ]+#+[\t ]*$',
    ).firstMatch(source);
    if (heading != null) return '${heading.group(1)} ${heading.group(2)}';
    final quote = MarkdownContent.quoteLineContent(source);
    if (quote != null) return quote.isEmpty ? '>' : '> $quote';
    final bullet = RegExp(r'^( {0,6})[-+*][\t ]+(.+)$').firstMatch(source);
    if (bullet != null && bullet.group(1)!.length.isEven) {
      return '${bullet.group(1)}- ${bullet.group(2)}';
    }
    final ordered = RegExp(r'^( {0,6})\d+[.)][\t ]+(.+)$').firstMatch(source);
    if (ordered != null && ordered.group(1)!.length.isEven) {
      return '${ordered.group(1)}1. ${ordered.group(2)}';
    }
    return source;
  }

  static bool isReaderThematicBreak(String source) => RegExp(
    r'^ {0,3}(?:(?:\*\s*){3,}|(?:_\s*){3,}|(?:-\s*){3,})$',
  ).hasMatch(source);

  static MarkdownRichLine? decode(String source) {
    var inlineSource = source;
    final lineAttributes = <String, dynamic>{};
    // 空标题也是合法的块；先选 H2/H3、再输入文字时不能将标记读成正文。
    final heading = RegExp(r'^(#{2,3})(?:[\t ]+(.*))?$').firstMatch(source);
    final quote = MarkdownContent.quoteLineContent(source);
    final list = RegExp(r'^( {0,6})(- |1\. )(.+)$').firstMatch(source);
    if (heading != null) {
      lineAttributes['header'] = heading.group(1)!.length;
      inlineSource = heading.group(2) ?? '';
    } else if (quote != null) {
      lineAttributes['blockquote'] = true;
      inlineSource = quote;
    } else if (list != null) {
      final spaces = list.group(1)!.length;
      final content = list.group(3)!;
      if (spaces.isOdd || RegExp(r'^\[[ xX]\]\s').hasMatch(content)) {
        return null;
      }
      lineAttributes['list'] = list.group(2) == '- ' ? 'bullet' : 'ordered';
      if (spaces > 0) lineAttributes['indent'] = spaces ~/ 2;
      inlineSource = content;
    }

    inlineSource = MarkdownInlineBoundary.canonicalize(inlineSource);

    final spans = <MarkdownRichSpan>[];
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    ).parseInline(inlineSource);
    if (!_appendNodes(nodes, const {}, spans)) return null;
    return MarkdownRichLine(
      spans: List.unmodifiable(spans),
      lineAttributes: Map.unmodifiable(lineAttributes),
    );
  }

  /// Keeps reader semantics when valid Markdown nesting cannot be represented
  /// losslessly by the editor's mutually exclusive inline attributes.
  static MarkdownRichLine? decodeEditable(String source) {
    final decoded = decode(source);
    if (decoded == null) return null;
    final hasFormatting =
        decoded.lineAttributes.isNotEmpty ||
        decoded.spans.any((span) => span.attributes?.isNotEmpty ?? false);
    if (!hasFormatting) return null;
    final spans = <MarkdownRichSpan>[];
    for (final span in decoded.spans) {
      if (span.internalReference != null) {
        spans.add(span);
        continue;
      }
      final attributes = Map<String, dynamic>.from(
        span.attributes ?? const <String, dynamic>{},
      );
      if (attributes['code'] == true) {
        attributes.removeWhere(
          (key, _) => const {'bold', 'italic', 'strike', 'link'}.contains(key),
        );
      }
      _appendEditableText(spans, span.text, attributes);
    }
    return MarkdownRichLine(
      spans: List.unmodifiable(spans),
      lineAttributes: decoded.lineAttributes,
    );
  }

  static void _appendEditableText(
    List<MarkdownRichSpan> output,
    String text,
    Map<String, dynamic> attributes,
  ) {
    if (text.isEmpty) return;
    if (attributes.isEmpty || attributes['code'] == true) {
      output.add(MarkdownRichSpan(text, _attributesOrNull(attributes)));
      return;
    }
    final leading = RegExp(r'^\s+').firstMatch(text)?.group(0) ?? '';
    final trailing = RegExp(r'\s+$').firstMatch(text)?.group(0) ?? '';
    if (leading.length + trailing.length >= text.length) {
      output.add(MarkdownRichSpan(text, null));
      return;
    }
    if (leading.isNotEmpty) output.add(MarkdownRichSpan(leading, null));
    output.add(
      MarkdownRichSpan(
        text.substring(leading.length, text.length - trailing.length),
        Map.unmodifiable(attributes),
      ),
    );
    if (trailing.isNotEmpty) output.add(MarkdownRichSpan(trailing, null));
  }

  static Map<String, dynamic>? _attributesOrNull(
    Map<String, dynamic> attributes,
  ) => attributes.isEmpty ? null : Map.unmodifiable(attributes);

  static bool _appendNodes(
    List<md.Node> nodes,
    Map<String, dynamic> inherited,
    List<MarkdownRichSpan> output,
  ) {
    for (final node in nodes) {
      if (node is md.Text) {
        if (node.text.isNotEmpty) {
          output.add(
            MarkdownRichSpan(
              node.text,
              inherited.isEmpty ? null : Map.unmodifiable(inherited),
            ),
          );
        }
        continue;
      }
      if (node is! md.Element || node.children == null) return false;
      final attributes = Map<String, dynamic>.from(inherited);
      if (node.tag == 'strong') {
        attributes['bold'] = true;
      } else if (node.tag == 'em') {
        attributes['italic'] = true;
      } else if (node.tag == 'del') {
        attributes['strike'] = true;
      } else if (node.tag == 'code') {
        attributes['code'] = true;
      } else if (node.tag == 'a') {
        // Delta links have no title field; accepting one would erase source
        // metadata during canonicalization (including escaped image syntax).
        if (node.attributes.containsKey('title')) return false;
        final href = node.attributes['href'];
        final reference = href == null ? null : parseInternalReference(href);
        if (reference != null && inherited.isEmpty) {
          final label = _plainText(node.children!);
          if (label == null ||
              label.isEmpty ||
              label.contains(']') ||
              label.contains('\n') ||
              label.contains('\r')) {
            return false;
          }
          output.add(
            MarkdownRichSpan.internalReference(
              InternalReferencePortal(label: label, reference: reference),
            ),
          );
          continue;
        }
        final uri = href == null ? null : Uri.tryParse(href);
        if (uri == null || !uri.hasScheme || !MarkdownContent.isSafeLink(uri)) {
          return false;
        }
        attributes['link'] = href;
      } else {
        return false;
      }
      if (!_appendNodes(node.children!, attributes, output)) return false;
    }
    return true;
  }

  static String? _plainText(List<md.Node> nodes) {
    final value = StringBuffer();
    for (final node in nodes) {
      if (node is! md.Text) return null;
      value.write(node.text);
    }
    return value.toString();
  }
}
