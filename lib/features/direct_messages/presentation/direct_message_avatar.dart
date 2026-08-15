import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

class DirectMessageAvatar extends StatelessWidget {
  const DirectMessageAvatar({required this.user, this.size = 44, super.key});

  final DirectMessageUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: WenyouIcon(
        user.isDeactivated
            ? WenyouIconIds.statusUserUnavailable
            : WenyouIconIds.identityMember,
        color: tokens.mutedText,
        size: size * 0.5,
      ),
    );
    return Semantics(
      image: true,
      label: '${user.username} 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: user.avatarUrl == null
              ? fallback
              : WenyouCachedImage(
                  imageUrl: user.avatarUrl!,
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
