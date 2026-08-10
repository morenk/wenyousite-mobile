import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum NotificationFilter {
  all(null, '全部'),
  replies('reply,mention', '回复与提及'),
  updates('new_post,thread_created', '主题更新'),
  social('follow,like', '关注与点赞'),
  rewards('tip,level_up', '温油与等级'),
  system('system', '系统');

  const NotificationFilter(this.wireValue, this.label);

  final String? wireValue;
  final String label;
}

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
    this.momentId,
    this.momentCommentId,
    this.userId,
    this.deletedHint,
  });

  final NotificationTargetKind kind;
  final String? threadId;
  final String? postId;
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

  String get displayText {
    final structured = _structuredText;
    if (structured != null) return structured;
    final sanitized = sanitizeNotificationText(content, payload?.preview);
    return sanitized.isEmpty ? '（图片内容）' : sanitized;
  }

  String? get _structuredText {
    final data = payload;
    final actorName = data?.actorName?.trim() ?? '';
    final action = data?.action;
    if (actorName.isEmpty || data == null) return null;
    final subthreadTitle = data.subthreadTitle?.trim() ?? '';
    final actionText = switch (action) {
      'reply' => '回复了你',
      'mention' => subthreadTitle.isEmpty ? '提到了你' : '在「$subthreadTitle」提到了你',
      'new_post' =>
        subthreadTitle.isEmpty ? '发布了新楼层' : '创建了新子贴「$subthreadTitle」',
      'moment_reply' => '回复了你在动态中的评论',
      'moment_comment' => '评论了你的动态',
      _ => null,
    };
    if (actionText == null) return null;
    final preview = sanitizeNotificationText(data.preview ?? '');
    return preview.isEmpty
        ? '$actorName $actionText'
        : '$actorName $actionText：$preview';
  }
}

String sanitizeNotificationText(String raw, [String? payloadPreview]) {
  var value = raw
      .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), '')
      .replaceAllMapped(
        RegExp(r'\\([!-/:-@\[-`{-~])'),
        (match) => match.group(1)!,
      )
      .replaceAll(RegExp(r'\\\r?\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  if (payloadPreview?.trim() == '1.00') {
    value = value.replaceFirst(RegExp(r'1\.00\s*$'), '').trimRight();
  }
  return value;
}

enum NotificationListPhase { loading, ready, failed }

enum NotificationPendingAction { markRead, remove, markAllRead }

class NotificationListState {
  const NotificationListState({
    required this.phase,
    this.filter = NotificationFilter.all,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
    this.pendingId,
    this.pendingAction,
    this.actionFailure,
  });

  const NotificationListState.loading({this.filter = NotificationFilter.all})
    : phase = NotificationListPhase.loading,
      items = const [],
      cursor = null,
      hasMore = false,
      isLoadingMore = false,
      failure = null,
      loadMoreFailure = null,
      pendingId = null,
      pendingAction = null,
      actionFailure = null;

  final NotificationListPhase phase;
  final NotificationFilter filter;
  final List<NotificationListItem> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final ApiFailure? failure;
  final ApiFailure? loadMoreFailure;
  final String? pendingId;
  final NotificationPendingAction? pendingAction;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingAction != null;
  bool get isBusy => isLoadingMore || isMutating;
  bool get hasUnread => items.any((item) => !item.isRead);
}

class NotificationUnreadState {
  const NotificationUnreadState({
    this.count = 0,
    this.isLoading = false,
    this.failure,
  });

  final int count;
  final bool isLoading;
  final ApiFailure? failure;
}
