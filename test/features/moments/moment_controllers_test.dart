import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

void main() {
  test('信息流游标失效自动回到首屏，点赞收藏采用服务端计数', () async {
    final repository = _FeedRepository();
    final controller = MomentFeedController(
      repository,
      const MomentFeedTarget.main(MomentFeedMode.discover),
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    expect(controller.state.items.single.id, 'moment-1');
    expect(controller.state.hasMore, isTrue);

    await controller.loadMore();
    expect(repository.cursors, [null, 'expired-cursor', null]);
    expect(controller.state.items.single.title, '刷新后的动态');
    expect(controller.state.hasMore, isFalse);

    final card = controller.state.items.single;
    expect(await controller.toggleLike(card), isTrue);
    final liked = controller.state.items.single;
    expect(liked.viewerLiked, isTrue);
    expect(liked.likeCount, 8);
    expect(await controller.toggleBookmark(liked), isTrue);
    expect(controller.state.items.single.viewerBookmarked, isTrue);
    expect(controller.state.items.single.bookmarkCount, 5);
  });

  test('评论失败重试复用同一请求 ID，并刷新主评论与作者候选', () async {
    final repository = _DetailRepository(failFirstComment: true);
    var requestIndex = 0;
    final controller = MomentDetailController(
      repository,
      'moment-1',
      autoStart: false,
      requestIdFactory: () => 'request-${++requestIndex}',
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.detail?.card.title, '今日微光');
    expect(controller.state.comments.single.id, 'comment-root');
    expect(controller.state.commentAuthors.single.username, '温柔测试员');

    const input = MomentCommentInput(
      content: '同一条回复',
      replyToCommentId: 'comment-root',
    );
    expect(await controller.sendComment(input), isNull);
    expect(controller.state.transientFailure?.userMessage, '暂时失败');
    expect(await controller.sendComment(input), isNotNull);
    expect(repository.commentRequestIds, ['request-1', 'request-1']);
    expect(repository.commentsCalls, greaterThanOrEqualTo(2));
  });

  test('楼中楼分页和评论筛选保留服务端顺序，删除后重新校准详情', () async {
    final repository = _DetailRepository();
    final controller = MomentDetailController(
      repository,
      'moment-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    await controller.loadReplies('comment-root');
    expect(
      controller.state.replyPages['comment-root']?.items.single.id,
      'comment-reply',
    );
    await controller.selectCommentOrder(MomentCommentOrder.oldest);
    await controller.selectCommentAuthor('user-1');
    expect(repository.orders.last, MomentCommentOrder.oldest);
    expect(repository.authorIds.last, 'user-1');
    expect(await controller.removeComment('comment-reply'), isTrue);
    expect(repository.removedCommentIds, ['comment-reply']);
    expect(controller.state.phase, MomentLoadPhase.ready);
  });

  test('新动态提交失败复用幂等请求，确认成功后才轮换请求 ID', () async {
    final repository = _ComposerRepository();
    var requestIndex = 0;
    final controller = MomentComposerController(
      repository,
      autoStart: false,
      requestIdFactory: () => 'request-${++requestIndex}',
    );
    addTearDown(controller.dispose);
    const input = MomentDraftInput(title: '今日微光', content: '纯文本', mediaIds: []);

    expect(await controller.submit(input), isNull);
    expect(await controller.submit(input), isNotNull);
    expect(repository.requestIds, ['request-1', 'request-1']);
    expect(controller.state.phase, MomentComposerPhase.succeeded);
  });
}

class _FeedRepository extends Fake implements MomentRepository {
  final cursors = <String?>[];
  var _firstPages = 0;

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    cursors.add(cursor);
    if (cursor == 'expired-cursor') {
      throw const ApiFailure(businessCode: 40007, userMessage: '游标失效');
    }
    _firstPages++;
    return CursorPage(
      items: [_card(title: _firstPages == 1 ? '今日微光' : '刷新后的动态')],
      cursor: _firstPages == 1 ? 'expired-cursor' : null,
      hasMore: _firstPages == 1,
    );
  }

  @override
  Future<MomentActionResult> setLike(
    String momentId, {
    required bool active,
  }) async {
    return MomentActionResult(momentId: momentId, count: 8, active: active);
  }

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
  }) async {
    return MomentActionResult(momentId: momentId, count: 5, active: active);
  }
}

class _DetailRepository extends Fake implements MomentRepository {
  _DetailRepository({this.failFirstComment = false});

  final bool failFirstComment;
  final commentRequestIds = <String>[];
  final orders = <MomentCommentOrder>[];
  final authorIds = <String?>[];
  final removedCommentIds = <String>[];
  var commentsCalls = 0;
  var _failedComment = false;

  @override
  Future<MomentDetail> fetchDetail(String momentId) async => _detail();

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    commentsCalls++;
    orders.add(order);
    authorIds.add(authorId);
    return CursorPage(items: [_rootComment()], cursor: null, hasMore: false);
  }

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) async {
    return [_author()];
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
    return CursorPage(items: [_reply()], cursor: null, hasMore: false);
  }

  @override
  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  }) async {
    commentRequestIds.add(clientRequestId);
    if (failFirstComment && !_failedComment) {
      _failedComment = true;
      throw const ApiFailure(userMessage: '暂时失败');
    }
    return _reply();
  }

  @override
  Future<void> removeComment(String momentId, String commentId) async {
    removedCommentIds.add(commentId);
  }
}

class _ComposerRepository extends Fake implements MomentRepository {
  final requestIds = <String>[];
  var _failed = false;

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    requestIds.add(clientRequestId);
    if (!_failed) {
      _failed = true;
      throw const ApiFailure(userMessage: '暂时失败');
    }
    return _detail();
  }
}

MomentAuthor _author() =>
    const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4);

MomentCard _card({String title = '今日微光'}) {
  final now = DateTime.utc(2026, 8, 10);
  return MomentCard(
    id: 'moment-1',
    author: _author(),
    title: title,
    contentExcerpt: '纯文本摘要',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.rose,
    imageCount: 0,
    likeCount: 2,
    commentCount: 1,
    bookmarkCount: 1,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: false,
    createdAt: now,
    updatedAt: now,
  );
}

MomentDetail _detail() => MomentDetail(
  card: _card(),
  content: '纯文本正文',
  images: const [],
  version: 3,
  canEdit: true,
  canDelete: true,
);

MomentComment _reply() => MomentComment(
  id: 'comment-reply',
  momentId: 'moment-1',
  author: _author(),
  content: '回复',
  parentCommentId: 'comment-root',
  replyToComment: MomentReplyTarget(id: 'comment-root', author: _author()),
  deleted: false,
  canDelete: true,
  createdAt: DateTime.utc(2026, 8, 10, 13),
);

MomentRootComment _rootComment() => MomentRootComment(
  id: 'comment-root',
  momentId: 'moment-1',
  author: _author(),
  content: '主评论',
  deleted: false,
  canDelete: true,
  createdAt: DateTime.utc(2026, 8, 10, 12),
  replyCount: 1,
  replies: [_reply()],
);
