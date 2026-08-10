import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_management_page.dart';

void main() {
  testWidgets('展示固定默认子贴并完成新增、详情读取和编辑', (tester) async {
    final repository = _FakeRepository(bootstrap: _bootstrap());
    await _pumpPage(tester, repository);

    expect(find.text('默认子贴固定置顶；标题随主题信息维护，正文从主题详情编辑。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('subthread-edit-sub-default')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('subthread-delete-sub-default')),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('subthread-management-create')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '玩家区',
    );
    await tester.tap(find.byKey(const Key('subthread-form-submit')));
    await tester.pumpAndSettle();
    expect(repository.createdTitles, ['玩家区']);
    expect(find.text('子贴已创建。'), findsOneWidget);

    final edit = find.byKey(const ValueKey('subthread-edit-sub-second'));
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(repository.findCalls, 1);
    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '新剧情区',
    );
    await tester.tap(find.byKey(const Key('subthread-form-submit')));
    await tester.pumpAndSettle();
    expect(repository.updatedTitles, ['新剧情区']);
    expect(find.text('新剧情区'), findsOneWidget);
  });

  testWidgets('显式上下排序并二次确认删除非默认子贴', (tester) async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(items: [_defaultItem, _secondary, _third]),
    );
    await _pumpPage(tester, repository);

    final up = find.byKey(const ValueKey('subthread-up-sub-third'));
    await tester.ensureVisible(up);
    await tester.tap(up);
    await tester.pumpAndSettle();
    expect(repository.reorderIds, [
      ['sub-default', 'sub-third', 'sub-second'],
    ]);

    final delete = find.byKey(const ValueKey('subthread-delete-sub-second'));
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(find.text('确认删除这个子贴？'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('subthread-delete-confirm-sub-second')),
    );
    await tester.pumpAndSettle();
    expect(repository.removedIds, ['sub-second']);
    expect(find.text('剧情区'), findsNothing);
  });

  testWidgets('版本冲突刷新目录并要求关闭旧表单后重新编辑', (tester) async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      updateFailureOnce: const ApiFailure(
        userMessage: '子贴已被修改，请重新编辑。',
        businessCode: 40002,
        httpStatus: 409,
      ),
    );
    await _pumpPage(tester, repository);

    final edit = find.byKey(const ValueKey('subthread-edit-sub-second'));
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '本机旧表单',
    );
    await tester.tap(find.byKey(const Key('subthread-form-submit')));
    await tester.pumpAndSettle();

    expect(find.text('返回最新目录'), findsOneWidget);
    await tester.tap(find.text('返回最新目录'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('subthread-form-title')), findsNothing);
    expect(find.text('子贴已被修改，请重新编辑。'), findsOneWidget);
  });

  testWidgets('40107 在表单内完成邮箱验证后保留输入并重试', (tester) async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      createFailureOnce: const ApiFailure(
        userMessage: '请先完成邮箱验证。',
        businessCode: 40107,
        requestId: 'subthread-verify-id',
      ),
    );
    await _pumpPage(tester, repository);

    await tester.tap(find.byKey(const Key('subthread-management-create')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '验证后创建',
    );
    await tester.tap(find.byKey(const Key('subthread-form-submit')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('subthread-form-failure')),
        matching: find.text('请求 ID：subthread-verify-id'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('subthread-form-verify-email')));
    await tester.pumpAndSettle();
    expect(find.text('邮箱验证占位'), findsOneWidget);
    await tester.tap(find.text('完成验证'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('subthread-form-title')))
          .controller!
          .text,
      '验证后创建',
    );
    await tester.tap(find.byKey(const Key('subthread-form-submit')));
    await tester.pumpAndSettle();
    expect(repository.createdTitles, ['验证后创建', '验证后创建']);
    expect(find.text('子贴已创建。'), findsOneWidget);
  });

  testWidgets('加载失败保留请求 ID并可重试', (tester) async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      loadFailureOnce: const ApiFailure(
        userMessage: '目录加载失败',
        requestId: 'subthread-load-id',
      ),
    );
    await _pumpPage(tester, repository);

    expect(find.text('目录加载失败'), findsOneWidget);
    await tester.tap(find.byKey(const Key('subthread-management-retry')));
    await tester.pumpAndSettle();
    expect(find.text('剧情区'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 子贴管理页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 820);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(
        tester,
        _FakeRepository(
          bootstrap: _bootstrap(items: [_defaultItem, _secondary, _third]),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('星海旅团'), findsOneWidget);
    });
  }
}

Future<void> _pumpPage(
  WidgetTester tester,
  SubthreadManagementRepository repository,
) async {
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
        path: '/me/security/verify-email',
        builder: (context, state) => Scaffold(
          body: Column(
            children: [
              const Text('邮箱验证占位'),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('完成验证'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subthreadManagementRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeRepository implements SubthreadManagementRepository {
  _FakeRepository({
    required this.bootstrap,
    this.createFailureOnce,
    this.updateFailureOnce,
    this.loadFailureOnce,
  });

  SubthreadManagementBootstrap bootstrap;
  ApiFailure? createFailureOnce;
  ApiFailure? updateFailureOnce;
  ApiFailure? loadFailureOnce;
  int findCalls = 0;
  final List<String> createdTitles = [];
  final List<String> updatedTitles = [];
  final List<String> removedIds = [];
  final List<List<String>> reorderIds = [];

  @override
  Future<SubthreadManagementBootstrap> load(String threadId) async {
    final failure = loadFailureOnce;
    loadFailureOnce = null;
    if (failure != null) throw failure;
    return bootstrap;
  }

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) async {
    findCalls += 1;
    return bootstrap.items
        .firstWhere((item) => item.id == subthreadId)
        .copyWith(version: 4);
  }

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) async {
    createdTitles.add(draft.normalizedTitle);
    final failure = createFailureOnce;
    createFailureOnce = null;
    if (failure != null) throw failure;
    return SubthreadManagementItem(
      id: 'sub-created',
      threadId: threadId,
      title: draft.normalizedTitle,
      sortOrder: bootstrap.items.length,
      postingPolicy: draft.postingPolicy,
      version: 1,
      postCount: 0,
      isDefault: false,
    );
  }

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) async {
    final failure = updateFailureOnce;
    updateFailureOnce = null;
    if (failure != null) throw failure;
    updatedTitles.add(draft.normalizedTitle);
    return current.copyWith(
      title: draft.normalizedTitle,
      postingPolicy: draft.postingPolicy,
      version: current.version + 1,
    );
  }

  @override
  Future<void> remove(SubthreadManagementItem item) async {
    removedIds.add(item.id);
  }

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) async {
    reorderIds.add(items.map((item) => item.id).toList());
    return [
      for (var index = 0; index < items.length; index++)
        items[index].copyWith(sortOrder: index),
    ];
  }
}

SubthreadManagementBootstrap _bootstrap({
  List<SubthreadManagementItem>? items,
}) {
  return SubthreadManagementBootstrap(
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    items: items ?? [_defaultItem, _secondary],
  );
}

const _defaultItem = SubthreadManagementItem(
  id: 'sub-default',
  threadId: 'thread-1',
  title: '主贴',
  sortOrder: 0,
  postingPolicy: SubthreadPostingPolicy.participants,
  version: 2,
  postCount: 1,
  isDefault: true,
);

const _secondary = SubthreadManagementItem(
  id: 'sub-second',
  threadId: 'thread-1',
  title: '剧情区',
  sortOrder: 1,
  postingPolicy: SubthreadPostingPolicy.participants,
  version: 3,
  postCount: 2,
  isDefault: false,
);

const _third = SubthreadManagementItem(
  id: 'sub-third',
  threadId: 'thread-1',
  title: '闲聊区',
  sortOrder: 2,
  postingPolicy: SubthreadPostingPolicy.players,
  version: 1,
  postCount: 0,
  isDefault: false,
);
