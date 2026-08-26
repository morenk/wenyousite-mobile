import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

void main() {
  test('动态收藏夹只加载目标夹并按不透明 cursor 分页', () async {
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(
          items: [_card('moment-1')],
          cursor: 'opaque-next',
          hasMore: true,
        ),
        'opaque-next': CursorPage(items: [_card('moment-2')], hasMore: false),
      },
    );
    final controller = MomentBookmarkListController(
      repository,
      'folder-current',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    await controller.loadMore();

    expect(controller.state.items.map((item) => item.id), [
      'moment-1',
      'moment-2',
    ]);
    expect(repository.requests, [
      (folderId: 'folder-current', cursor: null),
      (folderId: 'folder-current', cursor: 'opaque-next'),
    ]);
  });

  test('移动后从当前夹移除并权威刷新', () async {
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(items: [_card('moment-1')], hasMore: false),
      },
    );
    final controller = MomentBookmarkListController(
      repository,
      'folder-current',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    repository.pages[null] = const CursorPage(items: [], hasMore: false);

    expect(
      await controller.move(controller.state.items.single, 'folder-next'),
      isTrue,
    );

    expect(repository.moves, [('moment-1', 'folder-next')]);
    expect(controller.state.items, isEmpty);
    expect(repository.requests.length, 2);
  });

  test('canInteract false 禁止移动但仍允许取消收藏', () async {
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(
          items: [_card('moment-1', canInteract: false)],
          hasMore: false,
        ),
      },
    );
    final controller = MomentBookmarkListController(
      repository,
      'folder-current',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    final card = controller.state.items.single;

    expect(await controller.move(card, 'folder-next'), isFalse);
    expect(controller.state.transientFailure?.userMessage, contains('无法移动'));
    repository.pages[null] = const CursorPage(items: [], hasMore: false);
    expect(await controller.remove(card), isTrue);

    expect(repository.moves, isEmpty);
    expect(repository.removes, ['moment-1']);
  });

  test('分页 cursor 失效时从当前收藏夹首页重载', () async {
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(
          items: [_card('moment-1')],
          cursor: 'expired',
          hasMore: true,
        ),
      },
      invalidCursor: 'expired',
    );
    final controller = MomentBookmarkListController(
      repository,
      'folder-current',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    await controller.loadMore();

    expect(repository.requests.map((request) => request.cursor), [
      null,
      'expired',
      null,
    ]);
    expect(controller.state.phase, MomentBookmarkListPhase.ready);
    expect(controller.state.isLoadingMore, isFalse);
  });
}

class _FakeRepository implements MomentBookmarkRepository {
  _FakeRepository({required this.pages, this.invalidCursor});

  final Map<String?, CursorPage<MomentCard>> pages;
  final String? invalidCursor;
  final List<({String folderId, String? cursor})> requests = [];
  final List<(String, String)> moves = [];
  final List<String> removes = [];

  @override
  Future<CursorPage<MomentCard>> fetchPage({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) async {
    requests.add((folderId: folderId, cursor: cursor));
    if (invalidCursor != null && cursor == invalidCursor) {
      throw const ApiFailure(businessCode: 40007, userMessage: '游标失效');
    }
    return pages[cursor]!;
  }

  @override
  Future<void> moveBookmark(String momentId, String folderId) async {
    moves.add((momentId, folderId));
  }

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  }) async {
    if (!active) removes.add(momentId);
    return MomentActionResult(momentId: momentId, count: 0, active: active);
  }

  @override
  Future<BookmarkFolderItem> createFolder(String name) =>
      throw UnimplementedError();

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() => throw UnimplementedError();
}

MomentCard _card(String id, {bool canInteract = true}) {
  return MomentCard(
    id: id,
    author: const MomentAuthor(id: 'user-1', username: '测试员', level: 1),
    title: '动态 $id',
    contentExcerpt: '',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.rose,
    imageCount: 0,
    likeCount: 0,
    commentCount: 0,
    bookmarkCount: 1,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: true,
    canInteract: canInteract,
    bookmarkFolderId: 'folder-current',
    createdAt: DateTime.utc(2026, 8, 27),
    updatedAt: DateTime.utc(2026, 8, 27),
  );
}
