import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

/// 阅读层的图片位置，仅存在于解析树，不改写已发布 Markdown。
class MarkdownImageOccurrenceSyntax extends md.ImageSyntax {
  MarkdownImageOccurrenceSyntax({
    this.startIndex = 0,
    this.references = const {},
  });

  final int startIndex;
  final Map<String, md.LinkReference> references;
  md.Document? _document;
  var _index = 0;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    if (!identical(_document, parser.document)) {
      _document = parser.document;
      _index = startIndex;
      parser.document.linkReferences.addAll(references);
    }
    return super.onMatch(parser, match);
  }

  @override
  md.Element createNode(
    String destination,
    String? title, {
    required List<md.Node> Function() getChildren,
  }) {
    final element = super.createNode(
      destination,
      title,
      getChildren: getChildren,
    );
    if (isOrdinaryImage(element)) {
      element.attributes['data-image-index'] = '${_index++}';
    }
    return element;
  }

  static bool isOrdinaryImage(md.Element element) =>
      element.tag == 'img' &&
      !(element.attributes['title']?.startsWith('wenyousite-sticker:') ??
          false) &&
      _safeGalleryUri(Uri.tryParse(element.attributes['src'] ?? '') ?? Uri());

  static bool _safeGalleryUri(Uri uri) =>
      MarkdownContent.isSafeImage(uri) &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      uri.host != 'local.invalid';

  static int count(
    String source, {
    Map<String, md.LinkReference> references = const {},
  }) {
    var count = 0;
    void visit(md.Node node) {
      if (node is! md.Element) return;
      if (isOrdinaryImage(node)) count++;
      if (node.tag == 'code' || node.tag == 'pre' || node.tag == 'img') return;
      for (final child in node.children ?? const <md.Node>[]) {
        visit(child);
      }
    }

    final document = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored)
      ..linkReferences.addAll(references);
    for (final node in document.parse(source)) {
      visit(node);
    }
    return count;
  }
}
