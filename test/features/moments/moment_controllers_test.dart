import 'dart:async';

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

  test('评论失败重试复用同一请求 ID，详情初次加载同时取得作者候选', () async {
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
    final callsBeforeFilter = repository.commentsCalls;
    await controller.applyCommentFilters(
      order: MomentCommentOrder.oldest,
      authorId: 'user-1',
    );
    expect(repository.commentsCalls, callsBeforeFilter + 1);
    expect(repository.orders.last, MomentCommentOrder.oldest);
    expect(repository.authorIds.last, 'user-1');
    expect(await controller.removeComment('comment-reply'), isTrue);
    expect(repository.removedCommentIds, ['comment-reply']);
    expect(controller.state.phase, MomentLoadPhase.ready);
  });

  test('评论作者候选失败不阻塞正文与评论，并可独立重试', () async {
    final repository = _DetailRepository(failFirstAuthors: true);
    final controller = MomentDetailController(
      repository,
      'moment-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.phase, MomentLoadPhase.ready);
    expect(controller.state.detail?.card.title, '今日微光');
    expect(controller.state.comments.single.id, 'comment-root');
    expect(controller.state.commentAuthors, isEmpty);
    expect(controller.state.commentAuthorsFailure?.userMessage, '作者暂时不可用');
    final commentsCalls = repository.commentsCalls;

    await controller.retryCommentAuthors();

    expect(controller.state.commentAuthors.single.username, '温柔测试员');
    expect(controller.state.commentAuthorsFailure, isNull);
    expect(repository.commentsCalls, commentsCalls);
  });

  test('评论筛选不会取消仍在加载的作者候选', () async {
    final pendingAuthors = Completer<List<MomentAuthor>>();
    final repository = _DetailRepository(
      onAuthors: () => pendingAuthors.future,
    );
    final controller = MomentDetailController(
      repository,
      'moment-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.isLoadingCommentAuthors, isTrue);

    await controller.applyCommentFilters(
      order: MomentCommentOrder.oldest,
      authorId: null,
    );
    pendingAuthors.complete([_author()]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.isLoadingCommentAuthors, isFalse);
    expect(controller.state.commentAuthors.single.username, '温柔测试员');
  });

  test('评论筛选变化后忽略旧筛选条件下晚返回的楼中楼', () async {
    final staleReplies = Completer<CursorPage<MomentComment>>();
    final repository = _DetailRepository(
      onReplies: ({required authorId}) => staleReplies.future,
    );
    final controller = MomentDetailController(
      repository,
      'moment-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final loadReplies = controller.loadReplies('comment-root');
    await Future<void>.delayed(Duration.zero);
    await controller.selectCommentAuthor('user-1');
    staleReplies.complete(
      CursorPage(items: [_reply()], cursor: null, hasMore: false),
    );
    await loadReplies;

    expect(controller.state.commentAuthorId, 'user-1');
    expect(controller.state.replyPages, isEmpty);
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

  test('编辑冲突经用户确认后读取最新版本并保留本机内容重试', () async {
    final repository = _ConflictComposerRepository();
    final controller = MomentComposerController(
      repository,
      momentId: 'moment-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    const input = MomentDraftInput(
      title: '保留我的标题',
      content: '保留我的正文',
      mediaIds: [],
    );

    await controller.load();
    expect(await controller.submit(input), isNull);
    expect(controller.state.failure?.businessCode, 40002);

    final saved = await controller.resubmitAfterConflict(input);

    expect(saved?.card.title, '保留我的标题');
    expect(repository.updatedVersions, [3, 4]);
    expect(repository.fetchCalls, 2);
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
  _DetailRepository({
    this.failFirstComment = false,
    this.failFirstAuthors = false,
    this.onAuthors,
    this.onReplies,
  });

  final bool failFirstComment;
  final bool failFirstAuthors;
  final Future<List<MomentAuthor>> Function()? onAuthors;
  final Future<CursorPage<MomentComment>> Function({required String? authorId})?
  onReplies;
  final commentRequestIds = <String>[];
  final orders = <MomentCommentOrder>[];
  final authorIds = <String?>[];
  final removedCommentIds = <String>[];
  var commentsCalls = 0;
  var _failedComment = false;
  var _failedAuthors = false;

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
    if (onAuthors case final callback?) return callback();
    if (failFirstAuthors && !_failedAuthors) {
      _failedAuthors = true;
      throw const ApiFailure(userMessage: '作者暂时不可用');
    }
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
    if (onReplies case final callback?) {
      return callback(authorId: authorId);
    }
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

class _ConflictComposerRepository extends Fake implements MomentRepository {
  final updatedVersions = <int>[];
  var fetchCalls = 0;

  @override
  Future<MomentDetail> fetchDetail(String momentId) async {
    fetchCalls += 1;
    return _detail(version: fetchCalls == 1 ? 3 : 4);
  }

  @override
  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  }) async {
    updatedVersions.add(version);
    if (version == 3) {
      throw const ApiFailure(businessCode: 40002, userMessage: '这条动态刚刚更新了。');
    }
    return MomentDetail(
      card: _card(title: input.title),
      content: input.content,
      images: const [],
      version: 5,
      canEdit: true,
      canDelete: true,
    );
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

MomentDetail _detail({int version = 3}) => MomentDetail(
  card: _card(),
  content: '纯文本正文',
  images: const [],
  version: version,
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
