import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_compatibility_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_source_protection.dart';

/// 最近回复从完整正文生成阅读摘要，避免复用按实体源码提前截断的 preview。
String recentReplyPreview(
  String content, {
  Map<String, String> diceLabels = const {},
}) {
  // 对齐标记本身是 Markdown 引用定义，交给块解析器忽略；代码内保留原文。
  final source = MarkdownContent.normalize(
    MarkdownSourceProtection.prepareForReader(content),
  );
  final nodes = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    blockSyntaxes: [_EmptyParagraph()],
    inlineSyntaxes: [
      _Mention(),
      _Dice(diceLabels),
      ...MarkdownInlineCompatibilitySyntax.create(),
    ],
  ).parseLines(source.split('\n'));
  final output = StringBuffer();
  void append(md.Node node) {
    if (node is md.Text) {
      // 实体只由 Markdown 解析一次；代码和转义后的字面量保持原文。
      output.write(node.text);
      return;
    }
    if (node is! md.Element) return;
    if (node.tag == 'img') {
      output.write('[图片]');
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
  return runes.length <= 180
      ? text
      : '${String.fromCharCodes(runes.take(179))}…';
}

class _Mention extends md.InlineSyntax {
  _Mention() : super(MarkdownMentionTarget.nodePattern, startCharacter: 0x5b);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final target = MarkdownMentionTarget.parse(match[2]!);
    if (target == null || !target.acceptsLabel(match[1]!)) return false;
    // 与阅读器一致，提及昵称是原子文字，不能把昵称内的实体或格式再解析。
    parser.addNode(md.Text(match[1]!));
    return true;
  }
}

class _Dice extends md.InlineSyntax {
  _Dice(this.labels)
    : super(
        MarkdownDiceContract.nodeAtStart.pattern.substring(1),
        startCharacter: 0x5b,
        caseSensitive: false,
      );
  final Map<String, String> labels;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final notation = MarkdownDiceContract.normalizeNotation(match[2]!);
    if (notation == null) return false;
    parser.addNode(
      md.Text('[${labels[match[1]!.toLowerCase()] ?? '$notation = ?'}]'),
    );
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
