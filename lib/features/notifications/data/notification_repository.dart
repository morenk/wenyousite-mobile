import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/media_display_mapper.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

export 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart'
    show NotificationRepository, notificationRepositoryProvider;

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
        throw const ApiFailure(userMessage: '通知加载失败，请稍后重试。');
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
        throw const ApiFailure(userMessage: '未读通知数加载失败，请稍后重试。');
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
        throw const ApiFailure(userMessage: '通知状态更新失败，请重新加载。');
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
        throw const ApiFailure(userMessage: '删除失败，请重新加载。');
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
        throw const ApiFailure(userMessage: '全部已读失败，请重新加载。');
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
      recipientUserId: dto.userId,
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
              replyTargetUserId: payload.replyTargetUserId,
              replyTargetName: payload.replyTargetName,
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
        state: _targetState(target.state),
        threadId: target.threadId,
        postId: target.postId,
        parentPostId: dto.post?.parentPostId,
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
              avatarUrl: mapAvatarDisplayUrl(actor.avatar, actor.avatarDisplay),
              level: actor.level.toInt(),
              isDeleted: actor.deletedAt != null,
            ),
      isRead:
          dto.isRead ||
          target.state ==
              NotificationTargetResponseDtoStateEnum.CONTENT_DELETED ||
          target.state ==
              NotificationTargetResponseDtoStateEnum.USER_DEACTIVATED,
      createdAt: dto.createdAt,
    );
  }

  String? _deletedHint(NotificationResponseDto dto) {
    final state = dto.target.state;
    if (state == NotificationTargetResponseDtoStateEnum.USER_DEACTIVATED) {
      return '该用户已注销';
    }
    if (state != NotificationTargetResponseDtoStateEnum.CONTENT_DELETED) {
      return null;
    }
    if (dto.momentComment != null || dto.momentCommentId != null) {
      return '该评论已删除';
    }
    if (dto.moment != null || dto.momentId != null) return '该动态已删除';
    if (dto.post != null ||
        dto.postId != null ||
        dto.thread != null ||
        dto.threadId != null) {
      return '该内容已删除';
    }
    return '该内容已删除或不可访问';
  }

  NotificationTargetState _targetState(
    NotificationTargetResponseDtoStateEnum state,
  ) => switch (state) {
    NotificationTargetResponseDtoStateEnum.ACTIVE =>
      NotificationTargetState.active,
    NotificationTargetResponseDtoStateEnum.CONTENT_DELETED =>
      NotificationTargetState.contentDeleted,
    NotificationTargetResponseDtoStateEnum.USER_DEACTIVATED =>
      NotificationTargetState.userDeactivated,
    NotificationTargetResponseDtoStateEnum.NO_TARGET =>
      NotificationTargetState.noTarget,
    _ => NotificationTargetState.unknown,
  };
}

final apiNotificationRepositoryProvider = Provider<NotificationRepository>((
  ref,
) {
  return ApiNotificationRepository(
    ref.watch(wenyouApiProvider).getNotificationsApi(),
  );
});
