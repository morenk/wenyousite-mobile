import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editable_block_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_code_source.dart';

/// 验证行属性并写出受支持块；空块与有内容块经过同一入口和冲突规则。
abstract final class MarkdownDeltaBlockEncoder {
  static const emptyParagraphAttribute = MarkdownDeltaLineMetadata.emptyKey;
  static const sourceBreakAttribute = MarkdownDeltaLineMetadata.sourceBreakKey;
  static const literalLineAttribute = MarkdownDeltaLineMetadata.literalLineKey;
  static const literalTextAttribute = 'wenyou_literal_text';
  static const alignmentAttribute = 'align';

  static void validateTextAttributes(Map<String, dynamic> attributes) {
    _rejectUnknownAttributes(attributes, const {
      'bold',
      'italic',
      'strike',
      'code',
      'link',
      emptyParagraphAttribute,
      sourceBreakAttribute,
      literalLineAttribute,
      literalTextAttribute,
      MarkdownInlineCodeSource.key,
      MarkdownDeltaLineMetadata.guardedWhitespaceKey,
      MarkdownDeltaLineMetadata.guardedLeadingWhitespaceKey,
      alignmentAttribute,
      'header',
      'list',
      'blockquote',
      'indent',
    });
  }

  static String encode(
    String content,
    Map<String, dynamic>? attributes, {
    required bool containsLiteralText,
  }) {
    if (attributes == null || attributes.isEmpty) {
      return containsLiteralText
          ? MarkdownContent.protectUnsafeWhitespace(content)
          : content;
    }
    validateTextAttributes(attributes);
    if (attributes[literalLineAttribute] == true) {
      final incompatible = attributes.keys.where(
        (key) => key != literalLineAttribute && key != sourceBreakAttribute,
      );
      if (incompatible.isNotEmpty) {
        throw const MarkdownCodecException('字面源码行不能携带其他富文本属性');
      }
      return MarkdownContent.literalizeLine(content);
    }
    if (attributes[emptyParagraphAttribute] == true) {
      if (content.isNotEmpty ||
          attributes.containsKey('header') ||
          attributes.containsKey('list') ||
          attributes.containsKey('indent')) {
        throw const MarkdownCodecException('这段内容暂时无法安全编辑');
      }
      return attributes['blockquote'] == true ? '> <br />' : '<br />';
    }

    var canonicalContent = MarkdownInlineBoundary.canonicalize(content);

    final indentValue = attributes['indent'];
    final indent = switch (indentValue) {
      null => 0,
      int value when value >= 0 && value <= 2 => value,
      _ => throw const MarkdownCodecException('列表最多支持三级'),
    };
    final header = attributes['header'];
    final list = attributes['list'];
    final quote = attributes['blockquote'] == true;
    final blockStyleCount =
        (header == null ? 0 : 1) + (list == null ? 0 : 1) + (quote ? 1 : 0);
    if (blockStyleCount > 1) {
      throw const MarkdownCodecException('同一行不能组合标题、列表和引用');
    }
    if (blockStyleCount > 0 &&
        (RegExp(r'^[\t ]+$').hasMatch(canonicalContent) ||
            (list != null &&
                RegExp(r'^[\t \u00a0]+$').hasMatch(canonicalContent)))) {
      // 区分用户输入的空格／Tab 与块标记后的语法空白，不添加占位文字。
      canonicalContent = canonicalContent.codeUnits
          .map((unit) => '&#$unit;')
          .join();
    }
    final hasUnsafeWhitespace =
        canonicalContent.startsWith('    ') ||
        (attributes[MarkdownDeltaLineMetadata.guardedLeadingWhitespaceKey] ==
                true &&
            canonicalContent.startsWith(' ')) ||
        canonicalContent.startsWith('\t') ||
        RegExp(r' {2,}$').hasMatch(canonicalContent);
    if (hasUnsafeWhitespace &&
        blockStyleCount == 0 &&
        (containsLiteralText ||
            attributes[MarkdownDeltaLineMetadata.guardedWhitespaceKey] ==
                true)) {
      return MarkdownContent.protectUnsafeWhitespace(
        canonicalContent,
        minimumIndent:
            attributes[MarkdownDeltaLineMetadata.guardedLeadingWhitespaceKey] ==
                true
            ? 1
            : 4,
      );
    }
    if (header != null) {
      if (header != 2 && header != 3) {
        throw const MarkdownCodecException('编辑器只支持二级与三级标题');
      }
      return MarkdownEditableBlockSyntax.headingLine(
        header as int,
        canonicalContent,
      );
    }
    if (list != null) {
      if (list != 'bullet' && list != 'ordered') {
        throw const MarkdownCodecException('编辑器列表类型不受支持');
      }
      return canonicalContent;
    }
    if (quote) return canonicalContent.isEmpty ? '>' : '> $canonicalContent';
    if (indent != 0) {
      throw const MarkdownCodecException('只有列表行可以携带缩进');
    }
    return canonicalContent;
  }

  static void _rejectUnknownAttributes(
    Map<String, dynamic> attributes,
    Set<String> allowed,
  ) {
    final unknown = attributes.keys.where((key) => !allowed.contains(key));
    if (unknown.isNotEmpty) {
      throw MarkdownCodecException('遇到不支持的富文本属性：${unknown.join(', ')}');
    }
  }
}
