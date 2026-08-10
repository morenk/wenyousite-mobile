import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

const maxThreadTagCount = 5;
const maxTagNameLength = 20;

final RegExp _tagNamePattern = RegExp(r'^[a-zA-Z0-9_\u4e00-\u9fff#]+$');

String normalizeTagName(String value) => value.trim();

String? validateTagName(String value) {
  final normalized = normalizeTagName(value);
  if (normalized.isEmpty) return '请输入标签名称';
  if (normalized.length > maxTagNameLength) return '标签名称不能超过 20 个字符';
  if (!_tagNamePattern.hasMatch(normalized)) {
    return '只能使用中英文、数字、下划线和 #';
  }
  return null;
}

class TopicTagModel {
  const TopicTagModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    this.color,
    this.description,
  });

  final String id;
  final String name;
  final String? color;
  final String? description;
  final int sortOrder;
  final bool isActive;
}

class ThreadTagManagementBootstrap {
  const ThreadTagManagementBootstrap({
    required this.threadId,
    required this.threadTitle,
    required this.tags,
    required this.suggestions,
  });

  final String threadId;
  final String threadTitle;
  final List<TopicTagModel> tags;
  final List<TopicTagModel> suggestions;

  ThreadTagManagementBootstrap copyWith({
    List<TopicTagModel>? tags,
    List<TopicTagModel>? suggestions,
  }) {
    return ThreadTagManagementBootstrap(
      threadId: threadId,
      threadTitle: threadTitle,
      tags: tags ?? this.tags,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

enum ThreadTagManagementPhase { loading, ready, failed }

class ThreadTagManagementState {
  const ThreadTagManagementState({
    required this.phase,
    this.bootstrap,
    this.query = '',
    this.failure,
    this.isSearching = false,
    this.mutatingTagId,
  });

  const ThreadTagManagementState.loading()
    : this(phase: ThreadTagManagementPhase.loading);

  final ThreadTagManagementPhase phase;
  final ThreadTagManagementBootstrap? bootstrap;
  final String query;
  final ApiFailure? failure;
  final bool isSearching;
  final String? mutatingTagId;

  bool get isMutating => mutatingTagId != null;
  bool get isBusy => isSearching || isMutating;

  ThreadTagManagementState copyWith({
    ThreadTagManagementPhase? phase,
    Object? bootstrap = _unset,
    String? query,
    Object? failure = _unset,
    bool? isSearching,
    Object? mutatingTagId = _unset,
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
    );
  }
}

class TagThreadsBootstrap {
  const TagThreadsBootstrap({
    required this.tag,
    required this.categories,
    required this.page,
  });

  final TopicTagModel tag;
  final List<HomeCategory> categories;
  final CursorPage<HomeThreadCardModel> page;
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
