import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

/// 最近回复与搜索、草稿复用正文摘要，仅额外呈现骰子结果。
String recentReplyPreview(
  String content, {
  Map<String, String> diceLabels = const {},
}) => MarkdownContent.toPlainTextPreview(
  content,
  diceLabels: diceLabels,
  showUnresolvedDiceResult: true,
);
