import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import 'me_page_test_support.dart';

void registerMePageMediaLifecycleCases() {
  testWidgets('头像确认取景后在上传等待期间立即显示本地成品', (tester) async {
    final media = MePageTestDeferredMediaGateway();
    final container = await mePageTestAuthenticatedContainer(
      MePageTestFakeMeProfileRepository(),
      avatarPicker: MePageTestFakeAvatarPicker(mePageTestAvatarInput),
      mediaRepository: media,
      avatarRepository: MePageTestFakeAvatarRepository(),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('me-avatar-change')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pump();
    await tester.pump();

    expect(media.operations, hasLength(1));
    expect(find.byKey(const Key('me-avatar-local-preview')), findsOneWidget);
    media.complete(0);
    await tester.pumpAndSettle();
    expect(find.text('头像已更新。'), findsOneWidget);
  });

  testWidgets('头像选图失败后主动显示错误并允许重新选择', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = await mePageTestAuthenticatedContainer(
      MePageTestFakeMeProfileRepository(),
      avatarPicker: MePageTestFakeAvatarPicker(
        null,
        failure: const ApiFailure(
          userMessage: '系统相册没有返回图片，请重试。',
          requestId: 'avatar-picker-request',
        ),
      ),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    final change = find.byKey(const Key('me-avatar-change'));
    await tester.ensureVisible(change);
    await tester.tap(change);
    await tester.pumpAndSettle();

    final failure = find.byKey(const Key('me-avatar-failure'));
    expect(failure, findsOneWidget);
    expect(find.text('系统相册没有返回图片，请重试。'), findsOneWidget);
    expect(find.textContaining('问题编号：avatar-picker-request'), findsOneWidget);
    expect(find.text('重新选择'), findsOneWidget);
    expect(tester.getRect(failure).top, lessThan(480));
  });

  testWidgets('设置失败保留请求 ID，重试只调用设置端点', (tester) async {
    var failOnce = true;
    final repository = MePageTestFakeMeProfileRepository();
    final media = MePageTestFakeMediaRepository();
    final avatar = MePageTestFakeAvatarRepository(
      onSet: (_) async {
        if (failOnce) {
          failOnce = false;
          throw const ApiFailure(
            userMessage: '头像暂时无法设置。',
            requestId: 'avatar-widget-request-id',
          );
        }
        return mePageTestAvatarSetResult;
      },
    );
    final container = await mePageTestAuthenticatedContainer(
      repository,
      avatarPicker: MePageTestFakeAvatarPicker(mePageTestAvatarInput),
      mediaRepository: media,
      avatarRepository: avatar,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('me-avatar-change')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('问题编号：avatar-widget-request-id'),
      findsOneWidget,
    );
    expect(find.text('重试设置'), findsOneWidget);

    await tester.tap(find.byKey(const Key('me-avatar-retry')));
    await tester.pumpAndSettle();
    expect(media.uploadCalls, 1);
    expect(avatar.setCalls, 2);
    expect(find.text('头像已更新。'), findsOneWidget);
  });

  testWidgets('主页背景可分别调整网页端与手机端取景后再上传', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final media = MePageTestFakeMediaRepository();
    final coverRepository = MePageTestFakeProfileCoverRepository();
    final cropProcessor = MePageTestFakeImageCropProcessor();
    final container = await mePageTestAuthenticatedContainer(
      repository,
      profileCoverPicker: MePageTestFakeProfileCoverPicker(
        mePageTestAvatarInput,
      ),
      profileCoverRepository: coverRepository,
      imageCropProcessor: cropProcessor,
      mediaRepository: media,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('me-profile-cover-change')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-profile-cover-change')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-cover-crop-dialog')), findsOneWidget);
    expect(find.text('网页端 3:1'), findsOneWidget);
    expect(find.text('手机端 2:1'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('image-crop-zoom')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('image-crop-zoom')),
      const Offset(120, 0),
    );
    await tester.pump();
    await tester.tap(find.text('手机端 2:1'));
    await tester.pump();
    expect(find.byKey(const Key('profile-cover-crop-mobile')), findsOneWidget);
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();

    expect(cropProcessor.coverCropCalls, 1);
    expect(
      cropProcessor.lastWebCrop!.width,
      lessThan(cropProcessor.lastMobileCrop!.width),
    );
    expect(media.uploadCalls, 2);
    expect(coverRepository.setCalls, 1);
    expect(find.text('主页背景已更新。'), findsOneWidget);
  });

  testWidgets('主页背景确认双画幅后立即预览且两份上传同时启动', (tester) async {
    final media = MePageTestDeferredMediaGateway();
    final container = await mePageTestAuthenticatedContainer(
      MePageTestFakeMeProfileRepository(),
      profileCoverPicker: MePageTestFakeProfileCoverPicker(
        mePageTestAvatarInput,
      ),
      profileCoverRepository: MePageTestFakeProfileCoverRepository(),
      mediaRepository: media,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('me-profile-cover-change')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-profile-cover-change')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pump();
    await tester.pump();

    expect(media.operations, hasLength(2));
    expect(
      find.byKey(const Key('me-profile-cover-local-preview')),
      findsOneWidget,
    );
    media.complete(0);
    media.complete(1);
    await tester.pumpAndSettle();
    expect(find.text('主页背景已更新。'), findsOneWidget);
  });

  testWidgets('背景选图期间资料刷新替换编辑器后仍继续裁剪和上传', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final picker = MePageTestDeferredProfileCoverPicker();
    final media = MePageTestFakeMediaRepository();
    final coverRepository = MePageTestFakeProfileCoverRepository();
    final container = await mePageTestAuthenticatedContainer(
      repository,
      profileCoverPicker: picker,
      profileCoverRepository: coverRepository,
      mediaRepository: media,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    final change = find.byKey(const Key('me-profile-cover-change'));
    await tester.ensureVisible(change);
    await tester.pumpAndSettle();
    await tester.tap(change);
    await tester.pump();

    final reload = Completer<MeProfileModel>();
    repository.deferNextFetch(reload);
    container.invalidate(meProfileControllerProvider);
    await tester.pump();
    expect(find.byKey(const Key('wenyou-detail-skeleton')), findsOneWidget);

    reload.complete(repository.profile);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('me-profile-cover-change')), findsOneWidget);

    picker.complete(mePageTestAvatarInput);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-cover-crop-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();
    expect(media.uploadCalls, 2);
    expect(coverRepository.setCalls, 1);
    expect(find.text('主页背景已更新。'), findsOneWidget);
  });

  testWidgets('头像选图期间资料刷新替换编辑器后仍继续裁剪和上传', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final picker = MePageTestDeferredAvatarPicker();
    final media = MePageTestFakeMediaRepository();
    final avatar = MePageTestFakeAvatarRepository();
    final container = await mePageTestAuthenticatedContainer(
      repository,
      avatarPicker: picker,
      mediaRepository: media,
      avatarRepository: avatar,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('me-avatar-change')));
    await tester.pump();

    final reload = Completer<MeProfileModel>();
    repository.deferNextFetch(reload);
    container.invalidate(meProfileControllerProvider);
    await tester.pump();
    expect(find.byKey(const Key('wenyou-detail-skeleton')), findsOneWidget);

    reload.complete(repository.profile);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('me-avatar-change')), findsOneWidget);

    picker.complete(mePageTestAvatarInput);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('avatar-crop-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();
    expect(media.uploadCalls, 1);
    expect(avatar.setCalls, 1);
    expect(find.text('头像已更新。'), findsOneWidget);
  });

  testWidgets('主页背景上传失败后主动显示错误并保留同图重试', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = await mePageTestAuthenticatedContainer(
      MePageTestFakeMeProfileRepository(),
      profileCoverPicker: MePageTestFakeProfileCoverPicker(
        mePageTestAvatarInput,
      ),
      mediaRepository: MePageTestFailingProfileCoverUploadGateway(),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    final change = find.byKey(const Key('me-profile-cover-change'));
    await tester.ensureVisible(change);
    await tester.pumpAndSettle();
    await tester.tap(change);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();

    final failure = find.byKey(const Key('me-profile-cover-failure'));
    expect(failure, findsOneWidget);
    expect(find.text('背景图上传失败，请重试。'), findsOneWidget);
    expect(find.textContaining('问题编号：cover-upload-request'), findsOneWidget);
    expect(find.textContaining('问题环节：内容处理'), findsOneWidget);
    expect(find.text('复制问题详情'), findsOneWidget);
    expect(find.text('重试上传'), findsOneWidget);
    expect(tester.getRect(failure).top, lessThan(640));
  });

  testWidgets('主页背景选图失败后主动显示错误并允许重新选择', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = await mePageTestAuthenticatedContainer(
      MePageTestFakeMeProfileRepository(),
      profileCoverPicker: const MePageTestFakeProfileCoverPicker(
        null,
        failure: ApiFailure(
          userMessage: '系统相册没有返回背景图，请重试。',
          requestId: 'cover-picker-request',
        ),
      ),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    final change = find.byKey(const Key('me-profile-cover-change'));
    await tester.ensureVisible(change);
    await tester.tap(change);
    await tester.pumpAndSettle();

    final failure = find.byKey(const Key('me-profile-cover-failure'));
    expect(failure, findsOneWidget);
    expect(find.text('系统相册没有返回背景图，请重试。'), findsOneWidget);
    expect(find.textContaining('问题编号：cover-picker-request'), findsOneWidget);
    expect(find.text('重新选择'), findsOneWidget);
    expect(tester.getRect(failure).top, lessThan(640));
  });

  testWidgets('已有头像二次确认后移除并回到默认占位', (tester) async {
    final repository = MePageTestFakeMeProfileRepository(
      initialProfile: mePageTestProfileWithAvatar(
        'https://cdn.example.com/old.png',
      ),
    );
    final avatar = MePageTestFakeAvatarRepository();
    final container = await mePageTestAuthenticatedContainer(
      repository,
      avatarRepository: avatar,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('me-avatar-change')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-avatar-remove')));
    await tester.pumpAndSettle();
    expect(find.text('移除头像？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('me-avatar-remove-confirm')));
    await tester.pumpAndSettle();

    expect(avatar.removeCalls, 1);
    expect(find.text('头像已移除。'), findsOneWidget);
    expect(find.bySemanticsLabel('添加头像'), findsOneWidget);
    expect(find.byKey(const Key('me-avatar-remove')), findsNothing);
  });

  testWidgets('已有主页背景从统一操作面板二次确认后移除', (tester) async {
    final cover = MePageTestFakeProfileCoverRepository();
    final repository = MePageTestFakeMeProfileRepository(
      initialProfile: mePageTestProfileWithCover(),
    );
    final container = await mePageTestAuthenticatedContainer(
      repository,
      profileCoverRepository: cover,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('me-profile-cover-change')));
    await tester.pumpAndSettle();
    expect(find.text('更换主页背景'), findsOneWidget);
    await tester.tap(find.byKey(const Key('me-profile-cover-remove')));
    await tester.pumpAndSettle();
    expect(find.text('移除主页背景？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('me-profile-cover-remove-confirm')));
    await tester.pumpAndSettle();

    expect(cover.removeCalls, 1);
    expect(find.text('主页背景已移除。'), findsOneWidget);
    expect(find.bySemanticsLabel('添加主页背景'), findsOneWidget);
  });

  testWidgets('编辑资料加载失败可重试且已有简介不能伪装清空', (tester) async {
    final repository = MePageTestFakeMeProfileRepository(failFetchOnce: true);
    final container = await mePageTestAuthenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('资料加载失败'), findsOneWidget);
    expect(find.byKey(const Key('logout-submit')), findsNothing);
    await tester.tap(find.byKey(const Key('me-edit-retry')));
    await tester.pumpAndSettle();
    expect(find.text('温柔测试员'), findsWidgets);

    await tester.enterText(find.byKey(const Key('me-bio-field')), '');
    await tester.ensureVisible(find.byKey(const Key('me-settings-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-settings-save')));
    await tester.pump();
    expect(find.text('请至少保留 1 个字符'), findsOneWidget);
    expect(repository.updateCalls, 0);
  });
}
