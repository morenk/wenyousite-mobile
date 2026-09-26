import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// 私人资源入口独立于资料操作，避免与公开内容或编辑资料混为一组。
class MePersonalTools extends StatelessWidget {
  const MePersonalTools({required this.stickersEnabled, super.key});

  final bool stickersEnabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final entries = [
      _ToolEntry(
        key: const Key('me-open-bookmarks'),
        icon: WenyouIconIds.actionBookmark,
        label: '收藏夹',
        onPressed: () => context.pushNamed('me-bookmarks'),
      ),
      if (stickersEnabled)
        _ToolEntry(
          key: const Key('me-open-stickers'),
          icon: WenyouIconIds.actionAddReaction,
          label: '表情包',
          onPressed: () => context.pushNamed('me-stickers'),
        ),
      _ToolEntry(
        key: const Key('me-open-wallet'),
        icon: WenyouIconIds.economyWallet,
        label: '油卡',
        onPressed: () => context.pushNamed('wallet'),
      ),
    ];
    return Semantics(
      key: const Key('me-personal-tools'),
      container: true,
      explicitChildNodes: true,
      label: '个人工具',
      child: Material(
        color: tokens.panel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space16,
                vertical: tokens.space8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final entry in entries) Expanded(child: entry)],
              ),
            ),
            Divider(height: 1, thickness: 1, color: tokens.border),
          ],
        ),
      ),
    );
  }
}

class _ToolEntry extends StatelessWidget {
  const _ToolEntry({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: label,
      button: true,
      onTap: onPressed,
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: tokens.text),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouIcon(icon),
            SizedBox(height: tokens.space4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.wenyouCompactBody,
            ),
          ],
        ),
      ),
    );
  }
}
