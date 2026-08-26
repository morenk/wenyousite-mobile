import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_link_style.dart';

/// Shared typography and block decoration used by editable and published body
/// renderers.
///
/// Quill and flutter_markdown_plus keep their own layout adapters, but neither
/// is allowed to redefine these visual values independently.
@immutable
class WenyouRichTextStyleSpec {
  const WenyouRichTextStyleSpec({
    required this.body,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.compactBody,
    required this.strong,
    required this.emphasis,
    required this.link,
    required this.inlineCode,
    required this.codeBlock,
    required this.quote,
    required this.listMarker,
    required this.h1Padding,
    required this.h2Padding,
    required this.h3Padding,
    required this.quotePadding,
    required this.quoteDecoration,
    required this.horizontalRuleDecoration,
    required this.blockSpacing,
  });

  factory WenyouRichTextStyleSpec.resolve(
    BuildContext context, {
    double bodyFontSize = defaultBodyFontSize,
    double bodyHeight = defaultBodyHeight,
  }) {
    final tokens = context.wenyouTokens;
    final theme = Theme.of(context);
    final body = (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: tokens.text,
      fontSize: bodyFontSize,
      height: bodyHeight,
      fontWeight: FontWeight.w400,
      letterSpacing: bodyFontSize * 0.008,
      decoration: TextDecoration.none,
    );
    final h1 = body.copyWith(
      fontSize: bodyFontSize * 1.65,
      height: 1.4,
      fontWeight: FontWeight.w700,
      letterSpacing: bodyFontSize * 0.015,
    );
    final h2 = body.copyWith(
      fontSize: bodyFontSize * 1.35,
      height: 1.45,
      fontWeight: FontWeight.w700,
      letterSpacing: bodyFontSize * 0.015,
    );
    final h3 = body.copyWith(
      fontSize: bodyFontSize * 1.12,
      height: 1.55,
      fontWeight: FontWeight.w700,
      letterSpacing: bodyFontSize * 0.015,
    );
    final compactBody = body.copyWith(
      fontSize: bodyFontSize * 0.88,
      height: 1.7,
    );
    final quotePadding = EdgeInsets.symmetric(
      horizontal: bodyFontSize * WenyouElementContract.quotePaddingInline,
      vertical: bodyFontSize * WenyouElementContract.quotePaddingBlock,
    );

    return WenyouRichTextStyleSpec(
      body: body,
      h1: h1,
      h2: h2,
      h3: h3,
      compactBody: compactBody,
      strong: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: bodyFontSize * 0.018,
      ),
      emphasis: const TextStyle(fontStyle: FontStyle.italic),
      link: wenyouContentLinkStyle(context, base: body),
      inlineCode: compactBody.copyWith(
        color: tokens.text,
        backgroundColor: tokens.softPanel,
        fontFamily: 'monospace',
      ),
      codeBlock: compactBody.copyWith(
        color: tokens.text,
        backgroundColor: tokens.softPanel,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w500,
      ),
      quote: body.copyWith(
        color: tokens.text,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
      listMarker: body.copyWith(color: tokens.brandForeground),
      h1Padding: EdgeInsets.only(top: tokens.space16, bottom: tokens.space8),
      h2Padding: EdgeInsets.only(top: tokens.space16, bottom: tokens.space4),
      h3Padding: EdgeInsets.only(top: tokens.space12, bottom: tokens.space4),
      quotePadding: quotePadding,
      quoteDecoration: BoxDecoration(
        color: tokens.softPanel,
        border: BorderDirectional(
          start: BorderSide(
            color: tokens.brandForeground,
            width: WenyouElementContract.quoteMarkerWidth,
          ),
        ),
        borderRadius: const BorderRadiusDirectional.only(
          topEnd: Radius.circular(WenyouElementContract.quoteRadius),
          bottomEnd: Radius.circular(WenyouElementContract.quoteRadius),
        ),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      blockSpacing: tokens.space12,
    );
  }

  static const defaultBodyFontSize = 17.0;
  static const defaultBodyHeight = 1.8;

  final TextStyle body;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle compactBody;
  final TextStyle strong;
  final TextStyle emphasis;
  final TextStyle link;
  final TextStyle inlineCode;
  final TextStyle codeBlock;
  final TextStyle quote;
  final TextStyle listMarker;
  final EdgeInsets h1Padding;
  final EdgeInsets h2Padding;
  final EdgeInsets h3Padding;
  final EdgeInsets quotePadding;
  final BoxDecoration quoteDecoration;
  final BoxDecoration horizontalRuleDecoration;
  final double blockSpacing;
}
