import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

TextStyle wenyouContentLinkStyle(BuildContext context, {TextStyle? base}) {
  final tokens = context.wenyouTokens;
  return (base ?? DefaultTextStyle.of(context).style).copyWith(
    color: tokens.brandForeground,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
    decorationColor: tokens.brandForeground,
  );
}
