import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadPostAuthorLine extends StatelessWidget {
  const ThreadPostAuthorLine({
    required this.author,
    required this.time,
    this.editedAt,
    this.compact = false,
    this.avatarKey,
    super.key,
  });

  final ThreadAuthorModel author;
  final DateTime time;
  final DateTime? editedAt;
  final bool compact;
  final Key? avatarKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final size = compact ? 32.0 : 36.0;
    final identity = <Widget>[
      Flexible(
        child: Text(
          author.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.wenyouLabel,
        ),
      ),
      SizedBox(width: tokens.space4),
      WenyouLevelBadge(level: author.level),
    ];
    final timeLabel = WenyouTimeText(
      value: editedAt ?? time,
      prefix: editedAt == null ? '' : '编辑于',
      semanticsPrefix: editedAt == null ? '发布时间：' : '编辑时间：',
      maxLines: editedAt == null ? 1 : null,
      overflow: editedAt == null ? TextOverflow.ellipsis : null,
      style: Theme.of(
        context,
      ).textTheme.wenyouUtilityCaption.copyWith(color: tokens.mutedText),
    );
    return Row(
      children: [
        WenyouAvatarButton(
          key: avatarKey,
          username: author.username,
          avatarUrl: author.avatarUrl,
          visualSize: size,
          onTap: () => context.push(AppRouteLocations.user(author.id)),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          child: editedAt != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: identity),
                    SizedBox(height: tokens.space4 / 2),
                    timeLabel,
                  ],
                )
              : Row(
                  children: [
                    ...identity,
                    SizedBox(width: tokens.space8),
                    Flexible(child: timeLabel),
                  ],
                ),
        ),
      ],
    );
  }
}
