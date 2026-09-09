import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// flutter_markdown_plus 1.0.12 对所有段落强制固定 strut；多行代码、
/// 表情等 WidgetSpan 的实际高度会被忽略。通过公开 build 扩展点适配
/// 支持的正文、标题、引用和列表容器，不改解析、事件或节点内容。
class WenyouMarkdownBody extends MarkdownBody {
  const WenyouMarkdownBody({
    required super.data,
    super.selectable,
    super.fitContent,
    super.softLineBreak,
    super.styleSheet,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.builders,
    super.onTapLink,
    super.imageBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    final blocks = md.Document(
      blockSyntaxes: blockSyntaxes,
      inlineSyntaxes: inlineSyntaxes,
      extensionSet: extensionSet ?? md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    ).parse(data);
    // 上游在相邻顶层块之间插入 SizedBox。只收紧正文段落之间的
    // 间距；标题、列表、引用及图片仍保持既有块间距和内部结构。
    final mapped = <Widget>[];
    for (var index = 0; index < (children?.length ?? 0); index++) {
      final child = children![index];
      if (children.length == blocks.length * 2 - 1 &&
          index.isOdd &&
          child is SizedBox &&
          isBodyParagraph(blocks[index ~/ 2]) &&
          isBodyParagraph(blocks[index ~/ 2 + 1])) {
        continue;
      }
      mapped.add(_allowInlineHeight(child));
    }
    return super.build(context, mapped);
  }

  static bool isBodyParagraph(md.Node node) =>
      node is md.Element &&
      node.tag == 'p' &&
      !(node.children?.any(
            (child) => child is md.Element && child.tag == 'img',
          ) ??
          false);
}

Widget _allowInlineHeight(Widget widget) {
  // 只放开含占位组件的段落；纯文字继续使用上游的固定行高。
  if (widget is Text &&
      widget.textSpan != null &&
      widget.strutStyle?.forceStrutHeight == true &&
      _containsPlaceholder(widget.textSpan!)) {
    final strut = widget.strutStyle!;
    return Text.rich(
      widget.textSpan!,
      key: widget.key,
      style: widget.style,
      strutStyle: StrutStyle(
        fontFamily: strut.fontFamily,
        fontFamilyFallback: strut.fontFamilyFallback,
        fontSize: strut.fontSize,
        height: strut.height,
        leadingDistribution: strut.leadingDistribution,
        leading: strut.leading,
        fontWeight: strut.fontWeight,
        fontStyle: strut.fontStyle,
        forceStrutHeight: false,
      ),
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      semanticsIdentifier: widget.semanticsIdentifier,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }
  // 这里只遍历 MarkdownBuilder 产生的块容器。WidgetSpan 内部的自定义
  // 组件自行处理布局；代码围栏、图片与独占空行不需要修改。
  return switch (widget) {
    Column() => Column(
      key: widget.key,
      mainAxisAlignment: widget.mainAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      textBaseline: widget.textBaseline,
      spacing: widget.spacing,
      children: widget.children.map(_allowInlineHeight).toList(),
    ),
    Row() => Row(
      key: widget.key,
      mainAxisAlignment: widget.mainAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      textBaseline: widget.textBaseline,
      spacing: widget.spacing,
      children: widget.children.map(_allowInlineHeight).toList(),
    ),
    Wrap() => Wrap(
      key: widget.key,
      direction: widget.direction,
      alignment: widget.alignment,
      spacing: widget.spacing,
      runAlignment: widget.runAlignment,
      runSpacing: widget.runSpacing,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      clipBehavior: widget.clipBehavior,
      children: widget.children.map(_allowInlineHeight).toList(),
    ),
    Padding(:final child?) => Padding(
      key: widget.key,
      padding: widget.padding,
      child: _allowInlineHeight(child),
    ),
    DecoratedBox(:final child?) => DecoratedBox(
      key: widget.key,
      decoration: widget.decoration,
      position: widget.position,
      child: _allowInlineHeight(child),
    ),
    Flexible() => Flexible(
      key: widget.key,
      flex: widget.flex,
      fit: widget.fit,
      child: _allowInlineHeight(widget.child),
    ),
    _ => widget,
  };
}

bool _containsPlaceholder(InlineSpan span) => switch (span) {
  PlaceholderSpan() => true,
  TextSpan(:final children?) => children.any(_containsPlaceholder),
  _ => false,
};
