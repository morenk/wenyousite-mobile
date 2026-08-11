import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

class HomeThreadCard extends StatelessWidget {
  const HomeThreadCard({
    required this.thread,
    required this.categoryName,
    required this.onTap,
    this.onTagTap,
    super.key,
  });

  final HomeThreadCardModel thread;
  final String? categoryName;
  final VoidCallback onTap;
  final ValueChanged<HomeThreadTag>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      button: true,
      label: '打开主题：${thread.title}，作者 ${thread.ownerName}',
      child: WenyouPanel(
        onTap: onTap,
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThreadAuthor(thread: thread),
            SizedBox(height: tokens.space12),
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space4,
              children: [
                if (thread.isPinned)
                  const _ThreadPill(
                    icon: Icons.push_pin_rounded,
                    label: '置顶',
                    accent: true,
                  ),
                if (categoryName != null)
                  _ThreadPill(
                    icon: Icons.folder_open_rounded,
                    label: categoryName!,
                  ),
                _ThreadPill(
                  icon: _statusIcon(thread.status),
                  label: thread.status.label,
                  accent: thread.status == HomeThreadStatus.recruiting,
                ),
              ],
            ),
            SizedBox(height: tokens.space8),
            Text(thread.title, style: Theme.of(context).textTheme.titleLarge),
            if (thread.preview != null) ...[
              SizedBox(height: tokens.space8),
              Text(
                thread.preview!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (thread.coverImageUrls.isNotEmpty) ...[
              SizedBox(height: tokens.space12),
              _ThreadCoverGrid(urls: thread.coverImageUrls),
            ],
            if (thread.tags.isNotEmpty) ...[
              SizedBox(height: tokens.space12),
              Wrap(
                spacing: tokens.space8,
                runSpacing: tokens.space4,
                children: [
                  for (final tag in thread.tags.take(4))
                    WenyouTagChip(
                      key: Key('home-thread-tag-${thread.id}-${tag.id}'),
                      name: tag.name,
                      onPressed: onTagTap == null ? null : () => onTagTap!(tag),
                    ),
                ],
              ),
            ],
            SizedBox(height: tokens.space12),
            Divider(color: tokens.border),
            SizedBox(height: tokens.space12),
            Wrap(
              spacing: tokens.space16,
              runSpacing: tokens.space8,
              children: [
                _ThreadStat(
                  icon: Icons.people_outline_rounded,
                  label: '${thread.memberCount} 成员',
                ),
                _ThreadStat(
                  icon: Icons.theater_comedy_outlined,
                  label: '${thread.playerCount} 玩家',
                ),
                _ThreadStat(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${thread.postCount} 回复',
                ),
                if (thread.tipTotal != '0')
                  _ThreadStat(
                    icon: Icons.local_gas_station_outlined,
                    label: '${thread.tipTotal}L 加油',
                    accent: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _statusIcon(HomeThreadStatus status) {
    return switch (status) {
      HomeThreadStatus.recruiting => Icons.group_add_outlined,
      HomeThreadStatus.closed => Icons.lock_outline_rounded,
      HomeThreadStatus.finished => Icons.check_circle_outline_rounded,
      HomeThreadStatus.unknown => Icons.help_outline_rounded,
    };
  }
}

class _ThreadAuthor extends StatelessWidget {
  const _ThreadAuthor({required this.thread});

  final HomeThreadCardModel thread;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      children: [
        _ThreadAvatar(url: thread.ownerAvatarUrl, username: thread.ownerName),
        SizedBox(width: tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      thread.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(width: tokens.space4),
                  WenyouLevelBadge(level: thread.ownerLevel),
                ],
              ),
              SizedBox(height: tokens.space4),
              Text(
                '${formatWenyouRelativeTime(thread.lastActivityAt)}活跃',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({required this.url, required this.username});

  final String? url;
  final String username;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, color: tokens.mutedText),
    );
    return Semantics(
      image: true,
      label: '$username 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: 44,
          child: url == null
              ? fallback
              : CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class _ThreadCoverGrid extends StatelessWidget {
  const _ThreadCoverGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: AspectRatio(
        aspectRatio: urls.length == 1 ? 16 / 9 : 2.2,
        child: Row(
          children: [
            for (var index = 0; index < urls.length; index++) ...[
              if (index > 0) SizedBox(width: tokens.space4),
              Expanded(child: _ThreadCover(url: urls[index])),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThreadCover extends StatelessWidget {
  const _ThreadCover({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final placeholder = ColoredBox(
      color: tokens.softPanel,
      child: Center(child: Icon(Icons.image_outlined, color: tokens.mutedText)),
    );
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => Semantics(
        label: '图片加载失败',
        child: ColoredBox(
          color: tokens.softPanel,
          child: Center(
            child: Icon(Icons.broken_image_outlined, color: tokens.mutedText),
          ),
        ),
      ),
    );
  }
}

class _ThreadPill extends StatelessWidget {
  const _ThreadPill({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? tokens.accentedBackground : tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: Border.all(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: accent ? tokens.brand : tokens.mutedText,
            ),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ThreadStat extends StatelessWidget {
  const _ThreadStat({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = accent ? tokens.brand : tokens.mutedText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: tokens.space4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
