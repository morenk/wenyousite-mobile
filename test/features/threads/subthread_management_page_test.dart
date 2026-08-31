import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/subthread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_editor_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_management_page.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('目录只展示非默认子贴及正文状态', (tester) async {
    await _pumpWorkspace(tester, _FakeRepository());

    expect(find.text('主贴'), findsNothing);
    expect(find.text('剧情区'), findsOneWidget);
    expect(find.textContaining('有正文'), findsOneWidget);
    expect(
      find.byKey(const Key('subthread-management-create')),
      findsOneWidget,
    );
    expect(find.text('添加子贴'), findsOneWidget);
    expect(find.text('添加子贴并填写正文'), findsNothing);
    expect(find.textContaining('主正文位于'), findsNothing);
  });

  testWidgets('新建子贴只填写标题和发帖权限', (tester) async {
    final repository = _FakeRepository();
    await _pumpWorkspace(tester, repository);

    await tester.tap(find.byKey(const Key('subthread-management-create')));
    await tester.pumpAndSettle();
    expect(find.text('添加子贴'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-management-body-editor')),
      findsNothing,
    );
    expect(find.textContaining('正文编辑器'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '玩家区',
    );
    await tester.tap(find.byKey(const Key('subthread-editor-save')));
    await tester.pumpAndSettle();

    expect(repository.createdDraft?.title, '玩家区');
    expect(find.text('玩家区'), findsOneWidget);
  });

  testWidgets('点击子贴只编辑标题和发帖权限并保留既有正文', (tester) async {
    final repository = _FakeRepository();
    await _pumpWorkspace(tester, repository);

    await tester.tap(find.byKey(const ValueKey('subthread-edit-sub-second')));
    await tester.pumpAndSettle();
    expect(find.text('编辑子贴'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-management-body-editor')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '新剧情区',
    );
    await tester.tap(find.byKey(const Key('subthread-editor-save')));
    await tester.pumpAndSettle();

    expect(repository.updatedDraft?.title, '新剧情区');
    expect(repository.currentItems.last.body, '剧情区正文');
    expect(find.text('新剧情区'), findsOneWidget);
  });

  testWidgets('整页加载失败显示问题编号并可原地重试', (tester) async {
    final repository = _FakeRepository(
      loadFailure: const ApiFailure(
        userMessage: '子贴暂时不可用',
        requestId: 'subthread-load-request-id',
      ),
      failLoadOnce: true,
    );
    await _pumpWorkspace(tester, repository);

    expect(find.text('子贴管理暂时不可用'), findsOneWidget);
    expect(
      find.textContaining('问题编号：subthread-load-request-id'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('subthread-management-create')), findsNothing);

    await tester.tap(find.byKey(const Key('subthread-management-retry')));
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 2);
    expect(find.text('剧情区'), findsOneWidget);
    expect(
      find.byKey(const Key('subthread-management-create')),
      findsOneWidget,
    );
  });

  testWidgets('无管理权限时只显示禁止状态且不渲染写入入口', (tester) async {
    await _pumpWorkspace(
      tester,
      _FakeRepository(
        loadFailure: const ApiFailure(
          userMessage: '当前账号没有管理这个主题子贴的权限。',
          httpStatus: 403,
          businessCode: 40300,
        ),
      ),
    );

    expect(find.text('当前账号没有管理这个主题子贴的权限。'), findsOneWidget);
    expect(find.byKey(const Key('subthread-management-create')), findsNothing);
    expect(find.byKey(const Key('subthread-management-list')), findsNothing);
  });

  testWidgets('子贴保存失败保留标题以便重试', (tester) async {
    final repository = _FakeRepository(
      updateFailure: const ApiFailure(
        userMessage: '子贴保存失败',
        requestId: 'subthread-save-request-id',
      ),
    );
    await _pumpWorkspace(tester, repository);

    await tester.tap(find.byKey(const ValueKey('subthread-edit-sub-second')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '待重试的剧情区',
    );
    await tester.tap(find.byKey(const Key('subthread-editor-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('subthread-form-failure')), findsOneWidget);
    expect(
      find.textContaining('问题编号：subthread-save-request-id'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('subthread-form-title')))
          .controller!
          .text,
      '待重试的剧情区',
    );
    expect(
      find.byKey(const Key('thread-management-body-editor')),
      findsNothing,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('subthread-editor-save')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('删除和排序失败均保留服务端已加载的目录', (tester) async {
    final repository = _FakeRepository(
      initial: _initialBootstrap(includeThird: true),
      removeFailure: const ApiFailure(
        userMessage: '子贴删除失败',
        requestId: 'subthread-delete-request-id',
      ),
      reorderFailure: const ApiFailure(
        userMessage: '子贴排序失败',
        requestId: 'subthread-reorder-request-id',
      ),
    );
    final container = await _pumpWorkspace(tester, repository);

    await tester.tap(find.byKey(const ValueKey('subthread-delete-sub-second')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('subthread-delete-confirm-sub-second')),
    );
    await tester.pumpAndSettle();

    expect(find.text('剧情区'), findsOneWidget);
    expect(find.text('设定区'), findsOneWidget);
    expect(
      find.textContaining('问题编号：subthread-delete-request-id'),
      findsOneWidget,
    );

    final moved = await container
        .read(subthreadManagementControllerProvider('thread-1').notifier)
        .move('sub-third', -1);
    await tester.pumpAndSettle();

    expect(moved, isFalse);
    expect(
      find.textContaining('问题编号：subthread-reorder-request-id'),
      findsOneWidget,
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('subthread-edit-sub-second')))
          .dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('subthread-edit-sub-third')))
            .dy,
      ),
    );
  });

  testWidgets('排序写入期间列表保持目标位置且尾部操作不闪动', (tester) async {
    final reorder = Completer<List<SubthreadManagementItem>>();
    final repository = _FakeRepository(
      initial: _initialBootstrap(includeThird: true),
      reorderCompleter: reorder,
    );
    final container = await _pumpWorkspace(tester, repository);

    final moving = container
        .read(subthreadManagementControllerProvider('thread-1').notifier)
        .move('sub-third', -1);
    await tester.pump();

    final third = find.byKey(const ValueKey('subthread-edit-sub-third'));
    final second = find.byKey(const ValueKey('subthread-edit-sub-second'));
    expect(tester.getTopLeft(third).dy, lessThan(tester.getTopLeft(second).dy));
    expect(
      find.byKey(const ValueKey('subthread-delete-sub-third')),
      findsOneWidget,
    );

    reorder.complete(repository.currentItems);
    expect(await moving, isTrue);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(third).dy, lessThan(tester.getTopLeft(second).dy));
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 子贴目录无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 860);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpWorkspace(tester, _FakeRepository());

      expect(tester.takeException(), isNull);
      expect(find.text('剧情区'), findsOneWidget);
    });
  }

  testWidgets('360dp 子贴目录紧凑视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await _pumpWorkspace(
      tester,
      _FakeRepository(initial: _initialBootstrap(includeThird: true)),
    );

    await expectLater(
      find.byType(Scaffold).last,
      matchesGoldenFile('goldens/subthread_management_list_360.png'),
    );
  });
}

Future<ProviderContainer> _pumpWorkspace(
  WidgetTester tester,
  SubthreadManagementRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      subthreadManagementRepositoryProvider.overrideWithValue(repository),
    ],
  );
  final router = GoRouter(
    initialLocation: '/threads/thread-1/manage/subthreads',
    routes: [
      GoRoute(
        path: '/threads/:threadId/manage/subthreads',
        builder: (_, state) => SubthreadManagementPage(
          threadId: state.pathParameters['threadId']!,
        ),
      ),
      GoRoute(
        path: '/threads/:threadId/manage/subthreads/new',
        builder: (_, state) =>
            SubthreadEditorPage(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
        path: '/threads/:threadId/manage/subthreads/:subthreadId/edit',
        builder: (_, state) => SubthreadEditorPage(
          threadId: state.pathParameters['threadId']!,
          subthreadId: state.pathParameters['subthreadId']!,
        ),
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
  return container;
}

class _FakeRepository implements SubthreadManagementRepository {
  _FakeRepository({
    SubthreadManagementBootstrap? initial,
    this.loadFailure,
    this.failLoadOnce = false,
    this.updateFailure,
    this.removeFailure,
    this.reorderFailure,
    this.reorderCompleter,
  }) : _bootstrap = initial ?? _initialBootstrap();

  SubthreadManagementBootstrap _bootstrap;
  ApiFailure? loadFailure;
  final bool failLoadOnce;
  final ApiFailure? updateFailure;
  final ApiFailure? removeFailure;
  final ApiFailure? reorderFailure;
  final Completer<List<SubthreadManagementItem>>? reorderCompleter;
  SubthreadManagementDraft? createdDraft;
  SubthreadManagementDraft? updatedDraft;
  int loadCalls = 0;

  List<SubthreadManagementItem> get currentItems => _bootstrap.items;

  @override
  Future<SubthreadManagementBootstrap> load(String threadId) async {
    loadCalls += 1;
    final failure = loadFailure;
    if (failure != null) {
      if (failLoadOnce) loadFailure = null;
      throw failure;
    }
    return _bootstrap;
  }

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) async => _bootstrap.items.firstWhere((item) => item.id == subthreadId);

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) async {
    createdDraft = draft;
    final item = SubthreadManagementItem(
      id: 'sub-new',
      threadId: threadId,
      title: draft.normalizedTitle,
      sortOrder: _bootstrap.items.length,
      postingPolicy: draft.postingPolicy,
      version: 1,
      postCount: 0,
      isDefault: false,
    );
    _bootstrap = _bootstrap.copyWith(items: [..._bootstrap.items, item]);
    return item;
  }

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) async {
    updatedDraft = draft;
    if (updateFailure != null) throw updateFailure!;
    final item = current.copyWith(
      title: draft.normalizedTitle,
      postingPolicy: draft.postingPolicy,
      version: current.version + 1,
    );
    _bootstrap = _bootstrap.copyWith(
      items: [
        for (final candidate in _bootstrap.items)
          if (candidate.id == item.id) item else candidate,
      ],
    );
    return item;
  }

  @override
  Future<void> remove(SubthreadManagementItem item) async {
    if (removeFailure != null) throw removeFailure!;
    _bootstrap = _bootstrap.copyWith(
      items: _bootstrap.items
          .where((candidate) => candidate.id != item.id)
          .toList(),
    );
  }

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) async {
    if (reorderFailure != null) throw reorderFailure!;
    _bootstrap = _bootstrap.copyWith(items: List.unmodifiable(items));
    if (reorderCompleter != null) return reorderCompleter!.future;
    return _bootstrap.items;
  }
}

SubthreadManagementBootstrap _initialBootstrap({bool includeThird = false}) {
  return SubthreadManagementBootstrap(
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    items: [
      const SubthreadManagementItem(
        id: 'sub-default',
        threadId: 'thread-1',
        title: '主贴',
        sortOrder: 0,
        postingPolicy: SubthreadPostingPolicy.participants,
        version: 1,
        postCount: 0,
        isDefault: true,
        body: '主正文',
      ),
      const SubthreadManagementItem(
        id: 'sub-second',
        threadId: 'thread-1',
        title: '剧情区',
        sortOrder: 1,
        postingPolicy: SubthreadPostingPolicy.participants,
        version: 3,
        postCount: 2,
        isDefault: false,
        bodyPostId: 'body-second',
        bodyVersion: 5,
        body: '剧情区正文',
      ),
      if (includeThird)
        const SubthreadManagementItem(
          id: 'sub-third',
          threadId: 'thread-1',
          title: '设定区',
          sortOrder: 2,
          postingPolicy: SubthreadPostingPolicy.collaborators,
          version: 2,
          postCount: 1,
          isDefault: false,
          body: '设定区正文',
        ),
    ],
  );
}
