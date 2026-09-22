import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// 设置入口只展示名称和当前值，操作后果由目标页面说明。
class WenyouSettingsLink extends StatelessWidget {
  const WenyouSettingsLink({
    required this.title,
    required this.onTap,
    this.icon,
    this.value,
    this.destructive = false,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final String? icon;
  final String? value;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = onTap == null
        ? Theme.of(context).disabledColor
        : destructive
        ? Theme.of(context).colorScheme.error
        : null;
    return ListTile(
      enabled: onTap != null,
      leading: icon == null ? null : WenyouIcon(icon!, color: color),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.wenyouRowTitle.copyWith(color: color),
            ),
          ),
          if (value != null) ...[
            SizedBox(width: tokens.space12),
            Expanded(
              child: Text(
                value!,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.wenyouCaption,
              ),
            ),
          ],
        ],
      ),
      trailing: WenyouIcon(WenyouIconIds.navigationNext, color: color),
      onTap: onTap,
    );
  }
}

/// 设置说明按需展开，不占用每一行的常驻副标题空间。
class WenyouSettingsToggle extends StatelessWidget {
  const WenyouSettingsToggle({
    required this.title,
    required this.help,
    required this.value,
    required this.onChanged,
    this.toggleKey,
    super.key,
  });

  final String title;
  final String help;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Key? toggleKey;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      // 说明按钮放在 SwitchListTile 的 MergeSemantics 之外，避免读屏将
      // “查看说明”和“切换设置”合为同一个操作。
      Expanded(
        child: SwitchListTile(
          key: toggleKey,
          title: Text(title),
          value: value,
          onChanged: onChanged,
        ),
      ),
      IconButton(
        tooltip: '$title说明',
        icon: const WenyouIcon(WenyouIconIds.statusInfo),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            title: Text(title),
            content: Text(help),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
