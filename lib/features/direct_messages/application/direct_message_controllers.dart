import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

import 'direct_message_states.dart';

export 'direct_conversation_target_controller.dart';
export 'direct_message_states.dart';

typedef DirectMessageRequestIdFactory = String Function();

final directMessagesEnabledProvider = Provider<bool>(
  (ref) => ref.watch(
    appCapabilitiesProvider.select(
      (capabilities) => capabilities.directMessages,
    ),
  ),
  dependencies: [appCapabilitiesProvider],
);

class DirectUnreadController extends StateNotifier<DirectUnreadState> {
  DirectUnreadController(this._repository, {bool autoStart = true})
    : super(const DirectUnreadState()) {
    if (autoStart) unawaited(refresh());
  }

  final DirectMessageRepository _repository;

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = DirectUnreadState(counts: state.counts, isLoading: true);
    try {
      final counts = await _repository.fetchUnreadCounts();
      if (!mounted) return;
      state = DirectUnreadState(counts: counts);
    } on Object catch (error) {
      if (!mounted) return;
      state = DirectUnreadState(
        counts: state.counts,
        failure: _asFailure(error, '私聊未读数同步失败。'),
      );
    }
  }
}

final directUnreadControllerProvider =
    StateNotifierProvider<DirectUnreadController, DirectUnreadState>(
      (ref) {
        final authenticated = ref.watch(
          sessionControllerProvider.select(
            (session) => session.isAuthenticated,
          ),
        );
        final enabled = ref.watch(directMessagesEnabledProvider);
        return DirectUnreadController(
          ref.watch(directMessageRepositoryProvider),
          autoStart: authenticated && enabled,
        );
      },
      // This provider is read from the app shell while the server-advertised
      // capability is scoped by WenyouApp (and overridden by feature tests).
      // Declaring the dependency keeps Riverpod in the same override scope.
      dependencies: [
        directMessagesEnabledProvider,
        directMessageRepositoryProvider,
      ],
    );

class DirectConversationListController
    extends StateNotifier<DirectConversationListState> {
  DirectConversationListController(
    this._view,
    this._repository, {
    bool autoStart = true,
  }) : super(DirectConversationListState.loading(_view)) {
    if (autoStart) unawaited(load());
  }

  final DirectConversationView _view;
  final DirectMessageRepository _repository;
  var _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    state = DirectConversationListState.loading(_view);
    try {
      final page = await _repository.fetchConversations(view: _view);
      if (!mounted || epoch != _epoch) return;
      state = DirectConversationListState(
        phase: DirectConversationListPhase.ready,
        view: _view,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = DirectConversationListState(
        phase: DirectConversationListPhase.failed,
        view: _view,
        failure: _asFailure(error, '私聊会话列表加载失败。'),
      );
    }
  }

  Future<void> refresh() async {
    final epoch = ++_epoch;
    final before = state;
    if (before.phase != DirectConversationListPhase.ready) {
      await load();
      return;
    }
    state = before.copyWith(isRefreshing: true, transientFailure: null);
    try {
      final page = await _repository.fetchConversations(view: _view);
      if (!mounted || epoch != _epoch) return;
      state = DirectConversationListState(
        phase: DirectConversationListPhase.ready,
        view: _view,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = before.copyWith(
        isRefreshing: false,
        transientFailure: _asFailure(error, '私聊会话刷新失败，请重试。'),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.phase != DirectConversationListPhase.ready ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    final epoch = _epoch;
    final before = state;
    state = before.copyWith(isLoadingMore: true, transientFailure: null);
    try {
      final page = await _repository.fetchConversations(
        view: _view,
        cursor: before.cursor,
      );
      if (!mounted || epoch != _epoch) return;
      state = DirectConversationListState(
        phase: DirectConversationListPhase.ready,
        view: _view,
        items: mergeUniqueBy(
          before.items,
          page.items,
          keyOf: (item) => item.id,
        ),
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        await refresh();
        return;
      }
      state = before.copyWith(isLoadingMore: false, transientFailure: failure);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = before.copyWith(
        isLoadingMore: false,
        transientFailure: _asFailure(error, '更多私聊会话加载失败。'),
      );
    }
  }
}

final directConversationListControllerProvider = StateNotifierProvider
    .autoDispose
    .family<
      DirectConversationListController,
      DirectConversationListState,
      DirectConversationView
    >((ref, view) {
      return DirectConversationListController(
        view,
        ref.watch(directMessageRepositoryProvider),
      );
    }, dependencies: [directMessageRepositoryProvider]);

class DirectConversationController
    extends StateNotifier<DirectConversationState> {
  DirectConversationController(
    this._conversationId,
    this._repository, {
    bool autoStart = true,
    Duration pollInterval = const Duration(seconds: 8),
    this._catchUpPollInterval = const Duration(seconds: 2),
    DirectMessageRequestIdFactory? requestIdFactory,
    this._onUnreadChanged,
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       _pollInterval = pollInterval,
       super(const DirectConversationState.loading()) {
    if (autoStart) unawaited(loadInitial());
    _schedulePoll(pollInterval);
  }

  final String _conversationId;
  final DirectMessageRepository _repository;
  final DirectMessageRequestIdFactory _requestIdFactory;
  final Duration _pollInterval;
  final Duration _catchUpPollInterval;
  final Future<void> Function()? _onUnreadChanged;
  Timer? _pollTimer;
  var _epoch = 0;
  var _polling = false;
  var _pollingPaused = false;
  var _catchUpPollsRemaining = 0;
  String? _lastMarkedReadId;
  Future<void>? _markReadInFlight;

  Future<void> loadInitial() async {
    final epoch = ++_epoch;
    state = const DirectConversationState.loading();
    try {
      final results = await Future.wait<Object>([
        _repository.fetchConversation(_conversationId),
        _repository.fetchMessages(conversationId: _conversationId),
      ]);
      if (!mounted || epoch != _epoch) return;
      final conversation = results[0] as DirectConversation;
      final page = results[1] as CursorPage<DirectMessage>;
      _validateParticipants(conversation, page.items);
      state = DirectConversationState(
        phase: DirectConversationPhase.ready,
        conversation: conversation,
        messages: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
      unawaited(_markLatestIncomingRead());
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = DirectConversationState(
        phase: DirectConversationPhase.failed,
        failure: _asFailure(error, '私聊会话加载失败。'),
      );
    }
  }

  Future<void> refresh({bool resetPagination = false}) async {
    if (state.phase != DirectConversationPhase.ready) {
      await loadInitial();
      return;
    }
    if (state.isRefreshing) return;
    final epoch = ++_epoch;
    final before = state;
    state = before.copyWith(
      isRefreshing: true,
      isLoadingOlder: false,
      transientFailure: null,
    );
    try {
      final results = await Future.wait<Object>([
        _repository.fetchConversation(_conversationId),
        _repository.fetchMessages(conversationId: _conversationId),
      ]);
      if (!mounted || epoch != _epoch) return;
      final conversation = results[0] as DirectConversation;
      final page = results[1] as CursorPage<DirectMessage>;
      _validateParticipants(conversation, page.items);
      final current = state;
      state = current.copyWith(
        conversation: conversation,
        messages: _mergeMessages(current.messages, page.items),
        cursor: resetPagination ? page.cursor : current.cursor,
        hasMore: resetPagination ? page.hasMore : current.hasMore,
        isRefreshing: false,
        transientFailure: null,
      );
      unawaited(_markLatestIncomingRead());
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        isRefreshing: false,
        transientFailure: _asFailure(error, '私聊会话刷新失败，请重试。'),
      );
    }
  }

  Future<void> loadOlder() async {
    if (state.phase != DirectConversationPhase.ready ||
        state.isLoadingOlder ||
        state.isMutating ||
        !state.hasMore) {
      return;
    }
    final epoch = _epoch;
    final before = state;
    state = before.copyWith(isLoadingOlder: true, transientFailure: null);
    try {
      final page = await _repository.fetchMessages(
        conversationId: _conversationId,
        cursor: before.cursor,
      );
      if (!mounted || epoch != _epoch) return;
      final conversation = before.conversation;
      if (conversation == null) {
        throw const ApiFailure(userMessage: '会话加载失败，请重新打开。');
      }
      _validateParticipants(conversation, page.items);
      final current = state;
      state = current.copyWith(
        messages: _mergeMessages(current.messages, page.items),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingOlder: false,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        await refresh(resetPagination: true);
        return;
      }
      state = state.copyWith(isLoadingOlder: false, transientFailure: failure);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        isLoadingOlder: false,
        transientFailure: _asFailure(error, '更早消息加载失败。'),
      );
    }
  }

  Future<void> pollLatest() async {
    if (!mounted ||
        _polling ||
        state.phase != DirectConversationPhase.ready ||
        state.isRefreshing ||
        _pollingPaused) {
      return;
    }
    _polling = true;
    final epoch = _epoch;
    try {
      var anchor = state.messages
          .where((message) => !message.isOptimistic)
          .lastOrNull
          ?.id;
      var rounds = 0;
      do {
        final page = await _repository.fetchMessages(
          conversationId: _conversationId,
          after: anchor,
          limit: 50,
        );
        if (!mounted || epoch != _epoch || _pollingPaused) return;
        final conversation = state.conversation;
        if (conversation == null) return;
        _validateParticipants(conversation, page.items);
        if (page.items.isNotEmpty) {
          state = state.copyWith(
            messages: _mergeMessages(state.messages, page.items),
            transientFailure: null,
          );
          anchor = page.items.last.id;
        }
        rounds++;
        if (!page.hasMore || page.items.isEmpty || rounds >= 10) break;
      } while (true);
      unawaited(_markLatestIncomingRead());
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        await refresh(resetPagination: true);
      }
    } on Object {
      // 轮询失败保持当前可读记录；显式刷新仍会展示诊断请求 ID。
    } finally {
      _polling = false;
    }
  }

  Future<bool> send({
    String? content,
    String? mediaId,
    String? stickerAssetId,
  }) async {
    if (state.phase != DirectConversationPhase.ready) {
      return false;
    }
    final conversation = state.conversation;
    if (conversation == null || !conversation.canSend) return false;
    late final DirectMessageDraft draft;
    try {
      draft = DirectMessageDraft.normalized(
        clientRequestId: _requestIdFactory(),
        content: content,
        mediaId: mediaId,
        stickerAssetId: stickerAssetId,
      );
    } on Object catch (error) {
      state = state.copyWith(transientFailure: _asFailure(error, '消息内容不符合要求。'));
      return false;
    }
    final optimistic = DirectMessage.optimistic(
      conversationId: _conversationId,
      recipientId: conversation.otherUser.id,
      draft: draft,
      createdAt: DateTime.now().toUtc(),
    );
    state = state.copyWith(
      messages: _mergeMessages(state.messages, [optimistic]),
      transientFailure: null,
    );
    return _deliverOptimistic(optimistic.id);
  }

  Future<bool> retryMessage(String optimisticMessageId) async {
    final message = state.messages
        .where((item) => item.id == optimisticMessageId)
        .firstOrNull;
    if (state.phase != DirectConversationPhase.ready ||
        message?.deliveryState != DirectMessageDeliveryState.failed ||
        message?.localDraft == null) {
      return false;
    }
    final failures = Map<String, ApiFailure>.of(state.sendFailures)
      ..remove(optimisticMessageId);
    state = state.copyWith(
      messages: state.messages
          .map(
            (item) => item.id == optimisticMessageId
                ? item.copyWith(
                    deliveryState: DirectMessageDeliveryState.sending,
                  )
                : item,
          )
          .toList(growable: false),
      failedDraft: null,
      sendFailures: Map.unmodifiable(failures),
      transientFailure: null,
    );
    return _deliverOptimistic(optimisticMessageId);
  }

  Future<bool> _deliverOptimistic(String optimisticMessageId) async {
    final optimistic = state.messages
        .where((item) => item.id == optimisticMessageId)
        .firstOrNull;
    final conversation = state.conversation;
    final draft = optimistic?.localDraft;
    if (optimistic == null || conversation == null || draft == null) {
      return false;
    }
    try {
      final message = await _repository.sendMessage(
        conversationId: _conversationId,
        draft: draft,
      );
      if (!mounted) return false;
      _validateParticipants(conversation, [message], requireOutgoing: true);
      final remaining = state.messages.where(
        (item) => item.id != optimisticMessageId && item.id != message.id,
      );
      final failures = Map<String, ApiFailure>.of(state.sendFailures)
        ..remove(optimisticMessageId);
      state = state.copyWith(
        messages: _mergeMessages(remaining, [message]),
        transientFailure: null,
        failedDraft: state.failedDraft?.clientRequestId == draft.clientRequestId
            ? null
            : state.failedDraft,
        sendFailures: Map.unmodifiable(failures),
      );
      _beginCatchUpPolling();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      final failure = _asFailure(error, '消息发送失败，请重试。');
      final failures = Map<String, ApiFailure>.of(state.sendFailures)
        ..[optimisticMessageId] = failure;
      state = state.copyWith(
        messages: state.messages
            .map(
              (item) => item.id == optimisticMessageId
                  ? item.copyWith(
                      deliveryState: DirectMessageDeliveryState.failed,
                    )
                  : item,
            )
            .toList(growable: false),
        transientFailure: null,
        failedDraft: draft,
        sendFailures: Map.unmodifiable(failures),
      );
      return false;
    }
  }

  Future<bool> retrySend() async {
    final message = state.messages
        .where(
          (item) => item.deliveryState == DirectMessageDeliveryState.failed,
        )
        .lastOrNull;
    return message == null ? false : retryMessage(message.id);
  }

  void abandonFailedDraft() {
    final message = state.messages
        .where(
          (item) => item.deliveryState == DirectMessageDeliveryState.failed,
        )
        .lastOrNull;
    if (message != null) abandonFailedMessage(message.id);
  }

  void abandonFailedMessage(String optimisticMessageId) {
    final message = state.messages
        .where((item) => item.id == optimisticMessageId)
        .firstOrNull;
    if (message?.deliveryState != DirectMessageDeliveryState.failed) return;
    final failures = Map<String, ApiFailure>.of(state.sendFailures)
      ..remove(optimisticMessageId);
    state = state.copyWith(
      messages: state.messages
          .where((item) => item.id != optimisticMessageId)
          .toList(growable: false),
      failedDraft:
          state.failedDraft?.clientRequestId == message?.clientRequestId
          ? null
          : state.failedDraft,
      sendFailures: Map.unmodifiable(failures),
      transientFailure: null,
    );
  }

  Future<bool> handleRequest({required bool accept}) async {
    final conversation = state.conversation;
    if (state.phase != DirectConversationPhase.ready ||
        state.isMutating ||
        conversation == null ||
        (accept ? !conversation.canAccept : !conversation.canDecline)) {
      return false;
    }
    final before = state;
    state = before.copyWith(
      action: accept
          ? DirectConversationAction.accepting
          : DirectConversationAction.declining,
      transientFailure: null,
    );
    try {
      final updated = await _repository.handleRequest(
        conversationId: _conversationId,
        accept: accept,
      );
      if (!mounted) return false;
      final current = state;
      state = current.copyWith(
        conversation: updated,
        messages: accept ? current.messages : const [],
        cursor: accept ? current.cursor : null,
        hasMore: accept && current.hasMore,
        action: null,
        actionTargetId: null,
        transientFailure: null,
      );
      await _notifyUnreadChanged();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        action: null,
        actionTargetId: null,
        transientFailure: _asFailure(error, '消息请求处理失败，请重试。'),
      );
      return false;
    }
  }

  Future<bool> toggleArchive() async {
    final conversation = state.conversation;
    if (state.phase != DirectConversationPhase.ready ||
        state.isMutating ||
        conversation == null) {
      return false;
    }
    final before = state;
    final archived = conversation.archivedAt == null;
    state = before.copyWith(
      action: DirectConversationAction.archiving,
      transientFailure: null,
    );
    try {
      final updated = await _repository.setArchived(
        conversationId: _conversationId,
        archived: archived,
      );
      if (!mounted) return false;
      state = state.copyWith(
        conversation: updated,
        action: null,
        actionTargetId: null,
        transientFailure: null,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        action: null,
        actionTargetId: null,
        transientFailure: _asFailure(error, '会话归档操作失败，请重试。'),
      );
      return false;
    }
  }

  Future<bool> recall(String messageId, {DateTime? now}) async {
    final conversation = state.conversation;
    final message = state.messages
        .where((item) => item.id == messageId)
        .firstOrNull;
    if (state.phase != DirectConversationPhase.ready ||
        state.isMutating ||
        conversation == null ||
        message == null ||
        message.isRecalled ||
        !message.isMine(conversation.otherUser.id)) {
      return false;
    }
    final timestamp = now ?? DateTime.now().toUtc();
    if (timestamp.difference(message.createdAt.toUtc()) >
        const Duration(minutes: 10)) {
      state = state.copyWith(
        transientFailure: const ApiFailure(
          userMessage: '这条消息已超过十分钟撤回时限。',
          businessCode: 40908,
        ),
      );
      return false;
    }
    final before = state;
    state = before.copyWith(
      action: DirectConversationAction.recalling,
      actionTargetId: messageId,
      transientFailure: null,
    );
    try {
      final result = await _repository.recall(messageId);
      if (!mounted) return false;
      if (result.conversationCanceled) {
        state = state.copyWith(
          messages: const [],
          action: null,
          actionTargetId: null,
          transientFailure: null,
          conversationCanceled: true,
        );
      } else {
        state = state.copyWith(
          messages: state.messages
              .map(
                (item) =>
                    item.id == messageId ? item.asRecalled(timestamp) : item,
              )
              .toList(growable: false),
          action: null,
          actionTargetId: null,
          transientFailure: null,
        );
      }
      await _notifyUnreadChanged();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        action: null,
        actionTargetId: null,
        transientFailure: _asFailure(error, '消息撤回失败，请重试。'),
      );
      return false;
    }
  }

  Future<void> _markLatestIncomingRead() async {
    final conversation = state.conversation;
    if (conversation == null) return;
    final incoming = _latestIncomingMessage();
    if (incoming == null || incoming.id == _lastMarkedReadId) {
      return;
    }
    if (_markReadInFlight != null) return;
    final targetId = incoming.id;
    final operation = _repository.markRead(
      conversationId: _conversationId,
      throughMessageId: targetId,
    );
    _markReadInFlight = operation;
    var marked = false;
    try {
      await operation;
      if (!mounted) return;
      marked = true;
      _lastMarkedReadId = targetId;
      if (_latestIncomingMessage()?.id == targetId) {
        state = state.copyWith(
          conversation: state.conversation?.copyWith(unreadCount: 0),
        );
      }
      await _notifyUnreadChanged();
    } on Object {
      // 保留服务端未读事实；下次增量轮询或显式刷新会再次尝试。
    } finally {
      _markReadInFlight = null;
      if (mounted &&
          marked &&
          _latestIncomingMessage()?.id != _lastMarkedReadId) {
        unawaited(_markLatestIncomingRead());
      }
    }
  }

  DirectMessage? _latestIncomingMessage() {
    final otherUserId = state.conversation?.otherUser.id;
    if (otherUserId == null) return null;
    return state.messages
        .where(
          (message) => !message.isOptimistic && message.senderId == otherUserId,
        )
        .lastOrNull;
  }

  Future<void> _notifyUnreadChanged() async {
    try {
      await _onUnreadChanged?.call();
    } on Object {
      // 会话操作已经成功，角标校准失败不回滚业务结果。
    }
  }

  void pausePolling() {
    _pollingPaused = true;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void resumePolling() {
    if (!mounted) return;
    _pollingPaused = false;
    _beginCatchUpPolling();
    unawaited(pollLatest());
  }

  void _beginCatchUpPolling() {
    if (_pollingPaused || _pollInterval <= Duration.zero) return;
    _catchUpPollsRemaining = 3;
    _schedulePoll(_catchUpPollInterval);
  }

  void _schedulePoll(Duration interval) {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (_pollingPaused || interval <= Duration.zero) return;
    _pollTimer = Timer(interval, () {
      unawaited(pollLatest());
      if (_catchUpPollsRemaining > 0) {
        _catchUpPollsRemaining--;
        _schedulePoll(
          _catchUpPollsRemaining > 0 ? _catchUpPollInterval : _pollInterval,
        );
      } else {
        _schedulePoll(_pollInterval);
      }
    });
  }

  List<DirectMessage> _mergeMessages(
    Iterable<DirectMessage> current,
    Iterable<DirectMessage> incoming,
  ) {
    final byId = <String, DirectMessage>{};
    for (final message in current) {
      byId[message.id] = message;
    }
    for (final message in incoming) {
      byId[message.id] = message;
    }
    final merged = byId.values.toList()..sort(_compareMessages);
    return List.unmodifiable(merged);
  }

  int _compareMessages(DirectMessage left, DirectMessage right) {
    final byTime = left.createdAt.compareTo(right.createdAt);
    return byTime != 0 ? byTime : left.id.compareTo(right.id);
  }

  void _validateParticipants(
    DirectConversation conversation,
    Iterable<DirectMessage> messages, {
    bool requireOutgoing = false,
  }) {
    final otherUserId = conversation.otherUser.id;
    for (final message in messages) {
      final includesOther =
          message.senderId == otherUserId || message.recipientId == otherUserId;
      final isOutgoing = message.recipientId == otherUserId;
      if (!includesOther || (requireOutgoing && !isOutgoing)) {
        throw const ApiFailure(userMessage: '会话成员已经发生变化，请重新打开。');
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final directConversationControllerProvider = StateNotifierProvider.autoDispose
    .family<DirectConversationController, DirectConversationState, String>((
      ref,
      conversationId,
    ) {
      return DirectConversationController(
        conversationId,
        ref.watch(directMessageRepositoryProvider),
        onUnreadChanged: () =>
            ref.read(directUnreadControllerProvider.notifier).refresh(),
      );
    }, dependencies: [directMessageRepositoryProvider]);

ApiFailure _asFailure(Object error, String fallback) {
  return mapApplicationFailure(error, fallback);
}
