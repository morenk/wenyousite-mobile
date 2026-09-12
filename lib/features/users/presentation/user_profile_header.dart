import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

class UserProfileStatItem {
  const UserProfileStatItem({
    required this.label,
    this.value,
    this.semanticValue,
    this.icon,
    this.onTap,
    this.key,
  }) : assert(value != null || icon != null);

  final String label;
  final String? value;
  final String? semanticValue;
  final String? icon;
  final VoidCallback? onTap;
  final Key? key;
}

class UserProfileStatusItem {
  const UserProfileStatusItem({required this.icon, required this.label});

  final String icon;
  final String label;
}

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({
    required this.username,
    required this.level,
    required this.stats,
    this.avatarUrl,
    this.profileCover,
    this.bio,
    this.metadata,
    this.statuses = const [],
    this.levelProgress,
    this.levelProgressLabel,
    this.actions,
    super.key,
  });

  final String username;
  final String? avatarUrl;
  final ProfileCoverModel? profileCover;
  final int level;
  final String? bio;
  final String? metadata;
  final List<UserProfileStatItem> stats;
  final List<UserProfileStatusItem> statuses;
  final double? levelProgress;
  final String? levelProgressLabel;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final normalizedBio = bio?.trim();
    return SizedBox(
      width: double.infinity,
      child: WenyouPanel(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileIdentity(
              username: username,
              avatarUrl: avatarUrl,
              profileCover: profileCover,
              level: level,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space16,
                tokens.space8,
                tokens.space16,
                tokens.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (normalizedBio?.isNotEmpty == true) ...[
                    Text(
                      normalizedBio!,
                      style: Theme.of(
                        context,
                      ).textTheme.wenyouCompactBody.copyWith(height: 1.55),
                    ),
                  ],
                  if (metadata?.isNotEmpty == true) ...[
                    SizedBox(height: tokens.space12),
                    Row(
                      children: [
                        WenyouIcon(
                          WenyouIconIds.statusCalendar,
                          size: 17,
                          color: tokens.mutedText,
                        ),
                        SizedBox(width: tokens.space4),
                        Expanded(
                          child: Text(
                            metadata!,
                            style: Theme.of(context).textTheme.wenyouCaption,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (statuses.isNotEmpty) ...[
                    SizedBox(height: tokens.space12),
                    Wrap(
                      spacing: tokens.space8,
                      runSpacing: tokens.space8,
                      children: [
                        for (final status in statuses)
                          _ProfileBadge(icon: status.icon, label: status.label),
                      ],
                    ),
                  ],
                  if (levelProgress != null) ...[
                    SizedBox(height: tokens.space16),
                    if (levelProgressLabel != null) ...[
                      Text(
                        levelProgressLabel!,
                        style: Theme.of(context).textTheme.wenyouCaption,
                      ),
                      SizedBox(height: tokens.space8),
                    ],
                    Semantics(
                      label: '等级进度 ${(levelProgress! * 100).round()}%',
                      child: LinearProgressIndicator(
                        value: levelProgress,
                        color: wenyouLevelTier(context, level)?.foreground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space8),
              child: Row(
                children: [
                  for (var index = 0; index < stats.length; index++) ...[
                    Expanded(child: _ProfileStat(item: stats[index])),
                    if (index < stats.length - 1)
                      const SizedBox(
                        height: 48,
                        child: VerticalDivider(width: 1),
                      ),
                  ],
                ],
              ),
            ),
            if (actions != null) ...[
              const Divider(height: 1),
              Padding(padding: EdgeInsets.all(tokens.space12), child: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.username,
    required this.avatarUrl,
    required this.profileCover,
    required this.level,
  });

  final String username;
  final String? avatarUrl;
  final ProfileCoverModel? profileCover;
  final int level;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    const avatarSize = 72.0;
    const avatarOverlap = avatarSize / 2;
    if (profileCover == null) {
      return Padding(
        key: const Key('profile-identity-without-cover'),
        padding: EdgeInsets.fromLTRB(
          tokens.space16,
          tokens.space16,
          tokens.space16,
          tokens.space4,
        ),
        child: Row(
          children: [
            _ProfileAvatar(username: username, avatarUrl: avatarUrl),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.wenyouListTitle,
                    ),
                  ),
                  SizedBox(width: tokens.space8),
                  WenyouLevelBadge(level: level),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final coverHeight = constraints.maxWidth / 2;
        return SizedBox(
          height: coverHeight + avatarOverlap + tokens.space12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                bottom: avatarOverlap + tokens.space12,
                child: _ProfileCover(cover: profileCover!, username: username),
              ),
              Positioned(
                left: tokens.space16,
                top: coverHeight - avatarOverlap,
                child: _ProfileAvatar(username: username, avatarUrl: avatarUrl),
              ),
              Positioned(
                top: coverHeight + tokens.space8,
                right: tokens.space16,
                left: tokens.space16 + avatarSize + tokens.space12,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.wenyouListTitle,
                      ),
                    ),
                    SizedBox(width: tokens.space8),
                    WenyouLevelBadge(level: level),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({required this.cover, required this.username});

  final ProfileCoverModel cover;
  final String username;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Center(
        child: WenyouIcon(
          WenyouIconIds.contentGallery,
          size: 32,
          color: tokens.mutedText,
        ),
      ),
    );
    final variant = cover.preferredForMobile;
    return Semantics(
      image: true,
      label: '$username 的主页背景图',
      child: WenyouCachedImage(
        imageUrl: variant.url,
        width: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: 1200,
        cacheHeight: 600,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.username, required this.avatarUrl});

  final String username;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      key: ValueKey('profile-avatar-$username'),
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: tokens.panel,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.border),
      ),
      child: WenyouAvatar(username: username, avatarUrl: avatarUrl, size: 66),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.item});

  final UserProfileStatItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: '${item.label}：${item.semanticValue ?? item.value ?? ''}',
      excludeSemantics: true,
      button: item.onTap != null,
      child: InkWell(
        key: item.key,
        onTap: item.onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: tokens.minimumTouchTarget + 12,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space4,
              vertical: tokens.space8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.icon case final icon?)
                  WenyouIcon(icon, size: 22, color: tokens.mutedText)
                else
                  Text(
                    item.value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.wenyouUtilityRowTitle,
                  ),
                SizedBox(height: tokens.space4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.wenyouCaption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.accentedBackground,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouIcon(icon, size: 15, color: tokens.focus),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.wenyouCaption),
          ],
        ),
      ),
    );
  }
}
