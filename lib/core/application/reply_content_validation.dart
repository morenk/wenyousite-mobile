import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

/// 附件和骰子同样属于有效回复；空白或仅格式标记不属于内容。
String? replyContentValidationMessage(
  String content, {
  bool hasAttachment = false,
}) => hasAttachment || MarkdownContent.hasVisibleContent(content)
    ? null
    : '消息框不能为空。';
