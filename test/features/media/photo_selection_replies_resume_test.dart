import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_instant_keyboard_insets.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_page.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';

import '../../support/deterministic_test_fonts.dart';
import '../posts/post_replies_resume_test_support.dart';
import 'photo_selection_app_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDeterministicTestFonts);

  testWidgets(
    '组合候选：第14条中段打开头像图库，首次inset与恢复检查后取消保位',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final permissionCalls = <MethodCall>[];
      const photos = MethodChannel('com.fluttercandies/photo_manager');
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(photos, (call) async {
        if (call.method != 'requestPermissionExtend' &&
            call.method != 'getPermissionState') {
          throw StateError('意外图库 IO：${call.method}');
        }
        permissionCalls.add(call);
        // 拒绝读取；仍展示选择页及恢复入口，不访问真实图库。
        return PermissionState.denied.index;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(photos, null));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      late PhotoEntryAppFixture fixture;
      final h = RepliesResumeHarness(
        createContainer: (ioOverrides) {
          fixture = PhotoEntryAppFixture(
            readyStartup: false,
            overrides: ioOverrides,
          );
          return fixture.container;
        },
      );
      addTearDown(fixture.dispose);
      addTearDown(() => h.dio.close(force: true));
      // 完整 WenyouApp、真实路由/启动控制器/能力映射/生成客户端/帖子仓库。
      // 仅外部 IO 使用内存实现，没有 override postRepository。
      await fixture.pump(tester, '/me/edit');
      final router = fixture.container.read(appRouterProvider);
      router.go('/threads/thread/posts/root/replies');
      await pumpReplies(tester);
      expect(h.state.phase, PostDiscussionPhase.ready);
      await tester.runAsync(() => h.controller.loadAdjacent());
      await pumpReplies(tester);
      expect(h.state.replies, hasLength(40));
      final before = await h.readAt(tester, 14);
      final repository = h.container.read(postRepositoryProvider);
      final controller = h.controller;
      final window = h.state.window;
      final scope = h.container.read(sessionScopeProvider);
      final contract = h.container.read(startupControllerProvider).contract;
      final checks = h.meta.calls;
      final requests = h.postRequests.length;
      final phases = <PostDiscussionPhase>[];
      final subscription = h.container.listen(
        h.provider.select((state) => state.phase),
        (_, next) => phases.add(next),
      );
      addTearDown(subscription.close);

      unawaited(router.push<void>('/me/edit'));
      await pumpReplies(tester);
      await tester.tap(find.byKey(const Key('me-avatar-change')));
      await pumpReplies(tester);
      final gallery = find.byType(PhotoSelectionPage);
      expect(gallery, findsOneWidget);
      final galleryState = tester.state(gallery);
      expect(
        tester.widget<PhotoSelectionPage>(gallery).request.purpose,
        MediaUploadPurpose.avatar,
      );
      expect(permissionCalls.map((call) => call.method), [
        'requestPermissionExtend',
      ]);

      final completed = Completer<void>();
      await messenger.handlePlatformMessage(
        WenyouInstantKeyboardInsets.channelName,
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('keyboardInsetTargetChanged', {
            'bottomPhysicalPixels': 0.0,
          }),
        ),
        (_) => completed.complete(),
      );
      await completed.future;
      await pumpReplies(tester);
      expect(tester.state(gallery), same(galleryState));
      // 完整 App 含 AppLifecycleListener，按平台合法顺序进入/退出 paused。
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await pumpReplies(tester);

      expect(tester.state(gallery), same(galleryState));
      expect(h.container.read(sessionScopeProvider), scope);
      expect(h.container.read(sessionScopeProvider).accountId, 'user-1');
      expect(h.meta.calls, checks + 1, reason: '保留实际恢复前台更新检查');
      expect(
        h.container.read(startupControllerProvider).contract,
        isNot(same(contract)),
      );
      expect(permissionCalls.map((call) => call.method), [
        'requestPermissionExtend',
        'getPermissionState',
      ]);
      expect(
        h.container.read(photoSelectionCoordinatorProvider).presenter,
        isNotNull,
      );
      await tester.tap(find.byTooltip('取消选择'));
      await pumpReplies(tester);
      expect(gallery, findsNothing);
      router.pop();
      await pumpReplies(tester);

      h.expectBookmark(tester, before);
      expect(h.container.read(postRepositoryProvider), same(repository));
      expect(h.controller, same(controller));
      expect(h.state.window, same(window));
      expect(h.postRequests, hasLength(requests));
      expect(phases, isNot(contains(PostDiscussionPhase.loading)));
      expect(
        h.postRequests.every((request) => request.method == 'GET'),
        isTrue,
      );
      fixture.expectNoWrites();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      fixture.dispose();
      await pumpReplies(tester);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
