import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

import 'moment_pages_test_support.dart';

typedef CommentRequest = ({MomentCommentOrder order, String? cursor});

class CommentPaginationRepository extends Fake implements MomentRepository {
  late FutureOr<CursorPage<MomentRootComment>> Function(CommentRequest request)
  onComments;
  final requests = <CommentRequest>[];
  var detailCalls = 0;
  var replyCalls = 0;
  var failDetail = false;
  MomentCommentContext? target;

  @override
  Future<MomentDetail> fetchDetail(String momentId) async {
    detailCalls++;
    if (failDetail) throw StateError('offline');
    return momentPagesTestDetail();
  }

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    final request = (order: order, cursor: cursor);
    requests.add(request);
    return onComments(request);
  }

  @override
  Future<CursorPage<MomentComment>> fetchReplies({
    required String momentId,
    required String rootCommentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    replyCalls++;
    return CursorPage(
      items: [
        MomentComment(
          id: 'reply',
          momentId: momentId,
          parentCommentId: rootCommentId,
          author: momentPagesTestAuthor(),
          content: '楼中楼回复',
          deleted: false,
          canDelete: false,
          createdAt: DateTime.utc(2026, 8, 10),
        ),
      ],
      hasMore: false,
    );
  }

  @override
  Future<MomentCommentContext> fetchCommentContext({
    required String momentId,
    required String commentId,
  }) async => target!;
}

MomentRootComment paginationComment(
  String id, {
  int lines = 1,
  int replyCount = 0,
}) => MomentRootComment(
  id: id,
  momentId: 'moment-1',
  author: momentPagesTestAuthor(),
  content: List.filled(lines, '评论 $id').join('\n'),
  deleted: false,
  canDelete: false,
  createdAt: DateTime.utc(2026, 8, 10),
  replyCount: replyCount,
  replies: const [],
);

CursorPage<MomentRootComment> commentPage(
  List<String> ids, {
  String? cursor,
  int lines = 1,
}) => CursorPage(
  items: [for (final id in ids) paginationComment(id, lines: lines)],
  cursor: cursor,
  hasMore: cursor != null,
);
