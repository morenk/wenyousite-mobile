import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import '../../support/discussion_window_fixture.dart';

import 'post_controller_dice_fixtures.dart';

void main() {
  test('独立讨论首屏直接读取目标窗口，无须逐页扫描', () async {
    final repository = _FakePostRepository(
      posts: {'root': _post('root'), 'focus': _reply('focus', minute: 2)},
      onReplies: ({cursor, required order, authorId}) async {
        if (cursor == 'next') {
          return CursorPage(
            items: [_reply('reply-2', minute: 3), _reply('focus', minute: 2)],
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

    expect(controller.state.replies.map((item) => item.id), ['focus']);
    expect(repository.postRequests, ['root', 'focus']);
    await controller.locateReply('focus');
    expect(controller.state.replies.map((item) => item.id), ['focus']);

    await controller.setOrder(PostReplyOrder.newest);
    expect(controller.state.order, PostReplyOrder.newest);
    expect(repository.replyRequests.last.order, PostReplyOrder.newest);

    await controller.setAuthor('author-1');
    expect(controller.state.authorId, 'author-1');
    expect(repository.replyRequests.last.authorId, 'author-1');
    expect(controller.state.replies.map((item) => item.id), ['reply-1']);
  });

  test('首屏外目标回复归属不符时不显示讨论内容', () async {
    final repository = _FakePostRepository(
      posts: {'root': _post('root'), 'focus': _post('focus')},
      onReplies: ({cursor, required order, authorId}) async =>
          CursorPage(items: [_reply('reply-1')], hasMore: false),
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: 'focus',
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();

    expect(repository.postRequests, ['root', 'focus']);
    expect(controller.state.phase, PostDiscussionPhase.failed);
    expect(controller.state.root, isNull);
    expect(controller.state.replies, isEmpty);
  });

  for (final status in [403, 404]) {
    test('首屏外目标回复返回 $status 时隐藏讨论内容', () async {
      final repository = _FakePostRepository(
        posts: {'root': _post('root')},
        onFetchPost: (postId) async {
          if (postId == 'focus') {
            throw ApiFailure(userMessage: '当前无法查看目标回复。', httpStatus: status);
          }
          return _post('root');
        },
        onReplies: ({cursor, required order, authorId}) async =>
            CursorPage(items: [_reply('reply-1')], hasMore: false),
      );
      final controller = PostDiscussionController(repository, (
        rootPostId: 'root',
        focusedReplyId: 'focus',
      ), autoStart: false);
      addTearDown(controller.dispose);

      await controller.load();

      expect(repository.postRequests, ['root', 'focus']);
      expect(controller.state.phase, PostDiscussionPhase.restricted);
      expect(controller.state.root, isNull);
      expect(controller.state.replies, isEmpty);
      expect(controller.state.failure?.httpStatus, status);
    });
  }

  test('首屏外目标回复请求失败后可重新验证并打开', () async {
    var focusRequests = 0;
    final repository = _FakePostRepository(
      posts: {'root': _post('root'), 'focus': _reply('focus')},
      onFetchPost: (postId) async {
        if (postId == 'focus' && ++focusRequests == 1) {
          throw const ApiFailure(userMessage: '暂时不可用。', httpStatus: 503);
        }
        return postId == 'root' ? _post('root') : _reply('focus');
      },
      onReplies: ({cursor, required order, authorId}) async =>
          CursorPage(items: [_reply('reply-1')], hasMore: false),
    );
    final controller = PostDiscussionController(repository, (
      rootPostId: 'root',
      focusedReplyId: 'focus',
    ), autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.phase, PostDiscussionPhase.failed);
    expect(controller.state.root, isNull);
    expect(controller.state.replies, isEmpty);

    await controller.load();
    expect(repository.postRequests, ['root', 'focus', 'root', 'focus']);
    expect(controller.state.phase, PostDiscussionPhase.ready);
    expect(controller.state.replies.map((reply) => reply.id), ['focus']);
  });

  test('独立讨论每次邻近预取只加载一页', () async {
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
    ]);
    expect(controller.state.hasMore, isTrue);
    expect(controller.state.isPrefetchingReplies, isFalse);
    expect(maximumActiveRequests, 1);
    expect(repository.replyRequests.map((request) => request.cursor), [
      null,
      'page-2',
    ]);
  });

  test('回复分页 cursor 失效只重取当前位置窗口一次', () async {
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

  test('创建结果不明确时冻结正文、身份与幂等键，重试只确认原发表', () async {
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

    expect(
      await controller.submit(
        identityMode: PostIdentityMode.rp,
        identityToken: 'rp-old',
        identityId: 'role-old',
      ),
      isNull,
    );
    expect(controller.state.hasAmbiguousCreate, isTrue);
    controller.updateContent('断线后继续编辑');
    final result = await controller.submit(
      identityMode: PostIdentityMode.account,
      identityToken: 'changed',
      identityId: 'role-new',
    );

    expect(result?.content, '第一次提交');
    expect(repository.createInputs, hasLength(2));
    expect(
      repository.createInputs.map((input) => input.clientRequestId).toSet(),
      {'request-stable'},
    );
    expect(repository.createInputs.last.content, '第一次提交');
    expect(repository.createInputs.last.identityMode, PostIdentityMode.rp);
    expect(repository.createInputs.last.identityToken, 'rp-old');
    expect(repository.createInputs.last.identityId, 'role-old');
    expect(repository.updateRequests, isEmpty);
    expect(controller.state.pendingCreate, isNull);
  });

  test('先持久化发表意图再发送，重新打开仍复用原身份和请求键', () async {
    Map<String, Object?>? saved;
    final repository = _FakePostRepository(
      onCreate: (input) async {
        expect(saved, isNotNull);
        expect(
          PostPublishDraft.fromJson(saved)?.pending?.input.clientRequestId,
          input.clientRequestId,
        );
        throw const ApiFailure(userMessage: '连接中断');
      },
    );
    final controller = PostComposerController(
      repository,
      _createFloorTarget,
      createRequestId: () => 'stable',
    );
    controller.updateContent('持久草稿');
    await controller.submit(
      identityMode: PostIdentityMode.rp,
      identityToken: 'token-old',
      identityId: 'restored-role',
      persistCreateIntent: () async {
        saved = PostPublishDraft(
          mode: PostIdentityMode.rp,
          identityToken: 'token-old',
          identityId: 'restored-role',
          pending: controller.state.pendingCreate,
        ).toJson();
        expect(repository.createInputs, isEmpty);
        return true;
      },
    );
    controller.dispose();
    final retryRepository = _FakePostRepository();
    final reopened = PostComposerController(
      retryRepository,
      _createFloorTarget,
      createRequestId: () => 'must-not-use',
    );
    addTearDown(reopened.dispose);
    reopened.restorePendingCreate(PostPublishDraft.fromJson(saved)!.pending!);
    await reopened.submit(identityMode: PostIdentityMode.account);
    expect(retryRepository.createInputs.single.content, '持久草稿');
    expect(retryRepository.createInputs.single.clientRequestId, 'stable');
    expect(retryRepository.createInputs.single.identityToken, 'token-old');
    expect(retryRepository.createInputs.single.identityId, 'restored-role');
    expect(
      retryRepository.createInputs.single.identityMode,
      PostIdentityMode.rp,
    );
  });

  test('发表意图保存失败不发送请求，可原样重试', () async {
    final repository = _FakePostRepository();
    final controller = PostComposerController(
      repository,
      _createFloorTarget,
      createRequestId: () => 'stable',
    );
    addTearDown(controller.dispose);
    controller.updateContent('草稿');
    expect(
      await controller.submit(persistCreateIntent: () async => false),
      isNull,
    );
    expect(repository.createInputs, isEmpty);
    expect(controller.state.isSubmitting, isFalse);
    expect(controller.state.pendingCreate?.input.clientRequestId, 'stable');
    expect(
      await controller.submit(persistCreateIntent: () async => true),
      isNotNull,
    );
    expect(repository.createInputs.single.clientRequestId, 'stable');
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

    body.updateContent(postControllerDiceMarkdown(20));
    expect(await body.submit(), isNull);
    expect(body.state.failure?.userMessage, '子贴正文需要包含文字，骰子可作为补充。');
    expect(repository.bodyRequests, isEmpty);
  });

  test('子贴 BODY 在 20 个骰子边界可写入，第 21 个优先返回上限错误', () async {
    final repository = _FakePostRepository();
    final body = PostComposerController(repository, _bodyTarget);
    addTearDown(body.dispose);

    final maximum = '子贴文字 ${postControllerDiceMarkdown(20)}';
    body.updateContent(maximum);
    expect(await body.submit(), isNotNull);
    expect(repository.bodyRequests.single.content, maximum);

    body.updateContent('子贴文字 ${postControllerDiceMarkdown(21)}');
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

    body.updateContent('子贴文字 ${postControllerDiceMarkdown(20, namespace: 0)}');
    floor.updateContent(postControllerDiceMarkdown(20, namespace: 1));
    reply.updateContent(postControllerDiceMarkdown(20, namespace: 2));

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

      composer.updateContent(postControllerDiceMarkdown(21));
      expect(await composer.submit(), isNull);
      expect(composer.state.failure?.userMessage, '当前正文最多可插入 20 个骰子，请删除一个后重试。');
      expect(repository.createInputs, isEmpty);
    }
  });

  test('编辑路径允许纯骰子及 20 个边界，并在第 21 个时零调用', () async {
    final repository = _FakePostRepository();
    final editor = PostComposerController(repository, _editTarget);
    addTearDown(editor.dispose);

    editor.updateContent(postControllerDiceMarkdown(1));
    expect(await editor.submit(), isNotNull);
    expect(repository.updateRequests, hasLength(1));

    editor.updateContent(postControllerDiceMarkdown(20));
    expect(await editor.submit(), isNotNull);
    expect(repository.updateRequests, hasLength(2));

    editor.updateContent(postControllerDiceMarkdown(21));
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
        '${postControllerIgnoredDiceMarkdown()}\n${postControllerDiceMarkdown(20, namespace: 5)}';

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

class _FakePostRepository with PostWindowFixture implements PostRepository {
  _FakePostRepository({
    this.posts = const {},
    this.onFetchPost,
    this.onReplies,
    this.onCreate,
    this.onUpdate,
    this.removeFailure,
    this.pinFailure,
  });

  final Map<String, PostItem> posts;
  final Future<PostItem> Function(String postId)? onFetchPost;
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
  final List<String> postRequests = [];
  final List<({String postId, bool pinned})> pinRequests = [];

  @override
  Future<PostItem> fetchPost(String postId) async {
    postRequests.add(postId);
    return await onFetchPost?.call(postId) ?? posts[postId]!;
  }

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
    String? identityToken,
    String? identityId,
    PostIdentityMode? identityMode,
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
