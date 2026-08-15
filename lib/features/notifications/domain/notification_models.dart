enum NotificationKind {
  reply,
  mention,
  newPost,
  threadCreated,
  follow,
  like,
  tip,
  levelUp,
  system,
  unknown,
}

enum NotificationTargetKind { post, thread, moment, user, none, unknown }

class NotificationActor {
  const NotificationActor({
    required this.id,
    required this.username,
    required this.level,
    this.avatarUrl,
    this.isDeleted = false,
  });

  final String id;
  final String username;
  final int level;
  final String? avatarUrl;
  final bool isDeleted;
}

class NotificationPayload {
  const NotificationPayload({
    this.action,
    this.actorName,
    this.preview,
    this.subthreadTitle,
    this.threadTitle,
    this.momentTitle,
    this.totalCount,
  });

  final String? action;
  final String? actorName;
  final String? preview;
  final String? subthreadTitle;
  final String? threadTitle;
  final String? momentTitle;
  final int? totalCount;
}

class NotificationTarget {
  const NotificationTarget({
    required this.kind,
    this.threadId,
    this.postId,
    this.parentPostId,
    this.momentId,
    this.momentCommentId,
    this.userId,
    this.deletedHint,
  });

  final NotificationTargetKind kind;
  final String? threadId;
  final String? postId;
  final String? parentPostId;
  final String? momentId;
  final String? momentCommentId;
  final String? userId;
  final String? deletedHint;

  bool get canOpen =>
      deletedHint == null &&
      switch (kind) {
        NotificationTargetKind.post => threadId != null && postId != null,
        NotificationTargetKind.thread => threadId != null,
        NotificationTargetKind.user => userId != null,
        NotificationTargetKind.moment => momentId != null,
        _ => false,
      };
}

class NotificationListItem {
  const NotificationListItem({
    required this.id,
    required this.kind,
    required this.content,
    required this.target,
    required this.isRead,
    required this.createdAt,
    this.payload,
    this.actor,
  });

  final String id;
  final NotificationKind kind;
  final String content;
  final NotificationPayload? payload;
  final NotificationTarget target;
  final NotificationActor? actor;
  final bool isRead;
  final DateTime createdAt;

  NotificationListItem copyWith({bool? isRead}) {
    return NotificationListItem(
      id: id,
      kind: kind,
      content: content,
      payload: payload,
      target: target,
      actor: actor,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
