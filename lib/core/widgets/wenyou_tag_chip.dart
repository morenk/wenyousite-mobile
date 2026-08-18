import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouTagChip extends StatelessWidget {
  const WenyouTagChip({
    required this.name,
    this.onPressed,
    this.onDeleted,
    this.deleteTooltip,
    super.key,
  });

  final String name;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return InputChip(
      label: Text(
        '#$name',
        style: TextStyle(color: tokens.mutedText, fontWeight: FontWeight.w500),
      ),
      tooltip: onPressed == null ? null : '查看 #$name 标签下的主题',
      deleteButtonTooltipMessage: deleteTooltip,
      onPressed: onPressed,
      onDeleted: onDeleted,
      backgroundColor: Colors.transparent,
      side: BorderSide(color: tokens.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius12),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
