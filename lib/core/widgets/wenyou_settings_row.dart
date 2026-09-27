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
    this.enabled = true,
    this.contentPadding,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final String? icon;
  final String? value;
  final bool destructive;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final actionable = enabled && onTap != null;
    final color = !enabled
        ? Theme.of(context).disabledColor
        : destructive
        ? Theme.of(context).colorScheme.error
        : null;
    return ListTile(
      enabled: enabled,
      contentPadding: contentPadding,
      minTileHeight: tokens.minimumTouchTarget + tokens.space8,
      titleTextStyle: Theme.of(
        context,
      ).textTheme.wenyouRowTitle.copyWith(fontWeight: FontWeight.w400),
      leading: icon == null
          ? null
          : WenyouIcon(icon!, color: color ?? tokens.mutedText),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.wenyouRowTitle.copyWith(
                color: color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (value != null) ...[
            SizedBox(width: tokens.space12),
            Expanded(
              child: Text(
                value!,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.wenyouCompactBody.copyWith(
                  color: enabled ? tokens.mutedText : color,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: actionable
          ? WenyouIcon(WenyouIconIds.navigationNext, color: color)
          : null,
      onTap: actionable ? onTap : null,
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
    this.icon,
    this.showHelpButton = true,
    super.key,
  });

  final String title;
  final String help;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Key? toggleKey;
  final String? icon;
  final bool showHelpButton;

  @override
  Widget build(BuildContext context) {
    final toggle = SwitchListTile(
      key: toggleKey,
      title: showHelpButton
          ? Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.wenyouRowTitle.copyWith(fontWeight: FontWeight.w400),
            )
          : Tooltip(
              message: help,
              child: Text(
                title,
                style: Theme.of(context).textTheme.wenyouRowTitle.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
      secondary: icon == null
          ? null
          : WenyouIcon(icon!, color: context.wenyouTokens.mutedText),
      value: value,
      onChanged: onChanged,
    );
    if (!showHelpButton) return toggle;
    return Row(
      children: [
        // 说明按钮放在 SwitchListTile 的 MergeSemantics 之外，避免读屏将
        // “查看说明”和“切换设置”合为同一个操作。
        Expanded(child: toggle),
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
}
