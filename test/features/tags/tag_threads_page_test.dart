import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';
import 'package:wenyousite_mobile/features/tags/presentation/tag_threads_page.dart';

void main() {
  testWidgets('公开标签页展示标签事实并进入稳定主题路由', (tester) async {
    await _pumpPage(tester, _FakeTagRepository());

    expect(find.text('#太空歌剧'), findsWidgets);
    expect(find.textContaining('演绎'), findsOneWidget);
    expect(find.textContaining('DEDUCTION'), findsNothing);
    expect(find.byKey(const Key('tag-thread-thread-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tag-thread-thread-1')));
    await tester.pumpAndSettle();
    expect(find.text('主题详情占位'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 标签主题页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 860);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _FakeTagRepository());

      expect(tester.takeException(), isNull);
      expect(find.text('已加载 1 个主题'), findsOneWidget);
    });
  }
}

Future<void> _pumpPage(WidgetTester tester, TagRepository repository) async {
  final container = ProviderContainer(
    overrides: [tagRepositoryProvider.overrideWithValue(repository)],
  );
  final router = GoRouter(
    initialLocation: '/tags/tag-1',
    routes: [
      GoRoute(
        path: '/tags/:tagId',
        name: 'tag-threads',
        builder: (_, state) =>
            TagThreadsPage(tagId: state.pathParameters['tagId']!),
      ),
      GoRoute(
        path: '/threads/:threadId',
        name: 'thread-detail',
        builder: (_, _) => const Scaffold(body: Text('主题详情占位')),
      ),
    ],
  );
  addTearDown(router.dispose);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeTagRepository implements TagRepository {
  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) async {
    return TagThreadsBootstrap(
      tag: const TopicTagModel(
        id: 'tag-1',
        name: '太空歌剧',
        sortOrder: 1,
        isActive: true,
      ),
      categories: const [
        HomeCategory(
          id: 'category-1',
          slug: 'DEDUCTION',
          name: '演绎',
          sortOrder: 1,
        ),
      ],
      page: CursorPage(items: [_thread], hasMore: false),
    );
  }

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchTagThreads({
    required String tagId,
    String? cursor,
    int limit = 20,
  }) async {
    return CursorPage(items: [_thread], hasMore: false);
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

final _thread = HomeThreadCardModel(
  id: 'thread-1',
  title: '星海旅团',
  categorySlug: 'DEDUCTION',
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
