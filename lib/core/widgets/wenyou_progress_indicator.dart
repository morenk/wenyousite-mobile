import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';

/// 全应用加载指示器只重绘自身；减少动画时暂停不定进度，不伪造百分比。
class WenyouCircularProgressIndicator extends StatelessWidget {
  const WenyouCircularProgressIndicator({
    this.value,
    this.strokeWidth = 4,
    this.color,
    this.backgroundColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.reduceMotion = false,
    super.key,
  });

  final double? value;
  final double strokeWidth;
  final Color? color, backgroundColor;
  final String? semanticsLabel, semanticsValue;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => TickerMode(
    enabled: !reduceMotion && !wenyouAnimationsDisabled(context),
    child: RepaintBoundary(
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        color: color,
        backgroundColor: backgroundColor,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      ),
    ),
  );
}

class WenyouLinearProgressIndicator extends StatelessWidget {
  const WenyouLinearProgressIndicator({
    this.value,
    this.minHeight,
    this.stopIndicatorRadius,
    this.borderRadius,
    this.color,
    this.backgroundColor,
    this.semanticsLabel,
    this.semanticsValue,
    super.key,
  });

  final double? value, minHeight;
  final double? stopIndicatorRadius;
  final BorderRadiusGeometry? borderRadius;
  final Color? color, backgroundColor;
  final String? semanticsLabel, semanticsValue;

  @override
  Widget build(BuildContext context) => TickerMode(
    enabled: !wenyouAnimationsDisabled(context),
    child: RepaintBoundary(
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        stopIndicatorRadius: stopIndicatorRadius,
        borderRadius: borderRadius,
        color: color,
        backgroundColor: backgroundColor,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      ),
    ),
  );
}
