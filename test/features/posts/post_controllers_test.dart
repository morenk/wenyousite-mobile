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

  test('回复分页 cursor 失效时从当前筛选第一页恢复', () async {
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
    expect(controller.state.transientFailure, isNull);
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
}

const _author = PostAuthor(id: 'author-1', username: '作者甲', level: 3);
const _otherAuthor = PostAuthor(id: 'author-2', username: '作者乙', level: 2);

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
  });

  final Map<String, PostItem> posts;
  final _ReplyLoader? onReplies;
  final Future<PostItem> Function(PostCreateInput input)? onCreate;
  final _UpdateHandler? onUpdate;
  final List<({String? cursor, PostReplyOrder order, String? authorId})>
  replyRequests = [];
  final List<PostCreateInput> createInputs = [];
  final List<({String postId, String content, int version})> updateRequests =
      [];
  final List<({String subthreadId, String content, int? version})>
  bodyRequests = [];
  final List<String> removedIds = [];

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
  Future<void> remove(String postId) async => removedIds.add(postId);
}
