import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_copy.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_navigation.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

class BackgroundOnlinePoller {
  BackgroundOnlinePoller(
    this._notificationRepository,
    this._directMessageRepository,
  );

  final NotificationRepository _notificationRepository;
  final DirectMessageRepository _directMessageRepository;

  final Map<String, String> _notificationFingerprints = {};
  final Map<String, String> _conversationFingerprints = {};
  DirectUnreadCounts _directCounts = const DirectUnreadCounts(
    unreadMessages: 0,
    pendingRequests: 0,
  );
  Future<bool>? _preparing;
  bool _ready = false;
  bool _includesDirectMessages = false;
  int _epoch = 0;

  bool get hasBaseline => _ready;

  Future<bool> ensureBaseline({required bool includeDirectMessages}) {
    if (_ready && _includesDirectMessages == includeDirectMessages) {
      return Future.value(true);
    }
    final current = _preparing;
    if (current != null) return current;
    late final Future<bool> future;
    future = _prepare(includeDirectMessages).whenComplete(() {
      if (identical(_preparing, future)) _preparing = null;
    });
    _preparing = future;
    return future;
  }

  void invalidate() {
    _epoch++;
    _ready = false;
    _preparing = null;
    _notificationFingerprints.clear();
    _conversationFingerprints.clear();
    _directCounts = const DirectUnreadCounts(
      unreadMessages: 0,
      pendingRequests: 0,
    );
  }

  Future<List<BackgroundLocalAlert>> poll({
    required bool includeDirectMessages,
  }) async {
    if (!_ready || _includesDirectMessages != includeDirectMessages) {
      await ensureBaseline(includeDirectMessages: includeDirectMessages);
      return const [];
    }
    final epoch = _epoch;
    try {
      final notificationPageFuture = _notificationRepository.fetchPage();
      final notificationCountFuture = _notificationRepository
          .fetchUnreadCount();
      final directCountsFuture = includeDirectMessages
          ? _directMessageRepository.fetchUnreadCounts()
          : Future.value(
              const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
            );
      final notificationPage = await notificationPageFuture;
      await notificationCountFuture;
      final directCounts = await directCountsFuture;
      if (epoch != _epoch || !_ready) return const [];

      final alerts = <BackgroundLocalAlert>[];
      for (final item in notificationPage.items) {
        final fingerprint = _notificationFingerprint(item);
        final previous = _notificationFingerprints[item.id];
        _notificationFingerprints[item.id] = fingerprint;
        if (!item.isRead && previous != fingerprint) {
          alerts.add(_notificationAlert(item));
        }
      }

      if (includeDirectMessages) {
        final unreadIncreased =
            directCounts.unreadMessages > _directCounts.unreadMessages;
        final requestsIncreased =
            directCounts.pendingRequests > _directCounts.pendingRequests;
        if (unreadIncreased) {
          alerts.addAll(
            await _directAlertsFor(DirectConversationView.inbox, epoch),
          );
        }
        if (requestsIncreased) {
          alerts.addAll(
            await _directAlertsFor(DirectConversationView.requests, epoch),
          );
        }
        if (epoch != _epoch || !_ready) return const [];
        _directCounts = directCounts;
      }
      return _limitAlerts(alerts);
    } on Object {
      return const [];
    }
  }

  Future<bool> _prepare(bool includeDirectMessages) async {
    final epoch = _epoch;
    try {
      final notificationPageFuture = _notificationRepository.fetchPage();
      final notificationCountFuture = _notificationRepository
          .fetchUnreadCount();
      final directCountsFuture = includeDirectMessages
          ? _directMessageRepository.fetchUnreadCounts()
          : Future.value(
              const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
            );
      final inboxFuture = includeDirectMessages
          ? _directMessageRepository.fetchConversations(
              view: DirectConversationView.inbox,
              limit: 20,
            )
          : null;
      final requestsFuture = includeDirectMessages
          ? _directMessageRepository.fetchConversations(
              view: DirectConversationView.requests,
              limit: 20,
            )
          : null;

      final notificationPage = await notificationPageFuture;
      await notificationCountFuture;
      final directCounts = await directCountsFuture;
      final inbox = await inboxFuture;
      final requests = await requestsFuture;
      if (epoch != _epoch) return false;

      _notificationFingerprints
        ..clear()
        ..addEntries(
          notificationPage.items.map(
            (item) => MapEntry(item.id, _notificationFingerprint(item)),
          ),
        );
      _conversationFingerprints.clear();
      for (final page in [inbox, requests]) {
        if (page == null) continue;
        for (final conversation in page.items) {
          _conversationFingerprints[conversation.id] = _conversationFingerprint(
            conversation,
          );
        }
      }
      _directCounts = directCounts;
      _includesDirectMessages = includeDirectMessages;
      _ready = true;
      return true;
    } on Object {
      return false;
    }
  }

  Future<List<BackgroundLocalAlert>> _directAlertsFor(
    DirectConversationView view,
    int epoch,
  ) async {
    try {
      final page = await _directMessageRepository.fetchConversations(
        view: view,
        limit: 20,
      );
      if (epoch != _epoch) return const [];
      final alerts = <BackgroundLocalAlert>[];
      for (final conversation in page.items) {
        final fingerprint = _conversationFingerprint(conversation);
        final previous = _conversationFingerprints[conversation.id];
        _conversationFingerprints[conversation.id] = fingerprint;
        if (previous == fingerprint) continue;
        if (view == DirectConversationView.requests) {
          if (conversation.isIncomingRequest) {
            alerts.add(_directAlert(conversation, request: true));
          }
          continue;
        }
        final lastMessage = conversation.lastMessage;
        if (conversation.unreadCount > 0 &&
            lastMessage != null &&
            lastMessage.senderId == conversation.otherUser.id) {
          alerts.add(_directAlert(conversation, request: false));
        }
      }
      return alerts;
    } on Object {
      return const [];
    }
  }

  BackgroundLocalAlert _notificationAlert(NotificationListItem item) {
    final summary = _truncate(formatNotificationCopy(item).plainText, 160);
    final payload = BackgroundNotificationPayload.notification(
      notificationTargetLocation(item.target),
    );
    return BackgroundLocalAlert(
      id: _stableId('notification:${item.id}'),
      title: '温油站',
      body: summary,
      payload: payload.encode(),
    );
  }

  BackgroundLocalAlert _directAlert(
    DirectConversation conversation, {
    required bool request,
  }) {
    final unread = conversation.unreadCount;
    final body = request
        ? '发来一条新的私聊请求'
        : unread > 1
        ? '发来了 $unread 条新私聊'
        : '发来一条新私聊';
    return BackgroundLocalAlert(
      id: _stableId(
        'direct:${conversation.id}:${conversation.lastMessage?.id ?? 'request'}',
      ),
      title: _truncate(conversation.otherUser.username, 48),
      body: body,
      payload: BackgroundNotificationPayload.directMessage(
        conversation.id,
      ).encode(),
    );
  }

  List<BackgroundLocalAlert> _limitAlerts(List<BackgroundLocalAlert> alerts) {
    if (alerts.length <= 3) return List.unmodifiable(alerts);
    return [
      BackgroundLocalAlert(
        id: _stableId('aggregate:${alerts.map((alert) => alert.id).join(',')}'),
        title: '温油站',
        body: '你有 ${alerts.length} 条新消息',
        payload: const BackgroundNotificationPayload.messageCenter().encode(),
      ),
    ];
  }
}

final backgroundOnlinePollerProvider = Provider<BackgroundOnlinePoller>((ref) {
  return BackgroundOnlinePoller(
    ref.watch(notificationRepositoryProvider),
    ref.watch(directMessageRepositoryProvider),
  );
});

String _notificationFingerprint(NotificationListItem item) => [
  item.isRead,
  item.content,
  item.payload?.action,
  item.payload?.actorName,
  item.payload?.preview,
  item.payload?.totalCount,
  notificationTargetLocation(item.target),
].join('|');

String _conversationFingerprint(DirectConversation conversation) => [
  conversation.lastMessage?.id,
  conversation.unreadCount,
  conversation.status.name,
  conversation.requestDirection.name,
].join('|');

int _stableId(String value) {
  final bytes = sha256.convert(utf8.encode(value)).bytes;
  final hash = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  return 0x20000000 | (hash & 0x1fffffff);
}

String _truncate(String value, int maxRunes) {
  final collapsed = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  final runes = collapsed.runes.toList(growable: false);
  if (runes.length <= maxRunes) return collapsed;
  return '${String.fromCharCodes(runes.take(maxRunes))}…';
}
