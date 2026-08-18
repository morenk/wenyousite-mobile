import 'package:wenyousite_mobile/core/models/thread_feed_models.dart';

enum SearchResultTab {
  overview('综合', '一次查看主题、用户和正文摘要'),
  moments('动态', '搜索公开动态标题与正文'),
  threads('主题帖', '搜索公开主题标题'),
  users('用户', '搜索未注销用户名'),
  posts('楼层内容', '搜索公开楼层与楼中楼');

  const SearchResultTab(this.label, this.description);

  final String label;
  final String description;
}

typedef SearchThreadResult = ThreadFeedCardModel;

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

class SearchOverviewResult {
  const SearchOverviewResult({
    required this.threads,
    required this.users,
    required this.posts,
  });

  final List<SearchThreadResult> threads;
  final List<SearchUserResult> users;
  final List<SearchPostResult> posts;

  bool get isEmpty => threads.isEmpty && users.isEmpty && posts.isEmpty;
}
