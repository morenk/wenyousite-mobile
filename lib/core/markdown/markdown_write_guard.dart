import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

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
