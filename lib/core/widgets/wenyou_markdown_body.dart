import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/markdown_font_paragraph.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';

/// flutter_markdown_plus 1.0.12 对所有段落强制固定 strut；多行代码、
/// 表情等 WidgetSpan 的实际高度会被忽略。通过公开 build 扩展点适配
/// 支持的正文、标题、引用和列表容器，不改解析、事件或节点内容。
class WenyouMarkdownBody extends MarkdownBody {
  const WenyouMarkdownBody({
    this.mediaAudios = const {},
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
  final Map<String, MediaAudio> mediaAudios;

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
      if (children.length == blocks.length * 2 - 1 && index.isEven) {
        final audio = MarkdownAudioProjection.fromBlock(
          blocks[index ~/ 2],
          mediaAudios,
        );
        if (audio != null) {
          mapped.add(
            WenyouAudioPlayer(
              key: ValueKey('audio-${index ~/ 2}-${audio.audio.mediaId}'),
              audio: audio.audio,
              label: audio.label,
              labelRuns: audio.labelRuns,
            ),
          );
          continue;
        }
      }
      if (children.length == blocks.length * 2 - 1 &&
          index.isOdd &&
          child is SizedBox &&
          isBodyParagraph(blocks[index ~/ 2]) &&
          isBodyParagraph(blocks[index ~/ 2 + 1])) {
        continue;
      }
      final block = children.length == blocks.length * 2 - 1 && index.isEven
          ? blocks[index ~/ 2]
          : null;
      // 多个行内样式合并后，上游根 TextSpan 不再携带标题样式，
      // strut 会回退正文。用真实块类型保持标题自身的行高。
      final headingStyle = block is md.Element
          ? switch (block.tag) {
              'h1' => styleSheet?.h1,
              'h2' => styleSheet?.h2,
              'h3' => styleSheet?.h3,
              'h4' => styleSheet?.h4,
              'h5' => styleSheet?.h5,
              'h6' => styleSheet?.h6,
              _ => null,
            }
          : null;
      mapped.add(_allowInlineHeight(child, headingStyle));
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

Widget _allowInlineHeight(Widget widget, [TextStyle? headingStyle]) {
  // 纯文字使用所属块的固定行高；占位组件仍可按实际高度撑开。
  if (widget is Text &&
      widget.textSpan != null &&
      widget.strutStyle?.forceStrutHeight == true &&
      (headingStyle != null || _containsPlaceholder(widget.textSpan!))) {
    final strut = widget.strutStyle!;
    return Text.rich(
      widget.textSpan!,
      key: widget.key,
      style: widget.style,
      strutStyle: StrutStyle(
        fontFamily: headingStyle?.fontFamily ?? strut.fontFamily,
        fontFamilyFallback:
            headingStyle?.fontFamilyFallback ?? strut.fontFamilyFallback,
        fontSize: headingStyle?.fontSize ?? strut.fontSize,
        height: headingStyle?.height ?? strut.height,
        leadingDistribution: strut.leadingDistribution,
        leading: strut.leading,
        fontWeight: strut.fontWeight,
        fontStyle: strut.fontStyle,
        forceStrutHeight: !_containsPlaceholder(widget.textSpan!),
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
      children: widget.children
          .map((child) => _allowInlineHeight(child, headingStyle))
          .toList(),
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
      children: widget.children
          .map((child) => _allowInlineHeight(child, headingStyle))
          .toList(),
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
      children: mergeMarkdownFontInlines(
        widget.children,
        alignment: widget.alignment,
        adaptText: (child) => _allowInlineHeight(child, headingStyle),
      ).map((child) => _allowInlineHeight(child, headingStyle)).toList(),
    ),
    Padding(:final child?) => Padding(
      key: widget.key,
      padding: widget.padding,
      child: _allowInlineHeight(child, headingStyle),
    ),
    DecoratedBox(:final child?) => DecoratedBox(
      key: widget.key,
      decoration: widget.decoration,
      position: widget.position,
      child: _allowInlineHeight(child, headingStyle),
    ),
    Flexible() => Flexible(
      key: widget.key,
      flex: widget.flex,
      fit: widget.fit,
      child: _allowInlineHeight(widget.child, headingStyle),
    ),
    _ => widget,
  };
}

bool _containsPlaceholder(InlineSpan span) => switch (span) {
  PlaceholderSpan() => true,
  TextSpan(:final children?) => children.any(_containsPlaceholder),
  _ => false,
};
