import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notification_copy.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SetReadStatusDto((dto) => dto.isRead = true));
  });

  test('通知列表传递筛选与游标并映射结构化内容和目标', () async {
    final api = _MockNotificationsApi();
    when(
      () => api.notificationsFindAll(
        cursor: 'notification-cursor',
        type: 'reply,mention,follow,like',
      ),
    ).thenAnswer((_) async => _listResponse());

    final page = await ApiNotificationRepository(api).fetchPage(
      filter: NotificationFilters.byId('interaction'),
      cursor: 'notification-cursor',
    );

    expect(page.cursor, 'notification-next');
    expect(page.hasMore, isTrue);
    final item = page.items.single;
    expect(item.kind, NotificationKind.reply);
    expect(formatNotificationCopy(item).plainText, '骰子猫 回复了你：雾港见');
    expect(item.actor?.username, '骰子猫');
    expect(item.target.kind, NotificationTargetKind.post);
    expect(item.target.threadId, 'thread-1');
    expect(item.target.postId, 'post-7');
    expect(item.target.parentPostId, isNull);
    expect(item.target.canOpen, isTrue);
  });

  test('已删除目标和未知类型安全降级', () async {
    final api = _MockNotificationsApi();
    when(
      () => api.notificationsFindAll(cursor: null, type: null),
    ).thenAnswer((_) async => _listResponse(deleted: true, unknown: true));

    final item = (await ApiNotificationRepository(
      api,
    ).fetchPage()).items.single;

    expect(item.kind, NotificationKind.unknown);
    expect(item.target.deletedHint, '该内容已删除');
    expect(item.target.canOpen, isFalse);
  });

  test('未读数与三种写操作完整调用生成客户端', () async {
    final api = _MockNotificationsApi();
    when(
      () => api.notificationsUnreadCount(),
    ).thenAnswer((_) async => _unreadResponse(4));
    when(
      () => api.notificationsSetReadStatus(
        id: 'notification-1',
        setReadStatusDto: any(named: 'setReadStatusDto'),
      ),
    ).thenAnswer((_) async => _readResponse());
    when(
      () => api.notificationsRemove(id: 'notification-1'),
    ).thenAnswer((_) async => _removeResponse());
    when(
      () => api.notificationsMarkAllAsRead(),
    ).thenAnswer((_) async => _markAllResponse());
    final repository = ApiNotificationRepository(api);

    expect(await repository.fetchUnreadCount(), 4);
    await repository.setReadStatus('notification-1', isRead: true);
    await repository.remove('notification-1');
    await repository.markAllRead();

    final body =
        verify(
              () => api.notificationsSetReadStatus(
                id: 'notification-1',
                setReadStatusDto: captureAny(named: 'setReadStatusDto'),
              ),
            ).captured.single
            as SetReadStatusDto;
    expect(body.isRead, isTrue);
    verify(() => api.notificationsRemove(id: 'notification-1')).called(1);
    verify(() => api.notificationsMarkAllAsRead()).called(1);
  });

  test('写操作空响应不伪装成功', () async {
    final api = _MockNotificationsApi();
    when(() => api.notificationsRemove(id: 'notification-empty')).thenAnswer(
      (_) async => Response<NotificationsRemove200Response>(
        requestOptions: RequestOptions(path: '/api/v1/notifications/empty'),
      ),
    );

    await expectLater(
      ApiNotificationRepository(api).remove('notification-empty'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockNotificationsApi extends Mock implements NotificationsApi {}

Response<NotificationsFindAll200Response> _listResponse({
  bool deleted = false,
  bool unknown = false,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/notifications'),
    data: NotificationsFindAll200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = 'notification-next'
            ..hasMore = true,
        )
        ..data.add(
          NotificationResponseDto(
            (notification) => notification
              ..id = 'notification-1'
              ..userId = 'user-1'
              ..type = unknown
                  ? NotificationResponseDtoTypeEnum.unknownDefaultOpenApi
                  : NotificationResponseDtoTypeEnum.reply
              ..content = '旧文案'
              ..eventKey = 'reply:post-7:user-1'
              ..isRead = false
              ..createdAt = DateTime.utc(2026, 8, 10)
              ..threadId = 'thread-1'
              ..postId = 'post-7'
              ..fromUserId = 'actor-1'
              ..payload.update(
                (payload) => payload
                  ..schemaVersion =
                      NotificationPayloadResponseDtoSchemaVersionEnum.n1
                  ..action = 'reply'
                  ..actorName = '骰子猫'
                  ..preview = '雾港见',
              )
              ..target.update(
                (target) => target
                  ..kind = NotificationTargetResponseDtoKindEnum.post
                  ..state = NotificationTargetResponseDtoStateEnum.ACTIVE
                  ..threadId = 'thread-1'
                  ..postId = 'post-7',
              )
              ..post.update(
                (post) => post
                  ..id = 'post-7'
                  ..floorNumber = 7
                  ..deletedAt = deleted ? DateTime.utc(2026, 8, 11) : null,
              )
              ..thread.update(
                (thread) => thread
                  ..id = 'thread-1'
                  ..title = '雾港来信',
              )
              ..fromUser.update(
                (user) => user
                  ..id = 'actor-1'
                  ..username = '骰子猫'
                  ..level = 4,
              ),
          ),
        ),
    ),
  );
}

Response<NotificationsUnreadCount200Response> _unreadResponse(int count) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/notifications/unread'),
    data: NotificationsUnreadCount200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.unreadCount = count),
    ),
  );
}

Response<NotificationsSetReadStatus200Response> _readResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/notifications/notification-1',
    ),
    data: NotificationsSetReadStatus200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已读'),
    ),
  );
}

Response<NotificationsRemove200Response> _removeResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/notifications/notification-1',
    ),
    data: NotificationsRemove200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已删除'),
    ),
  );
}

Response<NotificationsMarkAllAsRead200Response> _markAllResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/notifications/read-all'),
    data: NotificationsMarkAllAsRead200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '全部已读'),
    ),
  );
}
