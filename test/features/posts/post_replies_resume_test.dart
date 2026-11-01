import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/scripted_http_client_adapter.dart';
import 'post_replies_page_discussion_fixtures.dart';
import 'post_replies_resume_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('切回前台收到相同新 meta，第14条中段与已加载窗口保持', (tester) async {
    final h = RepliesResumeHarness();
    addTearDown(h.close);
    await h.mount(tester);
    await tester.runAsync(
      () => h.controller.loadAdjacent().timeout(const Duration(seconds: 5)),
    );
    await pumpReplies(tester);
    expect(h.state.replies, hasLength(40));
    final before = await h.readAt(tester, 14);
    final controller = h.controller;
    final window = h.state.window;
    final requests = h.postRequests.length;
    final contract = h.container.read(startupControllerProvider).contract;
    final phases = <PostDiscussionPhase>[];
    final phaseSubscription = h.container.listen(
      h.provider.select((state) => state.phase),
      (_, phase) => phases.add(phase),
    );
    addTearDown(phaseSubscription.close);

    await h.resume(tester);

    h.expectBookmark(tester, before);
    expect(h.controller, same(controller));
    expect(h.state.window, same(window));
    expect(h.postRequests, hasLength(requests));
    expect(phases, isNot(contains(PostDiscussionPhase.loading)));
    expect(h.meta.calls, 2, reason: '保留每次恢复前台的更新检查');
    expect(
      h.container.read(startupControllerProvider).contract,
      isNot(same(contract)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('倒序与作者筛选、前后窗口恢复前台后保持', (tester) async {
    final h = RepliesResumeHarness();
    addTearDown(h.close);
    await h.mount(tester);
    await tester.runAsync(
      () => h.controller.applyFilters(
        order: PostReplyOrder.newest,
        authorId: 'author-1',
      ),
    );
    await pumpReplies(tester);
    final before = await h.readAt(tester, 14);
    final window = h.state.window;
    final requests = h.postRequests.length;

    await h.resume(tester);

    h.expectBookmark(tester, before);
    expect(h.state.order, PostReplyOrder.newest);
    expect(h.state.authorId, 'author-1');
    expect(h.state.window, same(window));
    expect(h.postRequests, hasLength(requests));
  });

  testWidgets('深链定位后读到第14条，恢复不重放入口目标', (tester) async {
    final h = RepliesResumeHarness(focusedReplyId: 'reply-3');
    addTearDown(h.close);
    await h.mount(tester);
    // 深链目标揭开及相邻窗口保位结束后，用户才开始下一段阅读。
    await _waitForTarget(tester);
    await pumpReplies(tester);
    expect(h.state.isPrefetchingReplies, isFalse);
    final before = await h.readAt(tester, 14);
    final requests = h.postRequests.length;

    await h.resume(tester);

    h.expectBookmark(tester, before);
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(h.postRequests, hasLength(requests));
  });

  testWidgets('数字跳转后继续阅读，恢复保留位置及回到刚才', (tester) async {
    final h = RepliesResumeHarness();
    addTearDown(h.close);
    await h.mount(tester);
    final original = await h.readAt(tester, 14);
    await tester.tap(find.byKey(const Key('discussion-position-button')));
    await pumpReplies(tester);
    await tester.enterText(
      find.byKey(const Key('discussion-number-input')),
      '30',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('discussion-number-submit')));
    await pumpReplies(tester);
    expect(find.byKey(const Key('discussion-number-input')), findsNothing);
    await _waitForTarget(tester);
    // 揭开目标后会补入前一页，先让这一轮窗口保位完成再开始下一次阅读。
    await pumpReplies(tester);
    expect(h.state.isPrefetchingReplies, isFalse);
    await tester.timedDrag(
      find.byKey(const Key('post-replies-list')),
      const Offset(0, -95),
      const Duration(milliseconds: 240),
    );
    await tester.pump(const Duration(milliseconds: 160));
    final scroll = h.reading(tester).scrollController;
    scroll.jumpTo(scroll.offset); // 在用户已停下阅读的位置恢复，排除手势惯性。
    await tester.pump();
    final before = h.reading(tester).captureBookmark()!;
    expect(before.id, 'reply-30');
    expect(before.offset, greaterThan(40));

    await h.resume(tester);

    h.expectBookmark(tester, before);
    expect(find.text('回到刚才'), findsOneWidget);
    await tester.tap(find.text('回到刚才'));
    await pumpReplies(tester);
    await _waitForTarget(tester);
    await pumpReplies(tester);
    h.expectBookmark(tester, original);
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpReplies(tester);
    expect(tester.takeException(), isNull);
  });

  for (final outcome in ['delayed', 'failed', 'unrelated']) {
    testWidgets('前台 meta $outcome 保留讨论且不增加首屏读取', (tester) async {
      final h = RepliesResumeHarness();
      addTearDown(h.close);
      await h.mount(tester);
      final before = await h.readAt(tester, 14);
      final controller = h.controller;
      final requests = h.postRequests.length;
      h.meta.fail = outcome == 'failed';
      h.meta.unrelated = outcome == 'unrelated';
      final gate = outcome == 'delayed' ? Completer<ContractInfo>() : null;
      h.meta.gate = gate;

      await h.resume(tester);
      h.expectBookmark(tester, before);
      expect(find.byType(WenyouDetailSkeleton), findsNothing);
      expect(h.controller, same(controller));
      expect(h.postRequests, hasLength(requests));
      expect(h.meta.calls, 2);
      if (gate != null) {
        expect(
          h.container.read(startupControllerProvider).isRechecking,
          isTrue,
        );
        await h.resume(tester);
        expect(h.meta.calls, 2, reason: '在途检查不并发重启');
        gate.complete(h.meta.nextContract());
        await pumpReplies(tester);
        h.expectBookmark(tester, before);
        expect(h.controller, same(controller));
        expect(h.postRequests, hasLength(requests));
      }
      expect(
        h.container.read(startupControllerProvider).status,
        StartupStatus.ready,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('同账号 Token 轮换后恢复保持讨论，退出与会话失效仍刷新', (tester) async {
    final h = RepliesResumeHarness();
    h.tokenStore.value = postRepliesPageTestTokensFor('author-1');
    addTearDown(h.close);
    await h.mount(tester);
    final before = await h.readAt(tester, 14);
    final controller = h.controller;
    final session = h.container.read(sessionControllerProvider.notifier);
    final scope = session.scope;
    await session.refresh();
    await h.resume(tester);
    expect(session.scope, scope);
    expect(h.controller, same(controller));
    h.expectBookmark(tester, before);

    await session.invalidate(SessionInvalidationReason.revoked);
    await pumpReplies(tester);
    expect(h.controller, isNot(same(controller)));
    expect(h.state.phase, PostDiscussionPhase.ready);
    final invalidated = h.controller;
    await session.authenticate(postRepliesPageTestTokensFor('author-2'));
    await pumpReplies(tester);
    expect(h.controller, isNot(same(invalidated)));
    final authenticated = h.controller;
    await session.logoutLocally();
    await pumpReplies(tester);
    expect(h.controller, isNot(same(authenticated)));
    expect(session.currentUserId, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('切号时刷新内容，旧账号迟到首屏不能覆盖新账号', (tester) async {
    final h = RepliesResumeHarness();
    h.tokenStore.value = postRepliesPageTestTokensFor('author-1');
    final oldRoot = h.rootDto()..['content'] = '旧账号迟到楼层';
    final gate = Completer<ScriptedHttpResponse>();
    h.rootGate = gate;
    addTearDown(h.close);
    await h.mount(tester, allowLoading: true);
    expect(h.state.phase, PostDiscussionPhase.loading);
    final oldController = h.controller;
    h.rootContent = '新账号楼层';
    await h.container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-2'));
    await pumpReplies(tester);
    expect(h.controller, isNot(same(oldController)));
    expect(h.state.root?.content, '新账号楼层');

    gate.complete(
      ScriptedHttpResponse.json(RepliesResumeHarness.envelope(oldRoot)),
    );
    await pumpReplies(tester);

    expect(h.state.root?.content, '新账号楼层');
    expect(find.text('旧账号迟到楼层'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('可见性失效仍重新验证讨论并替换旧投影', (tester) async {
    final h = RepliesResumeHarness();
    addTearDown(h.close);
    await h.mount(tester);
    final controller = h.controller;
    h.rootContent = '可见性变化后的原楼层';
    h.container.read(visibilityCacheInvalidatorProvider)();
    await pumpReplies(tester);
    expect(h.controller, isNot(same(controller)));
    expect(h.state.root?.content, h.rootContent);
    expect(tester.takeException(), isNull);
  });

  for (final capability in ['mentions', 'fonts', 'fontsV2', 'colors']) {
    testWidgets('真实能力 $capability 变化更新新写入载荷，关闭后撤回声明', (tester) async {
      final h = RepliesResumeHarness();
      addTearDown(h.close);
      // 不挂阅读页：只观察生产仓库装配，创建仅进入内存 adapter。
      final startup = (await tester.runAsync(() async {
        final controller = h.container.read(startupControllerProvider.notifier);
        await controller.check();
        return controller;
      }))!;
      final oldRepository = h.container.read(postRepositoryProvider);
      switch (capability) {
        case 'mentions':
          h.meta.mentions = true;
        case 'fonts':
          h.meta.fonts = true;
        case 'fontsV2':
          h.meta.fontsV2 = true;
        case 'colors':
          h.meta.colors = true;
      }
      await tester.runAsync(startup.recheckForUpdate);
      final enabled = h.container.read(postRepositoryProvider);
      expect(enabled, isNot(same(oldRepository)));
      h.acceptCreates = true;
      const input = PostCreateInput(
        subthreadId: 'subthread',
        parentPostId: 'root',
        content: '新的普通回复',
        clientRequestId: '11111111-1111-4111-8111-111111111111',
      );
      await tester.runAsync(() => enabled.create(input));
      final payload = h.postRequests.last.data as Map<String, dynamic>;
      final field = switch (capability) {
        'mentions' => 'markdownContractVersion',
        'colors' => 'textColorVersion',
        _ => 'textFontVersion',
      };
      expect(
        payload[field],
        capability == 'mentions'
            ? 6
            : capability == 'fontsV2'
            ? 2
            : 1,
      );

      h.meta.mentions = h.meta.fonts = h.meta.fontsV2 = h.meta.colors = false;
      await tester.runAsync(startup.recheckForUpdate);
      final disabled = h.container.read(postRepositoryProvider);
      expect(disabled, isNot(same(enabled)));
      await tester.runAsync(() => disabled.create(input));
      final reverted = h.postRequests.last.data as Map<String, dynamic>;
      expect(reverted, isNot(contains(field)));
    });
  }
}

Future<void> _waitForTarget(WidgetTester tester) async {
  final cover = find.byKey(const Key('discussion-target-cover'));
  for (var frame = 0; frame < 40 && cover.evaluate().isNotEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
  expect(cover, findsNothing);
}
