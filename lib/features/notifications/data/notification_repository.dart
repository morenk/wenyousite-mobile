import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

abstract interface class NotificationRepository {
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilter.all,
    String? cursor,
  });

  Future<int> fetchUnreadCount();

  Future<void> setReadStatus(String id, {required bool isRead});

  Future<void> remove(String id);

  Future<void> markAllRead();
}

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._api);

  final NotificationsApi _api;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilter.all,
    String? cursor,
  }) async {
    try {
      final envelope = (await _api.notificationsFindAll(
        cursor: cursor,
        type: filter.wireValue,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '通知列表响应为空，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapItem).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<int> fetchUnreadCount() async {
    try {
      final data = (await _api.notificationsUnreadCount()).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '未读通知数响应为空，请稍后重试。');
      }
      return data.unreadCount.toInt();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> setReadStatus(String id, {required bool isRead}) async {
    try {
      final data = (await _api.notificationsSetReadStatus(
        id: id,
        setReadStatusDto: SetReadStatusDto((dto) => dto.isRead = isRead),
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '通知状态响应不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(String id) async {
    try {
      final data = (await _api.notificationsRemove(id: id)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '删除通知响应不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      final data = (await _api.notificationsMarkAllAsRead()).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '全部已读响应不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  NotificationListItem _mapItem(NotificationResponseDto dto) {
    final actor = dto.fromUser;
    final payload = dto.payload;
    final target = dto.target;
    return NotificationListItem(
      id: dto.id,
      kind: switch (dto.type) {
        NotificationResponseDtoTypeEnum.reply => NotificationKind.reply,
        NotificationResponseDtoTypeEnum.mention => NotificationKind.mention,
        NotificationResponseDtoTypeEnum.newFloor ||
        NotificationResponseDtoTypeEnum.newPost => NotificationKind.newPost,
        NotificationResponseDtoTypeEnum.subthreadCreated ||
        NotificationResponseDtoTypeEnum.threadCreated =>
          NotificationKind.threadCreated,
        NotificationResponseDtoTypeEnum.follow => NotificationKind.follow,
        NotificationResponseDtoTypeEnum.like => NotificationKind.like,
        NotificationResponseDtoTypeEnum.tip => NotificationKind.tip,
        NotificationResponseDtoTypeEnum.levelUp => NotificationKind.levelUp,
        NotificationResponseDtoTypeEnum.system => NotificationKind.system,
        _ => NotificationKind.unknown,
      },
      content: dto.content ?? '',
      payload: payload == null
          ? null
          : NotificationPayload(
              action: payload.action,
              actorName: payload.actorName,
              preview: payload.preview,
              subthreadTitle: payload.subthreadTitle,
              threadTitle: payload.threadTitle,
              momentTitle: payload.momentTitle,
              totalCount: payload.totalCount?.toInt(),
            ),
      target: NotificationTarget(
        kind: switch (target.kind) {
          NotificationTargetResponseDtoKindEnum.post =>
            NotificationTargetKind.post,
          NotificationTargetResponseDtoKindEnum.thread =>
            NotificationTargetKind.thread,
          NotificationTargetResponseDtoKindEnum.moment =>
            NotificationTargetKind.moment,
          NotificationTargetResponseDtoKindEnum.user =>
            NotificationTargetKind.user,
          NotificationTargetResponseDtoKindEnum.none =>
            NotificationTargetKind.none,
          _ => NotificationTargetKind.unknown,
        },
        threadId: target.threadId,
        postId: target.postId,
        momentId: target.momentId,
        momentCommentId: target.momentCommentId,
        userId: target.userId,
        deletedHint: _deletedHint(dto),
      ),
      actor: actor == null
          ? null
          : NotificationActor(
              id: actor.id,
              username: actor.username,
              avatarUrl: actor.avatar,
              level: actor.level.toInt(),
              isDeleted: actor.deletedAt != null,
            ),
      isRead: dto.isRead,
      createdAt: dto.createdAt,
    );
  }

  String? _deletedHint(NotificationResponseDto dto) {
    final kind = dto.target.kind;
    if ((kind == NotificationTargetResponseDtoKindEnum.post ||
            kind == NotificationTargetResponseDtoKindEnum.thread) &&
        (dto.thread?.deletedAt != null || dto.post?.deletedAt != null)) {
      return '该内容已删除';
    }
    if (kind == NotificationTargetResponseDtoKindEnum.moment &&
        (dto.moment?.deletedAt != null ||
            dto.momentComment?.deletedAt != null)) {
      return '该动态或评论已删除';
    }
    if (kind == NotificationTargetResponseDtoKindEnum.user &&
        dto.fromUser?.deletedAt != null) {
      return '该用户已注销';
    }
    return null;
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return ApiNotificationRepository(
    ref.watch(wenyouApiProvider).getNotificationsApi(),
  );
});
