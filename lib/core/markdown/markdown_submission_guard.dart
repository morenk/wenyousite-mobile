import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_source_protection.dart';

/// 源码降级只保留编辑内容；实际保存前仍须拒绝白名单之外的 URL scheme。
abstract final class MarkdownSubmissionGuard {
  static void validate(String markdown) {
    final source = MarkdownSourceProtection.prepareForReader(markdown);
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
    ).parseLines(source.split('\n'));
    for (final node in nodes) {
      _validateNode(node);
    }
  }

  static void _validateNode(md.Node node) {
    if (node is! md.Element) return;
    final destination = node.tag == 'a'
        ? node.attributes['href']
        : node.tag == 'img'
        ? node.attributes['src']
        : null;
    if (destination != null) {
      final uri = Uri.tryParse(destination);
      // 相对站内坐标沿用原有节点校验；这里不赋予新链接或图片可编辑权限。
      if (uri == null ||
          uri.hasScheme &&
              !(node.tag == 'img'
                  ? MarkdownContent.isSafeImage(uri)
                  : MarkdownContent.isSafeLink(uri))) {
        throw const MarkdownCodecException('链接地址不受支持，请修改后再保存。');
      }
    }
    for (final child in node.children ?? const <md.Node>[]) {
      _validateNode(child);
    }
  }
}
