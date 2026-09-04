import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';

class WenyouAvatarButton extends StatelessWidget {
  const WenyouAvatarButton({
    required this.username,
    required this.visualSize,
    required this.onTap,
    this.avatarUrl,
    super.key,
  });

  final String username;
  final String? avatarUrl;
  final double visualSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '查看 $username 的个人主页',
      child: SizedBox.square(
        dimension: tokens.minimumTouchTarget,
        child: InkResponse(
          onTap: onTap,
          radius: tokens.minimumTouchTarget / 2,
          customBorder: const CircleBorder(),
          child: Center(
            child: ExcludeSemantics(
              child: WenyouAvatar(
                username: username,
                avatarUrl: avatarUrl,
                size: visualSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WenyouAvatar extends StatelessWidget {
  const WenyouAvatar({
    required this.username,
    required this.size,
    this.avatarUrl,
    this.unavailable = false,
    this.fallbackBackgroundColor,
    this.fallbackForegroundColor,
    super.key,
  });

  final String username;
  final String? avatarUrl;
  final double size;
  final bool unavailable;
  final Color? fallbackBackgroundColor;
  final Color? fallbackForegroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final initial = unavailable ? null : wenyouAvatarInitial(username);
    final foreground = fallbackForegroundColor ?? tokens.mutedText;
    final fallback = ColoredBox(
      color: fallbackBackgroundColor ?? tokens.softPanel,
      child: Center(
        child: initial == null
            ? WenyouIcon(
                unavailable
                    ? WenyouIconIds.statusUserUnavailable
                    : WenyouIconIds.identityMember,
                color: foreground,
                size: size * 0.5,
              )
            : Text(
                initial,
                key: const Key('avatar-initial'),
                style: Theme.of(context).textTheme.wenyouRowTitle.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.42,
                ),
              ),
      ),
    );
    return Semantics(
      image: true,
      label: username.trim().isEmpty
          ? '用户头像'
          : '$username 的头像${unavailable ? '，账号不可用' : ''}',
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: avatarUrl == null || unavailable
              ? fallback
              : WenyouCachedImage(
                  imageUrl: avatarUrl!,
                  fit: BoxFit.cover,
                  cacheWidth: size.ceil(),
                  cacheHeight: size.ceil(),
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

String? wenyouAvatarInitial(String username) {
  const skipped = {'@', '#', '.', '_', '-'};
  for (final character in username.trim().characters) {
    if (character.trim().isNotEmpty && !skipped.contains(character)) {
      return character.toUpperCase();
    }
  }
  return null;
}
