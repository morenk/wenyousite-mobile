import 'package:flutter/foundation.dart' show nonVirtual;
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// 自定义行内节点必须进入同一个文字布局，不能作为独立 Wrap 子项。
/// 子类只构建节点内容，由此入口统一保留软换行、折行与基线。
abstract class WenyouMarkdownInlineBuilder extends MarkdownElementBuilder {
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
    return child == null ? null : wrap(child);
  }

  /// 图片回调不经过元素 builder；行内表情也须使用同一接入方式。
  static Text wrap(
    Widget child, {
    PlaceholderAlignment alignment = PlaceholderAlignment.baseline,
  }) => Text.rich(
    TextSpan(
      children: [
        WidgetSpan(
          alignment: alignment,
          baseline: TextBaseline.alphabetic,
          child: child,
        ),
      ],
    ),
  );
}
