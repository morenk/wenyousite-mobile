import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_rich_text_style_spec.dart';

const wenyouEditorBodyFontSize = WenyouRichTextStyleSpec.defaultBodyFontSize;
const wenyouEditorBodyHeight = WenyouRichTextStyleSpec.defaultBodyHeight;

DefaultStyles wenyouEditorTextStyles(BuildContext context) {
  final tokens = context.wenyouTokens;
  final spec = WenyouRichTextStyleSpec.resolve(context);
  final textScaler = MediaQuery.textScalerOf(context);
  final markerWidths = <(double, int), double>{};
  double markerWidth(double fontSize, int count) =>
      markerWidths.putIfAbsent((fontSize, count), () {
        var width = TextBlockUtils.defaultNumberPointWidthBuilder(
          fontSize,
          count,
        );
        // 标记按实际字形预留单行空间，避免缩放后句点换行，也不挤占多余正文宽度。
        for (final marker in ['${'8' * '$count'.length}.', '•']) {
          final painter = TextPainter(
            text: TextSpan(
              text: marker,
              style: spec.listMarker.copyWith(
                fontSize: fontSize,
                fontWeight: marker == '•' ? FontWeight.bold : null,
              ),
            ),
            textDirection: TextDirection.ltr,
            textScaler: textScaler,
            locale: Localizations.maybeLocaleOf(context),
          )..layout();
          width = math.max(width, painter.width + fontSize / 2);
          painter.dispose();
        }
        return width.ceilToDouble();
      });
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
      numberPointWidthBuilder: markerWidth,
      indentWidthBuilder: (block, context, count, numberWidth) {
        final attributes = block.style.attributes;
        final list = attributes[Attribute.list.key];
        if (list != Attribute.ol && list != Attribute.ul) {
          return TextBlockUtils.defaultIndentWidthBuilder(
            block,
            context,
            count,
            numberWidth,
          );
        }
        final fontSize = spec.body.fontSize!;
        final depth = attributes[Attribute.indent.key]?.value as int? ?? 0;
        return HorizontalSpacing(
          numberWidth(fontSize, list == Attribute.ol ? count : 1) +
              fontSize * depth,
          0,
        );
      },
    ),
    // Quill 将标记与正文顶端对齐，leading 未提供时回退到 16 / 1.15。
    // 两者必须消费同一字体和行高，才能在缩放及折行时保持首行基线。
    leading: DefaultTextBlockStyle(
      spec.listMarker,
      noHorizontalSpacing,
      noVerticalSpacing,
      noVerticalSpacing,
      null,
    ),
    quote: DefaultTextBlockStyle(
      spec.quote,
      HorizontalSpacing(spec.quotePadding.left, spec.quotePadding.right),
      VerticalSpacing(spec.blockSpacing, spec.blockSpacing),
      // Quill applies lineSpacing between every quoted row, not to the
      // outside of the quote. A literal newline must retain only line height.
      noVerticalSpacing,
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
    if (config.attribute != Attribute.ol && config.attribute != Attribute.ul) {
      return null;
    }
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
