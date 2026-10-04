import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// 仅用于主题设置的直接操作，与设置名称共享起点和字重。
class ThreadManagementActionRow extends StatelessWidget {
  const ThreadManagementActionRow({
    required this.title,
    required this.icon,
    required this.onTap,
    this.busy = false,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String icon;
  final VoidCallback? onTap;
  final bool busy;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = onTap == null && !busy
        ? Theme.of(context).disabledColor
        : destructive
        ? Theme.of(context).colorScheme.error
        : null;
    final titleStyle = Theme.of(context).textTheme.wenyouRowTitle.copyWith(
      fontWeight: FontWeight.w400,
      color: color,
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: tokens.minimumTouchTarget + tokens.space8,
      title: Text(title, style: titleStyle),
      titleTextStyle: titleStyle,
      trailing: busy
          ? SizedBox.square(
              dimension: tokens.space20,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : WenyouIcon(icon, color: color),
      onTap: busy ? null : onTap,
    );
  }
}
