import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_async_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
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
    this.statuses = const [],
    this.levelProgress,
    this.levelProgressLabel,
    this.identityAction,
    this.actions,
    super.key,
  });

  final String username;
  final String? avatarUrl;
  final ProfileCoverModel? profileCover;
  final int level;
  final String? bio;
  final List<UserProfileStatItem> stats;
  final List<UserProfileStatusItem> statuses;
  final double? levelProgress;
  final String? levelProgressLabel;
  final Widget? identityAction;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final normalizedBio = bio?.trim();
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 20;
    final statsRow = UserProfileStats(items: stats);
    final identity = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.space8,
      runSpacing: tokens.space4,
      children: [
        Text(username, style: Theme.of(context).textTheme.wenyouListTitle),
        WenyouLevelBadge(level: level),
      ],
    );
    return Material(
      color: tokens.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (profileCover != null)
            AspectRatio(
              aspectRatio: 2,
              child: _ProfileCover(cover: profileCover!, username: username),
            ),
          Padding(
            key: profileCover == null
                ? const Key('profile-identity-without-cover')
                : null,
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              profileCover == null ? tokens.space16 : 0,
              tokens.space16,
              tokens.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 嵌入封面的部分不再占据正文高度，避免昵称上方留下空位。
                    Align(
                      alignment: Alignment.bottomCenter,
                      widthFactor: 1,
                      heightFactor: profileCover == null
                          ? 1
                          : (_ProfileAvatar.size - tokens.space24) /
                                _ProfileAvatar.size,
                      child: _ProfileAvatar(
                        username: username,
                        avatarUrl: avatarUrl,
                      ),
                    ),
                    SizedBox(width: tokens.space12),
                    Expanded(child: largeText ? identity : statsRow),
                  ],
                ),
                if (!largeText)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: tokens.space8),
                          child: identity,
                        ),
                      ),
                      if (identityAction != null) ...[
                        SizedBox(width: tokens.space12),
                        identityAction!,
                      ],
                    ],
                  ),
                if (largeText) ...[
                  statsRow,
                  if (identityAction != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: identityAction!,
                    ),
                ],
                if (normalizedBio?.isNotEmpty == true) ...[
                  SizedBox(height: tokens.space12),
                  Text(
                    normalizedBio!,
                    style: Theme.of(context).textTheme.wenyouCompactBody,
                  ),
                ],
                if (statuses.isNotEmpty) ...[
                  SizedBox(height: tokens.space8),
                  Wrap(
                    spacing: tokens.space8,
                    runSpacing: tokens.space4,
                    children: [
                      for (final status in statuses)
                        _ProfileBadge(icon: status.icon, label: status.label),
                    ],
                  ),
                ],
                if (levelProgress != null) ...[
                  SizedBox(height: tokens.space8),
                  _ProfileLevelProgress(
                    value: levelProgress!,
                    label: levelProgressLabel ?? '等级进度',
                  ),
                ],
                if (actions != null) ...[
                  SizedBox(height: tokens.space8),
                  actions!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfileEditButton extends StatelessWidget {
  const UserProfileEditButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => WenyouAsyncButton(
    label: '编辑资料',
    onPressed: onPressed,
    variant: WenyouAsyncButtonVariant.outlined,
    dense: true,
  );
}

class _ProfileLevelProgress extends StatelessWidget {
  const _ProfileLevelProgress({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      children: [
        Flexible(
          child: SizedBox(
            width: tokens.space32 * 3,
            child: LinearProgressIndicator(
              value: value,
              semanticsLabel: '等级进度',
            ),
          ),
        ),
        SizedBox(width: tokens.space8),
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
          ),
        ),
      ],
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

  static const double size = 72;
  final String username;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      key: ValueKey('profile-avatar-$username'),
      width: size,
      height: size,
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

class UserProfileStats extends StatelessWidget {
  const UserProfileStats({required this.items, super.key});
  final List<UserProfileStatItem> items;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in items) Expanded(child: _ProfileStat(item: item)),
    ],
  );
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
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space4,
              vertical: tokens.space4,
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
                  textAlign: TextAlign.center,
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
