import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';

/// 头像本身是编辑入口，角标仅提示动作，不形成额外的小点击区域。
class WenyouAvatarEditButton extends StatelessWidget {
  const WenyouAvatarEditButton({
    required this.username,
    required this.label,
    required this.onPressed,
    this.avatarUrl,
    this.size = 56,
    super.key,
  });

  final String username;
  final String label;
  final String? avatarUrl;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    excludeSemantics: true,
    child: Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: size.clamp(
              context.wenyouTokens.minimumTouchTarget,
              double.infinity,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: WenyouAvatar(
                    username: username,
                    avatarUrl: avatarUrl,
                    size: size,
                  ),
                ),
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: WenyouMediaEditBadge(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// 头像和主页背景共用的编辑标记。
class WenyouMediaEditBadge extends StatelessWidget {
  const WenyouMediaEditBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.panel,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.border),
      ),
      child: const SizedBox.square(
        dimension: 28,
        child: Center(child: WenyouIcon(WenyouIconIds.actionEdit, size: 16)),
      ),
    );
  }
}
