import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_editor_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_management_page.dart';

void main() {
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

  testWidgets('新建子贴可在全屏编辑器同时填写正文', (tester) async {
    final repository = _FakeRepository();
    await _pumpWorkspace(tester, repository);

    await tester.tap(find.byKey(const Key('subthread-management-create')));
    await tester.pumpAndSettle();
    expect(find.text('添加子贴'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-management-body-editor')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '玩家区',
    );
    await _replaceBody(tester, '这里是玩家区正文');
    await tester.tap(find.byKey(const Key('subthread-editor-save')));
    await tester.pumpAndSettle();

    expect(repository.createdDraft?.title, '玩家区');
    expect(repository.createdDraft?.body, '这里是玩家区正文');
    expect(find.text('玩家区'), findsOneWidget);
  });

  testWidgets('点击子贴进入全屏编辑并同时保存标题权限正文', (tester) async {
    final repository = _FakeRepository();
    await _pumpWorkspace(tester, repository);

    await tester.tap(find.byKey(const ValueKey('subthread-edit-sub-second')));
    await tester.pumpAndSettle();
    expect(find.text('编辑子贴'), findsOneWidget);
    expect(
      tester
          .widget<QuillEditor>(
            find.byKey(const Key('thread-management-body-editor')),
          )
          .controller
          .document
          .toPlainText()
          .trim(),
      '剧情区正文',
    );

    await tester.enterText(
      find.byKey(const Key('subthread-form-title')),
      '新剧情区',
    );
    await _replaceBody(tester, '更新后的剧情区正文');
    await tester.tap(find.byKey(const Key('subthread-editor-save')));
    await tester.pumpAndSettle();

    expect(repository.updatedDraft?.title, '新剧情区');
    expect(repository.updatedDraft?.body, '更新后的剧情区正文');
    expect(find.text('新剧情区'), findsOneWidget);
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
}

Future<void> _pumpWorkspace(
  WidgetTester tester,
  SubthreadManagementRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
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
}

Future<void> _replaceBody(WidgetTester tester, String text) async {
  final editor = tester.widget<QuillEditor>(
    find.byKey(const Key('thread-management-body-editor')),
  );
  editor.controller.replaceText(
    0,
    editor.controller.document.length - 1,
    text,
    TextSelection.collapsed(offset: text.length),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

class _FakeRepository implements SubthreadManagementRepository {
  _FakeRepository() : _bootstrap = _initialBootstrap();

  SubthreadManagementBootstrap _bootstrap;
  SubthreadManagementDraft? createdDraft;
  SubthreadManagementDraft? updatedDraft;

  @override
  Future<SubthreadManagementBootstrap> load(String threadId) async =>
      _bootstrap;

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
      body: draft.body,
      bodyPostId: draft.body.isEmpty ? null : 'body-new',
      bodyVersion: draft.body.isEmpty ? null : 1,
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
    final item = current.copyWith(
      title: draft.normalizedTitle,
      postingPolicy: draft.postingPolicy,
      version: current.version + 1,
      body: draft.body,
      bodyPostId: current.bodyPostId ?? 'body-second',
      bodyVersion: (current.bodyVersion ?? 0) + 1,
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
    _bootstrap = _bootstrap.copyWith(items: List.unmodifiable(items));
    return _bootstrap.items;
  }
}

SubthreadManagementBootstrap _initialBootstrap() {
  return const SubthreadManagementBootstrap(
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    items: [
      SubthreadManagementItem(
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
      SubthreadManagementItem(
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
    ],
  );
}
