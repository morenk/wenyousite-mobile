import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

enum SearchSectionPhase { idle, loading, ready, failed }

class SearchSectionState<T> {
  const SearchSectionState({
    this.phase = SearchSectionPhase.idle,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final SearchSectionPhase phase;
  final List<T> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final ApiFailure? failure;
}

class SearchState {
  const SearchState({
    this.query = '',
    this.activeTab = SearchResultTab.threads,
    this.overview = const SearchSectionState(),
    this.moments = const SearchSectionState(),
    this.threads = const SearchSectionState(),
    this.users = const SearchSectionState(),
    this.posts = const SearchSectionState(),
  });

  final String query;
  final SearchResultTab activeTab;
  final SearchSectionState<SearchOverviewResult> overview;
  final SearchSectionState<MomentCard> moments;
  final SearchSectionState<SearchThreadResult> threads;
  final SearchSectionState<SearchUserResult> users;
  final SearchSectionState<SearchPostResult> posts;

  bool get hasQuery => query.isNotEmpty;
  bool get isContentQueryValid => query.runes.length >= 2;

  SearchState copyWith({
    String? query,
    SearchResultTab? activeTab,
    SearchSectionState<SearchOverviewResult>? overview,
    SearchSectionState<MomentCard>? moments,
    SearchSectionState<SearchThreadResult>? threads,
    SearchSectionState<SearchUserResult>? users,
    SearchSectionState<SearchPostResult>? posts,
  }) {
    return SearchState(
      query: query ?? this.query,
      activeTab: activeTab ?? this.activeTab,
      overview: overview ?? this.overview,
      moments: moments ?? this.moments,
      threads: threads ?? this.threads,
      users: users ?? this.users,
      posts: posts ?? this.posts,
    );
  }
}

class ThreadPostSearchState {
  const ThreadPostSearchState({
    this.query = '',
    this.results = const SearchSectionState(),
  });

  final String query;
  final SearchSectionState<SearchPostResult> results;

  bool get hasQuery => query.isNotEmpty;
  bool get isQueryValid => query.runes.length >= 2;
}
