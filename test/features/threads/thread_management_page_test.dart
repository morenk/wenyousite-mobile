import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_page.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('主题管理页通过统一页签进入子贴管理', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(initial: _bootstrap()),
      subthreadRepository: _FakeSubthreadRepository(),
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'thread-management-tab-ThreadManagementSection.subthreads',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('子贴管理'), findsOneWidget);
    expect(
      find.byKey(const Key('subthread-management-create')),
      findsOneWidget,
    );
  });

  testWidgets('主题标签完成编辑后关闭面板并更新表单', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(initial: _bootstrap(tagNames: const ['原标签'])),
    );

    final entry = find.byKey(const Key('thread-management-edit-tags'));
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(find.text('编辑主题标签'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-management-tag-input')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('thread-management-tag-input')),
      '新标签',
    );
    await tester.tap(find.byKey(const Key('thread-management-tag-add')));
    await tester.pump();
    final originalChip = find.widgetWithText(InputChip, '原标签');
    tester.widget<InputChip>(originalChip).onDeleted!();
    await tester.pump();
    await tester.tap(find.byKey(const Key('thread-management-tag-done')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('编辑主题标签'), findsNothing);
    expect(find.text('主题标签'), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);
    expect(find.text('新标签'), findsOneWidget);
    expect(find.text('原标签'), findsNothing);
  });

  testWidgets('主题标签取消编辑后关闭面板并保留原表单', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(initial: _bootstrap(tagNames: const ['原标签'])),
    );

    final entry = find.byKey(const Key('thread-management-edit-tags'));
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('thread-management-tag-input')),
      '暂存标签',
    );
    await tester.tap(find.byKey(const Key('thread-management-tag-add')));
    await tester.pump();
    final originalChip = find.widgetWithText(InputChip, '原标签');
    tester.widget<InputChip>(originalChip).onDeleted!();
    await tester.pump();
    await tester.tap(find.byKey(const Key('thread-management-tag-cancel')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('编辑主题标签'), findsNothing);
    expect(find.text('主题标签'), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);
    expect(find.text('原标签'), findsOneWidget);
    expect(find.text('暂存标签'), findsNothing);
  });

  testWidgets('整页加载失败显示问题编号并可原地重试', (tester) async {
    final repository = _FakeRepository(
      initial: _bootstrap(),
      loadFailure: const ApiFailure(
        userMessage: '主题管理信息暂时不可用',
        requestId: 'thread-management-load-request-id',
      ),
      failLoadOnce: true,
    );
    await _pumpPage(tester, repository);

    expect(find.text('主题管理信息加载失败'), findsOneWidget);
    expect(
      find.textContaining('问题编号：thread-management-load-request-id'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('thread-management-save')), findsNothing);

    await tester.tap(find.byKey(const Key('thread-management-load-retry')));
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 2);
    expect(find.byKey(const Key('thread-management-title')), findsOneWidget);
    expect(
      find.byKey(const Key('thread-management-autosave-status')),
      findsOneWidget,
    );
  });

  testWidgets('无管理权限时不渲染保存、邀请或删除入口', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap(canManage: false));
    await _pumpPage(tester, repository);

    expect(find.text('当前账号没有管理这个主题的权限。'), findsOneWidget);
    expect(find.byKey(const Key('thread-management-save')), findsNothing);
    expect(find.byKey(const Key('thread-management-title')), findsNothing);
    expect(find.byKey(const Key('thread-invite-link-generate')), findsNothing);
    expect(find.byKey(const Key('thread-management-delete')), findsNothing);
    expect(repository.lastDraft, isNull);
    expect(repository.removeCalls, 0);
  });

  testWidgets('楼主修改标题后自动保存且不显示重复标题或保存按钮', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap());
    await _pumpPage(tester, repository);

    expect(find.text('主题设置'), findsOneWidget);
    expect(find.textContaining('会在一次保存中同时更新'), findsNothing);
    expect(find.byKey(const Key('thread-management-export')), findsOneWidget);
    expect(find.byKey(const Key('thread-management-delete')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '新的主题标题',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('thread-management-title')),
          )
          .controller!
          .text,
      '新的主题标题',
    );
    expect(find.byKey(const Key('thread-management-save')), findsNothing);
    await tester.pump();
    expect(find.text('待保存'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(repository.lastDraft?.title, '新的主题标题');
    expect(find.text('已保存'), findsOneWidget);
    expect(find.byKey(const Key('thread-management-title')), findsOneWidget);
  });

  testWidgets('发布设置通过列表面板选择并在变更后立即自动保存', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap());
    await _pumpPage(tester, repository);

    final status = find.byKey(const Key('thread-management-status'));
    await tester.ensureVisible(status);
    await tester.tap(status);
    await tester.pumpAndSettle();
    expect(find.text('选择招募状态'), findsOneWidget);
    expect(find.textContaining('不会限制发帖'), findsOneWidget);

    final closed = find.byKey(
      const ValueKey('thread-management-status-choice-closed'),
    );
    await tester.tap(closed);
    await tester.pumpAndSettle();

    expect(repository.lastDraft?.status, ThreadManagementStatus.closed);
    expect(find.text('已停招'), findsOneWidget);

    final visibility = find.byKey(const Key('thread-management-visibility'));
    await tester.ensureVisible(visibility);
    await tester.tap(visibility);
    await tester.pumpAndSettle();
    expect(find.text('选择可见范围'), findsOneWidget);
    final private = find.byKey(
      const ValueKey('thread-management-visibility-choice-private'),
    );
    await tester.tap(private);
    await tester.pumpAndSettle();

    expect(
      repository.lastDraft?.visibility,
      ThreadManagementVisibility.private,
    );
    expect(find.text('只有主题成员可以查看'), findsOneWidget);
  });

  testWidgets('主题分区使用整行入口和列表面板且不重复显示说明', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap());
    await _pumpPage(tester, repository);

    final category = find.byKey(const Key('thread-management-category'));
    expect(category, findsOneWidget);
    expect(find.text('角色扮演'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byType(InputChip), findsNothing);
    expect(find.text('添加后更容易被搜索到。'), findsNothing);

    await tester.ensureVisible(category);
    await tester.tap(category);
    await tester.pumpAndSettle();
    expect(find.text('选择主题分区'), findsOneWidget);
    expect(find.text('适合角色扮演主题'), findsNothing);
    expect(find.text('适合综合讨论主题'), findsNothing);
    final board = find.byKey(
      const Key('thread-management-category-option-BOARD'),
    );
    expect(board, findsOneWidget);
    await tester.tap(board);
    await tester.pumpAndSettle();

    expect(repository.lastDraft?.categorySlug, 'BOARD');
    expect(find.text('综合讨论'), findsOneWidget);
  });

  testWidgets('关闭单选面板不会修改或保存设置', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap());
    await _pumpPage(tester, repository);

    final status = find.byKey(const Key('thread-management-status'));
    await tester.ensureVisible(status);
    await tester.tap(status);
    await tester.pumpAndSettle();
    expect(find.text('选择招募状态'), findsOneWidget);

    await tester.tapAt(const Offset(8, 120));
    await tester.pumpAndSettle();

    expect(find.text('选择招募状态'), findsNothing);
    expect(repository.lastDraft, isNull);
    expect(find.text('招募中'), findsOneWidget);
  });

  testWidgets('管理页移除正文编辑且键盘收起后可滚动到邀请和删除', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    tester.view.viewInsets = FakeViewPadding.zero;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final repository = _FakeRepository(
      initial: _bootstrap(visibility: ThreadManagementVisibility.private),
    );
    await _pumpPage(
      tester,
      repository,
      invitationRepository: _FakeInvitationRepository(),
    );

    expect(find.text('主正文'), findsNothing);
    expect(
      find.byKey(const Key('thread-management-body-editor')),
      findsNothing,
    );

    final title = find.byKey(const Key('thread-management-title'));
    await tester.tap(title);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    await tester.enterText(title, '更新后的标题');
    tester.view.viewInsets = FakeViewPadding.zero;
    tester.testTextInput.hide();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final invitation = find.byKey(const Key('thread-management-invite'));
    await tester.ensureVisible(invitation);
    await tester.pumpAndSettle();
    expect(invitation, findsOneWidget);

    final delete = find.byKey(const Key('thread-management-delete'));
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    expect(delete, findsOneWidget);
    expect(repository.lastDraft?.title, '更新后的标题');
  });

  testWidgets('主题保存失败保留当前表单并恢复重试入口', (tester) async {
    final repository = _FakeRepository(
      initial: _bootstrap(),
      updateFailure: const ApiFailure(
        userMessage: '主题保存失败',
        requestId: 'thread-management-save-request-id',
      ),
    );
    await _pumpPage(tester, repository);
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '待重试的主题标题',
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(repository.lastDraft?.title, '待重试的主题标题');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('thread-management-title')),
          )
          .controller!
          .text,
      '待重试的主题标题',
    );
    final failure = find.byKey(const Key('thread-management-failure'));
    await tester.ensureVisible(failure);
    expect(
      find.textContaining('问题编号：thread-management-save-request-id'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-management-autosave-retry')),
      findsOneWidget,
    );
    expect(find.text('未保存'), findsOneWidget);
  });

  testWidgets('协作者可编辑常规信息但不能修改可见性或删除主题', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap(isOwner: false));
    await _pumpPage(tester, repository);

    final visibility = find.byKey(const Key('thread-management-visibility'));
    final visibilityTile = find.descendant(
      of: visibility,
      matching: find.byType(ListTile),
    );
    expect(tester.widget<ListTile>(visibilityTile).onTap, isNull);
    await tester.tap(visibility);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('thread-management-visibility-choice-private')),
      findsNothing,
    );
    expect(find.text('仅楼主可修改可见范围。'), findsOneWidget);
    expect(find.byKey(const Key('thread-management-delete')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '协作者修改的标题',
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(repository.lastDraft?.title, '协作者修改的标题');
    expect(repository.lastDraft?.visibility, ThreadManagementVisibility.public);
  });

  testWidgets('只有已发布私密主题楼主看到邀请链接管理', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(
        initial: _bootstrap(visibility: ThreadManagementVisibility.private),
      ),
      invitationRepository: _FakeInvitationRepository(),
    );
    final entry = find.byKey(const Key('thread-management-invite'));
    expect(entry, findsOneWidget);
    expect(find.byKey(const Key('thread-invite-link-generate')), findsNothing);

    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('thread-invite-link-generate')),
      findsOneWidget,
    );
  });

  testWidgets('楼主删除经过二次确认后返回首页', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap());
    await _pumpPage(tester, repository);

    await tester.ensureVisible(
      find.byKey(const Key('thread-management-delete')),
    );
    await tester.tap(find.byKey(const Key('thread-management-delete')));
    await tester.pumpAndSettle();
    expect(find.text('确认删除这个主题？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-management-delete-confirm')));
    await tester.pumpAndSettle();

    expect(repository.removeCalls, 1);
    expect(find.text('首页占位'), findsOneWidget);
  });

  testWidgets('主题删除失败留在管理页并恢复原设置', (tester) async {
    final repository = _FakeRepository(
      initial: _bootstrap(),
      removeFailure: const ApiFailure(
        userMessage: '主题删除失败',
        requestId: 'thread-management-delete-request-id',
      ),
    );
    await _pumpPage(tester, repository);

    await tester.ensureVisible(
      find.byKey(const Key('thread-management-delete')),
    );
    await tester.tap(find.byKey(const Key('thread-management-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-management-delete-confirm')));
    await tester.pumpAndSettle();

    expect(repository.removeCalls, 1);
    expect(find.byKey(const Key('thread-management-title')), findsOneWidget);
    expect(find.text('原主题'), findsOneWidget);
    expect(
      find.textContaining('问题编号：thread-management-delete-request-id'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ListTile>(find.byKey(const Key('thread-management-delete')))
          .onTap,
      isNotNull,
    );
  });

  testWidgets('版本冲突保留表单并允许采用云端最新版', (tester) async {
    final repository = _FakeRepository(
      initial: _bootstrap(version: 2),
      latest: _bootstrap(version: 3, title: '云端最新版标题'),
      conflictOnce: true,
    );
    await _pumpPage(tester, repository);
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '本机待保存标题',
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('thread-management-title')),
          )
          .controller!
          .text,
      '本机待保存标题',
    );
    final resolve = find.byKey(const Key('thread-management-resolve-conflict'));
    await tester.ensureVisible(resolve);
    await tester.tap(resolve);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-management-use-latest')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('thread-management-title')),
          )
          .controller!
          .text,
      '云端最新版标题',
    );
    expect(
      find.byKey(const Key('thread-management-resolve-conflict')),
      findsNothing,
    );
  });

  testWidgets('自动保存失败时返回需要明确确认放弃', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(
        initial: _bootstrap(),
        updateFailure: const ApiFailure(userMessage: '主题保存失败'),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '还没保存的标题',
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('修改还没有保存'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('还没保存的标题'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('thread-management-discard-confirm')),
    );
    await tester.pumpAndSettle();
    expect(find.text('主题详情占位'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 主题管理页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 860);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _FakeRepository(initial: _bootstrap()));

      expect(tester.takeException(), isNull);
      expect(find.text('主题设置'), findsOneWidget);
      expect(
        find.byKey(const Key('thread-management-autosave-status')),
        findsOneWidget,
      );
    });
  }

  testWidgets('360dp 放大字体时设置行无布局溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpPage(tester, _FakeRepository(initial: _bootstrap()));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('thread-management-status')), findsOneWidget);
    expect(find.byKey(const Key('thread-management-export')), findsOneWidget);
  });

  testWidgets('360dp 主题设置自动保存视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await _pumpPage(tester, _FakeRepository(initial: _bootstrap()));

    await expectLater(
      find.byType(Scaffold).last,
      matchesGoldenFile('goldens/thread_management_settings_360.png'),
    );
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  ThreadManagementRepository repository, {
  ThreadInvitationRepository? invitationRepository,
  SubthreadManagementRepository? subthreadRepository,
}) async {
  final container = ProviderContainer(
    overrides: [
      threadManagementRepositoryProvider.overrideWithValue(repository),
      if (invitationRepository != null)
        threadInvitationRepositoryProvider.overrideWithValue(
          invitationRepository,
        ),
      if (subthreadRepository != null)
        subthreadManagementRepositoryProvider.overrideWithValue(
          subthreadRepository,
        ),
    ],
  );
  final router = GoRouter(
    initialLocation: '/thread',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('首页占位')),
      ),
      GoRoute(
        path: '/thread',
        builder: (_, _) => Scaffold(
          body: Center(
            child: FilledButton(onPressed: () {}, child: const Text('主题详情占位')),
          ),
        ),
      ),
      GoRoute(
        path: '/threads/:threadId/manage',
        builder: (_, state) =>
            ThreadManagementPage(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
        path: '/threads/:threadId/manage/tags',
        builder: (_, _) => const Scaffold(body: Text('标签工作台占位')),
      ),
      GoRoute(
        path: '/threads/:threadId/manage/subthreads',
        builder: (_, _) => const Scaffold(body: Text('子贴工作台占位')),
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
  unawaited(router.push('/threads/thread-1/manage'));
  await tester.pumpAndSettle();
}

class _FakeRepository implements ThreadManagementRepository {
  _FakeRepository({
    required this.initial,
    ThreadManagementBootstrap? latest,
    this.conflictOnce = false,
    this.loadFailure,
    this.failLoadOnce = false,
    this.updateFailure,
    this.removeFailure,
  }) : latest = latest ?? initial;

  final ThreadManagementBootstrap initial;
  final ThreadManagementBootstrap latest;
  final bool conflictOnce;
  ApiFailure? loadFailure;
  final bool failLoadOnce;
  final ApiFailure? updateFailure;
  final ApiFailure? removeFailure;
  int loadCalls = 0;
  int removeCalls = 0;
  bool _didConflict = false;
  ThreadManagementDraft? lastDraft;

  @override
  Future<ThreadManagementBootstrap> load(String threadId) async {
    loadCalls += 1;
    final failure = loadFailure;
    if (failure != null) {
      if (failLoadOnce) loadFailure = null;
      throw failure;
    }
    return loadCalls == 1 ? initial : latest;
  }

  @override
  Future<void> remove(String threadId) async {
    removeCalls += 1;
    if (removeFailure != null) throw removeFailure!;
  }

  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) async {
    lastDraft = draft;
    if (updateFailure != null) throw updateFailure!;
    if (conflictOnce && !_didConflict) {
      _didConflict = true;
      throw const ApiFailure(
        userMessage: '内容已在其他位置修改',
        businessCode: 40002,
        httpStatus: 409,
      );
    }
    return ThreadManagementSnapshot(
      id: current.id,
      title: draft.title.trim(),
      categorySlug: draft.categorySlug,
      status: draft.status,
      visibility: draft.visibility,
      version: current.version + 1,
      published: current.published,
      canManage: true,
      isOwner: current.isOwner,
      defaultSubthreadId: current.defaultSubthreadId,
      defaultSubthreadVersion: current.defaultSubthreadVersion,
      bodyPostId: current.bodyPostId,
      bodyVersion: current.bodyVersion,
      body: current.body,
      tagNames: draft.normalizedTagNames,
    );
  }

  @override
  Future<ThreadArchive> exportArchive(
    String threadId,
    ThreadArchiveOptions options,
  ) => throw UnsupportedError('unused');
}

ThreadManagementBootstrap _bootstrap({
  int version = 1,
  String title = '原主题',
  bool isOwner = true,
  bool canManage = true,
  ThreadManagementVisibility visibility = ThreadManagementVisibility.public,
  List<String> tagNames = const [],
}) {
  return ThreadManagementBootstrap(
    thread: ThreadManagementSnapshot(
      id: 'thread-1',
      title: title,
      categorySlug: 'RPG',
      status: ThreadManagementStatus.recruiting,
      visibility: visibility,
      version: version,
      published: true,
      canManage: canManage,
      isOwner: isOwner,
      tagNames: tagNames,
    ),
    categories: const [
      ThreadManagementCategory(
        slug: 'RPG',
        name: '角色扮演',
        sortOrder: 1,
        description: '适合角色扮演主题',
      ),
      ThreadManagementCategory(
        slug: 'BOARD',
        name: '综合讨论',
        sortOrder: 2,
        description: '适合综合讨论主题',
      ),
    ],
  );
}

class _FakeInvitationRepository implements ThreadInvitationRepository {
  @override
  Future<ThreadInvitationLink> generateLink(String threadId) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadInvitationPreview> preview(String token) {
    throw UnimplementedError();
  }
}

class _FakeSubthreadRepository implements SubthreadManagementRepository {
  @override
  Future<SubthreadManagementBootstrap> load(String threadId) async {
    return SubthreadManagementBootstrap(
      threadId: threadId,
      threadTitle: '原主题',
      items: const [],
    );
  }

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) => throw UnimplementedError();

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) => throw UnimplementedError();

  @override
  Future<void> remove(SubthreadManagementItem item) =>
      throw UnimplementedError();

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) => throw UnimplementedError();

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) => throw UnimplementedError();
}
