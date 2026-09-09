import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

class MarkdownDeltaBlockValidator {
  MarkdownDeltaBlockValidator._();

  /// 空列表标记可能被阅读器当作标题下划线或正文；再编码自洽不足以证明安全。
  static void validateEmptyListReading(Delta delta, String markdown) {
    var listItems = 0;
    var emptyItems = 0;
    var hasContent = false;
    for (final operation in delta.operations) {
      final value = operation.data;
      if (value is! String) {
        hasContent = true;
        continue;
      }
      for (final unit in value.codeUnits) {
        if (unit != 10) {
          hasContent = true;
          continue;
        }
        if (operation.attributes?['list'] != null) {
          listItems++;
          if (!hasContent) emptyItems++;
        }
        hasContent = false;
      }
    }
    if (emptyItems == 0) return;
    var readItems = 0;
    var readEmptyItems = 0;
    void visit(Iterable<md.Node> nodes) {
      for (final node in nodes.whereType<md.Element>()) {
        if (node.tag == 'li') {
          readItems++;
          // 子列表的文字属于子项；父项可以为空而仍然拥有非空子项。
          final ownContent = (node.children ?? const <md.Node>[])
              .where(
                (child) =>
                    child is! md.Element ||
                    (child.tag != 'ul' && child.tag != 'ol'),
              )
              .map((child) => child.textContent)
              .join();
          if (ownContent.isEmpty) readEmptyItems++;
        }
        visit(node.children ?? const []);
      }
    }

    visit(
      md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
      ).parseLines(markdown.split('\n')),
    );
    if (readItems != listItems || readEmptyItems != emptyItems) {
      throw const MarkdownCodecException('列表层级无法安全保存，请调整列表缩进');
    }
  }

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
