import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notification_copy.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notification_navigation.dart';

void main() {
  test('通知分类直接遵循 Foundation 分组契约', () {
    expect(NotificationFilters.values.map((filter) => filter.label), [
      '全部',
      '互动',
      '订阅',
      '系统',
    ]);
    expect(
      NotificationFilters.byId('interaction').wireValue,
      'reply,mention,follow,like',
    );
    expect(
      NotificationFilters.byId('subscription').wireValue,
      'new_post,thread_created',
    );
    expect(NotificationFilters.byId('unknown'), NotificationFilters.all);
  });

  test('回复通知按真实回复对象区分本人、旁观者与旧载荷', () {
    final directRecipient = _item(
      recipientUserId: 'target-user',
      payload: const NotificationPayload(
        actorName: '骰子猫',
        action: 'reply',
        replyTargetUserId: 'target-user',
        replyTargetName: '阿忠',
        preview: '![图片](https://example.test/image.png)雾港见',
      ),
    );
    expect(formatNotificationCopy(directRecipient).plainText, '骰子猫 回复了你：雾港见');

    final subscriber = _item(
      recipientUserId: 'subscriber-user',
      payload: const NotificationPayload(
        actorName: '骰子猫',
        action: 'reply',
        replyTargetUserId: 'target-user',
        replyTargetName: '阿忠',
        preview: '雾港见',
      ),
    );
    expect(formatNotificationCopy(subscriber).plainText, '骰子猫 回复了阿忠：雾港见');

    final legacy = _item(
      payload: const NotificationPayload(
        actorName: '骰子猫',
        action: 'reply',
        preview: '雾港见',
      ),
    );
    expect(formatNotificationCopy(legacy).plainText, '骰子猫 回复了：雾港见');
  });

  test('旧正文由 presentation formatter 安全生成', () {
    final fallback = _item(content: r'旧文案\!');
    expect(formatNotificationCopy(fallback).plainText, '旧文案!');
  });

  test('主楼层与楼中楼回复生成不同的稳定目标路由', () {
    expect(
      notificationTargetLocation(
        const NotificationTarget(
          kind: NotificationTargetKind.post,
          threadId: 'thread-1',
          postId: 'floor-7',
        ),
      ),
      '/threads/thread-1?post=floor-7',
    );
    expect(
      notificationTargetLocation(
        const NotificationTarget(
          kind: NotificationTargetKind.post,
          threadId: 'thread-1',
          postId: 'reply-9',
          parentPostId: 'floor-7',
        ),
      ),
      '/threads/thread-1/posts/floor-7/replies?post=reply-9',
    );
    expect(
      notificationTargetLocation(
        const NotificationTarget(
          kind: NotificationTargetKind.thread,
          threadId: 'thread-1',
          deletedHint: '该内容已删除',
        ),
      ),
      isNull,
    );
  });

  test('动态评论通知保留评论坐标，普通动态通知不添加查询参数', () {
    expect(
      notificationTargetLocation(
        const NotificationTarget(
          kind: NotificationTargetKind.moment,
          momentId: 'moment-1',
          momentCommentId: 'comment-7',
        ),
      ),
      '/moments/moment-1?comment=comment-7',
    );
    expect(
      notificationTargetLocation(
        const NotificationTarget(
          kind: NotificationTargetKind.moment,
          momentId: 'moment-1',
        ),
      ),
      '/moments/moment-1',
    );
  });
}

NotificationListItem _item({
  String content = '',
  String recipientUserId = 'viewer-user',
  NotificationPayload? payload,
}) {
  return NotificationListItem(
    id: 'notification-1',
    recipientUserId: recipientUserId,
    kind: NotificationKind.reply,
    content: content,
    payload: payload,
    target: const NotificationTarget(kind: NotificationTargetKind.none),
    isRead: false,
    createdAt: DateTime.utc(2026, 8, 10),
  );
}
