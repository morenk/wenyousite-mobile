import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum SearchResultTab {
  threads('主题', '搜索公开主题标题'),
  users('用户', '搜索未注销用户名'),
  posts('正文', '搜索公开楼层与楼中楼');

  const SearchResultTab(this.label, this.description);

  final String label;
  final String description;
}

enum SearchSectionPhase { idle, loading, ready, failed }

class SearchThreadResult {
  const SearchThreadResult({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    required this.memberCount,
    required this.playerCount,
    required this.postCount,
    required this.coverImageUrls,
    this.categorySlug,
    this.ownerAvatarUrl,
  });

  final String id;
  final String title;
  final String? categorySlug;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final DateTime createdAt;
  final int memberCount;
  final int playerCount;
  final int postCount;
  final List<String> coverImageUrls;
}

class SearchUserResult {
  const SearchUserResult({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
}

class SearchPostResult {
  const SearchPostResult({
    required this.id,
    required this.content,
    required this.preview,
    required this.authorId,
    required this.authorName,
    required this.threadId,
    required this.threadTitle,
    required this.subthreadId,
    required this.subthreadTitle,
    required this.createdAt,
    this.floorNumber,
    this.parentPostId,
  });

  final String id;
  final int? floorNumber;
  final String? parentPostId;
  final String content;
  final String preview;
  final String authorId;
  final String authorName;
  final String threadId;
  final String threadTitle;
  final String subthreadId;
  final String subthreadTitle;
  final DateTime createdAt;
}

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
    this.threads = const SearchSectionState(),
    this.users = const SearchSectionState(),
    this.posts = const SearchSectionState(),
  });

  final String query;
  final SearchResultTab activeTab;
  final SearchSectionState<SearchThreadResult> threads;
  final SearchSectionState<SearchUserResult> users;
  final SearchSectionState<SearchPostResult> posts;

  bool get hasQuery => query.isNotEmpty;
  bool get isPostQueryValid => query.runes.length >= 2;

  SearchState copyWith({
    String? query,
    SearchResultTab? activeTab,
    SearchSectionState<SearchThreadResult>? threads,
    SearchSectionState<SearchUserResult>? users,
    SearchSectionState<SearchPostResult>? posts,
  }) {
    return SearchState(
      query: query ?? this.query,
      activeTab: activeTab ?? this.activeTab,
      threads: threads ?? this.threads,
      users: users ?? this.users,
      posts: posts ?? this.posts,
    );
  }
}
