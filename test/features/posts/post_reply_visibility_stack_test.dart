import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';

import '../../support/scripted_http_client_adapter.dart';

// 原楼层实测 76 条，正序每页 20 条，第 74 条的目标详情不可见；
// 倒序同一条位于首屏第 3 条。身份和正文均用占位数据，保留触发关系。
const _replyCount = 76;
const _unavailableReplyNumber = 74;

void main() {
  test('原楼层正序四页经过生成客户端完整加载，刷新重试不再卡在末页', () async {
    final stack = _DiscussionStack();
    addTearDown(stack.close);
    final controller = stack.controller;

    await controller.load();
    expect(controller.state.phase, PostDiscussionPhase.ready);
    expect(controller.state.replies, hasLength(20));
    await controller.prefetchRemainingReplies();
    _expectComplete(controller, PostReplyOrder.oldest);
    expect(
      stack.replyRequests.map((request) => request.queryParameters['cursor']),
      [null, 'reply-20', 'reply-40', 'reply-60'],
    );

    await controller.refresh();
    await controller.loadMore();
    _expectComplete(controller, PostReplyOrder.oldest);
    expect(stack.replyRequests, hasLength(8));
  });

  test('原楼层倒序首屏接受不可见目标，重载和作者筛选仍能读完四页', () async {
    final stack = _DiscussionStack();
    addTearDown(stack.close);
    final controller = stack.controller;
    await controller.load();
    await controller.setOrder(PostReplyOrder.newest);
    expect(controller.state.phase, PostDiscussionPhase.ready);
    expect(controller.state.replies[2].id, 'reply-74');
    expect(controller.state.replies[2].replyToAuthor, isNull);
    await controller.loadMore();
    _expectComplete(controller, PostReplyOrder.newest);

    await controller.load();
    await controller.loadMore();
    _expectComplete(controller, PostReplyOrder.newest);
    final previousRequests = stack.replyRequests.length;
    await controller.setAuthor('author');
    await controller.loadMore();
    _expectComplete(controller, PostReplyOrder.newest);
    final filteredRequests = stack.replyRequests.skip(previousRequests);
    expect(filteredRequests, hasLength(4));
    for (final request in filteredRequests) {
      expect(request.queryParameters['order'], 'NEWEST');
      expect(request.queryParameters['authorId'], 'author');
    }
  });

  test('主题内嵌预览保留目标不可见的回复，不额外请求目标资料', () async {
    final stack = _DiscussionStack();
    addTearDown(stack.close);
    final page = await stack.threadRepository.fetchFloors(
      subthreadId: 'subthread',
    );
    final reply = page.items.single.replies.single;
    expect(reply.id, 'reply-74');
    expect(reply.body.markdown, '回复 74');
    expect(reply.replyToUsername, isNull);
    expect(stack.adapter.requests, hasLength(1));
  });

  final invalidReplies = <String, Map<String, Object?>>{
    '目标 ID 错配': {
      ..._reply(1),
      'replyToPost': {..._target(), 'id': 'other-target'},
    },
    '目标作者错配': {
      ..._reply(1),
      'replyToPost': {..._target(), 'authorId': 'other-author'},
    },
    '无目标 ID 却返回目标详情': {..._reply(1), 'replyToPostId': null},
    '不可见目标不能掩盖父楼错配': {..._reply(74), 'parentPostId': 'other-floor'},
  };
  for (final sample in invalidReplies.entries) {
    for (final preview in [false, true]) {
      test('${preview ? '主题预览' : '独立讨论'}继续拒绝${sample.key}', () async {
        final stack = _DiscussionStack(replyOverride: sample.value);
        addTearDown(stack.close);
        await expectLater(
          preview
              ? stack.threadRepository.fetchFloors(subthreadId: 'subthread')
              : stack.repository.fetchReplies(rootPostId: 'floor'),
          throwsA(isA<ApiFailure>()),
        );
      });
    }
  }
}

void _expectComplete(
  PostDiscussionController controller,
  PostReplyOrder order,
) {
  final state = controller.state;
  expect(state.phase, PostDiscussionPhase.ready);
  expect(state.transientFailure, isNull);
  expect(state.failure, isNull);
  expect(state.hasMore, isFalse);
  expect(state.cursor, isNull);
  final expectedIds = List.generate(
    _replyCount,
    (index) => 'reply-${index + 1}',
  );
  expect(
    state.replies.map((reply) => reply.id),
    order == PostReplyOrder.oldest ? expectedIds : expectedIds.reversed,
  );
  final orphan = state.replies.singleWhere((reply) => reply.id == 'reply-74');
  expect(orphan.content, '回复 74');
  expect(orphan.replyToPostId, 'unavailable-target');
  expect(orphan.replyToAuthor, isNull);
}

class _DiscussionStack {
  _DiscussionStack({Map<String, Object?>? replyOverride}) {
    adapter = ScriptedHttpClientAdapter((request) async {
      if (request.path == '/api/v1/posts/floor') {
        return ScriptedHttpResponse.json({
          'code': 0,
          'message': 'ok',
          'data': {
            ..._root(),
            'thread': {'id': 'thread', 'title': '测试主题'},
            'subthread': {'id': 'subthread', 'title': '主线'},
            'parentPost': null,
          },
        });
      }
      if (request.path == '/api/v1/subthreads/subthread/posts') {
        return ScriptedHttpResponse.json(
          _page([
            {
              ..._root(),
              'replies': [replyOverride ?? _reply(74)],
            },
          ]),
        );
      }
      if (request.path != '/api/v1/posts/floor/replies') {
        throw StateError('意外请求：${request.path}');
      }
      if (replyOverride != null) {
        return ScriptedHttpResponse.json(_page([replyOverride]));
      }
      expect(request.queryParameters['limit'], 20);
      final numbers = List.generate(_replyCount, (index) => index + 1);
      final ordered = request.queryParameters['order'] == 'NEWEST'
          ? numbers.reversed.toList()
          : numbers;
      final cursor = request.queryParameters['cursor'];
      final start = cursor == null
          ? 0
          : ordered.indexWhere((number) => 'reply-$number' == cursor) + 1;
      if (cursor != null && start == 0) throw StateError('意外 cursor：$cursor');
      final current = ordered.skip(start).take(20).toList();
      return ScriptedHttpResponse.json(
        _page(
          current.map(_reply).toList(),
          cursor: 'reply-${current.last}',
          hasMore: start + current.length < _replyCount,
        ),
      );
    });
    dio = Dio(BaseOptions(baseUrl: 'https://example.invalid/api/v1'))
      ..httpClientAdapter = adapter;
    final api = WenyouApi(dio: dio, interceptors: []);
    repository = ApiPostRepository(api.getPostsApi());
    threadRepository = ApiThreadDetailRepository(
      api.getThreadsApi(),
      api.getPostsApi(),
    );
    controller = PostDiscussionController(repository, (
      rootPostId: 'floor',
      focusedReplyId: null,
    ), autoStart: false);
  }

  late final Dio dio;
  late final ScriptedHttpClientAdapter adapter;
  late final ApiPostRepository repository;
  late final ApiThreadDetailRepository threadRepository;
  late final PostDiscussionController controller;

  List<RequestOptions> get replyRequests => adapter.requests
      .where((request) => request.path == '/api/v1/posts/floor/replies')
      .toList();

  void close() {
    controller.dispose();
    dio.close();
  }
}

Map<String, Object?> _page(
  List<Map<String, Object?>> items, {
  String? cursor,
  bool hasMore = false,
}) => {
  'code': 0,
  'message': 'ok',
  'data': items,
  'meta': {'cursor': cursor, 'hasMore': hasMore},
};

Map<String, Object?> _root() => {
  ..._reply(0),
  'id': 'floor',
  'floorNumber': 1,
  'parentPostId': null,
  'replyToPostId': null,
  'replyToPost': null,
  '_count': {'replies': _replyCount},
};

Map<String, Object?> _reply(int number) {
  final timestamp = DateTime.utc(2026, 9, 4, 8, number).toIso8601String();
  return {
    'id': 'reply-$number',
    'threadId': 'thread',
    'subthreadId': 'subthread',
    'authorId': 'author',
    'kind': 'FLOOR',
    'floorNumber': null,
    'pinnedAt': null,
    'parentPostId': 'floor',
    'replyToPostId': number == _unavailableReplyNumber
        ? 'unavailable-target'
        : 'floor',
    'replyToPost': number == _unavailableReplyNumber ? null : _target(),
    'clientRequestId': null,
    'content': '回复 $number',
    'version': 1,
    'createdAt': timestamp,
    'updatedAt': timestamp,
    'deletedAt': null,
    'diceRolls': <Object?>[],
    'author': _author(),
  };
}

Map<String, Object?> _target() => {
  'id': 'floor',
  'authorId': 'author',
  'author': _author(),
};

Map<String, Object?> _author() => {
  'id': 'author',
  'username': '测试作者',
  'avatar': null,
  'level': 1,
};
