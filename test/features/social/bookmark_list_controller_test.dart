import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

void main() {
  test('首次读取和加载更多按服务端游标拼接', () async {
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(
          items: [_item('bookmark-1'), _item('bookmark-2')],
          cursor: 'bookmark-2',
          hasMore: true,
        ),
        'bookmark-2': CursorPage(items: [_item('bookmark-3')], hasMore: false),
      },
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    await controller.loadMore();

    expect(controller.state.items.map((item) => item.bookmarkId), [
      'bookmark-1',
      'bookmark-2',
      'bookmark-3',
    ]);
    expect(repository.requestedCursors, [null, 'bookmark-2']);
    expect(controller.state.hasMore, isFalse);
  });

  test('取消尾项后游标回退到新的尾项并继续分页', () async {
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(
          items: [_item('bookmark-1'), _item('bookmark-2')],
          cursor: 'bookmark-2',
          hasMore: true,
        ),
        'bookmark-1': CursorPage(items: [_item('bookmark-3')], hasMore: false),
      },
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.removeBookmark('bookmark-2'), isTrue);
    expect(controller.state.cursor, 'bookmark-1');
    await controller.loadMore();

    expect(repository.removedIds, ['bookmark-2']);
    expect(repository.requestedCursors.last, 'bookmark-1');
    expect(controller.state.items.map((item) => item.bookmarkId), [
      'bookmark-1',
      'bookmark-3',
    ]);
  });

  test('取消失败保留条目与游标并显示请求 ID', () async {
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(
          items: [_item('bookmark-1')],
          cursor: 'bookmark-1',
          hasMore: true,
        ),
      },
      removeFailure: const ApiFailure(
        userMessage: '取消失败',
        requestId: 'bookmark-request-id',
      ),
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.removeBookmark('bookmark-1'), isFalse);

    expect(controller.state.items.single.bookmarkId, 'bookmark-1');
    expect(controller.state.cursor, 'bookmark-1');
    expect(controller.state.actionFailure?.requestId, 'bookmark-request-id');
  });

  test('加载更多期间不并发取消收藏', () async {
    final loadMore = Completer<CursorPage<BookmarkListItem>>();
    final repository = _FakeRepository(
      pages: {
        null: CursorPage(
          items: [_item('bookmark-1')],
          cursor: 'bookmark-1',
          hasMore: true,
        ),
      },
      loadMoreCompleter: loadMore,
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    final pending = controller.loadMore();
    expect(await controller.removeBookmark('bookmark-1'), isFalse);
    loadMore.complete(CursorPage(items: const [], hasMore: false));
    await pending;

    expect(repository.removedIds, isEmpty);
  });
}

class _FakeRepository implements BookmarkListRepository {
  _FakeRepository({
    required this.pages,
    this.removeFailure,
    this.loadMoreCompleter,
  });

  final Map<String?, CursorPage<BookmarkListItem>> pages;
  final ApiFailure? removeFailure;
  final Completer<CursorPage<BookmarkListItem>>? loadMoreCompleter;
  final List<String?> requestedCursors = [];
  final List<String> removedIds = [];

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    int limit = 20,
  }) async {
    requestedCursors.add(cursor);
    if (cursor != null && loadMoreCompleter != null) {
      return loadMoreCompleter!.future;
    }
    return pages[cursor]!;
  }

  @override
  Future<void> remove(String bookmarkId) async {
    if (removeFailure != null) throw removeFailure!;
    removedIds.add(bookmarkId);
  }
}

BookmarkListItem _item(String bookmarkId) {
  return BookmarkListItem(
    bookmarkId: bookmarkId,
    threadId: 'thread-$bookmarkId',
    title: '收藏 $bookmarkId',
    status: BookmarkedThreadStatus.recruiting,
    isPrivate: false,
    isPinned: false,
    ownerName: '骰子猫',
    ownerLevel: 3,
    createdAt: DateTime.utc(2026, 8, 1),
    memberCount: 4,
    postCount: 18,
    tipTotal: '9',
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);
