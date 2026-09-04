import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';

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
    final isEditingControl = deleteTooltip != null || onDeleted != null;
    if (!isEditingControl && onPressed == null) {
      return WenyouTagLink(name: name, onPressed: null);
    }

    return InputChip(
      label: Text(
        '${WenyouElementContract.topicTagPrefix}$name',
        style: Theme.of(context).textTheme.wenyouLabel.copyWith(
          color: tokens.brandForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
      tooltip: onPressed == null ? null : '查看 #$name 标签下的主题',
      deleteButtonTooltipMessage: deleteTooltip,
      onPressed: onPressed,
      onDeleted: onDeleted,
      backgroundColor: tokens.panel,
      side: BorderSide(color: tokens.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius12),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
