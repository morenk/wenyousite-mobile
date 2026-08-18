import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/models/thread_feed_models.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';

class ThreadFeedCard extends StatelessWidget {
  const ThreadFeedCard({
    required this.thread,
    required this.categoryName,
    required this.onTap,
    this.onTagTap,
    super.key,
  });

  final ThreadFeedCardModel thread;
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
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          excludeFromSemantics: true,
          child: Padding(
            key: Key('home-thread-card-${thread.id}'),
            padding: EdgeInsets.all(compact ? tokens.space12 : tokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ThreadHeader(thread: thread, categoryName: categoryName),
                SizedBox(height: tokens.space12),
                Text(
                  thread.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.wenyouListTitle,
                ),
                if (thread.coverImageUrls.isNotEmpty) ...[
                  SizedBox(height: tokens.space12),
                  _ThreadCover(
                    key: Key('home-thread-cover-${thread.id}'),
                    url: thread.coverImageUrls.first,
                  ),
                ],
                if (thread.preview != null) ...[
                  SizedBox(height: tokens.space12),
                  Text(
                    thread.preview!,
                    key: Key('home-thread-preview-${thread.id}'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                SizedBox(height: tokens.space8),
                SizedBox(
                  key: Key('home-thread-footer-${thread.id}'),
                  height: tokens.minimumTouchTarget,
                  child: _ThreadFooter(thread: thread, onTagTap: onTagTap),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef HomeThreadCard = ThreadFeedCard;

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({required this.thread, required this.categoryName});

  final ThreadFeedCardModel thread;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ThreadAuthorAvatar(
          threadId: thread.id,
          ownerName: thread.ownerName,
          avatarUrl: thread.ownerAvatarUrl,
        ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThreadAuthor(thread: thread),
              SizedBox(height: tokens.space4),
              _ThreadContextLine(thread: thread, categoryName: categoryName),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadContextLine extends StatelessWidget {
  const _ThreadContextLine({required this.thread, required this.categoryName});

  final HomeThreadCardModel thread;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final labels = <String>[
      ?categoryName,
      thread.status.label,
      if (!thread.isPublished) '草稿',
      if (thread.isPrivate) '私密',
      if (thread.isPinned) '置顶',
    ];
    return Text(
      labels.join(' · '),
      key: Key('home-thread-context-${thread.id}'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: thread.status == HomeThreadStatus.recruiting
            ? tokens.brandForeground
            : tokens.mutedText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ThreadAuthor extends StatelessWidget {
  const _ThreadAuthor({required this.thread});

  final ThreadFeedCardModel thread;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      children: [
        Flexible(
          child: Text(
            thread.ownerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SizedBox(width: tokens.space4),
        WenyouLevelBadge(level: thread.ownerLevel),
        SizedBox(width: tokens.space8),
        Flexible(
          child: WenyouTimeText(
            value: thread.activityAt,
            prefix: '· ',
            semanticsPrefix: '最近活跃时间：',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
        ),
      ],
    );
  }
}

class _ThreadAuthorAvatar extends StatelessWidget {
  const _ThreadAuthorAvatar({
    required this.threadId,
    required this.ownerName,
    required this.avatarUrl,
  });

  final String threadId;
  final String ownerName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return WenyouAvatar(
      key: Key('home-thread-author-avatar-$threadId'),
      username: ownerName,
      avatarUrl: avatarUrl,
      size: 40,
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
      child: Center(
        child: WenyouIcon(WenyouIconIds.actionImage, color: tokens.mutedText),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: WenyouCachedImage(
          imageUrl: url,
          fit: BoxFit.cover,
          cacheWidth: 1080,
          cacheHeight: 608,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => Semantics(
            label: '图片加载失败',
            child: ColoredBox(
              color: tokens.softPanel,
              child: Center(
                child: WenyouIcon(
                  WenyouIconIds.statusImageUnavailable,
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

class _ThreadFooter extends StatelessWidget {
  const _ThreadFooter({required this.thread, required this.onTagTap});

  final ThreadFeedCardModel thread;
  final ValueChanged<HomeThreadTag>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tagLimit = constraints.maxWidth <= 300
            ? 1
            : constraints.maxWidth <= 400
            ? 2
            : 3;
        return Row(
          children: [
            if (thread.playerCount case final playerCount?) ...[
              _ThreadStat(
                icon: WenyouIconIds.metricPlayers,
                value: playerCount,
                label: '玩家',
              ),
              SizedBox(width: tokens.space12),
            ],
            _ThreadStat(
              icon: WenyouIconIds.metricReplies,
              value: thread.postCount,
              label: '回复',
            ),
            if (thread.tipTotal != '0') ...[
              SizedBox(width: tokens.space12),
              _ThreadTipStat(value: thread.tipTotal),
            ],
            if (thread.tags.isNotEmpty) ...[
              SizedBox(width: tokens.space8),
              Expanded(
                child: _ThreadTagSummary(
                  threadId: thread.id,
                  tags: thread.tags,
                  visibleLimit: tagLimit,
                  onTagTap: onTagTap,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ThreadTagSummary extends StatelessWidget {
  const _ThreadTagSummary({
    required this.threadId,
    required this.tags,
    required this.visibleLimit,
    required this.onTagTap,
  });

  final String threadId;
  final List<HomeThreadTag> tags;
  final int visibleLimit;
  final ValueChanged<HomeThreadTag>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final visibleTags = tags.take(visibleLimit).toList(growable: false);
    final hiddenCount = tags.length - visibleTags.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var index = 0; index < visibleTags.length; index++) ...[
          if (index > 0) SizedBox(width: tokens.space4),
          Flexible(
            child: WenyouTagLink(
              key: Key('home-thread-tag-$threadId-${visibleTags[index].id}'),
              name: visibleTags[index].name,
              onPressed: onTagTap == null
                  ? null
                  : () => onTagTap!(visibleTags[index]),
            ),
          ),
        ],
        if (hiddenCount > 0) ...[
          SizedBox(width: tokens.space4),
          Text(
            '+$hiddenCount',
            key: Key('home-thread-tags-more-$threadId'),
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
        ],
      ],
    );
  }
}

class _ThreadStat extends StatelessWidget {
  const _ThreadStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: '$value $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WenyouIcon(icon, size: 16, color: tokens.mutedText),
          SizedBox(width: tokens.space4),
          Text(
            formatWenyouCompactCount(value),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
        ],
      ),
    );
  }
}

class _ThreadTipStat extends StatelessWidget {
  const _ThreadTipStat({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: '$value L 加油',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WenyouIcon(
            WenyouIconIds.metricTips,
            size: 16,
            color: tokens.brandForeground,
          ),
          SizedBox(width: tokens.space4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.brandForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
