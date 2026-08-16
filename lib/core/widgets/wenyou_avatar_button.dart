import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
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
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: WenyouIcon(WenyouIconIds.identityMember, color: tokens.mutedText),
    );
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
              child: ClipOval(
                child: SizedBox.square(
                  dimension: visualSize,
                  child: avatarUrl == null
                      ? fallback
                      : WenyouCachedImage(
                          imageUrl: avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => fallback,
                          errorWidget: (_, _, _) => fallback,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
