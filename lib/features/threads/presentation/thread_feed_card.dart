import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';
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
      explicitChildNodes: true,
      button: true,
      label: '打开主题：${thread.title}，作者 ${thread.ownerName}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            key: Key('home-thread-card-${thread.id}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? tokens.space12 : tokens.space16,
                  compact ? tokens.space12 : tokens.space16,
                  compact ? tokens.space12 : tokens.space16,
                  tokens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      key: Key('home-thread-context-${thread.id}'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (categoryName != null)
                            _ThreadContextLabel(label: categoryName!),
                          if (thread.status case final status) ...[
                            SizedBox(width: tokens.space12),
                            _ThreadContextLabel(
                              label: status.label,
                              accent: status == HomeThreadStatus.recruiting,
                            ),
                          ],
                          if (thread.isPinned) ...[
                            SizedBox(width: tokens.space12),
                            const _ThreadContextLabel(label: '置顶'),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      thread.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: tokens.space4),
                    _ThreadAuthor(thread: thread),
                  ],
                ),
              ),
              if (thread.coverImageUrls.isNotEmpty)
                _ThreadCover(
                  key: Key('home-thread-cover-${thread.id}'),
                  url: thread.coverImageUrls.first,
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? tokens.space12 : tokens.space16,
                  thread.coverImageUrls.isEmpty ? 0 : tokens.space12,
                  compact ? tokens.space12 : tokens.space16,
                  compact ? tokens.space12 : tokens.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (thread.preview != null)
                      Text(
                        thread.preview!,
                        maxLines: thread.coverImageUrls.isEmpty ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    if (thread.tags.isNotEmpty) ...[
                      SizedBox(height: tokens.space4),
                      Wrap(
                        spacing: tokens.space4,
                        runSpacing: 0,
                        children: [
                          for (final tag in thread.tags.take(4))
                            WenyouTagLink(
                              key: Key(
                                'home-thread-tag-${thread.id}-${tag.id}',
                              ),
                              name: tag.name,
                              onPressed: onTagTap == null
                                  ? null
                                  : () => onTagTap!(tag),
                            ),
                        ],
                      ),
                    ],
                    if (thread.preview != null || thread.tags.isNotEmpty)
                      SizedBox(height: tokens.space8),
                    Text(
                      [
                        '${thread.memberCount} 成员',
                        '${thread.playerCount} 玩家',
                        '${thread.postCount} 回复',
                        if (thread.tipTotal != '0') '${thread.tipTotal}L 加油',
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        Text(
          thread.ownerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge,
        ),
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
  const _ThreadCover({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final placeholder = ColoredBox(
      color: tokens.softPanel,
      child: Center(child: Icon(Icons.image_outlined, color: tokens.mutedText)),
    );
    return SizedBox(
      width: double.infinity,
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

class _ThreadContextLabel extends StatelessWidget {
  const _ThreadContextLabel({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: accent ? tokens.brand : tokens.mutedText,
        fontWeight: accent ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
