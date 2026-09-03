import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

void main() {
  test('独立讨论保留首屏外目标回复并按筛选和 cursor 分页', () async {
    final repository = _FakePostRepository(
      posts: {'root': _post('root'), 'focus': _reply('focus', minute: 2)},
      onReplies: ({cursor, required order, authorId}) async {
        if (cursor == 'next') {
          return CursorPage(
            items: [_reply('reply-2', minute: 3)],
            hasMore: false,
          );
        }
        return CursorPage(
          items: [_reply('reply-1', minute: 1)],
          cursor: authorId == null ? 'next' : null,
          hasMore: authorId == null,
        );
      },
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: 'focus',
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.state.replies.map((item) => item.id), [
      'reply-1',
      'focus',
    ]);
    await controller.loadMore();
    expect(controller.state.replies.map((item) => item.id), [
      'reply-1',
      'focus',
      'reply-2',
    ]);

    await controller.setOrder(PostReplyOrder.newest);
    expect(controller.state.order, PostReplyOrder.newest);
    expect(repository.replyRequests.last.order, PostReplyOrder.newest);

    await controller.setAuthor('author-1');
    expect(controller.state.authorId, 'author-1');
    expect(repository.replyRequests.last.authorId, 'author-1');
    expect(controller.state.replies.map((item) => item.id), ['reply-1']);
  });

  test('独立讨论首屏完成后串行预取剩余全部文字回复', () async {
    var activeRequests = 0;
    var maximumActiveRequests = 0;
    final repository = _FakePostRepository(
      posts: {'root': _post('root')},
      onReplies: ({cursor, required order, authorId}) async {
        activeRequests += 1;
        maximumActiveRequests = maximumActiveRequests < activeRequests
            ? activeRequests
            : maximumActiveRequests;
        await Future<void>.delayed(Duration.zero);
        activeRequests -= 1;
        return switch (cursor) {
          null => CursorPage(
            items: [_reply('reply-1')],
            cursor: 'page-2',
            hasMore: true,
          ),
          'page-2' => CursorPage(
            items: [_reply('reply-2')],
            cursor: 'page-3',
            hasMore: true,
          ),
          _ => CursorPage(items: [_reply('reply-3')], hasMore: false),
        };
      },
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.replies.map((item) => item.id), ['reply-1']);

    final prefetch = controller.prefetchRemainingReplies();
    expect(controller.state.isPrefetchingReplies, isTrue);
    await prefetch;

    expect(controller.state.replies.map((item) => item.id), [
      'reply-1',
      'reply-2',
      'reply-3',
    ]);
    expect(controller.state.hasMore, isFalse);
    expect(controller.state.isPrefetchingReplies, isFalse);
    expect(maximumActiveRequests, 1);
    expect(repository.replyRequests.map((request) => request.cursor), [
      null,
      'page-2',
      'page-3',
    ]);
  });

  test('回复分页 cursor 连续失效时只重载一次首页并提供重试', () async {
    var firstPage = 0;
    final repository = _FakePostRepository(
      posts: {'root': _post('root')},
      onReplies: ({cursor, required order, authorId}) async {
        if (cursor != null) {
          throw const ApiFailure(userMessage: '列表位置已失效。', businessCode: 40007);
        }
        firstPage += 1;
        return CursorPage(
          items: [_reply('fresh-$firstPage')],
          cursor: 'expired',
          hasMore: true,
        );
      },
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();
    await controller.loadMore();

    expect(firstPage, 2);
    expect(controller.state.replies.single.id, 'fresh-2');
    expect(controller.state.transientFailure?.isInvalidCursor, isTrue);
    expect(controller.state.retryAction, PostDiscussionRetryAction.loadMore);
    expect(controller.state.isPrefetchingReplies, isFalse);
  });

  test('楼中楼刷新遇到权限撤销时清除已经显示的私密内容', () async {
    var calls = 0;
    final repository = _FakePostRepository(
      posts: {'root': _post('root')},
      onReplies: ({cursor, required order, authorId}) async {
        calls += 1;
        if (calls > 1) {
          throw const ApiFailure(userMessage: '当前无法查看这段讨论。', httpStatus: 403);
        }
        return CursorPage(
          items: [_reply('private-reply')],
          cursor: 'next',
          hasMore: true,
        );
      },
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.root, isNotNull);
    expect(controller.state.replies, isNotEmpty);

    await controller.refresh();

    expect(controller.state.phase, PostDiscussionPhase.restricted);
    expect(controller.state.root, isNull);
    expect(controller.state.replies, isEmpty);
    expect(controller.state.cursor, isNull);
    expect(controller.state.hasMore, isFalse);
    expect(controller.state.failure?.httpStatus, 403);
  });

  test('刷新失败的重试仍刷新首屏而不是错误加载下一页', () async {
    var calls = 0;
    final repository = _FakePostRepository(
      posts: {'root': _post('root')},
      onReplies: ({cursor, required order, authorId}) async {
        calls += 1;
        if (calls == 2) {
          throw const ApiFailure(userMessage: '暂时不可用。', httpStatus: 503);
        }
        return CursorPage(items: [_reply('reply-$calls')], hasMore: false);
      },
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();
    await controller.refresh();
    expect(controller.state.retryAction, PostDiscussionRetryAction.refresh);

    await controller.retryTransientFailure();

    expect(controller.state.replies.single.id, 'reply-3');
    expect(repository.replyRequests.last.cursor, isNull);
    expect(controller.state.transientFailure, isNull);
    expect(controller.state.retryAction, isNull);
  });

  test('一次应用回复顺序与作者筛选只重新加载一次', () async {
    final repository = _FakePostRepository(
      posts: {'root': _post('root')},
      onReplies: ({cursor, required order, authorId}) async =>
          CursorPage(items: [_reply('reply')], hasMore: false),
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: null,
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();
    final callsBeforeFilter = repository.replyRequests.length;
    await controller.applyFilters(
      order: PostReplyOrder.newest,
      authorId: 'author-1',
    );

    expect(repository.replyRequests.length, callsBeforeFilter + 1);
    expect(controller.state.authorId, 'author-1');
    expect(repository.replyRequests.last.authorId, 'author-1');
    expect(repository.replyRequests.last.order, PostReplyOrder.newest);
  });

  test('创建结果不明确时复用幂等键，确认后补写用户的新内容', () async {
    var createCalls = 0;
    final repository = _FakePostRepository(
      onCreate: (input) async {
        createCalls += 1;
        if (createCalls == 1) {
          throw const ApiFailure(userMessage: '服务不可用。', httpStatus: 503);
        }
        return _post('created', content: input.content, version: 1);
      },
      onUpdate: ({required postId, required content, required version}) async {
        return _post(postId, content: content, version: version + 1);
      },
    );
    final controller = PostComposerController(
      repository,
      _createFloorTarget,
      createRequestId: () => 'request-stable',
    );
    addTearDown(controller.dispose);
    controller.updateContent('第一次提交');

    expect(await controller.submit(), isNull);
    expect(controller.state.hasAmbiguousCreate, isTrue);
    controller.updateContent('断线后继续编辑');
    final result = await controller.submit();

    expect(result?.content, '断线后继续编辑');
    expect(repository.createInputs, hasLength(2));
    expect(
      repository.createInputs.map((input) => input.clientRequestId).toSet(),
      {'request-stable'},
    );
    expect(repository.createInputs.last.content, '第一次提交');
    expect(repository.updateRequests.single.content, '断线后继续编辑');
    expect(controller.state.pendingCreate, isNull);
  });

  test('编辑版本冲突读取最新版并只在确认后以新版本覆盖', () async {
    var updateCalls = 0;
    final repository = _FakePostRepository(
      posts: {'floor': _post('floor', content: '云端新版', version: 4)},
      onUpdate: ({required postId, required content, required version}) async {
        updateCalls += 1;
        if (updateCalls == 1) {
          throw const ApiFailure(
            userMessage: '版本冲突。',
            httpStatus: 409,
            businessCode: 40002,
          );
        }
        return _post(postId, content: content, version: version + 1);
      },
    );
    final controller = PostComposerController(repository, _editTarget);
    addTearDown(controller.dispose);
    controller.updateContent('我的编辑');

    expect(await controller.submit(), isNull);
    expect(controller.state.conflict?.latest.version, 4);
    expect(repository.updateRequests.single.version, 1);

    final result = await controller.retryConflict();
    expect(result?.version, 5);
    expect(repository.updateRequests.last.version, 4);
    expect(repository.updateRequests.last.content, '我的编辑');
  });

  test('编辑结果丢失后回读到相同正文时直接收敛为成功', () async {
    final repository = _FakePostRepository(
      posts: {'floor': _post('floor', content: '我的编辑', version: 2)},
      onUpdate: ({required postId, required content, required version}) async {
        throw const ApiFailure(
          userMessage: '正文已有更新。',
          httpStatus: 409,
          businessCode: 40002,
        );
      },
    );
    final controller = PostComposerController(repository, _editTarget);
    addTearDown(controller.dispose);
    controller.updateContent('我的编辑');

    final result = await controller.submit();

    expect(result?.content, '我的编辑');
    expect(result?.version, 2);
    expect(controller.state.result, same(result));
    expect(controller.state.failure, isNull);
    expect(controller.state.conflict, isNull);
    expect(repository.updateRequests, hasLength(1));
  });

  test('携带其他业务码的 409 不误判为正文版本冲突', () async {
    final repository = _FakePostRepository(
      onUpdate: ({required postId, required content, required version}) async {
        throw const ApiFailure(
          userMessage: '这次操作与待确认请求冲突。',
          httpStatus: 409,
          businessCode: 40912,
        );
      },
    );
    final controller = PostComposerController(repository, _editTarget);
    addTearDown(controller.dispose);
    controller.updateContent('我的编辑');

    expect(await controller.submit(), isNull);
    expect(controller.state.failure?.businessCode, 40912);
    expect(controller.state.conflict, isNull);
  });

  test('正文写入透传版本，删除动作拒绝正文但允许普通楼层', () async {
    final repository = _FakePostRepository();
    final composer = PostComposerController(repository, _bodyTarget);
    final actions = PostActionController(repository);
    addTearDown(composer.dispose);
    addTearDown(actions.dispose);
    composer.updateContent('更新后的正文');

    final body = await composer.submit();
    expect(body?.isBody, isTrue);
    expect(repository.bodyRequests.single.version, 7);
    expect(await actions.remove(body!), isFalse);

    final floor = _post('floor');
    expect(await actions.remove(floor), isTrue);
    expect(repository.removedIds, ['floor']);
  });

  test('子贴 BODY 拒绝空正文和纯骰子，且不请求仓储', () async {
    final repository = _FakePostRepository();
    final body = PostComposerController(repository, _bodyTarget);
    addTearDown(body.dispose);

    body.updateContent('');
    expect(await body.submit(), isNull);
    expect(body.state.failure?.userMessage, '子贴正文需要包含文字，骰子可作为补充。');
    expect(repository.bodyRequests, isEmpty);

    body.updateContent(_diceMarkdown(20));
    expect(await body.submit(), isNull);
    expect(body.state.failure?.userMessage, '子贴正文需要包含文字，骰子可作为补充。');
    expect(repository.bodyRequests, isEmpty);
  });

  test('子贴 BODY 在 20 个骰子边界可写入，第 21 个优先返回上限错误', () async {
    final repository = _FakePostRepository();
    final body = PostComposerController(repository, _bodyTarget);
    addTearDown(body.dispose);

    final maximum = '子贴文字 ${_diceMarkdown(20)}';
    body.updateContent(maximum);
    expect(await body.submit(), isNotNull);
    expect(repository.bodyRequests.single.content, maximum);

    body.updateContent('子贴文字 ${_diceMarkdown(21)}');
    expect(await body.submit(), isNull);
    expect(body.state.failure?.userMessage, '当前正文最多可插入 20 个骰子，请删除一个后重试。');
    expect(repository.bodyRequests, hasLength(1));
  });

  test('楼层和楼中楼回复均允许纯骰子，且每份 Post 独立拥有 20 个', () async {
    final repository = _FakePostRepository();
    final body = PostComposerController(repository, _bodyTarget);
    final floor = PostComposerController(repository, _createFloorTarget);
    final reply = PostComposerController(repository, _createReplyTarget);
    addTearDown(body.dispose);
    addTearDown(floor.dispose);
    addTearDown(reply.dispose);

    body.updateContent('子贴文字 ${_diceMarkdown(20, namespace: 0)}');
    floor.updateContent(_diceMarkdown(20, namespace: 1));
    reply.updateContent(_diceMarkdown(20, namespace: 2));

    expect(await body.submit(), isNotNull);
    expect(await floor.submit(), isNotNull);
    expect(await reply.submit(), isNotNull);
    expect(repository.bodyRequests, hasLength(1));
    expect(repository.createInputs, hasLength(2));
    expect(repository.createInputs[0].parentPostId, isNull);
    expect(repository.createInputs[1].parentPostId, 'floor');
    expect(repository.createInputs[1].replyToPostId, 'floor');
  });

  test('楼层和回复创建路径均在 0 和 21 个骰子时拦截仓储请求', () async {
    for (final target in [_createFloorTarget, _createReplyTarget]) {
      final repository = _FakePostRepository();
      final composer = PostComposerController(repository, target);
      addTearDown(composer.dispose);

      composer.updateContent('');
      expect(await composer.submit(), isNull);
      expect(composer.state.failure?.userMessage, '正文和骰子不能同时为空。');
      expect(repository.createInputs, isEmpty);

      composer.updateContent(_diceMarkdown(21));
      expect(await composer.submit(), isNull);
      expect(composer.state.failure?.userMessage, '当前正文最多可插入 20 个骰子，请删除一个后重试。');
      expect(repository.createInputs, isEmpty);
    }
  });

  test('编辑路径允许纯骰子及 20 个边界，并在第 21 个时零调用', () async {
    final repository = _FakePostRepository();
    final editor = PostComposerController(repository, _editTarget);
    addTearDown(editor.dispose);

    editor.updateContent(_diceMarkdown(1));
    expect(await editor.submit(), isNotNull);
    expect(repository.updateRequests, hasLength(1));

    editor.updateContent(_diceMarkdown(20));
    expect(await editor.submit(), isNotNull);
    expect(repository.updateRequests, hasLength(2));

    editor.updateContent(_diceMarkdown(21));
    expect(await editor.submit(), isNull);
    expect(editor.state.failure?.userMessage, '当前正文最多可插入 20 个骰子，请删除一个后重试。');
    expect(repository.updateRequests, hasLength(2));
  });

  test('代码、行内代码、转义和非法协议中的伪骰子不占用 Post 上限', () async {
    final repository = _FakePostRepository();
    final body = PostComposerController(repository, _bodyTarget);
    final floor = PostComposerController(repository, _createFloorTarget);
    addTearDown(body.dispose);
    addTearDown(floor.dispose);
    final content =
        '${_ignoredDiceMarkdown()}\n${_diceMarkdown(20, namespace: 5)}';

    body.updateContent(content);
    floor.updateContent(content);

    expect(await body.submit(), isNotNull);
    expect(await floor.submit(), isNotNull);
    expect(repository.bodyRequests.single.content, content);
    expect(repository.createInputs.single.content, content);
  });

  test('帖子删除重放返回 POST_NOT_FOUND 时收敛为已经删除', () async {
    final repository = _FakePostRepository(
      removeFailure: const ApiFailure(
        userMessage: '帖子不存在。',
        httpStatus: 404,
        businessCode: 40403,
      ),
    );
    final actions = PostActionController(repository);
    addTearDown(actions.dispose);

    expect(await actions.remove(_post('already-removed')), isTrue);
    expect(actions.state.failure, isNull);
    expect(actions.state.successMessage, '帖子已删除。');
  });

  test('主楼层置顶成功递增完成版本，非法目标与失败不递增', () async {
    final repository = _FakePostRepository();
    final actions = PostActionController(repository);
    addTearDown(actions.dispose);

    expect(await actions.setPinned(_post('floor'), pinned: true), isTrue);
    expect(repository.pinRequests, [(postId: 'floor', pinned: true)]);
    expect(actions.state.pinRevision, 1);
    expect(actions.state.successMessage, '楼层已置顶。');
    actions.clearFeedback();
    expect(actions.state.pinRevision, 1);
    expect(await actions.setPinned(_reply('reply'), pinned: true), isFalse);
    expect(repository.pinRequests, hasLength(1));

    final denied = PostActionController(
      _FakePostRepository(
        pinFailure: const ApiFailure(
          userMessage: '当前账号不能执行这项操作。',
          httpStatus: 403,
        ),
      ),
    );
    addTearDown(denied.dispose);
    expect(await denied.setPinned(_post('floor'), pinned: false), isFalse);
    expect(denied.state.pinRevision, 0);
    expect(denied.state.failure?.httpStatus, 403);
  });
}

const _author = PostAuthor(id: 'author-1', username: '作者甲', level: 3);
const _otherAuthor = PostAuthor(id: 'author-2', username: '作者乙', level: 2);

String _diceMarkdown(int count, {int namespace = 0}) =>
    List.generate(count, (index) {
      final suffix = (namespace * 100 + index).toString().padLeft(12, '0');
      return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
    }).join(' ');

String _ignoredDiceMarkdown() {
  final nodes = _diceMarkdown(21);
  return [
    '可见文字',
    '```text',
    nodes,
    '```',
    '`${_diceMarkdown(1)}`',
    r'\[[dice:v1:00000000-0000-4000-8000-000000000099:1d6]]',
    '[[dice:v1:not-a-uuid:1d6]]',
    '[[dice:v1:00000000-0000-4000-8000-000000000098:1d1]]',
  ].join('\n');
}

PostItem _post(
  String id, {
  String content = '楼层内容',
  int version = 1,
  bool body = false,
}) {
  return PostItem(
    id: id,
    threadId: 'thread',
    subthreadId: 'subthread',
    author: _author,
    content: content,
    version: version,
    createdAt: DateTime.utc(2026, 8, 10),
    updatedAt: DateTime.utc(2026, 8, 10),
    isBody: body,
    isDeleted: false,
    floorNumber: body ? null : 1,
  );
}

PostItem _reply(String id, {int minute = 0}) {
  return PostItem(
    id: id,
    threadId: 'thread',
    subthreadId: 'subthread',
    author: id == 'focus' ? _otherAuthor : _author,
    content: '回复 $id',
    version: 1,
    createdAt: DateTime.utc(2026, 8, 10, 0, minute),
    updatedAt: DateTime.utc(2026, 8, 10, 0, minute),
    isBody: false,
    isDeleted: false,
    parentPostId: 'root',
    replyToPostId: 'root',
  );
}

const PostComposerTarget _createFloorTarget = (
  kind: PostComposerKind.createFloor,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: null,
  parentPostId: null,
  replyToPostId: null,
  version: null,
  initialContent: '',
  label: '发表楼层',
);

const PostComposerTarget _createReplyTarget = (
  kind: PostComposerKind.createReply,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: null,
  parentPostId: 'floor',
  replyToPostId: 'floor',
  version: null,
  initialContent: '',
  label: '回复楼主',
);

const PostComposerTarget _editTarget = (
  kind: PostComposerKind.editPost,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: 'floor',
  parentPostId: null,
  replyToPostId: null,
  version: 1,
  initialContent: '旧内容',
  label: '编辑楼层',
);

const PostComposerTarget _bodyTarget = (
  kind: PostComposerKind.upsertBody,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: 'body',
  parentPostId: null,
  replyToPostId: null,
  version: 7,
  initialContent: '旧正文',
  label: '编辑正文',
);

typedef _ReplyLoader =
    Future<PostReplyPage> Function({
      String? cursor,
      required PostReplyOrder order,
      String? authorId,
    });
typedef _UpdateHandler =
    Future<PostItem> Function({
      required String postId,
      required String content,
      required int version,
    });

class _FakePostRepository implements PostRepository {
  _FakePostRepository({
    this.posts = const {},
    this.onReplies,
    this.onCreate,
    this.onUpdate,
    this.removeFailure,
    this.pinFailure,
  });

  final Map<String, PostItem> posts;
  final _ReplyLoader? onReplies;
  final Future<PostItem> Function(PostCreateInput input)? onCreate;
  final _UpdateHandler? onUpdate;
  final ApiFailure? removeFailure;
  final ApiFailure? pinFailure;
  final List<({String? cursor, PostReplyOrder order, String? authorId})>
  replyRequests = [];
  final List<PostCreateInput> createInputs = [];
  final List<({String postId, String content, int version})> updateRequests =
      [];
  final List<({String subthreadId, String content, int? version})>
  bodyRequests = [];
  final List<String> removedIds = [];
  final List<({String postId, bool pinned})> pinRequests = [];

  @override
  Future<PostItem> fetchPost(String postId) async => posts[postId]!;

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) {
    replyRequests.add((cursor: cursor, order: order, authorId: authorId));
    return onReplies?.call(cursor: cursor, order: order, authorId: authorId) ??
        Future.value(const CursorPage(items: [], hasMore: false));
  }

  @override
  Future<PostItem> create(PostCreateInput input) {
    createInputs.add(input);
    return onCreate?.call(input) ?? Future.value(_post('created'));
  }

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) {
    updateRequests.add((postId: postId, content: content, version: version));
    return onUpdate?.call(postId: postId, content: content, version: version) ??
        Future.value(_post(postId, content: content, version: version + 1));
  }

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) async {
    bodyRequests.add((
      subthreadId: subthreadId,
      content: content,
      version: version,
    ));
    return _post(
      'body',
      content: content,
      version: (version ?? 0) + 1,
      body: true,
    );
  }

  @override
  Future<void> remove(String postId) async {
    if (removeFailure case final failure?) throw failure;
    removedIds.add(postId);
  }

  @override
  Future<void> setPinned(String postId, {required bool pinned}) async {
    if (pinFailure case final failure?) throw failure;
    pinRequests.add((postId: postId, pinned: pinned));
  }
}
