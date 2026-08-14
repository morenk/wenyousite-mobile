import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

abstract interface class MomentRepository {
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  });

  Future<CursorPage<MomentCard>> fetchBookmarks({
    String? cursor,
    int limit = 20,
  });

  Future<CursorPage<MomentCard>> fetchUserMoments({
    required String userId,
    String? cursor,
    int limit = 20,
  });

  Future<MomentDetail> fetchDetail(String momentId);

  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  });

  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  });

  Future<void> remove(String momentId);

  Future<MomentActionResult> setLike(String momentId, {required bool active});

  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
  });

  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  });

  Future<CursorPage<MomentComment>> fetchReplies({
    required String momentId,
    required String rootCommentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  });

  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId);

  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  });

  Future<void> removeComment(String momentId, String commentId);
}

final momentRepositoryProvider = Provider<MomentRepository>((ref) {
  return const _UnboundMomentRepository();
});

class _UnboundMomentRepository implements MomentRepository {
  const _UnboundMomentRepository();

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<CursorPage<MomentCard>> fetchBookmarks({
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<CursorPage<MomentCard>> fetchUserMoments({
    required String userId,
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<MomentDetail> fetchDetail(String momentId) => Future.error(_error());

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) => Future.error(_error());

  @override
  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  }) => Future.error(_error());

  @override
  Future<void> remove(String momentId) => Future.error(_error());

  @override
  Future<MomentActionResult> setLike(String momentId, {required bool active}) =>
      Future.error(_error());

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
  }) => Future.error(_error());

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<CursorPage<MomentComment>> fetchReplies({
    required String momentId,
    required String rootCommentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) {
    return Future.error(_error());
  }

  @override
  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  }) => Future.error(_error());

  @override
  Future<void> removeComment(String momentId, String commentId) {
    return Future.error(_error());
  }
}

StateError _error() => StateError('动态仓储尚未在应用组合根绑定。');
