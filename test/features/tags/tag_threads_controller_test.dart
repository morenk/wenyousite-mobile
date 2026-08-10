import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_threads_controller.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';

void main() {
  test('标签主题首屏和下一页按主题 ID 去重', () async {
    final repository = _FakeTagRepository();
    final controller = TagThreadsController(
      'tag-1',
      repository,
      autoStart: false,
    );

    await controller.loadInitial();
    await controller.loadMore();

    expect(controller.state.tag!.name, '太空歌剧');
    expect(controller.state.items.map((item) => item.id), [
      'thread-1',
      'thread-2',
    ]);
    expect(controller.state.hasMore, isFalse);
  });

  test('分页 cursor 失效时刷新标签事实和第一页', () async {
    final repository = _FakeTagRepository(
      loadMoreFailure: const ApiFailure(
        userMessage: '游标失效',
        businessCode: 40007,
      ),
    );
    final controller = TagThreadsController(
      'tag-1',
      repository,
      autoStart: false,
    );
    await controller.loadInitial();

    await controller.loadMore();

    expect(repository.initialCalls, 2);
    expect(controller.state.phase, TagThreadsPhase.ready);
    expect(controller.state.transientFailure, isNull);
  });
}

class _FakeTagRepository implements TagRepository {
  _FakeTagRepository({this.loadMoreFailure});

  final ApiFailure? loadMoreFailure;
  int initialCalls = 0;

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchTagThreads({
    required String tagId,
    String? cursor,
    int limit = 20,
  }) async {
    if (loadMoreFailure != null) throw loadMoreFailure!;
    return CursorPage(items: [_thread1, _thread2], hasMore: false);
  }

  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) async {
    initialCalls += 1;
    return TagThreadsBootstrap(
      tag: _tag,
      categories: const [
        HomeCategory(id: 'category-1', slug: 'RPG', name: '角色扮演', sortOrder: 1),
      ],
      page: CursorPage(items: [_thread1], cursor: 'next', hasMore: true),
    );
  }

  @override
  Future<TopicTagModel> addToThread({
    required String threadId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TopicTagModel> create(String name) {
    throw UnimplementedError();
  }

  @override
  Future<TopicTagModel> findById(String tagId) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadTagManagementBootstrap> loadManagement(String threadId) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeFromThread({
    required String threadId,
    required String tagId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<TopicTagModel>> search(String query) {
    throw UnimplementedError();
  }
}

const _tag = TopicTagModel(
  id: 'tag-1',
  name: '太空歌剧',
  sortOrder: 1,
  isActive: true,
);

final _thread1 = HomeThreadCardModel(
  id: 'thread-1',
  title: '星海旅团',
  status: HomeThreadStatus.recruiting,
  isPinned: false,
  ownerId: 'owner-1',
  ownerName: '楼主',
  ownerLevel: 1,
  tags: const [HomeThreadTag(id: 'tag-1', name: '太空歌剧')],
  coverImageUrls: const [],
  memberCount: 2,
  playerCount: 1,
  postCount: 3,
  tipTotal: '0',
  lastActivityAt: DateTime.utc(2026, 8, 10),
);

final _thread2 = HomeThreadCardModel(
  id: 'thread-2',
  title: '第二主题',
  status: HomeThreadStatus.closed,
  isPinned: false,
  ownerId: 'owner-2',
  ownerName: '协作者',
  ownerLevel: 2,
  tags: const [HomeThreadTag(id: 'tag-1', name: '太空歌剧')],
  coverImageUrls: const [],
  memberCount: 2,
  playerCount: 1,
  postCount: 3,
  tipTotal: '0',
  lastActivityAt: DateTime.utc(2026, 8, 10),
);
