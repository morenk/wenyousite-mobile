import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_row.dart';

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
  Widget build(BuildContext context) => WenyouSettingsLink(
    title: title,
    icon: icon,
    onTap: onTap,
    enabled: onTap != null || busy,
    isBusy: busy,
    destructive: destructive,
  );
}
