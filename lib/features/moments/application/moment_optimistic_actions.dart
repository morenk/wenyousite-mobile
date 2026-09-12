import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

/// 只投影本次操作的字段，避免覆盖同时返回的正文、评论和其他动态。
MomentCard projectMomentAction(
  MomentCard current,
  MomentCard source, {
  required bool bookmark,
}) => bookmark
    ? current.copyWith(
        viewerBookmarked: source.viewerBookmarked,
        bookmarkCount: source.bookmarkCount,
        bookmarkFolderId: source.bookmarkFolderId,
      )
    : current.copyWith(
        viewerLiked: source.viewerLiked,
        likeCount: source.likeCount,
      );

MomentCard optimisticMomentAction(
  MomentCard before, {
  required bool bookmark,
  String? folderId,
}) => bookmark
    ? before.copyWith(
        viewerBookmarked: !before.viewerBookmarked,
        bookmarkCount:
            (before.bookmarkCount + (before.viewerBookmarked ? -1 : 1)).clamp(
              0,
              1 << 31,
            ),
        bookmarkFolderId: before.viewerBookmarked ? null : folderId,
      )
    : before.copyWith(
        viewerLiked: !before.viewerLiked,
        likeCount: (before.likeCount + (before.viewerLiked ? -1 : 1)).clamp(
          0,
          1 << 31,
        ),
      );

Future<WriteOutcome<MomentActionResult, MomentCard>> writeMomentAction(
  MomentRepository repository,
  MomentCard before, {
  required bool bookmark,
  required bool Function() isCurrent,
  String? folderId,
}) => const WriteReconciler().run<MomentActionResult, MomentCard>(
  write: () => bookmark
      ? repository.setBookmark(
          before.id,
          active: !before.viewerBookmarked,
          folderId: folderId,
        )
      : repository.setLike(before.id, active: !before.viewerLiked),
  read: () async => (await repository.fetchDetail(before.id)).card,
  targetReached: (card) => bookmark
      ? card.viewerBookmarked != before.viewerBookmarked
      : card.viewerLiked != before.viewerLiked,
  failureMessage: bookmark ? '收藏操作失败，请重试。' : '点赞操作失败，请重试。',
  isCurrent: isCurrent,
);

MomentCard confirmedMomentAction(
  MomentCard before,
  WriteOutcome<MomentActionResult, MomentCard> outcome, {
  required bool bookmark,
  String? folderId,
}) {
  if (outcome.projection case final projection?) return projection;
  final result = outcome.writeValue;
  if (result == null) return before;
  return bookmark
      ? before.copyWith(
          viewerBookmarked: result.active,
          bookmarkCount: result.count,
          bookmarkFolderId: result.active ? folderId : null,
        )
      : before.copyWith(viewerLiked: result.active, likeCount: result.count);
}
