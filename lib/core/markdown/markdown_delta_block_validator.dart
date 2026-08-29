import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

class MarkdownDeltaBlockValidator {
  MarkdownDeltaBlockValidator._();

  static void validate(Delta delta, {required String horizontalRuleEmbed}) {
    var lineHasContent = false;
    var lineHasHorizontalRule = false;
    for (final operation in delta.operations) {
      final data = operation.data;
      if (data is String) {
        for (var index = 0; index < data.length; index++) {
          if (data[index] == '\n') {
            if (lineHasHorizontalRule &&
                operation.attributes?.keys.any(
                      const {
                        'header',
                        'list',
                        'blockquote',
                        'indent',
                        'align',
                      }.contains,
                    ) ==
                    true) {
              throw const MarkdownCodecException('分隔线不能同时作为标题、列表或引用');
            }
            lineHasContent = false;
            lineHasHorizontalRule = false;
          } else {
            if (lineHasHorizontalRule) {
              throw const MarkdownCodecException('分隔线必须独占一行');
            }
            lineHasContent = true;
          }
        }
        continue;
      }
      if (data is! Map ||
          !Map<String, dynamic>.from(data).containsKey(horizontalRuleEmbed)) {
        if (lineHasHorizontalRule) {
          throw const MarkdownCodecException('分隔线必须独占一行');
        }
        lineHasContent = true;
        continue;
      }
      if (lineHasContent || lineHasHorizontalRule) {
        throw const MarkdownCodecException('分隔线必须独占一行');
      }
      lineHasHorizontalRule = true;
    }
    if (lineHasHorizontalRule) {
      throw const MarkdownCodecException('分隔线后缺少块终止换行');
    }
  }
}
