import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_list_structure.dart';

/// 复杂列表不能恢复成可编辑列表时，仍按阅读树投影文字。
///
/// 此入口只接受站内阅读源码；外部剪贴板和编辑中的兼容源码不经过它。
/// Markdown 解析器只解码语法转义，代码节点中的反斜杠保留原样。
String readerMarkdownListText(String source) {
  final document = md.Document(
    blockSyntaxes: MarkdownListStructure.blockSyntaxes(),
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
  );
  return document
      .parseLines(source.split('\n'))
      .map((node) => _text(node, 0))
      .join('\n\n');
}

String _text(md.Node node, int depth) {
  if (node is! md.Element) return node.textContent;
  final children = node.children ?? const <md.Node>[];
  if (node.tag == 'ul' || node.tag == 'ol') {
    var number = int.tryParse(node.attributes['start'] ?? '1') ?? 1;
    return children
        .whereType<md.Element>()
        .map((item) {
          final marker = node.tag == 'ol' ? '${number++}.' : '•';
          return '${'  ' * depth}$marker ${_listItem(item, depth)}';
        })
        .join('\n');
  }
  if (node.tag == 'br') return '\n';
  if (node.tag == 'hr') return '';
  if (node.tag == 'img') {
    return node.attributes['title']?.startsWith('wenyousite-sticker:v1:') ==
            true
        ? '[表情]'
        : '[图片]';
  }
  if (node.tag == 'pre') {
    // 块解析器附加的末尾 LF 是代码块边界，不额外生成一个可编辑空行。
    return node.textContent.replaceFirst(RegExp(r'\n$'), '');
  }
  return children
      .map((child) => _text(child, depth))
      .join(node.tag == 'blockquote' ? '\n\n' : '');
}

String _listItem(md.Element item, int depth) {
  final output = StringBuffer();
  var previousWasList = false;
  var previousWasBlock = false;
  for (final child in item.children ?? const <md.Node>[]) {
    final isList =
        child is md.Element && (child.tag == 'ul' || child.tag == 'ol');
    final isBlock =
        child is md.Element &&
        const {
          'p',
          'pre',
          'blockquote',
          'h1',
          'h2',
          'h3',
          'h4',
          'h5',
          'h6',
        }.contains(child.tag);
    if (output.isNotEmpty &&
        (isList || previousWasList || isBlock || previousWasBlock)) {
      output.write(isList || previousWasList ? '\n' : '\n\n');
    }
    output.write(_text(child, isList ? depth + 1 : depth));
    previousWasList = isList;
    previousWasBlock = isBlock;
  }
  return output.toString();
}
