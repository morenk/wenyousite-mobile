import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_pending_media.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

enum DirectConversationListPhase { loading, ready, failed }

class DirectConversationListState {
  const DirectConversationListState({
    required this.phase,
    required this.view,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.failure,
    this.transientFailure,
  });

  const DirectConversationListState.loading(DirectConversationView view)
    : this(phase: DirectConversationListPhase.loading, view: view);

  final DirectConversationListPhase phase;
  final DirectConversationView view;
  final List<DirectConversation> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;

  DirectConversationListState copyWith({
    DirectConversationListPhase? phase,
    List<DirectConversation>? items,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    Object? failure = _unset,
    Object? transientFailure = _unset,
  }) {
    return DirectConversationListState(
      phase: phase ?? this.phase,
      view: view,
      items: items ?? this.items,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
    );
  }
}

class DirectUnreadState {
  const DirectUnreadState({
    this.counts = const DirectUnreadCounts(
      unreadMessages: 0,
      pendingRequests: 0,
    ),
    this.isLoading = false,
    this.failure,
  });

  final DirectUnreadCounts counts;
  final bool isLoading;
  final ApiFailure? failure;
}

enum DirectConversationPhase { loading, ready, failed }

enum DirectConversationAction {
  sending,
  accepting,
  declining,
  archiving,
  markingRead,
  recalling,
}

class DirectConversationState {
  const DirectConversationState({
    required this.phase,
    this.conversation,
    this.messages = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingOlder = false,
    this.isRefreshing = false,
    this.failure,
    this.transientFailure,
    this.action,
    this.actionTargetId,
    this.failedDraft,
    this.sendFailures = const {},
    this.pendingMedia = const {},
    this.conversationCanceled = false,
  });

  const DirectConversationState.loading()
    : this(phase: DirectConversationPhase.loading);

  final DirectConversationPhase phase;
  final DirectConversation? conversation;
  final List<DirectMessage> messages;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingOlder;
  final bool isRefreshing;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final DirectConversationAction? action;
  final String? actionTargetId;
  final DirectMessageDraft? failedDraft;
  final Map<String, ApiFailure> sendFailures;
  final Map<String, PendingDirectMessageMedia> pendingMedia;
  final bool conversationCanceled;

  bool get isMutating => action != null;

  DirectConversationState copyWith({
    DirectConversationPhase? phase,
    Object? conversation = _unset,
    List<DirectMessage>? messages,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoadingOlder,
    bool? isRefreshing,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    Object? action = _unset,
    Object? actionTargetId = _unset,
    Object? failedDraft = _unset,
    Map<String, ApiFailure>? sendFailures,
    Map<String, PendingDirectMessageMedia>? pendingMedia,
    bool? conversationCanceled,
  }) {
    return DirectConversationState(
      phase: phase ?? this.phase,
      conversation: identical(conversation, _unset)
          ? this.conversation
          : conversation as DirectConversation?,
      messages: messages ?? this.messages,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      action: identical(action, _unset)
          ? this.action
          : action as DirectConversationAction?,
      actionTargetId: identical(actionTargetId, _unset)
          ? this.actionTargetId
          : actionTargetId as String?,
      failedDraft: identical(failedDraft, _unset)
          ? this.failedDraft
          : failedDraft as DirectMessageDraft?,
      sendFailures: sendFailures ?? this.sendFailures,
      pendingMedia: pendingMedia ?? this.pendingMedia,
      conversationCanceled: conversationCanceled ?? this.conversationCanceled,
    );
  }
}

enum DirectConversationTargetPhase { loading, ready, failed }

class DirectConversationTargetState {
  const DirectConversationTargetState({
    required this.phase,
    this.user,
    this.lookup,
    this.failure,
    this.isSending = false,
    this.failedDraft,
  });

  const DirectConversationTargetState.loading()
    : this(phase: DirectConversationTargetPhase.loading);

  final DirectConversationTargetPhase phase;
  final DirectMessageUser? user;
  final DirectConversationLookup? lookup;
  final ApiFailure? failure;
  final bool isSending;
  final DirectMessageDraft? failedDraft;

  DirectConversationTargetState copyWith({
    DirectConversationTargetPhase? phase,
    Object? user = _unset,
    Object? lookup = _unset,
    Object? failure = _unset,
    bool? isSending,
    Object? failedDraft = _unset,
  }) {
    return DirectConversationTargetState(
      phase: phase ?? this.phase,
      user: identical(user, _unset) ? this.user : user as DirectMessageUser?,
      lookup: identical(lookup, _unset)
          ? this.lookup
          : lookup as DirectConversationLookup?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      isSending: isSending ?? this.isSending,
      failedDraft: identical(failedDraft, _unset)
          ? this.failedDraft
          : failedDraft as DirectMessageDraft?,
    );
  }
}

const _unset = Object();
