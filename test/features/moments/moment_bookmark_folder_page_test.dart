import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_bookmark_folder_page.dart';

void main() {
  testWidgets('关闭管理面板不写入，取消在途不能重复操作', (tester) async {
    final gate = Completer<void>();
    final repository = _PageRepository(card: _card('moment-1'))
      ..writeGate = gate;
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    final manage = find.byKey(const Key('moment-bookmark-manage-moment-1'));
    await tester.tap(manage);
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('取消收藏'))).pop();
    await tester.pumpAndSettle();
    expect(repository.moves, isEmpty);
    expect(repository.removes, isEmpty);

    await tester.tap(manage);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-bookmark-remove-moment-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widget<IconButton>(manage).onPressed, isNull);
    expect(
      find.descendant(
        of: manage,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    await tester.tap(manage);
    expect(repository.removes, ['moment-1']);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('已取消收藏。'), findsOneWidget);
  });

  testWidgets('移动失败只在选择弹窗报错，取消收藏失败仍有反馈', (tester) async {
    final repository = _PageRepository(card: _card('moment-1'))
      ..failWrites = true;
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-bookmark-manage-moment-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-bookmark-move-moment-1')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('bookmark-folder-picker-option-folder-next')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();
    expect(find.byType(WenyouFailureBanner), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    final context = tester.element(
      find.byKey(const Key('bookmark-folder-picker-confirm')),
    );
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-bookmark-manage-moment-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-bookmark-remove-moment-1')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('已取消收藏。'), findsNothing);
  });
  testWidgets('动态收藏卡片通过 48dp 更多操作移动到独立收藏夹', (tester) async {
    final repository = _PageRepository(card: _card('moment-1'));
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    final manage = find.byKey(const Key('moment-bookmark-manage-moment-1'));
    expect(manage, findsOneWidget);
    expect(tester.getSize(manage), const Size(48, 48));

    await tester.tap(manage);
    await tester.pumpAndSettle();
    expect(find.text('当前所在收藏夹'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-bookmark-move-moment-1')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('bookmark-folder-picker-option-folder-next')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();

    expect(repository.moves, [('moment-1', 'folder-next')]);
    expect(find.text('已移动到“稍后阅读”。'), findsOneWidget);
  });

  testWidgets('不可新增互动的动态禁止移动但仍可取消收藏', (tester) async {
    final repository = _PageRepository(
      card: _card('moment-locked', canInteract: false),
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('moment-bookmark-manage-moment-locked')),
    );
    await tester.pumpAndSettle();
    final move = tester.widget<ListTile>(
      find.byKey(const Key('moment-bookmark-move-moment-locked')),
    );
    expect(move.enabled, isFalse);

    await tester.tap(
      find.byKey(const Key('moment-bookmark-remove-moment-locked')),
    );
    await tester.pumpAndSettle();

    expect(repository.removes, ['moment-locked']);
    expect(repository.moves, isEmpty);
    expect(find.text('已取消收藏。'), findsOneWidget);
  });
}

Widget _app(_PageRepository repository) {
  return ProviderScope(
    overrides: [
      momentBookmarkRepositoryProvider.overrideWithValue(repository),
      bookmarkFolderCatalogProvider.overrideWith((ref, kind) => repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const MomentBookmarkFolderPage(
        folderId: 'folder-current',
        initialFolderName: '默认收藏夹',
      ),
    ),
  );
}

class _PageRepository implements MomentBookmarkRepository {
  _PageRepository({required this.card});

  final MomentCard card;
  final List<(String, String)> moves = [];
  final List<String> removes = [];
  bool failWrites = false;
  Completer<void>? writeGate;

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async => [
    BookmarkFolderItem(
      id: 'folder-current',
      name: '默认收藏夹',
      isDefault: true,
      bookmarkCount: 1,
      createdAt: DateTime.utc(2026, 8, 27),
    ),
    BookmarkFolderItem(
      id: 'folder-next',
      name: '稍后阅读',
      isDefault: false,
      bookmarkCount: 0,
      createdAt: DateTime.utc(2026, 8, 27),
    ),
  ];

  @override
  Future<CursorPage<MomentCard>> fetchPage({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) async => CursorPage(items: [card], hasMore: false);

  @override
  Future<void> moveBookmark(String momentId, String folderId) async {
    if (failWrites) {
      throw const ApiFailure(userMessage: '移动失败', httpStatus: 500);
    }
    moves.add((momentId, folderId));
  }

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  }) async {
    if (failWrites) {
      throw const ApiFailure(userMessage: '取消收藏失败', httpStatus: 500);
    }
    if (!active) removes.add(momentId);
    await writeGate?.future;
    return MomentActionResult(momentId: momentId, count: 0, active: active);
  }

  @override
  Future<BookmarkFolderItem> createFolder(String name) async {
    return BookmarkFolderItem(
      id: 'folder-created',
      name: name,
      isDefault: false,
      bookmarkCount: 0,
      createdAt: DateTime.utc(2026, 8, 27),
    );
  }
}

MomentCard _card(String id, {bool canInteract = true}) {
  return MomentCard(
    id: id,
    author: const MomentAuthor(id: 'user-1', username: '动态作者', level: 2),
    title: '收藏动态',
    contentExcerpt: '',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.lilac,
    imageCount: 0,
    likeCount: 1,
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
