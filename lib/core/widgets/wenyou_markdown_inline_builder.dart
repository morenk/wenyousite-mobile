import 'package:flutter/foundation.dart' show nonVirtual;
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// 自定义行内节点必须进入同一个文字布局，不能作为独立 Wrap 子项。
/// 子类只构建节点内容，由此入口统一保留软换行、折行与基线。
abstract class WenyouMarkdownInlineBuilder extends MarkdownElementBuilder {
  /// 混合图片节点中的普通图片保留块尺寸；真正行内内容统一经过 wrap。
  bool usesInlineLayout(md.Element element) => true;

  PlaceholderAlignment inlineAlignment(md.Element element) =>
      PlaceholderAlignment.baseline;

  Widget? buildInlineContent(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  );

  @override
  @nonVirtual
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final child = buildInlineContent(
      context,
      element,
      preferredStyle,
      parentStyle,
    );
    return child == null || !usesInlineLayout(element)
        ? child
        : wrap(child, alignment: inlineAlignment(element));
  }

  /// 行内表情与其他自定义节点共用此入口；普通图片通过 usesInlineLayout
  /// 保留块尺寸，旧的独立图片回调也可显式调用 wrap。
  static Text wrap(
    Widget child, {
    PlaceholderAlignment alignment = PlaceholderAlignment.baseline,
  }) => Text.rich(
    TextSpan(
      children: [
        WidgetSpan(
          alignment: alignment,
          baseline: TextBaseline.alphabetic,
          // WidgetSpan 已按段落 TextScaler 缩放整个组件；内部 Text 再读
          // MediaQuery 会重复放大，窄屏长代码因而占据异常多行。
          child: MediaQuery.withNoTextScaling(child: child),
        ),
      ],
    ),
  );
}
