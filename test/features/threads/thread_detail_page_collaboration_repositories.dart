import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import 'thread_detail_page_content_fixtures.dart';

class ThreadDetailPageTestFakePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async {
    return [
      PostDiscussionAuthor(
        userId: threadDetailPageTestAuthor.id,
        username: threadDetailPageTestAuthor.username,
        role: PostDiscussionAuthorRole.owner,
      ),
      PostDiscussionAuthor(
        userId: threadDetailPageTestPlayerAuthor.id,
        username: threadDetailPageTestPlayerAuthor.username,
        role: PostDiscussionAuthorRole.player,
      ),
    ];
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async => const [];
}

class ThreadDetailPageTestMutablePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  int floorCalls = 0;
  List<PostDiscussionAuthor> floorAuthors = [
    PostDiscussionAuthor(
      userId: threadDetailPageTestAuthor.id,
      username: threadDetailPageTestAuthor.username,
      role: PostDiscussionAuthorRole.owner,
    ),
    PostDiscussionAuthor(
      userId: threadDetailPageTestPlayerAuthor.id,
      username: threadDetailPageTestPlayerAuthor.username,
      role: PostDiscussionAuthorRole.player,
    ),
  ];

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async {
    floorCalls += 1;
    return floorAuthors;
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async => const [];
}

class ThreadDetailPageTestFakeHomeRepository implements HomeRepository {
  int threadCalls = 0;

  @override
  Future<List<ThreadCategory>> fetchCategories() async => const [
    ThreadCategory(id: 'category-rpg', slug: 'RPG', name: '角色扮演', sortOrder: 1),
  ];

  @override
  Future<CursorPage<ThreadFeedCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) async {
    threadCalls += 1;
    return CursorPage(items: [threadDetailPageTestHomeThread], hasMore: false);
  }
}

final threadDetailPageTestRecentFixtureTime = DateTime.utc(2026, 8, 1, 5, 23);

final threadDetailPageTestDetail = ThreadDetailModel(
  id: 'thread-1',
  title: '星海旅团',
  owner: threadDetailPageTestAuthor,
  categorySlug: 'RPG',
  status: ThreadDetailStatus.recruiting,
  isPrivate: false,
  isPinned: true,
  viewCount: 128,
  likeCount: 12,
  tipTotal: '8',
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tags: const [ThreadTagModel(id: 'tag-1', name: '太空歌剧')],
  subthreads: const [
    ThreadSubthreadModel(
      id: 'subthread-1',
      title: '主线',
      sortOrder: 1,
      postCount: 8,
      postingPolicyLabel: '参与者发言',
      body: ThreadBodyModel(
        markdown:
            '主线正文\n\n检定 [[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]',
        diceRolls: [
          ThreadDiceRollModel(
            nodeId: '550e8400-e29b-41d4-a716-446655440000',
            notation: '1d20',
            results: [16],
            total: 16,
          ),
        ],
      ),
    ),
    ThreadSubthreadModel(
      id: 'subthread-2',
      title: '支线',
      sortOrder: 2,
      postCount: 4,
      postingPolicyLabel: '玩家发言',
      body: ThreadBodyModel(markdown: '支线正文'),
    ),
  ],
  defaultSubthreadId: 'subthread-1',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: threadDetailPageTestRecentFixtureTime,
);

ThreadDetailModel threadDetailPageTestDetailWithTags(
  List<ThreadTagModel> tags,
) {
  return ThreadDetailModel(
    id: threadDetailPageTestDetail.id,
    title: threadDetailPageTestDetail.title,
    owner: threadDetailPageTestDetail.owner,
    categorySlug: threadDetailPageTestDetail.categorySlug,
    status: threadDetailPageTestDetail.status,
    isPrivate: threadDetailPageTestDetail.isPrivate,
    isPinned: threadDetailPageTestDetail.isPinned,
    viewCount: threadDetailPageTestDetail.viewCount,
    likeCount: threadDetailPageTestDetail.likeCount,
    tipTotal: threadDetailPageTestDetail.tipTotal,
    memberCount: threadDetailPageTestDetail.memberCount,
    playerCount: threadDetailPageTestDetail.playerCount,
    postCount: threadDetailPageTestDetail.postCount,
    tags: tags,
    subthreads: threadDetailPageTestDetail.subthreads,
    defaultSubthreadId: threadDetailPageTestDetail.defaultSubthreadId,
    createdAt: threadDetailPageTestDetail.createdAt,
    updatedAt: threadDetailPageTestDetail.updatedAt,
  );
}

ThreadDetailModel threadDetailPageTestCopyThreadDetail(
  ThreadDetailModel source, {
  required List<ThreadSubthreadModel> subthreads,
  String? title,
  bool? isPrivate,
  bool? isCurrentUserPlayer,
  bool? isCurrentUserOwner,
  String? currentUserId,
  int? likeCount,
  int? postCount,
}) {
  return ThreadDetailModel(
    id: source.id,
    title: title ?? source.title,
    owner: source.owner,
    categorySlug: source.categorySlug,
    status: source.status,
    isPrivate: isPrivate ?? source.isPrivate,
    isPinned: source.isPinned,
    viewCount: source.viewCount,
    likeCount: likeCount ?? source.likeCount,
    isLiked: source.isLiked,
    isBookmarked: source.isBookmarked,
    bookmarkId: source.bookmarkId,
    hasAutomaticUpdates: source.hasAutomaticUpdates,
    canManageThread: source.canManageThread,
    isCurrentUserPlayer: isCurrentUserPlayer ?? source.isCurrentUserPlayer,
    isCurrentUserOwner: isCurrentUserOwner ?? source.isCurrentUserOwner,
    currentUserId: currentUserId ?? source.currentUserId,
    tipTotal: source.tipTotal,
    memberCount: source.memberCount,
    playerCount: source.playerCount,
    postCount: postCount ?? source.postCount,
    tags: source.tags,
    subthreads: subthreads,
    defaultSubthreadId: subthreads.firstOrNull?.id,
    createdAt: source.createdAt,
    updatedAt: source.updatedAt,
  );
}

final threadDetailPageTestManagerDetail = ThreadDetailModel(
  id: 'thread-1',
  title: '星海旅团',
  owner: threadDetailPageTestAuthor,
  categorySlug: 'RPG',
  status: ThreadDetailStatus.recruiting,
  isPrivate: false,
  isPinned: true,
  viewCount: 128,
  likeCount: 12,
  tipTotal: '8',
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tags: const [],
  subthreads: const [
    ThreadSubthreadModel(
      id: 'subthread-1',
      title: '主线',
      sortOrder: 1,
      postCount: 8,
      postingPolicyLabel: '参与者发言',
      body: ThreadBodyModel(markdown: '主线正文', postId: 'body-1', version: 5),
    ),
  ],
  defaultSubthreadId: 'subthread-1',
  canManageThread: true,
  hasAutomaticUpdates: true,
  currentUserId: 'collaborator-1',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: threadDetailPageTestRecentFixtureTime,
);

const threadDetailPageTestAuthor = ThreadAuthorModel(
  id: 'user-1',
  username: '温柔测试员',
  level: 3,
);

const threadDetailPageTestPlayerAuthor = ThreadAuthorModel(
  id: 'user-2',
  username: '下一位接力者',
  level: 5,
);

const threadDetailPageTestTokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

SessionTokens threadDetailPageTestTokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'e30.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class ThreadDetailPageTestMemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class ThreadDetailPageTestFakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      threadDetailPageTestTokens;
}

class ThreadDetailPageTestFakeThreadSubscriptionRepository
    implements ThreadSubscriptionRepository {
  @override
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(
    String threadId,
  ) async => const [];

  @override
  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  }) async => const [];

  @override
  Future<ThreadSubscriptionRecord> create({
    required String threadId,
    required ThreadSubscriptionType type,
    String? targetUserId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String subscriptionId) {
    throw UnimplementedError();
  }
}

class ThreadDetailPageTestFakeThreadInteractionRepository
    implements ThreadInteractionRepository {
  @override
  Future<String> createBookmark(String threadId, String folderId) async =>
      'bookmark-1';

  @override
  Future<int> like(String threadId) async => 13;

  @override
  Future<void> removeBookmark(String bookmarkId) async {}

  @override
  Future<int> unlike(String threadId) async => 12;
}

class ThreadDetailPageTestFakePostRepository implements PostRepository {
  final List<String> removedIds = [];
  final List<({String postId, bool pinned})> pinRequests = [];

  @override
  Future<void> remove(String postId) async => removedIds.add(postId);

  @override
  Future<void> setPinned(String postId, {required bool pinned}) async {
    pinRequests.add((postId: postId, pinned: pinned));
  }

  @override
  Future<PostItem> fetchPost(String postId) async {
    if (postId != 'body-1') throw UnsupportedError('unused');
    final timestamp = DateTime.utc(2026, 8, 10, 9);
    return PostItem(
      id: postId,
      threadId: 'thread-1',
      subthreadId: 'subthread-1',
      author: const PostAuthor(id: 'collaborator-1', username: '协作者', level: 4),
      content: '主线正文',
      version: 5,
      createdAt: timestamp,
      updatedAt: timestamp,
      isBody: true,
      isDeleted: false,
    );
  }

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) => throw UnsupportedError('unused');

  @override
  Future<PostItem> create(PostCreateInput input) =>
      throw UnsupportedError('unused');

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) => throw UnsupportedError('unused');

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) => throw UnsupportedError('unused');
}

class ThreadDetailPageTestCreatingPostRepository implements PostRepository {
  final List<PostCreateInput> createInputs = [];

  @override
  Future<PostItem> create(PostCreateInput input) async {
    createInputs.add(input);
    final createdAt = DateTime.utc(2026, 8, 10, 9);
    return PostItem(
      id: 'floor-created',
      threadId: 'thread-1',
      subthreadId: input.subthreadId,
      author: const PostAuthor(id: 'user-1', username: '温柔测试员', level: 3),
      content: input.content,
      version: 1,
      createdAt: createdAt,
      updatedAt: createdAt,
      isBody: false,
      isDeleted: false,
      floorNumber: 2,
      parentPostId: input.parentPostId,
      replyToPostId: input.replyToPostId,
    );
  }

  @override
  Future<PostItem> fetchPost(String postId) => throw UnsupportedError('unused');

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) => throw UnsupportedError('unused');

  @override
  Future<void> remove(String postId) => throw UnsupportedError('unused');

  @override
  Future<void> setPinned(String postId, {required bool pinned}) =>
      throw UnsupportedError('unused');

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) => throw UnsupportedError('unused');

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) => throw UnsupportedError('unused');
}

final threadDetailPageTestMainFloor = ThreadFloorModel(
  id: 'floor-1',
  floorNumber: 1,
  author: threadDetailPageTestAuthor,
  body: const ThreadBodyModel(markdown: '第一层内容'),
  createdAt: threadDetailPageTestRecentFixtureTime,
  isDeleted: false,
  replyCount: 1,
  replies: [
    ThreadReplyModel(
      id: 'reply-1',
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '收到，准备出发。'),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
      replyToUsername: '温柔测试员',
    ),
  ],
);

final threadDetailPageTestLongMainFloor = ThreadFloorModel(
  id: 'floor-long',
  floorNumber: 1,
  author: threadDetailPageTestAuthor,
  body: const ThreadBodyModel(
    markdown: '''第一层内容

舷窗外的群星缓慢后退。温柔测试员把航线重新标在纸图上，让后来者不必猜测故事从哪里继续。

引擎发出低沉而均匀的嗡鸣，甲板上的每个人都在等待下一位接力者写下选择。

远处的信标终于亮起，新的章节也在这一刻展开。''',
  ),
  createdAt: threadDetailPageTestRecentFixtureTime,
  isDeleted: false,
  replyCount: 1,
  replies: [
    ThreadReplyModel(
      id: 'reply-long',
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '收到，准备出发。'),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
      replyToUsername: '温柔测试员',
    ),
  ],
);

final threadDetailPageTestLongSecondFloor = ThreadFloorModel(
  id: 'floor-long-2',
  floorNumber: 2,
  author: threadDetailPageTestPlayerAuthor,
  body: const ThreadBodyModel(
    markdown: '''第二层内容

舱门在身后合拢。下一位接力者没有解释来意，只把一页写满坐标的纸放在桌上。''',
  ),
  createdAt: threadDetailPageTestRecentFixtureTime,
  isDeleted: false,
  replyCount: 2,
  replies: [
    ThreadReplyModel(
      id: 'reply-long-2',
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '这条讨论不应插进接力正文。'),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
      replyToUsername: '下一位接力者',
    ),
  ],
);
