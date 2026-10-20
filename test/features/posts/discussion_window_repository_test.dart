import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';

class _Posts extends Mock implements PostsApi {}

class _Threads extends Mock implements ThreadsApi {}

void main() {
  test('回复窗口透传固定编号、顺序与筛选，并映射真实双向游标', () async {
    final api = _Posts();
    when(
      () => api.postsFindReplyWindow(
        id: 'root',
        number: 5000,
        limit: 20,
        order: 'NEWEST',
        authorId: 'author',
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        data: standardSerializers.deserializeWith(
          PostsFindReplyWindow200Response.serializer,
          _envelope(_window(replies: true)),
        ),
      ),
    );
    final page = await ApiPostRepository(api).fetchReplyWindow(
      rootPostId: 'root',
      number: 5000,
      order: PostReplyOrder.newest,
      authorId: 'author',
    );
    expect(page.items.single.replyNumber, 5000);
    expect(page.targetId, 'target');
    expect(page.targetNumber, 5000);
    expect(page.beforeCursor, 'before');
    expect(page.afterCursor, 'after');
    expect(page.maxNumber, 10000);
    expect(page.total, 40);
    verify(
      () => api.postsFindReplyWindow(
        id: 'root',
        number: 5000,
        limit: 20,
        order: 'NEWEST',
        authorId: 'author',
      ),
    ).called(1);
  });

  test('主楼窗口保留首屏置顶及自然编号，不在消费者重新排序', () async {
    final api = _Posts();
    final data = _window(replies: false)..['target'] = null;
    data['pinnedItems'] = [_item(replies: false)];
    when(
      () => api.postsFindFloorWindow(
        subthreadId: 'scope',
        limit: 20,
        order: 'OLDEST',
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        data: standardSerializers.deserializeWith(
          PostsFindFloorWindow200Response.serializer,
          _envelope(data),
        ),
      ),
    );
    final page = await ApiThreadDetailRepository(
      _Threads(),
      api,
    ).fetchFloorWindow(subthreadId: 'scope');
    expect(page.items.single.floorNumber, 5000);
    expect(page.pinnedItems.single.id, page.items.single.id);
    expect(page.targetId, isNull);
  });

  for (final replies in [false, true]) {
    for (final fault in [
      'fraction',
      'duplicate',
      'target',
      'cursor',
      'scope',
      'pins',
    ]) {
      test('${replies ? '回复' : '主楼'}窗口拒绝 $fault 错误形状', () async {
        final api = _Posts();
        final data = _window(replies: replies);
        final item = _item(replies: replies);
        switch (fault) {
          case 'fraction':
            item[replies ? 'replyNumber' : 'floorNumber'] = 5000.5;
          case 'scope':
            item[replies ? 'parentPostId' : 'subthreadId'] = 'wrong';
          case 'target':
            data['target'] = {'id': 'wrong', 'number': 5000};
          case 'cursor':
            data['hasBefore'] = false;
          case 'pins':
            data['pinnedItems'] = [_item(replies: false)];
          case 'duplicate':
            break;
        }
        data['items'] = [item, if (fault == 'duplicate') item];
        if (replies) {
          when(
            () => api.postsFindReplyWindow(
              id: 'root',
              number: 5000,
              limit: 20,
              order: 'OLDEST',
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(),
              data: standardSerializers.deserializeWith(
                PostsFindReplyWindow200Response.serializer,
                _envelope(data),
              ),
            ),
          );
          await expectLater(
            ApiPostRepository(
              api,
            ).fetchReplyWindow(rootPostId: 'root', number: 5000),
            throwsA(isA<ApiFailure>()),
          );
        } else {
          when(
            () => api.postsFindFloorWindow(
              subthreadId: 'scope',
              number: 5000,
              limit: 20,
              order: 'OLDEST',
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(),
              data: standardSerializers.deserializeWith(
                PostsFindFloorWindow200Response.serializer,
                _envelope(data),
              ),
            ),
          );
          await expectLater(
            ApiThreadDetailRepository(
              _Threads(),
              api,
            ).fetchFloorWindow(subthreadId: 'scope', number: 5000),
            throwsA(isA<ApiFailure>()),
          );
        }
      });
    }
  }
}

Map<String, Object?> _envelope(Map<String, Object?> data) => {
  'code': 0,
  'message': 'ok',
  'data': data,
};
Map<String, Object?> _window({required bool replies}) => {
  'items': [_item(replies: replies)],
  'pinnedItems': [],
  'total': 40,
  'maxNumber': 10000,
  'target': {'id': 'target', 'number': 5000},
  'beforeCursor': 'before',
  'afterCursor': 'after',
  'hasBefore': true,
  'hasAfter': true,
};
Map<String, Object?> _item({required bool replies}) => {
  'id': 'target',
  'threadId': 'thread',
  'subthreadId': 'scope',
  'authorId': 'author',
  'kind': 'FLOOR',
  'floorNumber': replies ? null : 5000,
  'replyNumber': replies ? 5000 : null,
  'parentPostId': replies ? 'root' : null,
  'replyToPostId': replies ? 'root' : null,
  'content': '正文',
  'diceRolls': [],
  'version': 1,
  'createdAt': '2026-10-01T00:00:00.000Z',
  'updatedAt': '2026-10-01T00:00:00.000Z',
  'author': {'id': 'author', 'username': '作者', 'level': 1},
  if (!replies) '_count': {'replies': 0},
  if (!replies) 'replies': [],
};
