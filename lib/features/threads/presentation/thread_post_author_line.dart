import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_author_header.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadPostAuthorLine extends StatelessWidget {
  const ThreadPostAuthorLine({
    required this.author,
    this.time,
    this.compact = false,
    this.avatarKey,
    this.metadata = const [],
    this.trailing,
    super.key,
  });

  final ThreadAuthorModel author;
  final DateTime? time;
  final bool compact;
  final Key? avatarKey;
  final List<Widget> metadata;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final size = compact ? 32.0 : 36.0;
    final scope = ThreadIdentityReadingScope.maybeOf(context);
    final role = scope?.roleLabelFor(author.id);
    return WenyouAuthorHeader(
      name: author.displayName,
      level: author.level,
      trailing: trailing,
      avatar: WenyouAvatarButton(
        key: avatarKey,
        username: author.displayName,
        avatarUrl: author.displayAvatarUrl,
        semanticsLabel: scope?.available == true && author.rpIdentity != null
            ? '查看 ${author.displayName} 的帖内身份'
            : null,
        visualSize: size,
        onTap: () {
          if (scope?.available == true) {
            scope!.open(
              context,
              author.id,
              historical: author.rpIdentity,
              roleLabel: role,
            );
          } else {
            context.push(AppRouteLocations.user(author.id));
          }
        },
      ),
      metadata: [
        if (role != null) Text(role),
        if (time != null)
          WenyouTimeText(
            value: time!,
            semanticsPrefix: '发布时间：',
            style: Theme.of(
              context,
            ).textTheme.wenyouUtilityCaption.copyWith(color: tokens.mutedText),
          ),
        ...metadata,
      ],
    );
  }
}
