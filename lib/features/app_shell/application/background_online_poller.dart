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

abstract interface class BackgroundOnlinePollingSession {
  bool get hasBaseline;

  Future<bool> ensureBaseline({required bool includeDirectMessages});

  Future<BackgroundOnlinePollBatch?> poll({
    required bool includeDirectMessages,
  });

  void invalidate();
}

class BackgroundOnlinePollBatch {
  BackgroundOnlinePollBatch({
    required List<BackgroundLocalAlert> alerts,
    required this.commitCallback,
  }) : alerts = List.unmodifiable(alerts),
       super();

  final List<BackgroundLocalAlert> alerts;
  final bool Function() commitCallback;
  bool _committed = false;

  bool commit() {
    if (_committed) return false;
    final committed = commitCallback();
    if (committed) _committed = true;
    return committed;
  }
}

class BackgroundOnlinePoller implements BackgroundOnlinePollingSession {
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
  bool? _preparingIncludesDirectMessages;
  bool _ready = false;
  bool _includesDirectMessages = false;
  int _epoch = 0;

  @override
  bool get hasBaseline => _ready;

  @override
  Future<bool> ensureBaseline({required bool includeDirectMessages}) {
    if ((_ready && _includesDirectMessages != includeDirectMessages) ||
        (_preparing != null &&
            _preparingIncludesDirectMessages != includeDirectMessages)) {
      invalidate();
    }
    if (_ready && _includesDirectMessages == includeDirectMessages) {
      return Future.value(true);
    }
    final current = _preparing;
    if (current != null) return current;
    late final Future<bool> future;
    future = _prepare(includeDirectMessages).whenComplete(() {
      if (identical(_preparing, future)) {
        _preparing = null;
        _preparingIncludesDirectMessages = null;
      }
    });
    _preparing = future;
    _preparingIncludesDirectMessages = includeDirectMessages;
    return future;
  }

  @override
  void invalidate() {
    _epoch++;
    _ready = false;
    _preparing = null;
    _preparingIncludesDirectMessages = null;
    _includesDirectMessages = false;
    _notificationFingerprints.clear();
    _conversationFingerprints.clear();
    _directCounts = const DirectUnreadCounts(
      unreadMessages: 0,
      pendingRequests: 0,
    );
  }

  @override
  Future<BackgroundOnlinePollBatch?> poll({
    required bool includeDirectMessages,
  }) async {
    if (!_ready || _includesDirectMessages != includeDirectMessages) {
      await ensureBaseline(includeDirectMessages: includeDirectMessages);
      return null;
    }
    final epoch = _epoch;
    final notificationPageFuture = _notificationRepository.fetchPage();
    final notificationCountFuture = _notificationRepository.fetchUnreadCount();
    final directCountsFuture = includeDirectMessages
        ? _directMessageRepository.fetchUnreadCounts()
        : Future.value(
            const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
          );
    final (notificationPage, _, directCounts) = await (
      notificationPageFuture,
      notificationCountFuture,
      directCountsFuture,
    ).wait;
    if (epoch != _epoch || !_ready) return null;

    final nextNotificationFingerprints = Map<String, String>.of(
      _notificationFingerprints,
    );
    final nextConversationFingerprints = Map<String, String>.of(
      _conversationFingerprints,
    );
    final alerts = <BackgroundLocalAlert>[];
    for (final item in notificationPage.items) {
      final fingerprint = _notificationFingerprint(item);
      final previous = nextNotificationFingerprints[item.id];
      nextNotificationFingerprints[item.id] = fingerprint;
      if (!item.isRead && previous != fingerprint) {
        alerts.add(_notificationAlert(item));
      }
    }

    if (includeDirectMessages) {
      final unreadIncreased =
          directCounts.unreadMessages > _directCounts.unreadMessages;
      final requestsIncreased =
          directCounts.pendingRequests > _directCounts.pendingRequests;
      final inboxAlertsFuture = unreadIncreased
          ? _directAlertsFor(
              DirectConversationView.inbox,
              epoch,
              nextConversationFingerprints,
            )
          : Future.value(const <BackgroundLocalAlert>[]);
      final requestAlertsFuture = requestsIncreased
          ? _directAlertsFor(
              DirectConversationView.requests,
              epoch,
              nextConversationFingerprints,
            )
          : Future.value(const <BackgroundLocalAlert>[]);
      final (inboxAlerts, requestAlerts) = await (
        inboxAlertsFuture,
        requestAlertsFuture,
      ).wait;
      if (epoch != _epoch || !_ready) return null;
      alerts
        ..addAll(inboxAlerts)
        ..addAll(requestAlerts);
    }

    return BackgroundOnlinePollBatch(
      alerts: _limitAlerts(alerts),
      commitCallback: () {
        if (epoch != _epoch ||
            !_ready ||
            _includesDirectMessages != includeDirectMessages) {
          return false;
        }
        _notificationFingerprints
          ..clear()
          ..addAll(nextNotificationFingerprints);
        _conversationFingerprints
          ..clear()
          ..addAll(nextConversationFingerprints);
        _directCounts = directCounts;
        return true;
      },
    );
  }

  Future<bool> _prepare(bool includeDirectMessages) async {
    final epoch = _epoch;
    final notificationPageFuture = _notificationRepository.fetchPage();
    final notificationCountFuture = _notificationRepository.fetchUnreadCount();
    final directCountsFuture = includeDirectMessages
        ? _directMessageRepository.fetchUnreadCounts()
        : Future.value(
            const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
          );
    final inboxFuture = includeDirectMessages
        ? _directMessageRepository
              .fetchConversations(view: DirectConversationView.inbox, limit: 20)
              .then((page) => page)
        : Future.value(null);
    final requestsFuture = includeDirectMessages
        ? _directMessageRepository
              .fetchConversations(
                view: DirectConversationView.requests,
                limit: 20,
              )
              .then((page) => page)
        : Future.value(null);

    final (notificationPage, _, directCounts, inbox, requests) = await (
      notificationPageFuture,
      notificationCountFuture,
      directCountsFuture,
      inboxFuture,
      requestsFuture,
    ).wait;
    if (epoch != _epoch) return false;

    final nextNotificationFingerprints = <String, String>{
      for (final item in notificationPage.items)
        item.id: _notificationFingerprint(item),
    };
    final nextConversationFingerprints = <String, String>{};
    for (final page in [inbox, requests]) {
      if (page == null) continue;
      for (final conversation in page.items) {
        nextConversationFingerprints[conversation.id] =
            _conversationFingerprint(conversation);
      }
    }
    _notificationFingerprints
      ..clear()
      ..addAll(nextNotificationFingerprints);
    _conversationFingerprints
      ..clear()
      ..addAll(nextConversationFingerprints);
    _directCounts = directCounts;
    _includesDirectMessages = includeDirectMessages;
    _ready = true;
    return true;
  }

  Future<List<BackgroundLocalAlert>> _directAlertsFor(
    DirectConversationView view,
    int epoch,
    Map<String, String> nextConversationFingerprints,
  ) async {
    final page = await _directMessageRepository.fetchConversations(
      view: view,
      limit: 20,
    );
    if (epoch != _epoch) return const [];
    final alerts = <BackgroundLocalAlert>[];
    for (final conversation in page.items) {
      final fingerprint = _conversationFingerprint(conversation);
      final previous = nextConversationFingerprints[conversation.id];
      nextConversationFingerprints[conversation.id] = fingerprint;
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
