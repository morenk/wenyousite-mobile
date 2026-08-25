import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

String? notificationTargetLocation(NotificationTarget target) {
  if (!target.canOpen) return null;
  return switch (target.kind) {
    NotificationTargetKind.post => _postLocation(target),
    NotificationTargetKind.thread => AppRouteLocations.thread(target.threadId!),
    NotificationTargetKind.moment => AppRouteLocations.moment(
      target.momentId!,
      commentId: target.momentCommentId,
    ),
    NotificationTargetKind.user => AppRouteLocations.user(target.userId!),
    NotificationTargetKind.none || NotificationTargetKind.unknown => null,
  };
}

String _postLocation(NotificationTarget target) {
  final parentPostId = target.parentPostId;
  if (parentPostId != null && parentPostId.isNotEmpty) {
    return AppRouteLocations.postReplies(
      target.threadId!,
      parentPostId,
      postId: target.postId!,
    );
  }
  return AppRouteLocations.thread(target.threadId!, postId: target.postId!);
}
