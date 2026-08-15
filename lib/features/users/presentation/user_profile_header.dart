import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

class UserProfileStatItem {
  const UserProfileStatItem({
    required this.label,
    required this.value,
    this.onTap,
    this.key,
  });

  final String label;
  final String value;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profileCover case final cover?)
              _ProfileCover(cover: cover, username: username)
            else
              Container(height: 4, color: tokens.brandSurface),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space16,
                tokens.space20,
                tokens.space16,
                tokens.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ProfileAvatar(username: username, avatarUrl: avatarUrl),
                      SizedBox(width: tokens.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: tokens.space8),
                            _ProfileBadge(
                              icon: WenyouIconIds.navigationMoments,
                              label: 'Lv.$level',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (normalizedBio?.isNotEmpty == true) ...[
                    SizedBox(height: tokens.space16),
                    Text(
                      normalizedBio!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.55),
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
                            style: Theme.of(context).textTheme.bodySmall,
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
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: tokens.space8),
                    ],
                    Semantics(
                      label: '等级进度 ${(levelProgress! * 100).round()}%',
                      child: LinearProgressIndicator(value: levelProgress),
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

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({required this.cover, required this.username});

  final ProfileCoverModel cover;
  final String username;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final variant = cover.preferredForMobile;
    final fallback = ColoredBox(
      color: tokens.brandSurface,
      child: Center(
        child: WenyouIcon(
          WenyouIconIds.contentGallery,
          size: 32,
          color: tokens.mutedText,
        ),
      ),
    );
    return Semantics(
      image: true,
      label: '$username 的主页背景图',
      child: AspectRatio(
        aspectRatio: 2,
        child: WenyouCachedImage(
          imageUrl: variant.url,
          width: double.infinity,
          fit: BoxFit.cover,
          cacheWidth: 1200,
          cacheHeight: 600,
          placeholder: (_, _) => fallback,
          errorWidget: (_, _, _) => fallback,
        ),
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
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: WenyouIcon(
        WenyouIconIds.identityMember,
        size: 44,
        color: tokens.mutedText,
      ),
    );
    return Semantics(
      image: true,
      label: '$username 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: 88,
          child: avatarUrl == null
              ? fallback
              : WenyouCachedImage(
                  imageUrl: avatarUrl!,
                  width: 88,
                  height: 88,
                  cacheWidth: 176,
                  cacheHeight: 176,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.item});

  final UserProfileStatItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return InkWell(
      key: item.key,
      onTap: item.onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget + 12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space4,
            vertical: tokens.space8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.space4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
