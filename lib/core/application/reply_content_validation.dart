import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

/// 附件属于有效回复；正文按各入口原有的 Markdown／纯文本语义判空。
String? replyContentValidationMessage(
  String content, {
  bool plainText = false,
  bool hasAttachment = false,
}) {
  if (hasAttachment) return null;
  // 仅用于可见性判断，不改写发送正文或另建一套 Unicode 空白规则。
  final source = plainText
      ? MarkdownContent.literalizeInlineText(content)
      : content;
  return MarkdownContent.hasVisibleContent(source) ? null : '消息框不能为空。';
}
