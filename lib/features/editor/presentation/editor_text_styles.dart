import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

const wenyouEditorBodyFontSize = 17.0;
const wenyouEditorBodyHeight = 1.8;

DefaultStyles wenyouEditorTextStyles(BuildContext context) {
  final tokens = context.wenyouTokens;
  final theme = Theme.of(context);
  final body = (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
    color: tokens.text,
    fontSize: wenyouEditorBodyFontSize,
    height: wenyouEditorBodyHeight,
    fontWeight: FontWeight.w400,
    letterSpacing: wenyouEditorBodyFontSize * 0.008,
    decoration: TextDecoration.none,
  );
  final h2 = body.copyWith(
    fontSize: wenyouEditorBodyFontSize * 1.35,
    height: 1.45,
    fontWeight: FontWeight.w700,
    letterSpacing: wenyouEditorBodyFontSize * 0.015,
  );
  final h3 = body.copyWith(
    fontSize: wenyouEditorBodyFontSize * 1.12,
    height: 1.55,
    fontWeight: FontWeight.w700,
    letterSpacing: wenyouEditorBodyFontSize * 0.015,
  );
  final compact = body.copyWith(
    fontSize: wenyouEditorBodyFontSize * 0.88,
    height: 1.7,
  );
  const noHorizontalSpacing = HorizontalSpacing.zero;
  const noVerticalSpacing = VerticalSpacing.zero;

  return DefaultStyles(
    paragraph: DefaultTextBlockStyle(
      body,
      noHorizontalSpacing,
      noVerticalSpacing,
      noVerticalSpacing,
      null,
    ),
    h2: DefaultTextBlockStyle(
      h2,
      noHorizontalSpacing,
      VerticalSpacing(context.wenyouTokens.space16, tokens.space4),
      noVerticalSpacing,
      null,
    ),
    h3: DefaultTextBlockStyle(
      h3,
      noHorizontalSpacing,
      VerticalSpacing(tokens.space12, tokens.space4),
      noVerticalSpacing,
      null,
    ),
    placeHolder: DefaultTextBlockStyle(
      body.copyWith(color: tokens.mutedText),
      noHorizontalSpacing,
      noVerticalSpacing,
      noVerticalSpacing,
      null,
    ),
    lists: DefaultListBlockStyle(
      body,
      noHorizontalSpacing,
      noVerticalSpacing,
      VerticalSpacing(0, tokens.space4),
      null,
      null,
    ),
    quote: DefaultTextBlockStyle(
      body.copyWith(
        color: tokens.text,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
      const HorizontalSpacing(
        wenyouEditorBodyFontSize * WenyouElementContract.quotePaddingInline,
        wenyouEditorBodyFontSize * WenyouElementContract.quotePaddingInline,
      ),
      VerticalSpacing(tokens.space8, tokens.space8),
      const VerticalSpacing(
        wenyouEditorBodyFontSize * WenyouElementContract.quotePaddingBlock,
        wenyouEditorBodyFontSize * WenyouElementContract.quotePaddingBlock,
      ),
      BoxDecoration(
        color: tokens.softPanel,
        border: BorderDirectional(
          start: BorderSide(
            color: tokens.brandForeground,
            width: WenyouElementContract.quoteMarkerWidth,
          ),
        ),
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(WenyouElementContract.quoteRadius),
          bottomEnd: Radius.circular(WenyouElementContract.quoteRadius),
        ),
      ),
    ),
    code: DefaultTextBlockStyle(
      compact.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.w500),
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
      style: compact.copyWith(fontFamily: 'monospace'),
      backgroundColor: tokens.softPanel,
      radius: Radius.circular((compact.fontSize ?? 14) * 0.35),
      header2: compact.copyWith(fontSize: h2.fontSize),
      header3: compact.copyWith(fontSize: h3.fontSize),
    ),
    link: body.copyWith(
      color: tokens.brandForeground,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: tokens.brandForeground,
    ),
    bold: const TextStyle(fontWeight: FontWeight.w700),
  );
}
