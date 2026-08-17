import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

class MarkdownRichLine {
  const MarkdownRichLine({required this.spans, required this.lineAttributes});

  final List<MarkdownRichSpan> spans;
  final Map<String, dynamic> lineAttributes;
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
/// for proving that the candidate serializes back to the canonical input.
class MarkdownRichLineDecoder {
  MarkdownRichLineDecoder._();

  static MarkdownRichLine? decode(String source) {
    var inlineSource = source;
    final lineAttributes = <String, dynamic>{};
    final heading = RegExp(r'^(#{2,3}) (.+)$').firstMatch(source);
    final quote = RegExp(r'^> (.+)$').firstMatch(source);
    final list = RegExp(r'^( {0,6})(- |1\. )(.+)$').firstMatch(source);
    if (heading != null) {
      lineAttributes['header'] = heading.group(1)!.length;
      inlineSource = heading.group(2)!;
    } else if (quote != null) {
      lineAttributes['blockquote'] = true;
      inlineSource = quote.group(1)!;
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
