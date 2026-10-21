import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_compatibility_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_reader_paragraph_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_color.dart';

/// 将完整正文解析为可见文字，仅在解析结束后截断。
String markdownPlainTextPreview(
  String source, {
  required int maxLength,
  Map<String, String> mentionLabels = const {},
  Map<String, String> diceLabels = const {},
  bool showUnresolvedDiceResult = false,
}) {
  // 对齐标记是引用定义，由块解析器忽略；代码内保留原文。
  final nodes = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    blockSyntaxes: [
      // 标准缩进代码优先于颜色段落识别，代码中的 span 是字面正文。
      const md.CodeBlockSyntax(),
      _EmptyParagraph(),
      const MarkdownReaderParagraphSyntax(),
    ],
    inlineSyntaxes: [
      MarkdownTextColorSyntax(),
      _Mention(mentionLabels),
      _Dice(diceLabels, showUnresolvedDiceResult),
      ...MarkdownInlineCompatibilitySyntax.create(),
    ],
  ).parseLines(source.split('\n'));
  final output = StringBuffer();
  void append(md.Node node) {
    if (node is md.Text) {
      // 实体只由解析器解码一次，不对代码、转义或损坏标记再次删标签。
      output.write(node.text);
      return;
    }
    if (node is! md.Element) return;
    if (node.tag == 'img') {
      if ((node.attributes['src'] ?? '').isNotEmpty) output.write('[图片]');
      return;
    }
    if (node.tag == 'br' || node.tag == 'hr') {
      output.write(' ');
      return;
    }
    if (node.tag == 'a' &&
        node.textContent == node.attributes['href'] &&
        RegExp(
          r'^https?://',
          caseSensitive: false,
        ).hasMatch(node.textContent)) {
      output.write('[链接]');
      return;
    }
    const blocks = {
      'p',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'blockquote',
      'pre',
      'ul',
      'ol',
      'li',
      'table',
      'tr',
      'th',
      'td',
    };
    final block = blocks.contains(node.tag);
    if (block) output.write(' ');
    for (final child in node.children ?? const <md.Node>[]) {
      append(child);
    }
    if (block) output.write(' ');
  }

  for (final node in nodes) {
    append(node);
  }
  final text = output
      .toString()
      .replaceAll(RegExp(r'\s+', unicode: true), ' ')
      .trim();
  final runes = text.runes.toList(growable: false);
  return runes.length <= maxLength
      ? text
      : '${String.fromCharCodes(runes.take(maxLength - 1))}…';
}

class _Mention extends md.InlineSyntax {
  _Mention(this.labels)
    : super(MarkdownMentionTarget.nodePattern, startCharacter: 0x5b);
  final Map<String, String> labels;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final target = MarkdownMentionTarget.parse(match[2]!);
    if (target == null || !target.acceptsLabel(match[1]!)) return false;
    // 原子昵称不再解析实体或格式；角色投影仍使用完整身份键。
    final label = match[1]!.substring(1);
    parser.addNode(md.Text('@${labels[target.projectionKey(label)] ?? label}'));
    return true;
  }
}

class _Dice extends md.InlineSyntax {
  _Dice(this.labels, this.showUnresolvedResult)
    : super(
        MarkdownDiceContract.nodeAtStart.pattern.substring(1),
        startCharacter: 0x5b,
        caseSensitive: false,
      );
  final Map<String, String> labels;
  final bool showUnresolvedResult;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final notation = MarkdownDiceContract.normalizeNotation(match[2]!);
    if (notation == null) return false;
    final fallback = showUnresolvedResult ? '$notation = ?' : notation;
    parser.addNode(md.Text('[${labels[match[1]!.toLowerCase()] ?? fallback}]'));
    return true;
  }
}

class _EmptyParagraph extends md.BlockSyntax {
  @override
  RegExp get pattern =>
      RegExp(r'^ {0,3}<br\s*/?>[\t ]*$', caseSensitive: false);

  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();
    return md.Element.empty('br');
  }
}
