import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import '../../support/deterministic_test_fonts.dart';
import 'thread_management_test_support.dart';

void registerThreadManagementPostingPolicyCases() {
  setUpAll(loadDeterministicTestFonts);
  const rowKey = Key('thread-management-posting-policy');
  Future<void> choose(WidgetTester tester, String value) async {
    await tester.ensureVisible(find.byKey(rowKey));
    await tester.tap(find.byKey(rowKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey('thread-management-posting-policy-choice-$value')),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('主贴权限读取实际值并复用发布设置的单选列表，关闭不保存', (tester) async {
    final repository = ThreadManagementTestRepository(
      initial: threadManagementTestBootstrap(
        postingPolicy: SubthreadPostingPolicy.players,
      ),
    );
    await pumpThreadManagementTestPage(tester, repository);
    expect(
      find.descendant(of: find.byKey(rowKey), matching: find.text('仅玩家')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(rowKey));
    await tester.pumpAndSettle();
    expect(find.text('仅影响主贴下的发言，子贴权限单独设置。'), findsOneWidget);
    expect(find.text('玩家、楼主和协作者可以发言'), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(
            find.byKey(
              const ValueKey('thread-management-posting-policy-choice-players'),
            ),
          )
          .selected,
      isTrue,
    );
    Navigator.of(tester.element(find.text('有权查看的登录用户均可发言'))).pop();
    await tester.pumpAndSettle();
    expect(repository.updateCalls, 0);
    expect(find.text('仅玩家'), findsOneWidget);
  });

  testWidgets('协作者修改主贴权限与待保存标题合并一次自动保存，重复选择不重发', (tester) async {
    final repository = ThreadManagementTestRepository(
      initial: threadManagementTestBootstrap(isOwner: false),
    );
    await pumpThreadManagementTestPage(tester, repository);
    // 保留尚未失焦提交的文字，使权限变更走整页聚合保存。
    tester
            .widget<TextFormField>(
              find.byKey(const Key('thread-management-title')),
            )
            .controller!
            .text =
        '一起保存的新标题';
    await choose(tester, 'collaborators');
    expect(repository.lastDraft?.title, '一起保存的新标题');
    expect(
      repository.lastDraft?.defaultSubthreadPostingPolicy,
      SubthreadPostingPolicy.collaborators,
    );
    expect(repository.updateCalls, 1);
    await choose(tester, 'collaborators');
    expect(repository.updateCalls, 1);
    await choose(tester, 'players');
    await choose(tester, 'participants');
    expect(repository.updateCalls, 3);
    expect(
      repository.lastDraft?.defaultSubthreadPostingPolicy,
      SubthreadPostingPolicy.participants,
    );
    expect(find.byKey(const Key('thread-management-save')), findsNothing);
  });

  testWidgets('未发布主题不显示主贴发言权限入口', (tester) async {
    await pumpThreadManagementTestPage(
      tester,
      ThreadManagementTestRepository(
        initial: threadManagementTestBootstrap(published: false),
      ),
    );
    expect(find.byKey(rowKey), findsNothing);
  });

  testWidgets('无改动切换页签后主贴权限仍可自动保存', (tester) async {
    final repository = ThreadManagementTestRepository(
      initial: threadManagementTestBootstrap(),
    );
    await pumpThreadManagementTestPage(
      tester,
      repository,
      subthreadRepository: ThreadManagementTestSubthreadRepository(),
    );
    await tester.tap(
      find.byKey(
        const ValueKey(
          'thread-management-tab-ThreadManagementSection.subthreads',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'thread-management-tab-ThreadManagementSection.settings',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await choose(tester, 'players');
    expect(repository.updateCalls, 1);
    expect(
      repository.lastDraft?.defaultSubthreadPostingPolicy,
      SubthreadPostingPolicy.players,
    );
  });

  testWidgets('主贴权限保存失败保留选择，离开仍需确认放弃', (tester) async {
    final repository = ThreadManagementTestRepository(
      initial: threadManagementTestBootstrap(),
      updateFailure: const ApiFailure(userMessage: '操作失败，请重试。'),
    );
    await pumpThreadManagementTestPage(tester, repository);
    await choose(tester, 'players');
    expect(find.text('仅玩家'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-management-autosave-retry')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('修改还没有保存'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('仅玩家'), findsOneWidget);
  });

  testWidgets('主贴权限冲突保留选择，采用最新版恢复实际权限', (tester) async {
    final repository = ThreadManagementTestRepository(
      initial: threadManagementTestBootstrap(version: 2),
      latest: threadManagementTestBootstrap(
        version: 3,
        postingPolicy: SubthreadPostingPolicy.collaborators,
      ),
      conflictOnce: true,
    );
    await pumpThreadManagementTestPage(tester, repository);
    await choose(tester, 'players');
    expect(find.text('仅玩家'), findsOneWidget);
    final action = find.byKey(const Key('thread-management-resolve-conflict'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-management-use-latest')));
    await tester.pumpAndSettle();
    expect(find.text('仅协作者'), findsOneWidget);
    expect(find.text('仅玩家'), findsNothing);
    expect(repository.updateCalls, 1);
  });

  testWidgets('320dp 两倍字体的主贴权限设置与完整选项无溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1000);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpThreadManagementTestPage(
      tester,
      ThreadManagementTestRepository(initial: threadManagementTestBootstrap()),
    );
    await tester.ensureVisible(find.byKey(rowKey));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(rowKey));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/thread_management_policy_320_text_2x.png'),
    );
  });
}
