import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';
import 'package:wenyousite_mobile/features/tags/presentation/thread_tag_management_page.dart';

void main() {
  testWidgets('搜索已有标签并在读取最新详情后添加', (tester) async {
    final repository = _FakeTagRepository();
    await _pumpPage(tester, repository);

    final suggestion = find.byKey(const Key('thread-tag-suggestion-tag-2'));
    await tester.ensureVisible(suggestion);
    await tester.tap(suggestion);
    await tester.pumpAndSettle();

    expect(repository.findIds, ['tag-2']);
    expect(repository.addedNames, ['群像']);
    expect(find.byKey(const Key('thread-tag-selected-tag-2')), findsOneWidget);
  });

  testWidgets('有效新名称通过统一入口复用或创建后关联主题', (tester) async {
    final repository = _FakeTagRepository();
    await _pumpPage(tester, repository);

    await tester.enterText(find.byKey(const Key('thread-tag-search')), '新标签');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    final create = find.byKey(const Key('thread-tag-create'));
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();

    expect(repository.createdNames, isEmpty);
    expect(repository.addedNames, ['新标签']);
    expect(
      find.byKey(const Key('thread-tag-selected-created')),
      findsOneWidget,
    );
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 标签管理页无布局溢出且触控区达标', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 860);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _FakeTagRepository());

      expect(tester.takeException(), isNull);
      expect(find.text('已选标签 1/5'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('thread-tag-search'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }
}

Future<void> _pumpPage(WidgetTester tester, TagRepository repository) async {
  final container = ProviderContainer(
    overrides: [tagRepositoryProvider.overrideWithValue(repository)],
  );
  final router = GoRouter(
    initialLocation: '/threads/thread-1/manage/tags',
    routes: [
      GoRoute(
        path: '/threads/:threadId/manage/tags',
        builder: (_, state) => ThreadTagManagementPage(
          threadId: state.pathParameters['threadId']!,
        ),
      ),
      GoRoute(
        path: '/tags/:tagId',
        name: 'tag-threads',
        builder: (_, _) => const Scaffold(body: Text('标签主题占位')),
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
  final findIds = <String>[];
  final addedNames = <String>[];
  final createdNames = <String>[];

  @override
  Future<TopicTagModel> addToThread({
    required String threadId,
    required String name,
  }) async {
    addedNames.add(name);
    return name == '新标签'
        ? _tag(id: 'created', name: name)
        : _tag(id: 'tag-2', name: name);
  }

  @override
  Future<TopicTagModel> create(String name) async {
    createdNames.add(name);
    return _tag(id: 'created', name: name);
  }

  @override
  Future<TopicTagModel> findById(String tagId) async {
    findIds.add(tagId);
    return _tag(id: tagId, name: '群像');
  }

  @override
  Future<ThreadTagManagementBootstrap> loadManagement(String threadId) async {
    return ThreadTagManagementBootstrap(
      threadId: threadId,
      threadTitle: '星海旅团',
      tags: [_tag()],
      suggestions: [
        _tag(),
        _tag(id: 'tag-2', name: '群像'),
      ],
    );
  }

  @override
  Future<void> removeFromThread({
    required String threadId,
    required String tagId,
  }) async {}

  @override
  Future<List<TopicTagModel>> search(String query) async {
    if (query == '新标签') return [];
    return [_tag(), _tag(id: 'tag-2', name: '群像')];
  }

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchTagThreads({
    required String tagId,
    String? cursor,
    int limit = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) {
    throw UnimplementedError();
  }
}

TopicTagModel _tag({String id = 'tag-1', String name = '太空歌剧'}) {
  return TopicTagModel(
    id: id,
    name: name,
    color: '#704C65',
    sortOrder: id == 'tag-1' ? 1 : 2,
    isActive: true,
  );
}
