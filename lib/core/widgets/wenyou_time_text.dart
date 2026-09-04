import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';

class WenyouTimeText extends StatelessWidget {
  const WenyouTimeText({
    required this.value,
    this.reference,
    this.prefix = '',
    this.suffix = '',
    this.semanticsPrefix = '时间：',
    this.style,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final DateTime value;
  final DateTime? reference;
  final String prefix;
  final String suffix;
  final String semanticsPrefix;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$semanticsPrefix${formatWenyouExactTime(value)}$suffix',
      excludeSemantics: true,
      child: Text(
        '$prefix${formatWenyouTime(value, reference: reference)}$suffix',
        style: style ?? Theme.of(context).textTheme.wenyouUtilityCaption,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
