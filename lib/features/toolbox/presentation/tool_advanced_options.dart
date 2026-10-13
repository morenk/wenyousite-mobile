import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';

/// 收起只隐藏控件，生效中的条件始终保留在入口上。
class ToolAdvancedOptions extends StatelessWidget {
  const ToolAdvancedOptions({
    required this.expanded,
    required this.onToggle,
    required this.children,
    this.summary,
    super.key,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final String? summary;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final text = Theme.of(context).textTheme;
    return WenyouSettingsGroup(
      children: [
        Semantics(
          expanded: expanded,
          child: ListTile(
            key: const Key('name-advanced-disclosure'),
            minTileHeight: tokens.minimumTouchTarget + tokens.space8,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('进阶选项', style: text.wenyouRowTitle),
                if (summary != null) ...[
                  SizedBox(height: tokens.space4),
                  Text(
                    summary!,
                    style: text.wenyouCompactBody.copyWith(
                      color: tokens.mutedText,
                    ),
                  ),
                ],
              ],
            ),
            trailing: WenyouIcon(
              expanded
                  ? WenyouIconIds.navigationCollapse
                  : WenyouIconIds.navigationExpand,
              color: tokens.mutedText,
            ),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onToggle();
            },
          ),
        ),
        if (expanded) ...children,
      ],
    );
  }
}
