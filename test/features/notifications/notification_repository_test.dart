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

  test('异步升级通知保留服务端内容，不从奖励或旧等级合成升级提示', () async {
    final api = _MockNotificationsApi();
    when(() => api.notificationsFindAll(cursor: null, type: null)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/v1/notifications'),
        data: NotificationsFindAll200Response(
          (b) => b
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update((m) => m..hasMore = false)
            ..data.add(
              NotificationResponseDto(
                (n) => n
                  ..id = 'level-notice-1'
                  ..userId = 'user-1'
                  ..type = NotificationResponseDtoTypeEnum.levelUp
                  ..content = '恭喜你升级到 Lv.3'
                  ..eventKey = 'level-up:user-1:3:50'
                  ..isRead = false
                  ..createdAt = DateTime.utc(2026, 9, 5)
                  ..payload.update(
                    (p) => p
                      ..schemaVersion =
                          NotificationPayloadResponseDtoSchemaVersionEnum.n1
                      ..action = 'level_up'
                      ..previousLevel = 2
                      ..level = 3
                      ..experience = 50,
                  )
                  ..target.update(
                    (t) => t
                      ..kind = NotificationTargetResponseDtoKindEnum.none
                      ..state =
                          NotificationTargetResponseDtoStateEnum.NO_TARGET,
                  ),
              ),
            ),
        ),
      ),
    );
    final item = (await ApiNotificationRepository(
      api,
    ).fetchPage()).items.single;
    expect(item.kind, NotificationKind.levelUp);
    expect(item.actor, isNull);
    expect(item.target.canOpen, isFalse);
    expect(formatNotificationCopy(item).plainText, '恭喜你升级到 Lv.3');
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
    expect(item.recipientUserId, 'user-1');
    expect(item.payload?.replyTargetUserId, 'target-user');
    expect(item.payload?.replyTargetName, '阿忠');
    expect(formatNotificationCopy(item).plainText, '骰子猫 回复了阿忠：雾港见');
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
    expect(item.target.state, NotificationTargetState.contentDeleted);
    expect(item.target.deletedHint, '该内容已删除');
    expect(item.target.canOpen, isFalse);
    expect(item.isRead, isTrue);
  });

  test('目标状态区分已删评论、动态、未知内容、注销用户与普通无目标通知', () async {
    final cases =
        <
          ({
            NotificationTargetResponseDtoStateEnum state,
            String? momentId,
            String? momentCommentId,
            String? expectedHint,
            NotificationTargetState expectedState,
          })
        >[
          (
            state: NotificationTargetResponseDtoStateEnum.CONTENT_DELETED,
            momentId: 'moment-1',
            momentCommentId: 'comment-1',
            expectedHint: '该评论已删除',
            expectedState: NotificationTargetState.contentDeleted,
          ),
          (
            state: NotificationTargetResponseDtoStateEnum.CONTENT_DELETED,
            momentId: 'moment-1',
            momentCommentId: null,
            expectedHint: '该动态已删除',
            expectedState: NotificationTargetState.contentDeleted,
          ),
          (
            state: NotificationTargetResponseDtoStateEnum.CONTENT_DELETED,
            momentId: null,
            momentCommentId: null,
            expectedHint: '该内容已删除或不可访问',
            expectedState: NotificationTargetState.contentDeleted,
          ),
          (
            state: NotificationTargetResponseDtoStateEnum.USER_DEACTIVATED,
            momentId: null,
            momentCommentId: null,
            expectedHint: '该用户已注销',
            expectedState: NotificationTargetState.userDeactivated,
          ),
          (
            state: NotificationTargetResponseDtoStateEnum.NO_TARGET,
            momentId: null,
            momentCommentId: null,
            expectedHint: null,
            expectedState: NotificationTargetState.noTarget,
          ),
        ];

    for (final testCase in cases) {
      final api = _MockNotificationsApi();
      when(() => api.notificationsFindAll(cursor: null, type: null)).thenAnswer(
        (_) async => _targetStateResponse(
          testCase.state,
          momentId: testCase.momentId,
          momentCommentId: testCase.momentCommentId,
        ),
      );

      final item = (await ApiNotificationRepository(
        api,
      ).fetchPage()).items.single;
      expect(item.target.state, testCase.expectedState);
      expect(item.target.deletedHint, testCase.expectedHint);
      expect(item.target.canOpen, isFalse);
      expect(
        item.isRead,
        testCase.state != NotificationTargetResponseDtoStateEnum.NO_TARGET,
      );
    }
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
                  ..replyTargetUserId = 'target-user'
                  ..replyTargetName = '阿忠'
                  ..preview = '雾港见',
              )
              ..target.update(
                (target) => target
                  ..kind = deleted
                      ? NotificationTargetResponseDtoKindEnum.none
                      : NotificationTargetResponseDtoKindEnum.post
                  ..state = deleted
                      ? NotificationTargetResponseDtoStateEnum.CONTENT_DELETED
                      : NotificationTargetResponseDtoStateEnum.ACTIVE
                  ..threadId = deleted ? null : 'thread-1'
                  ..postId = deleted ? null : 'post-7',
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

Response<NotificationsFindAll200Response> _targetStateResponse(
  NotificationTargetResponseDtoStateEnum state, {
  String? momentId,
  String? momentCommentId,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/notifications'),
    data: NotificationsFindAll200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update((meta) => meta..hasMore = false)
        ..data.add(
          NotificationResponseDto(
            (notification) => notification
              ..id = 'state-notification'
              ..userId = 'user-1'
              ..type = NotificationResponseDtoTypeEnum.system
              ..content = '历史通知'
              ..eventKey = 'state-notification'
              ..isRead = false
              ..createdAt = DateTime.utc(2026, 9, 23)
              ..momentId = momentId
              ..momentCommentId = momentCommentId
              ..target.update(
                (target) => target
                  ..kind = NotificationTargetResponseDtoKindEnum.none
                  ..state = state,
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
