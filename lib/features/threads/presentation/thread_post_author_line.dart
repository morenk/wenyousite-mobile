import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadPostAuthorLine extends StatelessWidget {
  const ThreadPostAuthorLine({
    required this.author,
    this.time,
    this.compact = false,
    this.avatarKey,
    super.key,
  });

  final ThreadAuthorModel author;
  final DateTime? time;
  final bool compact;
  final Key? avatarKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final size = compact ? 32.0 : 36.0;
    final scope = ThreadIdentityReadingScope.maybeOf(context);
    final role = scope?.roleLabelFor(author.id);
    return Row(
      children: [
        WenyouAvatarButton(
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
        SizedBox(width: tokens.space8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  author.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.wenyouLabel,
                ),
              ),
              SizedBox(width: tokens.space4),
              WenyouLevelBadge(level: author.level),
              if (role != null) ...[
                SizedBox(width: tokens.space4),
                Text(role, style: Theme.of(context).textTheme.wenyouCaption),
              ],
              if (time != null) ...[
                SizedBox(width: tokens.space8),
                Flexible(
                  child: WenyouTimeText(
                    value: time!,
                    semanticsPrefix: '发布时间：',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.wenyouUtilityCaption
                        .copyWith(color: tokens.mutedText),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
