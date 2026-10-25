import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

/// 字体与颜色共用一个受控 span，禁止嵌套、任意 HTML 属性及跨行。
abstract final class MarkdownTextColor {
  static const tag = 'wenyou-text-color';
  static final opening = RegExp(
    r'<span (data-wenyou-(?:color-v1|font-v[12])="[^"<>\r\n]+"(?: data-wenyou-(?:color-v1|font-v[12])="[^"<>\r\n]+")?)>',
  );
  static final rgb = RegExp(r'^#[0-9A-Fa-f]{6}$');

  static Map<String, String>? attributes(
    Match match, {
    bool allowUnknownFonts = false,
  }) {
    final result = <String, String>{};
    final fields = RegExp(
      r'data-wenyou-(color|font)-v([12])="([^"]+)"',
    ).allMatches(match[1]!);
    for (final field in fields) {
      final key = field[1]!;
      final version = field[2]!;
      final value = field[3]!;
      if (result.containsKey(key) ||
          (key == 'color'
              ? version != '1' || !rgb.hasMatch(value)
              : version == '2'
              ? !MarkdownTextFont.isVersionId(value)
              : !MarkdownTextFont.ids.contains(value) &&
                    !(allowUnknownFonts &&
                        RegExp(r'^[a-z][a-z0-9-]*$').hasMatch(value)))) {
        return null;
      }
      result[key] = key == 'color' ? value.toUpperCase() : value;
    }
    return result.isEmpty ? null : result;
  }

  static String openingFor(Map<String, dynamic> marks) {
    final fields = [
      if (marks['font'] case final String font)
        'data-wenyou-font-v${MarkdownTextFont.isVersionId(font) ? 2 : 1}="$font"',
      if (marks['color'] case final String color)
        'data-wenyou-color-v1="$color"',
    ];
    return fields.isEmpty ? '' : '<span ${fields.join(' ')}>';
  }

  static String _maskCode(String source) => source.replaceAllMapped(
    md.CodeSyntax().pattern,
    (match) => match.start > 0 && source[match.start - 1] == '`'
        ? match[0]!
        : ' ' * match[0]!.length,
  );

  static List<md.Node>? parseInner(String source) {
    // 同形字面源码只允许处于真正的行内代码或转义区域。
    final masked = _maskCode(
      source,
    ).replaceAllMapped(RegExp(r'\\[!-/:-@\[-`{-~]'), (m) => ' ' * m[0]!.length);
    if (RegExp(r'<[^>]*>|!\[|\[\[|@全体玩家').hasMatch(masked)) return null;
    if (tokenizeInternalReferenceText(
      masked,
    ).any((segment) => segment is InternalReferencePortal)) {
      return null;
    }
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    ).parseInline(source);
    bool valid(List<md.Node> nodes) => nodes.every((node) {
      if (node is md.Text) return true;
      if (node is! md.Element ||
          !const {'strong', 'em', 'del', 'a', 'code'}.contains(node.tag)) {
        return false;
      }
      if (node.tag == 'a') {
        final href = node.attributes['href'];
        final uri = href == null ? null : Uri.tryParse(href);
        if (uri == null ||
            (uri.hasScheme &&
                !const {'http', 'https', 'mailto'}.contains(uri.scheme)) ||
            href!.startsWith('//') ||
            RegExp(r'^/users(?:/|$)').hasMatch(href) ||
            RegExp(
              r'wenyousite-(?:audio|sticker):',
            ).hasMatch(node.attributes['title'] ?? '') ||
            parseInternalReference(href) != null) {
          return false;
        }
      }
      return node.children != null && valid(node.children!);
    });
    return valid(nodes) ? nodes : null;
  }

  static bool hasCrossingMarks(String value) {
    bool visit(List<md.Node> nodes, bool styled) => nodes.any((node) {
      if (node is md.Text) {
        return styled &&
            RegExp(
              r'<span data-wenyou-(?:color-v1|font-v[12])=|</span>',
            ).hasMatch(node.text);
      }
      if (node is! md.Element || node.tag == 'code') return false;
      return visit(
        node.children ?? [],
        styled || const {'strong', 'em', 'del', 'a'}.contains(node.tag),
      );
    });
    return visit(
      md.Document(
        encodeHtml: false,
        extensionSet: md.ExtensionSet.gitHubFlavored,
      ).parseInline(value),
      false,
    );
  }

  static ({int end, String inner})? range(String source, Match match) {
    final masked = _maskCode(source);
    final close = masked.indexOf('</span>', match.end);
    if (close < 0) return null;
    final inner = source.substring(match.end, close);
    if (inner.isEmpty || inner.contains('\n') || inner.contains('\r')) {
      return null;
    }
    return (end: close + '</span>'.length, inner: inner);
  }

  static String maskValidTags(String line) {
    if (hasCrossingMarks(line)) return line;
    final result = line.split('');
    for (final match in opening.allMatches(_maskCode(line))) {
      var slashCount = 0;
      for (var i = match.start - 1; i >= 0 && line[i] == r'\'; i--) {
        slashCount++;
      }
      final found = range(line, match);
      if (attributes(match, allowUnknownFonts: true) == null ||
          slashCount.isOdd ||
          found == null ||
          parseInner(found.inner) == null) {
        continue;
      }
      result.fillRange(match.start, match.end, ' ');
      result.fillRange(found.end - '</span>'.length, found.end, ' ');
    }
    return result.join();
  }
}

class MarkdownTextColorSyntax extends md.InlineSyntax {
  MarkdownTextColorSyntax() : super(MarkdownTextColor.opening.pattern);

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    final match = pattern.matchAsPrefix(
      parser.source,
      startMatchPos ?? parser.pos,
    );
    if (match == null) return false;
    final attributes = MarkdownTextColor.attributes(
      match,
      allowUnknownFonts: true,
    );
    if (attributes == null) return false;
    if (MarkdownTextColor.hasCrossingMarks(parser.source)) return false;
    final range = MarkdownTextColor.range(parser.source, match);
    if (range == null) return false;
    final nodes = MarkdownTextColor.parseInner(range.inner);
    if (nodes == null) return false;
    parser.writeText();
    parser.addNode(
      md.Element(MarkdownTextColor.tag, nodes)..attributes.addAll(attributes),
    );
    parser.consume(range.end - match.start);
    return true;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) => false;
}
