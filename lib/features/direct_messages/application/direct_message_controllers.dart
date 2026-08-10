import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

import 'direct_message_states.dart';
export 'direct_message_states.dart';

part 'direct_conversation_target_controller.dart';

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
  DirectUnreadController(
    this._repository, {
    bool autoStart = true,
    Duration refreshInterval = const Duration(seconds: 30),
  }) : super(const DirectUnreadState()) {
    if (autoStart) {
      unawaited(refresh());
      _timer = Timer.periodic(refreshInterval, (_) => unawaited(refresh()));
    }
  }

  final DirectMessageRepository _repository;
  Timer? _timer;

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
        failure: _asFailure(error, '私聊未读数没有同步完成。'),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final directUnreadControllerProvider =
    StateNotifierProvider<DirectUnreadController, DirectUnreadState>((ref) {
      final authenticated = ref.watch(
        sessionControllerProvider.select((session) => session.isAuthenticated),
      );
      final enabled = ref.watch(directMessagesEnabledProvider);
      return DirectUnreadController(
        ref.watch(directMessageRepositoryProvider),
        autoStart: authenticated && enabled,
      );
    });

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
        failure: _asFailure(error, '私聊会话列表没有加载完成。'),
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
      final seen = before.items.map((item) => item.id).toSet();
      state = DirectConversationListState(
        phase: DirectConversationListPhase.ready,
        view: _view,
        items: List.unmodifiable([
          ...before.items,
          ...page.items.where((item) => seen.add(item.id)),
        ]),
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
        transientFailure: _asFailure(error, '更多私聊会话没有加载完成。'),
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
    });

class DirectConversationController
    extends StateNotifier<DirectConversationState> {
  DirectConversationController(
    this._conversationId,
    this._repository, {
    bool autoStart = true,
    Duration pollInterval = const Duration(seconds: 8),
    DirectMessageRequestIdFactory? requestIdFactory,
    this._onUnreadChanged,
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       super(const DirectConversationState.loading()) {
    if (autoStart) unawaited(loadInitial());
    if (pollInterval > Duration.zero) {
      _pollTimer = Timer.periodic(pollInterval, (_) => unawaited(pollLatest()));
    }
  }

  final String _conversationId;
  final DirectMessageRepository _repository;
  final DirectMessageRequestIdFactory _requestIdFactory;
  final Future<void> Function()? _onUnreadChanged;
  Timer? _pollTimer;
  var _epoch = 0;
  var _polling = false;
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
        failure: _asFailure(error, '私聊会话没有加载完成。'),
      );
    }
  }

  Future<void> refresh() async {
    if (state.phase != DirectConversationPhase.ready || state.isRefreshing) {
      await loadInitial();
      return;
    }
    final epoch = ++_epoch;
    final before = state;
    state = before.copyWith(isRefreshing: true, transientFailure: null);
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
        failedDraft: before.failedDraft,
      );
      unawaited(_markLatestIncomingRead());
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = before.copyWith(
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
        throw const ApiFailure(userMessage: '私聊会话参与者缺失，请重新加载。');
      }
      _validateParticipants(conversation, page.items);
      final seen = before.messages.map((item) => item.id).toSet();
      state = before.copyWith(
        messages: List.unmodifiable(
          <DirectMessage>[
            ...page.items.where((item) => seen.add(item.id)),
            ...before.messages,
          ]..sort(_compareMessages),
        ),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingOlder: false,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        await refresh();
        return;
      }
      state = before.copyWith(isLoadingOlder: false, transientFailure: failure);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = before.copyWith(
        isLoadingOlder: false,
        transientFailure: _asFailure(error, '更早消息没有加载完成。'),
      );
    }
  }

  Future<void> pollLatest() async {
    if (!mounted ||
        _polling ||
        state.phase != DirectConversationPhase.ready ||
        state.isRefreshing ||
        state.messages.isEmpty) {
      return;
    }
    _polling = true;
    final epoch = _epoch;
    try {
      var anchor = state.messages.last.id;
      var rounds = 0;
      do {
        final page = await _repository.fetchMessages(
          conversationId: _conversationId,
          after: anchor,
          limit: 50,
        );
        if (!mounted || epoch != _epoch || state.isMutating) return;
        final conversation = state.conversation;
        if (conversation == null) return;
        _validateParticipants(conversation, page.items);
        if (page.items.isNotEmpty) {
          final seen = state.messages.map((item) => item.id).toSet();
          final merged = [
            ...state.messages,
            ...page.items.where((item) => seen.add(item.id)),
          ]..sort(_compareMessages);
          state = state.copyWith(
            messages: List.unmodifiable(merged),
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
        await refresh();
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
    if (state.phase != DirectConversationPhase.ready || state.isMutating) {
      return false;
    }
    final conversation = state.conversation;
    if (conversation == null || !conversation.canSend) return false;
    final previous = state.failedDraft;
    final requestId =
        previous?.samePayload(
              content: content,
              mediaId: mediaId,
              stickerAssetId: stickerAssetId,
            ) ??
            false
        ? previous!.clientRequestId
        : _requestIdFactory();
    late final DirectMessageDraft draft;
    try {
      draft = DirectMessageDraft.normalized(
        clientRequestId: requestId,
        content: content,
        mediaId: mediaId,
        stickerAssetId: stickerAssetId,
      );
    } on Object catch (error) {
      state = state.copyWith(transientFailure: _asFailure(error, '消息内容不符合要求。'));
      return false;
    }
    final before = state;
    state = before.copyWith(
      action: DirectConversationAction.sending,
      transientFailure: null,
    );
    try {
      final message = await _repository.sendMessage(
        conversationId: _conversationId,
        draft: draft,
      );
      if (!mounted) return false;
      _validateParticipants(conversation, [message], requireOutgoing: true);
      final seen = before.messages.map((item) => item.id).toSet();
      final merged = [...before.messages, if (seen.add(message.id)) message]
        ..sort(_compareMessages);
      state = before.copyWith(
        messages: List.unmodifiable(merged),
        action: null,
        actionTargetId: null,
        transientFailure: null,
        failedDraft: null,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = before.copyWith(
        action: null,
        actionTargetId: null,
        transientFailure: _asFailure(error, '消息发送失败，请使用原请求重试。'),
        failedDraft: draft,
      );
      return false;
    }
  }

  Future<bool> retrySend() async {
    final draft = state.failedDraft;
    if (draft == null) return false;
    return send(
      content: draft.content,
      mediaId: draft.mediaId,
      stickerAssetId: draft.stickerAssetId,
    );
  }

  void abandonFailedDraft() {
    if (state.isMutating || state.failedDraft == null) return;
    state = state.copyWith(failedDraft: null, transientFailure: null);
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
      state = before.copyWith(
        conversation: updated,
        messages: accept ? before.messages : const [],
        cursor: accept ? before.cursor : null,
        hasMore: accept && before.hasMore,
        action: null,
        actionTargetId: null,
        transientFailure: null,
      );
      await _notifyUnreadChanged();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = before.copyWith(
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
      state = before.copyWith(
        conversation: updated,
        action: null,
        actionTargetId: null,
        transientFailure: null,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = before.copyWith(
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
        state = before.copyWith(
          messages: const [],
          action: null,
          actionTargetId: null,
          transientFailure: null,
          conversationCanceled: true,
        );
      } else {
        state = before.copyWith(
          messages: before.messages
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
      state = before.copyWith(
        action: null,
        actionTargetId: null,
        transientFailure: _asFailure(error, '消息撤回失败，请重试。'),
      );
      return false;
    }
  }

  Future<void> _markLatestIncomingRead() async {
    final conversation = state.conversation;
    if (conversation == null || conversation.unreadCount <= 0) return;
    final incoming = state.messages
        .where((message) => message.senderId == conversation.otherUser.id)
        .lastOrNull;
    if (incoming == null ||
        incoming.id == _lastMarkedReadId ||
        _markReadInFlight != null) {
      return;
    }
    final operation = _repository.markRead(
      conversationId: _conversationId,
      throughMessageId: incoming.id,
    );
    _markReadInFlight = operation;
    try {
      await operation;
      if (!mounted) return;
      _lastMarkedReadId = incoming.id;
      state = state.copyWith(
        conversation: state.conversation?.copyWith(unreadCount: 0),
      );
      await _notifyUnreadChanged();
    } on Object {
      // 保留服务端未读事实；下次增量轮询或显式刷新会再次尝试。
    } finally {
      _markReadInFlight = null;
    }
  }

  Future<void> _notifyUnreadChanged() async {
    try {
      await _onUnreadChanged?.call();
    } on Object {
      // 会话操作已经成功，角标校准失败不回滚业务结果。
    }
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
        throw const ApiFailure(userMessage: '消息参与者与当前会话不匹配，已停止展示。');
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
    });
