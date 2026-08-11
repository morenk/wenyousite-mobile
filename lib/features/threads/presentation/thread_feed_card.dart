import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';
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
    final compact = MediaQuery.sizeOf(context).width <= 400;
    return Semantics(
      container: true,
      button: true,
      label: '打开主题：${thread.title}，作者 ${thread.ownerName}',
      child: WenyouPanel(
        onTap: onTap,
        padding: EdgeInsets.all(compact ? tokens.space12 : tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space4,
              children: [
                if (thread.isPinned)
                  const _ThreadPill(label: '置顶', accent: true),
                if (categoryName != null)
                  _ThreadPill(label: categoryName!, outlined: true),
                _ThreadPill(
                  label: thread.status.label,
                  accent: thread.status == HomeThreadStatus.recruiting,
                ),
              ],
            ),
            SizedBox(height: tokens.space8),
            Text(thread.title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.space8),
            _ThreadAuthor(thread: thread),
            if (thread.preview != null) ...[
              SizedBox(height: tokens.space12),
              Text(
                thread.preview!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (thread.coverImageUrls.isNotEmpty) ...[
              SizedBox(height: tokens.space12),
              _ThreadCover(url: thread.coverImageUrls.first),
            ],
            if (thread.tags.isNotEmpty) ...[
              SizedBox(height: tokens.space4),
              Wrap(
                spacing: tokens.space4,
                runSpacing: 0,
                children: [
                  for (final tag in thread.tags.take(4))
                    WenyouTagLink(
                      key: Key('home-thread-tag-${thread.id}-${tag.id}'),
                      name: tag.name,
                      onPressed: onTagTap == null ? null : () => onTagTap!(tag),
                    ),
                ],
              ),
            ],
            SizedBox(height: tokens.space8),
            Wrap(
              spacing: tokens.space12,
              runSpacing: tokens.space4,
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
}

class _ThreadAuthor extends StatelessWidget {
  const _ThreadAuthor({required this.thread});

  final HomeThreadCardModel thread;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.space4,
      runSpacing: tokens.space4,
      children: [
        Text(thread.ownerName, style: Theme.of(context).textTheme.labelLarge),
        WenyouLevelBadge(level: thread.ownerLevel),
        Text(
          '${formatWenyouRelativeTime(thread.lastActivityAt)}活跃',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
      ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => Semantics(
            label: '图片加载失败',
            child: ColoredBox(
              color: tokens.softPanel,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: tokens.mutedText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadPill extends StatelessWidget {
  const _ThreadPill({
    required this.label,
    this.accent = false,
    this.outlined = false,
  });

  final String label;
  final bool accent;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? tokens.accentedBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: outlined ? Border.all(color: tokens.border) : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: accent ? tokens.brand : tokens.mutedText,
            fontWeight: FontWeight.w600,
          ),
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
