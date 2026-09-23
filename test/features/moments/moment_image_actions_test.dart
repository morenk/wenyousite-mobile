import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_comment_body.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/data/sticker_repository.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

void main() {
  testWidgets('动态正文当前图片可从原图页添加到表情收藏', (tester) async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: fixture.container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: MomentGallery(
              momentId: 'moment-1',
              images: [
                MomentMedia(
                  id: 'media-1',
                  url: 'https://cdn.example.com/one.png',
                ),
                MomentMedia(
                  id: 'media-2',
                  url: 'https://cdn.example.com/two.png',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('moment-detail-image')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    tester
        .widget<PageView>(find.byType(PageView).last)
        .controller!
        .jumpToPage(1);
    await tester.pump();
    await _addCurrentImageToStickers(tester);

    final source = fixture.repository.sources.single;
    expect(source, isA<StickerMomentImageSource>());
    expect((source as StickerMomentImageSource).momentId, 'moment-1');
    expect(source.mediaId, 'media-2');
  });

  testWidgets('动态评论图片可从原图页添加到表情收藏', (tester) async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: fixture.container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentBody(
              comment: MomentComment(
                id: 'comment-1',
                momentId: 'moment-1',
                author: _author,
                media: const MomentMedia(
                  id: 'comment-media-1',
                  url: 'https://cdn.example.com/comment.png',
                ),
                deleted: false,
                canDelete: false,
                createdAt: DateTime.utc(2026, 9, 3),
              ),
              busy: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('moment-comment-image-comment-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await _addCurrentImageToStickers(tester);

    final source = fixture.repository.sources.single;
    expect(source, isA<StickerMomentCommentImageSource>());
    expect(
      (source as StickerMomentCommentImageSource).momentCommentId,
      'comment-1',
    );
    expect(source.mediaId, 'comment-media-1');
  });

  testWidgets('动态根评论图片同行空白长按打开评论操作', (tester) async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: fixture.container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentBody(
              comment: MomentComment(
                id: 'comment-blank-long-press',
                momentId: 'moment-1',
                author: _author,
                media: const MomentMedia(
                  id: 'comment-media-blank-long-press',
                  url: 'https://cdn.example.com/comment.webp',
                  thumbnailUrl: 'https://cdn.example.com/comment-thumb.webp',
                  animated: true,
                  width: 120,
                  height: 80,
                ),
                deleted: false,
                canDelete: true,
                createdAt: DateTime.utc(2026, 9, 3),
              ),
              busy: false,
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final imageRect = tester.getRect(
      find.byKey(const Key('moment-comment-image-comment-blank-long-press')),
    );
    final cardRect = tester.getRect(
      find.byKey(const Key('moment-comment-card-comment-blank-long-press')),
    );
    final blankPosition = Offset(imageRect.right + 24, imageRect.center.dy);
    expect(blankPosition.dx, lessThan(cardRect.right));

    await tester.longPressAt(blankPosition);
    await tester.pump();

    expect(
      find.byKey(
        const Key('moment-comment-action-comment-blank-long-press-delete'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('动态评论只有头像可进入作者个人主页', (tester) async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: MomentCommentBody(
              comment: MomentComment(
                id: 'comment-author-target',
                momentId: 'moment-1',
                author: _author,
                content: '评论正文',
                deleted: false,
                canDelete: false,
                createdAt: DateTime.utc(2026, 9, 3),
              ),
              busy: false,
            ),
          ),
        ),
        GoRoute(
          name: 'user-profile',
          path: '/users/:userId',
          builder: (context, state) => const Scaffold(
            body: Text('个人主页', key: Key('profile-destination')),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: fixture.container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('温油'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-destination')), findsNothing);

    await tester.tap(
      find.byKey(
        const Key('moment-comment-author-avatar-comment-author-target'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-destination')), findsOneWidget);
  });

  testWidgets('动态根评论文字长按仍优先选字而不打开评论操作', (tester) async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);
    const content = '可选择的评论正文';
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: fixture.container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentBody(
              comment: MomentComment(
                id: 'comment-selectable-text',
                momentId: 'moment-1',
                author: _author,
                content: content,
                deleted: false,
                canDelete: true,
                createdAt: DateTime.utc(2026, 9, 3),
              ),
              busy: false,
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final paragraph = tester.renderObject<RenderParagraph>(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == content,
      ),
    );
    final glyph = paragraph
        .getBoxesForSelection(
          const TextSelection(baseOffset: 2, extentOffset: 3),
        )
        .single
        .toRect();
    await tester.longPressAt(paragraph.localToGlobal(glyph.center));
    await tester.pump();

    expect(
      find.byKey(
        const Key('moment-comment-action-comment-selectable-text-delete'),
      ),
      findsNothing,
    );
    expect(paragraph.selections, isNotEmpty);
  });
}

Future<void> _addCurrentImageToStickers(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('content-image-actions')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('添加到表情收藏'));
  await tester.pumpAndSettle();
  expect(find.text('已添加到表情收藏。'), findsOneWidget);
}

Future<_Fixture> _fixture() async {
  final repository = _StickerRepository();
  final container = ProviderContainer(
    overrides: [
      sessionControllerProvider.overrideWith(
        (ref) => SessionController(_TokenStore(), _SessionRemote()),
      ),
      stickersEnabledProvider.overrideWithValue(true),
      stickerRepositoryProvider.overrideWithValue(repository),
      stickerCollectionControllerProvider.overrideWith(
        (ref) => StickerCollectionController(
          repository,
          pollInterval: Duration.zero,
        ),
      ),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(
        const SessionTokens(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
        ),
      );
  return _Fixture(container, repository);
}

class _Fixture {
  const _Fixture(this.container, this.repository);

  final ProviderContainer container;
  final _StickerRepository repository;

  void dispose() => container.dispose();
}

class _StickerRepository implements StickerRepository {
  final sources = <StickerImportSource>[];

  @override
  Future<StickerCollection> fetchCollection() async => _collection;

  @override
  Future<StickerImport> fetchImport(String id) => throw UnimplementedError();

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) async {
    sources.add(source);
    return const StickerImport(
      id: 'import-1',
      status: StickerImportStatus.completed,
      favorite: _favorite,
      alreadySaved: false,
    );
  }

  @override
  Future<StickerCollection> remove(String favoriteId) =>
      throw UnimplementedError();

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) => throw UnimplementedError();
}

class _TokenStore implements TokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<SessionTokens?> read() async => null;

  @override
  Future<void> write(SessionTokens tokens) async {}
}

class _SessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}

const _author = MomentAuthor(id: 'user-1', username: '温油', level: 1);

const _asset = StickerAsset(
  id: 'asset-1',
  url: 'https://cdn.example.com/sticker.webp',
  thumbnailUrl: 'https://cdn.example.com/sticker-thumb.webp',
  width: 96,
  height: 96,
  animated: false,
  frameCount: 1,
  durationMs: 0,
);

const _favorite = UserSticker(
  id: 'favorite-1',
  position: 0,
  asset: _asset,
  markdown: '![表情](https://cdn.example.com/sticker.webp)',
);

const _collection = StickerCollection(
  version: 1,
  limit: 200,
  items: [_favorite],
  recent: [],
  pendingImports: [],
);
