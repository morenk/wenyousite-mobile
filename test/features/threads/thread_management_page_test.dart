import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_page.dart';

void main() {
  testWidgets('主题管理页进入独立子贴工作台', (tester) async {
    await _pumpPage(tester, _FakeRepository(initial: _bootstrap()));

    final entry = find.byKey(const Key('thread-management-open-subthreads'));
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(find.text('子贴工作台占位'), findsOneWidget);
  });

  testWidgets('楼主修改标题并保存后返回主题详情调用方', (tester) async {
    final repository = _FakeRepository(initial: _bootstrap());
    await _pumpPage(tester, repository);

    expect(find.text('主题信息'), findsOneWidget);
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
    expect(
      tester
          .widget<WenyouAsyncPrimaryButton>(
            find.byKey(const Key('thread-management-save')),
          )
          .onPressed,
      isNotNull,
    );
    await tester.ensureVisible(find.byKey(const Key('thread-management-save')));
    await tester.tap(find.byKey(const Key('thread-management-save')));
    await tester.pumpAndSettle();

    expect(repository.lastDraft?.title, '新的主题标题');
    expect(find.text('主题详情占位'), findsOneWidget);
  });

  testWidgets('协作者可编辑常规信息但不能修改可见性或删除主题', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(initial: _bootstrap(isOwner: false)),
    );

    final visibility = tester
        .widget<DropdownButtonFormField<ThreadManagementVisibility>>(
          find.descendant(
            of: find.byKey(const Key('thread-management-visibility')),
            matching: find.byType(
              DropdownButtonFormField<ThreadManagementVisibility>,
            ),
          ),
        );
    expect(visibility.onChanged, isNull);
    expect(find.textContaining('可见范围仅楼主可修改'), findsOneWidget);
    expect(find.byKey(const Key('thread-management-delete')), findsNothing);
  });

  testWidgets('只有已发布私密主题楼主看到邀请链接管理', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(
        initial: _bootstrap(visibility: ThreadManagementVisibility.private),
      ),
      invitationRepository: _FakeInvitationRepository(),
    );
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
    await tester.ensureVisible(find.byKey(const Key('thread-management-save')));
    await tester.tap(find.byKey(const Key('thread-management-save')));
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
    await tester.tap(
      find.byKey(const Key('thread-management-resolve-conflict')),
    );
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

  testWidgets('40107 提供邮箱验证入口并保留表单', (tester) async {
    final repository = _FakeRepository(
      initial: _bootstrap(),
      updateFailure: const ApiFailure(
        userMessage: '请先完成邮箱验证。',
        businessCode: 40107,
      ),
    );
    await _pumpPage(tester, repository);
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '验证后继续保存',
    );
    await tester.ensureVisible(find.byKey(const Key('thread-management-save')));
    await tester.tap(find.byKey(const Key('thread-management-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-management-verify-email')));
    await tester.pumpAndSettle();
    expect(find.text('邮箱验证占位'), findsOneWidget);
    await tester.tap(find.text('完成验证'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-management-failure')), findsNothing);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('thread-management-title')),
          )
          .controller!
          .text,
      '验证后继续保存',
    );
  });

  testWidgets('有未保存修改时返回需要明确确认放弃', (tester) async {
    await _pumpPage(tester, _FakeRepository(initial: _bootstrap()));
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '还没保存的标题',
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
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
      expect(find.text('主题信息'), findsOneWidget);
      expect(find.byKey(const Key('thread-management-save')), findsOneWidget);
    });
  }
}

Future<void> _pumpPage(
  WidgetTester tester,
  ThreadManagementRepository repository, {
  ThreadInvitationRepository? invitationRepository,
}) async {
  final container = ProviderContainer(
    overrides: [
      threadManagementRepositoryProvider.overrideWithValue(repository),
      if (invitationRepository != null)
        threadInvitationRepositoryProvider.overrideWithValue(
          invitationRepository,
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
        path: '/threads/:threadId/manage/subthreads',
        builder: (_, _) => const Scaffold(body: Text('子贴工作台占位')),
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
    this.updateFailure,
  }) : latest = latest ?? initial;

  final ThreadManagementBootstrap initial;
  final ThreadManagementBootstrap latest;
  final bool conflictOnce;
  final ApiFailure? updateFailure;
  int loadCalls = 0;
  int removeCalls = 0;
  bool _didConflict = false;
  ThreadManagementDraft? lastDraft;

  @override
  Future<ThreadManagementBootstrap> load(String threadId) async {
    loadCalls += 1;
    return loadCalls == 1 ? initial : latest;
  }

  @override
  Future<void> remove(String threadId) async {
    removeCalls += 1;
  }

  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) async {
    lastDraft = draft;
    if (conflictOnce && !_didConflict) {
      _didConflict = true;
      throw const ApiFailure(
        userMessage: '内容已在其他位置修改',
        businessCode: 40002,
        httpStatus: 409,
      );
    }
    if (updateFailure != null) throw updateFailure!;
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
    );
  }
}

ThreadManagementBootstrap _bootstrap({
  int version = 1,
  String title = '原主题',
  bool isOwner = true,
  ThreadManagementVisibility visibility = ThreadManagementVisibility.public,
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
      canManage: true,
      isOwner: isOwner,
    ),
    categories: const [
      ThreadManagementCategory(slug: 'RPG', name: '角色扮演', sortOrder: 1),
      ThreadManagementCategory(slug: 'BOARD', name: '综合讨论', sortOrder: 2),
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
