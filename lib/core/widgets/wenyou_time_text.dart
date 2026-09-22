import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_clock.dart';

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
    if (reference == null) {
      return ListenableBuilder(
        listenable: _contentClock,
        builder: (context, _) => _buildTime(context, _contentClock.value),
      );
    }
    return _buildTime(context, reference!);
  }

  Widget _buildTime(BuildContext context, DateTime now) {
    return Semantics(
      label: '$semanticsPrefix${formatWenyouDate(value)}$suffix',
      excludeSemantics: true,
      child: Text(
        '$prefix${formatWenyouTime(value, reference: now)}$suffix',
        style: style ?? Theme.of(context).textTheme.wenyouUtilityCaption,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

final _contentClock = WenyouTimeClock();
