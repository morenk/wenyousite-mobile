import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

class NotificationCopy {
  const NotificationCopy({
    required this.actorName,
    required this.actionText,
    required this.preview,
    required this.fallbackText,
  });

  final String? actorName;
  final String? actionText;
  final String? preview;
  final String fallbackText;

  bool get isStructured => actorName != null && actionText != null;

  String get plainText {
    if (!isStructured) return fallbackText;
    final suffix = preview == null ? '' : '：$preview';
    return '$actorName $actionText$suffix';
  }
}

NotificationCopy formatNotificationCopy(NotificationListItem item) {
  final payload = item.payload;
  final actorName = (payload?.actorName ?? item.actor?.username)?.trim();
  final subthreadTitle = payload?.subthreadTitle?.trim() ?? '';
  final actionText = switch (payload?.action) {
    'reply' => '回复了你',
    'mention' => subthreadTitle.isEmpty ? '提到了你' : '在「$subthreadTitle」提到了你',
    'new_post' => subthreadTitle.isEmpty ? '发布了新楼层' : '创建了新子贴「$subthreadTitle」',
    'thread_created' => '创建了新主题',
    'follow' => '关注了你',
    'like' => '赞了你的内容',
    'tip' => '赠送了温油',
    'moment_reply' => '回复了你在动态中的评论',
    'moment_comment' => '评论了你的动态',
    _ => null,
  };
  final preview = sanitizeNotificationText(payload?.preview ?? '');
  final fallback = sanitizeNotificationText(item.content, payload?.preview);
  return NotificationCopy(
    actorName: actorName == null || actorName.isEmpty ? null : actorName,
    actionText: actionText,
    preview: preview.isEmpty ? null : preview,
    fallbackText: fallback.isEmpty ? '（图片内容）' : fallback,
  );
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
