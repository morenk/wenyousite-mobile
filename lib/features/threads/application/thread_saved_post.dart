import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

/// 保存响应是完整正文投影；窗口已有的内嵌回复另行保留。
ThreadFloorModel savedPostAsFloor(
  PostItem post, {
  List<ThreadReplyModel> replies = const [],
}) => ThreadFloorModel(
  id: post.id,
  floorNumber: post.floorNumber,
  author: ThreadAuthorModel(
    id: post.author.id,
    username: post.author.username,
    level: post.author.level,
    avatarUrl: post.author.avatarUrl,
    rpIdentity: post.author.rpIdentity,
  ),
  body: ThreadBodyModel(
    markdown: post.content,
    postId: post.id,
    version: post.version,
    mediaDisplays: post.mediaDisplays,
    mediaAudios: post.mediaAudios,
    mentionLabels: post.mentionLabels,
    diceRolls: post.diceRolls
        .map(
          (roll) => ThreadDiceRollModel(
            nodeId: roll.nodeId,
            notation: roll.notation,
            results: roll.results,
            total: roll.total,
          ),
        )
        .toList(growable: false),
  ),
  version: post.version,
  createdAt: post.createdAt,
  editedAt: post.editedAt,
  isDeleted: post.isDeleted,
  replyCount: post.replyCount,
  replies: replies,
  pinnedAt: post.pinnedAt,
);
