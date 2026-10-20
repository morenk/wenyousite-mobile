import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_reader_paragraph_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_color.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void requireTextFontWriteSupport(String content, {required bool supported}) {
  if (supported || !content.contains('data-wenyou-font-v1')) return;
  final delta = MarkdownDeltaCodec.decode(content).delta;
  if (delta.operations.any(
    (op) =>
        op.attributes?['font'] != null ||
        switch (op.data) {
          {MarkdownDeltaCodec.compatibilityEmbed: {'raw': final String raw}} =>
            MarkdownTextFont.hasUnknown(raw),
          _ => false,
        },
  )) {
    throw const ApiFailure.textFontUnavailable();
  }
}

/// 颜色读取与写入能力独立于角色提及；旧服务不能接收恢复的有色草稿。
void requireTextColorWriteSupport(String content, {required bool supported}) {
  if (supported || !content.contains('data-wenyou-color-v1')) return;
  bool colored(List<md.Node> nodes) => nodes.any(
    (node) =>
        node is md.Element &&
        ((node.tag == MarkdownTextColor.tag &&
                node.attributes.containsKey('color')) ||
            colored(node.children ?? [])),
  );
  final nodes = md.Document(
    inlineSyntaxes: [MarkdownTextColorSyntax()],
    blockSyntaxes: [const MarkdownReaderParagraphSyntax()],
    extensionSet: md.ExtensionSet.gitHubFlavored,
  ).parseLines(content.split('\n'));
  if (colored(nodes)) {
    throw const ApiFailure.textColorUnavailable();
  }
}

/// 旧服务不能接收本地恢复或跨端粘贴的角色目标，保留正文等待兼容服务。
void requireMentionWriteSupport(String content, {required bool supported}) {
  if (supported || !content.contains('/users/')) return;
  final delta = MarkdownDeltaCodec.decode(content).delta;
  for (final operation in delta.toList()) {
    final data = operation.data;
    if (data is! Map) continue;
    final payload = data[MarkdownDeltaCodec.mentionEmbed];
    if (payload is Map &&
        MarkdownMentionTarget.fromPayload(payload)?.isLegacy == false) {
      throw const ApiFailure(
        userMessage: '暂时无法保存这段提及，草稿已保留。',
        businessCode: 40014,
      );
    }
  }
}
