import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';

import '../../support/foundation_test_fonts.dart';
import '../../support/scripted_http_client_adapter.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('路由经生产仓储、生成客户端和 Dio 展示主题正文与楼层', (tester) async {
    final adapter = ScriptedHttpClientAdapter((request) async {
      return switch (request.path) {
        '/api/v1/threads/thread-1' => ScriptedHttpResponse.json(
          _threadEnvelope(),
        ),
        '/api/v1/subthreads/subthread-1/posts' => ScriptedHttpResponse.json(
          _floorsEnvelope(),
        ),
        _ => ScriptedHttpResponse.json({
          'code': 40400,
          'message': 'unexpected ${request.path}',
        }, statusCode: 404),
      };
    });
    final dio = _dio(adapter);
    addTearDown(dio.close);

    await tester.pumpWidget(_stackApp(dio));
    await tester.pumpAndSettle();

    expect(find.text('真实网络栈主题'), findsOneWidget);
    expect(find.text('由生成客户端返回的正文'), findsOneWidget);
    expect(find.text('真实楼层内容'), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-retry')), findsNothing);
    expect(
      adapter.requests.map((request) => request.path),
      containsAllInOrder([
        '/api/v1/threads/thread-1',
        '/api/v1/subthreads/subthread-1/posts',
      ]),
    );
  });

  testWidgets('生成 DTO 的主题标识不符时整栈拒绝展示并允许重试', (tester) async {
    final adapter = ScriptedHttpClientAdapter((request) async {
      return ScriptedHttpResponse.json(
        _threadEnvelope(threadId: 'thread-from-another-request'),
      );
    });
    final dio = _dio(adapter);
    addTearDown(dio.close);

    await tester.pumpWidget(_stackApp(dio));
    await tester.pumpAndSettle();

    expect(find.text('真实网络栈主题'), findsNothing);
    expect(find.text('主题详情加载失败'), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-retry')), findsOneWidget);
    expect(adapter.requests, hasLength(1));
  });

  test('楼层筛选经生成客户端保留不透明游标和查询参数', () async {
    final adapter = ScriptedHttpClientAdapter((request) async {
      return ScriptedHttpResponse.json(_floorsEnvelope());
    });
    final dio = _dio(adapter);
    addTearDown(dio.close);
    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(container.dispose);
    final repository = container.read(apiThreadDetailRepositoryProvider);

    final page = await repository.fetchFloors(
      subthreadId: 'subthread-1',
      cursor: 'opaque+/=cursor',
      limit: 7,
      order: ThreadFloorOrder.newest,
      authorId: 'author-2',
    );

    expect(page.items.single.id, 'floor-1');
    final request = adapter.requests.single;
    expect(request.path, '/api/v1/subthreads/subthread-1/posts');
    expect(request.queryParameters, {
      'cursor': 'opaque+/=cursor',
      'limit': 7,
      'order': 'NEWEST',
      'authorId': 'author-2',
    });
  });

  test('楼中楼写入经生成客户端发送稳定幂等键与精确层级', () async {
    const clientRequestId = '123e4567-e89b-42d3-a456-426614174000';
    final adapter = ScriptedHttpClientAdapter((request) async {
      return ScriptedHttpResponse.json(
        _createdReplyEnvelope(clientRequestId: clientRequestId),
        statusCode: 201,
      );
    });
    final dio = _dio(adapter);
    addTearDown(dio.close);
    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(container.dispose);

    final created = await container
        .read(apiPostRepositoryProvider)
        .create(
          const PostCreateInput(
            subthreadId: 'subthread-1',
            content: '经真实生成客户端写入的回复',
            clientRequestId: clientRequestId,
            parentPostId: 'floor-1',
            replyToPostId: 'reply-target',
          ),
        );

    expect(created.id, 'reply-created');
    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/api/v1/subthreads/subthread-1/posts');
    expect(request.extra[ApiRequestExtraKeys.idempotentCreate], isTrue);
    expect(request.data, {
      'content': '经真实生成客户端写入的回复',
      'parentPostId': 'floor-1',
      'replyToPostId': 'reply-target',
      'clientRequestId': clientRequestId,
    });
  });
}

Dio _dio(HttpClientAdapter adapter) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://thread-stack.test',
      responseType: ResponseType.json,
    ),
  )..httpClientAdapter = adapter;
}

Widget _stackApp(Dio dio) {
  final router = GoRouter(
    initialLocation: '/threads/thread-1',
    routes: [
      GoRoute(
        path: '/threads/:threadId',
        builder: (context, state) =>
            ThreadDetailPage(threadId: state.pathParameters['threadId']!),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      dioProvider.overrideWithValue(dio),
      threadDetailRepositoryProvider.overrideWith(
        (ref) => ref.watch(apiThreadDetailRepositoryProvider),
      ),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        const _EmptyAuthorDirectory(),
      ),
      stickersEnabledProvider.overrideWithValue(false),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

class _EmptyAuthorDirectory implements PostDiscussionAuthorDirectory {
  const _EmptyAuthorDirectory();

  @override
  Future<List<PostDiscussionAuthor>> fetchAuthors(String threadId) async =>
      const [];
}

Map<String, Object?> _threadEnvelope({String threadId = 'thread-1'}) {
  const createdAt = '2026-08-20T08:00:00.000Z';
  return {
    'code': 0,
    'message': 'ok',
    'data': {
      'id': threadId,
      'title': '真实网络栈主题',
      'ownerId': 'owner-1',
      'category': 'RPG',
      'status': 'RECRUITING',
      'visibility': 'PUBLIC',
      'published': true,
      'publishedAt': createdAt,
      'pinned': false,
      'pinnedAt': null,
      'viewCount': 11,
      'version': 1,
      'likeCount': 2,
      'tipTotal': '0',
      'defaultSubthreadId': 'subthread-1',
      'createdAt': createdAt,
      'updatedAt': createdAt,
      'deletedAt': null,
      'owner': {
        'id': 'owner-1',
        'username': '网络栈作者',
        'avatar': null,
        'level': 3,
      },
      'subthreads': [
        {
          'id': 'subthread-1',
          'threadId': threadId,
          'title': '主线',
          'sortOrder': 1,
          'postingPolicy': 'PARTICIPANTS',
          'postingCapability': {'canPost': true, 'denialReason': null},
          'version': 1,
          'lastPostAt': createdAt,
          'deletedAt': null,
          'createdAt': createdAt,
          'bodyPost': {
            'id': 'body-1',
            'content': '由生成客户端返回的正文',
            'version': 1,
            'diceRolls': <Object?>[],
          },
          '_count': {'posts': 1},
        },
      ],
      'topicTags': <Object?>[],
      '_count': {'members': 1, 'posts': 1, 'players': 0},
      'isBookmarked': false,
      'bookmarkId': null,
      'bookmarkFolderId': null,
      'isLiked': false,
      'currentMembership': null,
      'capabilities': null,
    },
  };
}

Map<String, Object?> _floorsEnvelope() {
  const createdAt = '2026-08-20T08:05:00.000Z';
  return {
    'code': 0,
    'message': 'ok',
    'meta': {'cursor': null, 'hasMore': false},
    'data': [
      {
        'id': 'floor-1',
        'threadId': 'thread-1',
        'subthreadId': 'subthread-1',
        'authorId': 'author-2',
        'kind': 'FLOOR',
        'floorNumber': 1,
        'parentPostId': null,
        'replyToPostId': null,
        'clientRequestId': '123e4567-e89b-42d3-a456-426614174002',
        'content': '真实楼层内容',
        'diceRolls': <Object?>[],
        'version': 1,
        'createdAt': createdAt,
        'updatedAt': createdAt,
        'deletedAt': null,
        'author': {
          'id': 'author-2',
          'username': '网络栈玩家',
          'avatar': null,
          'level': 2,
        },
        '_count': {'replies': 0},
        'replies': <Object?>[],
      },
    ],
  };
}

Map<String, Object?> _createdReplyEnvelope({required String clientRequestId}) {
  const createdAt = '2026-08-20T08:10:00.000Z';
  return {
    'code': 0,
    'message': 'ok',
    'data': {
      'id': 'reply-created',
      'threadId': 'thread-1',
      'subthreadId': 'subthread-1',
      'authorId': 'author-2',
      'kind': 'FLOOR',
      'floorNumber': null,
      'parentPostId': 'floor-1',
      'replyToPostId': 'reply-target',
      'clientRequestId': clientRequestId,
      'content': '经真实生成客户端写入的回复',
      'diceRolls': <Object?>[],
      'version': 1,
      'createdAt': createdAt,
      'updatedAt': createdAt,
      'deletedAt': null,
      'author': {
        'id': 'author-2',
        'username': '网络栈玩家',
        'avatar': null,
        'level': 2,
      },
    },
  };
}
