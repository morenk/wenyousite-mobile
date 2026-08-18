import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

class DirectMessageAvatar extends StatelessWidget {
  const DirectMessageAvatar({required this.user, this.size = 44, super.key});

  final DirectMessageUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return WenyouAvatar(
      username: user.username,
      avatarUrl: user.avatarUrl,
      size: size,
      unavailable: user.isDeactivated,
    );
  }
}
