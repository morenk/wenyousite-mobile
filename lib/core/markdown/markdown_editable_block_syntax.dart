/// 编辑器可写出的标题／列表前缀。块模型与行解码共用同一套识别规则。
///
/// 空内容是合法块状态；标记本身不是正文。调用方仍须先排除代码、任务
/// 列表等不支持的上下文，不能用前缀识别替代完整 Markdown 语义校验。
abstract final class MarkdownEditableBlockSyntax {
  static final _heading = RegExp(r'^(#{2,3})(?:[\t ]+(.*))?$');
  static final _list = RegExp(r'^( {0,6})(-|1\.)(?:[\t ](.*))?$', dotAll: true);
  static final _onlyAsciiSpace = RegExp(r'^[\t ]*$');

  /// 阅读复制允许去掉合法的 ATX 结束标记；普通编辑保留既有源码语义。
  static ({int level, String content})? readerHeading(String source) {
    final match = RegExp(
      r'^(#{2,3})[\t ]+(.+?)[\t ]+#+[\t ]*$',
    ).firstMatch(source);
    return match == null
        ? null
        : (level: match.group(1)!.length, content: match.group(2)!);
  }

  static ({int level, String content})? heading(String source) {
    final match = _heading.firstMatch(source);
    if (match == null) return null;
    final content = match.group(2) ?? '';
    return (
      level: match.group(1)!.length,
      content: _onlyAsciiSpace.hasMatch(content) ? '' : content,
    );
  }

  static ({bool ordered, int indent, String content})? listItem(String source) {
    final match = _list.firstMatch(source);
    if (match == null || match.group(1)!.length.isOdd) return null;
    final content = match.group(3) ?? '';
    return (
      ordered: match.group(2) == '1.',
      indent: match.group(1)!.length ~/ 2,
      content: _onlyAsciiSpace.hasMatch(content) ? '' : content,
    );
  }

  static String headingLine(int level, String content) =>
      content.isEmpty ? '#' * level : '${'#' * level} $content';

  static String listLine({
    required bool ordered,
    required int indent,
    required String content,
  }) {
    final marker = '${'  ' * indent}${ordered ? '1.' : '-'}';
    return content.isEmpty ? marker : '$marker $content';
  }
}
