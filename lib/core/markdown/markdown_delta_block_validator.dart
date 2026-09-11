import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_list_structure.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_source_protection.dart';

class MarkdownDeltaBlockValidator {
  MarkdownDeltaBlockValidator._();

  /// 整篇校验与阅读／写出共用本站空段、代码保护和列表边界规则。
  /// 空项和非空项始终核对类型、父子关系与直属内容是否为空。
  static void validateListReading(Delta delta, String markdown) {
    final expected = <({bool ordered, int depth, int? parent, bool empty})>[];
    final parents = <int, int>{};
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
        if (operation.attributes?['list'] case final String type) {
          final depth = operation.attributes?['indent'] as int? ?? 0;
          final parent = depth == 0 ? null : parents[depth - 1];
          if (depth > 0 && parent == null) {
            throw const MarkdownCodecException('列表缺少上一级条目');
          }
          parents.removeWhere((level, _) => level >= depth);
          parents[depth] = expected.length;
          expected.add((
            ordered: type == 'ordered',
            depth: depth,
            parent: parent,
            empty: !hasContent,
          ));
        } else {
          parents.clear();
        }
        hasContent = false;
      }
    }
    final actual = <({bool ordered, int depth, int? parent, bool empty})>[];
    final source = MarkdownSourceProtection.prepareForReader(markdown);
    for (final list in MarkdownListStructure.parse(source).values) {
      final offset = actual.length;
      for (final row in list.rows) {
        actual.add((
          ordered: row.ordered,
          depth: row.depth,
          parent: row.parent == null ? null : offset + row.parent!,
          empty: row.content.isEmpty,
        ));
      }
    }
    if (actual.length != expected.length ||
        Iterable.generate(
          expected.length,
        ).any((i) => actual[i] != expected[i])) {
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
