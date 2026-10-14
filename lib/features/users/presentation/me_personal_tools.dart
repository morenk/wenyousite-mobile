import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_row.dart';

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
      _ToolEntry(
        key: const Key('me-open-toolbox'),
        icon: WenyouIconIds.contentCategory,
        label: '工具箱',
        onPressed: () => context.pushNamed(AppRouteNames.toolbox),
      ),
    ];
    return Semantics(
      key: const Key('me-personal-tools'),
      container: true,
      explicitChildNodes: true,
      label: '个人工具',
      child: Material(
        color: tokens.panel,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space16,
            vertical: tokens.space8,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              var minimumWidth = tokens.minimumTouchTarget;
              for (final entry in entries) {
                final label = TextPainter(
                  text: TextSpan(
                    text: entry.label,
                    style: Theme.of(context).textTheme.wenyouCompactBody,
                  ),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout();
                final width = label.width + tokens.space16;
                if (width > minimumWidth) minimumWidth = width;
                label.dispose();
              }
              // 大字按实际标签宽度换行，避免把三个字拆成竖列。
              final columns = (constraints.maxWidth / minimumWidth)
                  .floor()
                  .clamp(1, entries.length);
              return Wrap(
                children: [
                  for (final entry in entries)
                    SizedBox(
                      width: constraints.maxWidth / columns,
                      child: entry,
                    ),
                ],
              );
            },
          ),
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
        style: TextButton.styleFrom(
          foregroundColor: tokens.text,
          minimumSize: Size(
            tokens.minimumTouchTarget,
            tokens.minimumTouchTarget,
          ),
          padding: EdgeInsets.all(tokens.space8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouSettingsIcon(icon, color: tokens.text),
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
