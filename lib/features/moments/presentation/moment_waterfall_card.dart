import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';

/// 动态信息流专用紧凑卡片。
///
/// 列表只保留封面、标题、作者和点赞；正文、评论、收藏与加油等完整操作
/// 继续在详情页呈现，避免双列布局压缩信息层级和触控目标。
class MomentWaterfallCard extends StatelessWidget {
  const MomentWaterfallCard({
    required this.moment,
    required this.onTap,
    this.onAuthorTap,
    this.onLike,
    this.pendingAction,
    super.key,
  });

  final MomentCard moment;
  final VoidCallback onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onLike;
  final MomentInteractionAction? pendingAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius12),
      side: BorderSide(color: tokens.border),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Material(
        color: tokens.panel,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              label: _detailSemanticsLabel,
              child: InkWell(
                key: Key('moment-open-${moment.id}'),
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ExcludeSemantics(child: _buildCover(context)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        tokens.space8,
                        tokens.space8,
                        tokens.space8,
                        tokens.space4,
                      ),
                      child: ExcludeSemantics(
                        child: Text(
                          moment.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: tokens.text,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: onAuthorTap != null,
                    label: '查看作者：${moment.author.username}',
                    child: InkWell(
                      key: Key('moment-author-${moment.id}'),
                      onTap: onAuthorTap,
                      borderRadius: BorderRadius.circular(tokens.radius12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: tokens.minimumTouchTarget,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: tokens.space8),
                          child: Row(
                            children: [
                              ExcludeSemantics(
                                child: MomentAvatar(
                                  author: moment.author,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: tokens.space4),
                              Expanded(
                                child: ExcludeSemantics(
                                  child: Text(
                                    moment.author.username,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _MomentWaterfallLikeButton(
                  key: Key('moment-like-${moment.id}'),
                  count: moment.likeCount,
                  selected: moment.viewerLiked,
                  pending: pendingAction == MomentInteractionAction.like,
                  onPressed: pendingAction == null ? onLike : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _detailSemanticsLabel {
    final imageSummary = moment.imageCount > 0
        ? '，${moment.imageCount} 张图'
        : '';
    return '查看动态：${moment.title}$imageSummary';
  }

  Widget _buildCover(BuildContext context) {
    final tokens = context.wenyouTokens;
    return AspectRatio(
      aspectRatio: _feedCoverAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (moment.coverType == MomentCoverType.image)
            MomentCoverImage(media: moment.coverMedia!)
          else
            MomentTextCover(theme: moment.textCoverTheme, title: moment.title),
          if (moment.imageCount > 1)
            Positioned(
              top: tokens.space8,
              right: tokens.space8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.text.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.space8,
                    vertical: tokens.space4,
                  ),
                  child: Text(
                    '${moment.imageCount} 图',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tokens.panel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _feedCoverAspectRatio {
    if (moment.coverType != MomentCoverType.image) return 3 / 4;
    return (moment.coverMedia?.aspectRatio ?? 3 / 4)
        .clamp(3 / 4, double.infinity)
        .toDouble();
  }
}

class _MomentWaterfallLikeButton extends StatelessWidget {
  const _MomentWaterfallLikeButton({
    required this.count,
    required this.selected,
    required this.pending,
    this.onPressed,
    super.key,
  });

  final int count;
  final bool selected;
  final bool pending;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = selected ? '取消点赞' : '点赞';
    final countLabel = count > 0 ? '，$count' : '';
    return WenyouInteractionToggle(
      kind: WenyouInteractionKind.like,
      selected: selected,
      pending: pending,
      onPressed: onPressed,
      semanticLabel: '$label$countLabel',
      iconSize: 18,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      supporting: count > 0
          ? Text(
              formatWenyouCompactCount(count),
              style: Theme.of(context).textTheme.labelSmall,
            )
          : null,
    );
  }
}
