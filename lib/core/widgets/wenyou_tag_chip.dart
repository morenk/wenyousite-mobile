import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouTagChip extends StatelessWidget {
  const WenyouTagChip({
    required this.name,
    this.colorHex,
    this.onPressed,
    this.onDeleted,
    this.deleteTooltip,
    super.key,
  });

  final String name;
  final String? colorHex;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final accent = _parseColor(colorHex) ?? tokens.brandForeground;
    return InputChip(
      avatar: WenyouIcon(WenyouIconIds.contentTag, size: 18, color: accent),
      label: Text(name),
      tooltip: onPressed == null ? null : '查看 #$name 标签下的主题',
      deleteButtonTooltipMessage: deleteTooltip,
      onPressed: onPressed,
      onDeleted: onDeleted,
      backgroundColor: Color.alphaBlend(
        accent.withValues(alpha: 0.08),
        tokens.softPanel,
      ),
      side: BorderSide(color: accent.withValues(alpha: 0.28)),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

Color? _parseColor(String? value) {
  if (value == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
    return null;
  }
  return Color(int.parse(value.substring(1), radix: 16) | 0xff000000);
}
