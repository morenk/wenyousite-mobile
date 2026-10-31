import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_indicator.dart';

/// 图片等紧凑异步区域共用进度环；仅可量化的传输传入 value。
class WenyouProgressRing extends StatelessWidget {
  const WenyouProgressRing({this.value, this.size = 18, super.key});

  final double? value;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: WenyouCircularProgressIndicator(value: value, strokeWidth: 2),
  );
}
