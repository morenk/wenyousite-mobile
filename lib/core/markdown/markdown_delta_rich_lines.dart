import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_inline_encoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_source.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_rich_line_decoder.dart';

/// 将中立富文本行映射为 Delta，并通过重新解析验证可编辑语义。
final class MarkdownDeltaRichLines {
  MarkdownDeltaRichLines._();

  static const internalReferenceEmbed = 'wenyou_internal_reference';
  static void append(MarkdownRichLine richLine, Delta delta) {
    for (final span in richLine.spans) {
      final portal = span.internalReference;
      if (portal == null) {
        // 标签形可见文字保留来源，取消代码格式后也不能变成样式。
        // 原样保留的兼容源码不走此处。
        final literalHtml =
            span.text.contains('<') &&
            MarkdownInlineSource.analyze(span.text).html.isNotEmpty;
        delta.insert(
          span.text,
          literalHtml
              ? {
                  ...?span.attributes,
                  MarkdownDeltaInlineEncoder.literalTextKey: true,
                }
              : span.attributes,
        );
      } else {
        delta.insert({
          internalReferenceEmbed: {
            'version': 1,
            'label': portal.label,
            'location': portal.reference.location.toString(),
          },
        });
      }
    }
  }

  static MarkdownRichLine? decode(
    String source, {
    bool protocolTextOnly = false,
    bool inlineOnly = false,
    required String Function(Delta) encode,
  }) {
    if (!protocolTextOnly &&
        (source.contains('](/users/') ||
            source.contains('@全体玩家') ||
            source.toLowerCase().contains('[[dice:') ||
            source.contains('!['))) {
      return null;
    }
    final decode = inlineOnly
        ? MarkdownRichLineDecoder.decodeInline
        : MarkdownRichLineDecoder.decode;
    final richLine = decode(source);
    if (richLine == null) return null;

    final candidate = Delta();
    append(richLine, candidate);
    candidate.insert('\n', {
      ...richLine.lineAttributes,
      MarkdownDeltaLineMetadata.sourceBreakKey: false,
    });
    try {
      final encoded = encode(candidate);
      // Automatic URL links retain their existing source spelling. Explicit
      // rich marks may canonicalize their nesting after semantic proof.
      if (encoded != MarkdownInlineBoundary.canonicalize(source) &&
          RegExp(r'(^|[\s>])<?https?://').hasMatch(source)) {
        return null;
      }
      final reparsed = decode(encoded);
      if (reparsed == null || !richLine.semanticallyEquivalentTo(reparsed)) {
        return null;
      }
    } on MarkdownCodecException {
      return null;
    }
    return richLine;
  }
}
