import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';

/// 展开使用进阶条件，收起回到普通起名。
class ToolAdvancedOptions extends StatelessWidget {
  const ToolAdvancedOptions({
    required this.expanded,
    required this.onToggle,
    required this.children,
    super.key,
  });

  final bool expanded;
  final VoidCallback onToggle;
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
            title: Text('进阶选项', style: text.wenyouRowTitle),
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
