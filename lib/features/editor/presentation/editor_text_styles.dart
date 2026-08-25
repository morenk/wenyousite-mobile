import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_rich_text_style_spec.dart';

const wenyouEditorBodyFontSize = WenyouRichTextStyleSpec.defaultBodyFontSize;
const wenyouEditorBodyHeight = WenyouRichTextStyleSpec.defaultBodyHeight;

DefaultStyles wenyouEditorTextStyles(BuildContext context) {
  final tokens = context.wenyouTokens;
  final spec = WenyouRichTextStyleSpec.resolve(context);
  const noHorizontalSpacing = HorizontalSpacing.zero;
  const noVerticalSpacing = VerticalSpacing.zero;

  return DefaultStyles(
    paragraph: DefaultTextBlockStyle(
      spec.body,
      noHorizontalSpacing,
      noVerticalSpacing,
      noVerticalSpacing,
      null,
    ),
    h2: DefaultTextBlockStyle(
      spec.h2,
      noHorizontalSpacing,
      VerticalSpacing(spec.h2Padding.top, spec.h2Padding.bottom),
      noVerticalSpacing,
      null,
    ),
    h3: DefaultTextBlockStyle(
      spec.h3,
      noHorizontalSpacing,
      VerticalSpacing(spec.h3Padding.top, spec.h3Padding.bottom),
      noVerticalSpacing,
      null,
    ),
    placeHolder: DefaultTextBlockStyle(
      spec.body.copyWith(color: tokens.mutedText),
      noHorizontalSpacing,
      noVerticalSpacing,
      noVerticalSpacing,
      null,
    ),
    lists: DefaultListBlockStyle(
      spec.body,
      noHorizontalSpacing,
      noVerticalSpacing,
      VerticalSpacing(0, tokens.space4),
      null,
      null,
    ),
    quote: DefaultTextBlockStyle(
      spec.quote,
      HorizontalSpacing(spec.quotePadding.left, spec.quotePadding.right),
      VerticalSpacing(spec.blockSpacing, spec.blockSpacing),
      VerticalSpacing(spec.quotePadding.top, spec.quotePadding.bottom),
      spec.quoteDecoration,
    ),
    code: DefaultTextBlockStyle(
      spec.codeBlock,
      noHorizontalSpacing,
      VerticalSpacing(tokens.space8, tokens.space8),
      noVerticalSpacing,
      BoxDecoration(
        color: tokens.softPanel,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radius12),
      ),
    ),
    inlineCode: InlineCodeStyle(
      style: spec.inlineCode,
      backgroundColor: tokens.softPanel,
      radius: Radius.circular((spec.inlineCode.fontSize ?? 14) * 0.35),
      header2: spec.inlineCode.copyWith(fontSize: spec.h2.fontSize),
      header3: spec.inlineCode.copyWith(fontSize: spec.h3.fontSize),
    ),
    link: spec.link,
    bold: spec.strong,
  );
}

LeadingBlockNodeBuilder wenyouEditorLeadingBlockBuilder(BuildContext context) {
  final markerStyle = WenyouRichTextStyleSpec.resolve(context).listMarker;
  return (node, config) {
    final style = (config.style ?? markerStyle).copyWith(
      color: markerStyle.color,
    );
    if (config.attribute == Attribute.ul) {
      return QuillBulletPoint(
        style: style,
        width: config.width!,
        padding: config.padding!,
      );
    }
    if (config.attribute == Attribute.ol) {
      return QuillNumberPoint(
        index: config.getIndexNumberByIndent!,
        indentLevelCounts: config.indentLevelCounts,
        count: config.count,
        style: style,
        attrs: config.attrs,
        width: config.width!,
        padding: config.padding!,
      );
    }
    return null;
  };
}
