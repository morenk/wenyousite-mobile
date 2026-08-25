import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

typedef MomentCommentDtoMapper =
    MomentComment Function(
      MomentCommentResponseDto dto, {
      required String expectedMomentId,
      String? expectedRootId,
    });

typedef NonNegativeIntegerMapper = int Function(num value, String label);

class MomentCommentContextMapper {
  const MomentCommentContextMapper({
    required this.mapComment,
    required this.nonNegativeInteger,
  });

  final MomentCommentDtoMapper mapComment;
  final NonNegativeIntegerMapper nonNegativeInteger;

  MomentCommentContext map(
    MomentCommentContextResponseDto dto, {
    required String momentId,
    required String commentId,
  }) {
    final root = mapComment(dto.root, expectedMomentId: momentId);
    final target = mapComment(dto.target, expectedMomentId: momentId);
    final replyCount = nonNegativeInteger(dto.replyCount, '评论回复数');
    if (root.parentCommentId != null || root.replyToComment != null) {
      throw const ApiFailure(userMessage: '目标评论层级无效，请重新加载。');
    }
    if (target.id != commentId || target.deleted) {
      throw const ApiFailure(userMessage: '目标评论已经发生变化，请重新加载。');
    }

    if (target.id == root.id) {
      if (target.parentCommentId != null ||
          target.replyToComment != null ||
          !_sameComment(root, target)) {
        throw const ApiFailure(userMessage: '目标评论层级无效，请重新加载。');
      }
      return MomentCommentContext(
        root: _asRoot(target, replyCount: replyCount),
        target: target,
      );
    }

    if (target.parentCommentId != root.id || replyCount < 1) {
      throw const ApiFailure(userMessage: '目标回复层级无效，请重新加载。');
    }
    return MomentCommentContext(
      root: _asRoot(root, replyCount: replyCount, replies: [target]),
      target: target,
    );
  }

  MomentRootComment _asRoot(
    MomentComment comment, {
    required int replyCount,
    List<MomentComment> replies = const [],
  }) {
    return MomentRootComment(
      id: comment.id,
      momentId: comment.momentId,
      author: comment.author,
      deleted: comment.deleted,
      canDelete: comment.canDelete,
      createdAt: comment.createdAt,
      content: comment.content,
      media: comment.media,
      sticker: comment.sticker,
      replyCount: replyCount,
      replies: List.unmodifiable(replies),
    );
  }

  bool _sameComment(MomentComment left, MomentComment right) {
    return left.id == right.id &&
        left.momentId == right.momentId &&
        left.author.id == right.author.id &&
        left.content == right.content &&
        left.media?.id == right.media?.id &&
        left.sticker?.id == right.sticker?.id &&
        left.deleted == right.deleted;
  }
}
