import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

enum ThreadTagManagementPhase { loading, ready, failed }

class ThreadTagManagementState {
  const ThreadTagManagementState({
    required this.phase,
    this.bootstrap,
    this.query = '',
    this.failure,
    this.isSearching = false,
    this.mutatingTagId,
    this.actionOutcome,
    this.actionRequestId,
    this.actionOutcomeFailure,
  });

  const ThreadTagManagementState.loading()
    : this(phase: ThreadTagManagementPhase.loading);

  final ThreadTagManagementPhase phase;
  final ThreadTagManagementBootstrap? bootstrap;
  final String query;
  final ApiFailure? failure;
  final bool isSearching;
  final String? mutatingTagId;
  final WriteOutcomeStatus? actionOutcome;
  final String? actionRequestId;
  final ApiFailure? actionOutcomeFailure;

  bool get isMutating => mutatingTagId != null;
  bool get isBusy => isSearching || isMutating;

  ThreadTagManagementState copyWith({
    ThreadTagManagementPhase? phase,
    Object? bootstrap = _unset,
    String? query,
    Object? failure = _unset,
    bool? isSearching,
    Object? mutatingTagId = _unset,
    Object? actionOutcome = _unset,
    Object? actionRequestId = _unset,
    Object? actionOutcomeFailure = _unset,
  }) {
    return ThreadTagManagementState(
      phase: phase ?? this.phase,
      bootstrap: identical(bootstrap, _unset)
          ? this.bootstrap
          : bootstrap as ThreadTagManagementBootstrap?,
      query: query ?? this.query,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      isSearching: isSearching ?? this.isSearching,
      mutatingTagId: identical(mutatingTagId, _unset)
          ? this.mutatingTagId
          : mutatingTagId as String?,
      actionOutcome: identical(actionOutcome, _unset)
          ? this.actionOutcome
          : actionOutcome as WriteOutcomeStatus?,
      actionRequestId: identical(actionRequestId, _unset)
          ? this.actionRequestId
          : actionRequestId as String?,
      actionOutcomeFailure: identical(actionOutcomeFailure, _unset)
          ? this.actionOutcomeFailure
          : actionOutcomeFailure as ApiFailure?,
    );
  }
}

enum TagThreadsPhase { loading, ready, failed }

enum TagThreadsRetryAction { refresh, loadMore }

class TagThreadsState {
  const TagThreadsState({
    required this.phase,
    this.tag,
    this.categories = const [],
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.failure,
    this.transientFailure,
    this.transientRetryAction = TagThreadsRetryAction.refresh,
    this.isRefreshing = false,
    this.isLoadingMore = false,
  });

  const TagThreadsState.loading() : this(phase: TagThreadsPhase.loading);

  final TagThreadsPhase phase;
  final TopicTagModel? tag;
  final List<HomeCategory> categories;
  final List<HomeThreadCardModel> items;
  final String? cursor;
  final bool hasMore;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final TagThreadsRetryAction transientRetryAction;
  final bool isRefreshing;
  final bool isLoadingMore;

  TagThreadsState copyWith({
    TagThreadsPhase? phase,
    Object? tag = _unset,
    List<HomeCategory>? categories,
    List<HomeThreadCardModel>? items,
    Object? cursor = _unset,
    bool? hasMore,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    TagThreadsRetryAction? transientRetryAction,
    bool? isRefreshing,
    bool? isLoadingMore,
  }) {
    return TagThreadsState(
      phase: phase ?? this.phase,
      tag: identical(tag, _unset) ? this.tag : tag as TopicTagModel?,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      transientRetryAction: transientRetryAction ?? this.transientRetryAction,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

const _unset = Object();
