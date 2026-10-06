import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/media/reading_gallery.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/stickers/stickers.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';

/// 楼层与身份资料共用正文渲染；管理、回复动作只由楼层外层提供。
class PostReadingBody extends StatelessWidget {
  const PostReadingBody({
    required this.post,
    required this.galleryTarget,
    this.onTapText,
    this.onLongPressNonText,
    super.key,
  });
  final PostItem post;
  final ReadingGalleryTarget galleryTarget;
  final VoidCallback? onTapText;
  final VoidCallback? onLongPressNonText;

  @override
  Widget build(BuildContext context) => StickerPostMarkdown(
    postId: post.id,
    postVersion: post.version,
    galleryTarget: galleryTarget,
    data: post.content,
    mediaDisplays: post.mediaDisplays,
    mentionLabels: post.mentionLabels,
    onInternalLink: (uri) => openThreadReadingLink(context, uri),
    diceLabels: {
      for (final roll in post.diceRolls)
        roll.nodeId.toLowerCase(): '${roll.notation} = ${roll.total}',
    },
    diceSemantics: {
      for (final roll in post.diceRolls)
        roll.nodeId: formatWenyouDiceSemantics(
          notation: roll.notation,
          results: roll.results,
          total: roll.total,
        ),
    },
    diceDetails: {
      for (final roll in post.diceRolls)
        roll.nodeId.toLowerCase(): WenyouDiceRollDetail(
          results: roll.results,
          total: roll.total,
        ),
    },
    bodyFontSize: 17,
    bodyHeight: 1.8,
    onTapText: onTapText,
    onLongPressNonText: onLongPressNonText,
  );
}
