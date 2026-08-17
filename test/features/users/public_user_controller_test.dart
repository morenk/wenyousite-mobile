import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

void main() {
  test('资料加载后只请求创建主题，其他允许内容首次切换时才加载', () async {
    final repository = _FakePublicUserRepository();
    final controller = PublicUserController(
      repository,
      'user-1',
      autoStart: false,
    );

    await controller.load();

    expect(controller.state.phase, PublicUserPhase.ready);
    expect(controller.state.created.phase, PublicUserContentPhase.ready);
    expect(repository.createdCalls, 1);
    expect(repository.playedCalls, 0);
    expect(repository.replyCalls, 0);
    expect(repository.bookmarkCalls, 0);

    await controller.selectTab(PublicUserContentTab.played);
    await controller.selectTab(PublicUserContentTab.replies);
    await controller.selectTab(PublicUserContentTab.bookmarks);

    expect(repository.playedCalls, 1);
    expect(repository.replyCalls, 1);
    expect(repository.bookmarkCalls, 1);
    expect(controller.state.bookmarks.phase, PublicUserContentPhase.ready);
  });

  test('隐私开关关闭的内容不出现在可用页签且不会发请求', () async {
    final repository = _FakePublicUserRepository(
      profile: _profile(
        showRecentReplies: false,
        showPlayedThreads: false,
        showBookmarks: false,
      ),
    );
    final controller = PublicUserController(
      repository,
      'user-1',
      autoStart: false,
    );

    await controller.load();
    await controller.selectTab(PublicUserContentTab.replies);

    expect(controller.state.availableTabs, [PublicUserContentTab.created]);
    expect(controller.state.activeTab, PublicUserContentTab.created);
    expect(repository.replyCalls, 0);
  });

  test('本人内容模式不读取公开资料并允许按需加载全部内容', () async {
    final repository = _FakePublicUserRepository(
      profile: _profile(
        showRecentReplies: false,
        showPlayedThreads: false,
        showBookmarks: false,
      ),
    );
    final controller = PublicUserController(
      repository,
      'user-1',
      selfContentOnly: true,
      autoStart: false,
    );

    await controller.load();
    await controller.selectTab(PublicUserContentTab.played);
    await controller.selectTab(PublicUserContentTab.replies);
    await controller.selectTab(PublicUserContentTab.bookmarks);

    expect(controller.state.availableTabs, PublicUserContentTab.values);
    expect(controller.state.activityPhase, PublicUserActivityPhase.ready);
    expect(repository.fetchUserCalls, 0);
    expect(repository.activityCalls, 1);
    expect(repository.createdCalls, 1);
    expect(repository.playedCalls, 1);
    expect(repository.replyCalls, 1);
    expect(repository.bookmarkCalls, 1);
  });

  test('主题分页按 ID 去重，cursor 失效后重新加载第一页', () async {
    var firstPageCalls = 0;
    final repository = _FakePublicUserRepository(
      onCreated: (cursor) async {
        if (cursor == 'next') {
          throw const ApiFailure(
            userMessage: '列表位置已失效，正在重新加载。',
            businessCode: 40007,
          );
        }
        firstPageCalls += 1;
        return CursorPage(
          items: [
            firstPageCalls == 1
                ? _thread('thread-1', '第一页')
                : _thread('thread-2', '恢复页'),
          ],
          cursor: 'next',
          hasMore: true,
        );
      },
    );
    final controller = PublicUserController(
      repository,
      'user-1',
      autoStart: false,
    );

    await controller.load();
    await controller.loadMoreActive();

    expect(firstPageCalls, 2);
    expect(controller.state.created.items.single.id, 'thread-2');
    expect(controller.state.created.failure, isNull);
    expect(controller.state.created.isLoadingMore, isFalse);
  });
}

class _FakePublicUserRepository implements PublicUserRepository {
  _FakePublicUserRepository({PublicUserProfileModel? profile, this.onCreated})
    : profile = profile ?? _profile();

  final PublicUserProfileModel profile;
  final Future<CursorPage<PublicUserThreadModel>> Function(String? cursor)?
  onCreated;
  int createdCalls = 0;
  int playedCalls = 0;
  int replyCalls = 0;
  int bookmarkCalls = 0;
  int fetchUserCalls = 0;
  int activityCalls = 0;

  @override
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) async {
    activityCalls += 1;
    return const PublicUserActivitySummary(
      momentCount: 3,
      createdThreadCount: 2,
      playedThreadCount: 1,
      replyCount: 4,
    );
  }

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async {
    fetchUserCalls += 1;
    return profile;
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) {
    createdCalls += 1;
    return onCreated?.call(cursor) ??
        Future.value(
          CursorPage(
            items: [_thread('thread-created', '创建主题')],
            hasMore: false,
          ),
        );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    playedCalls += 1;
    return CursorPage(
      items: [_thread('thread-played', '参与主题')],
      hasMore: false,
    );
  }

  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) async {
    replyCalls += 1;
    return [_reply];
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    bookmarkCalls += 1;
    return CursorPage(
      items: [_thread('thread-bookmark', '收藏主题')],
      hasMore: false,
    );
  }
}

PublicUserProfileModel _profile({
  bool showRecentReplies = true,
  bool showPlayedThreads = true,
  bool showBookmarks = true,
}) {
  return PublicUserProfileModel(
    id: 'user-1',
    username: '温柔测试员',
    level: 4,
    followingCount: 7,
    followerCount: 9,
    receivedTipTotal: '18',
    receivedTipCount: 6,
    showRecentReplies: showRecentReplies,
    showPlayedThreads: showPlayedThreads,
    showBookmarks: showBookmarks,
    isFollowing: false,
    isFollowedBy: false,
    isBlocked: false,
    isBlockedBy: false,
    isDeactivated: false,
  );
}

PublicUserThreadModel _thread(String id, String title) {
  return PublicUserThreadModel(
    id: id,
    title: title,
    categorySlug: 'RPG',
    status: PublicUserThreadStatus.recruiting,
    isPrivate: false,
    ownerName: '温柔测试员',
    ownerLevel: 4,
    createdAt: DateTime.utc(2026, 8, 10),
    memberCount: 5,
    postCount: 12,
  );
}

final _reply = PublicUserReplyModel(
  id: 'reply-1',
  threadId: 'thread-1',
  threadTitle: '星海旅团',
  subthreadId: 'subthread-1',
  subthreadTitle: '主线',
  preview: '最近回复',
  createdAt: DateTime.utc(2026, 8, 10),
  parentPostId: 'floor-1',
);
