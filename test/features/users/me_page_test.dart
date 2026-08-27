import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_content_dashboard.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

void main() {
  testWidgets('游客我的页提供登录入口且不读取私有资料', (tester) async {
    final repository = _FakeMeProfileRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [meProfileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.light, home: const MePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前以游客身份浏览'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.byKey(const Key('open-appearance-settings')), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
    expect(repository.fetchCalls, 0);
  });

  testWidgets('本人中心展示身份摘要、内容入口并下沉编辑与设置', (tester) async {
    final repository = _FakeMeProfileRepository();
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('温柔测试员'), findsWidgets);
    expect(find.textContaining('o***@example.com'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('me-profile-header')),
        matching: find.text('Lv.4'),
      ),
      findsOneWidget,
    );
    expect(find.text('150 / 200 经验'), findsOneWidget);
    expect(find.byKey(const Key('me-profile-header')), findsOneWidget);
    expect(find.byKey(const Key('me-open-following')), findsOneWidget);
    expect(find.byKey(const Key('me-open-followers')), findsOneWidget);
    expect(find.byKey(const Key('me-open-wallet')), findsOneWidget);
    expect(find.byKey(const Key('me-open-bookmarks')), findsOneWidget);
    expect(find.text('温油'), findsOneWidget);
    final followingWidth = tester
        .getSize(find.byKey(const Key('me-open-following')))
        .width;
    expect(
      tester.getSize(find.byKey(const Key('me-open-followers'))).width,
      closeTo(followingWidth, 0.01),
    );
    expect(
      tester.getSize(find.byKey(const Key('me-open-wallet'))).width,
      closeTo(followingWidth, 0.01),
    );
    final editRect = tester.getRect(
      find.byKey(const Key('me-open-edit-profile')),
    );
    final bookmarkRect = tester.getRect(
      find.byKey(const Key('me-open-bookmarks')),
    );
    expect(bookmarkRect.top, editRect.top);
    expect(bookmarkRect.height, editRect.height);
    expect(bookmarkRect.width, closeTo(editRect.width, 0.01));
    expect(
      bookmarkRect.top,
      greaterThan(
        tester.getRect(find.byKey(const Key('me-open-wallet'))).bottom,
      ),
    );
    expect(find.byKey(const Key('me-open-edit-profile')), findsOneWidget);
    expect(find.byKey(const Key('me-open-public-profile')), findsNothing);
    expect(find.text('预览公开主页'), findsNothing);
    expect(find.byKey(const Key('me-open-settings')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byKey(const Key('me-open-settings')),
      ),
      findsOneWidget,
    );
    expect(find.text('我的内容'), findsNothing);
    await tester.drag(find.byType(NestedScrollView), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(find.text('概览'), findsOneWidget);
    expect(find.text('动态'), findsOneWidget);
    expect(find.text('创建'), findsOneWidget);
    expect(find.text('参与'), findsOneWidget);
    expect(find.text('帖子'), findsNothing);
    expect(find.text('创作概览'), findsOneWidget);
    expect(find.text('发布动态'), findsOneWidget);
    expect(find.text('创建主题'), findsOneWidget);
    expect(find.text('参与主题'), findsOneWidget);
    expect(find.text('累计回复'), findsOneWidget);
    expect(find.text('最近回复'), findsOneWidget);
    expect(find.text('创建的'), findsNothing);
    expect(find.text('参与的'), findsNothing);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('注销账号'), findsNothing);
    expect(find.text('公开最近回复'), findsNothing);
    expect(repository.fetchCalls, 1);
  });

  testWidgets('动态列表回到顶部后继续展开资料头并只从整页顶部刷新', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final profileRepository = _FakeMeProfileRepository();
    final publicRepository = _FakePublicUserRepository();
    final walletRepository = _FakeWalletRepository();
    final momentRepository = _FakeProfileMomentRepository();
    final container = await _authenticatedContainer(
      profileRepository,
      publicUserRepository: publicRepository,
      walletRepository: walletRepository,
      momentRepository: momentRepository,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: MePage(
            userMoments: MeUserMomentsIntegration(
              builder: (userId) => MomentFeedList(
                target: MomentFeedTarget.user(userId),
                emptyTitle: '还没有发布动态',
                emptyMessage: '',
                pullToRefreshEnabled: false,
              ),
              refresh: (userId) => container
                  .read(
                    momentFeedControllerProvider(
                      MomentFeedTarget.user(userId),
                    ).notifier,
                  )
                  .refresh(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.drag(find.byType(NestedScrollView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.text('动态'));
    await tester.pumpAndSettle();

    final nested = tester.widget<NestedScrollView>(
      find.byType(NestedScrollView),
    );
    final outer = nested.controller!;
    final moments = find.byType(CustomScrollView);
    expect(moments, findsOneWidget);
    final initialProfileCalls = profileRepository.fetchCalls;
    final initialWalletCalls = walletRepository.walletCalls;
    final initialMomentCalls = momentRepository.userCalls;

    expect(outer.offset, greaterThan(0));
    await tester.drag(moments, const Offset(0, 700));
    await tester.pumpAndSettle();

    expect(outer.offset, closeTo(0, 0.1));
    expect(find.byKey(const Key('me-profile-header')), findsOneWidget);
    expect(profileRepository.fetchCalls, initialProfileCalls);
    expect(walletRepository.walletCalls, initialWalletCalls);
    expect(momentRepository.userCalls, initialMomentCalls);

    await tester.drag(moments, const Offset(0, -1800));
    await tester.pumpAndSettle();
    expect(outer.offset, greaterThan(0));

    await tester.drag(moments, const Offset(0, 2400));
    await tester.pumpAndSettle();

    expect(outer.offset, closeTo(0, 0.1));
    expect(profileRepository.fetchCalls, initialProfileCalls);
    expect(walletRepository.walletCalls, initialWalletCalls);
    expect(momentRepository.userCalls, initialMomentCalls);

    await tester.drag(moments, const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(profileRepository.fetchCalls, initialProfileCalls + 1);
    expect(walletRepository.walletCalls, initialWalletCalls + 1);
    expect(momentRepository.userCalls, initialMomentCalls + 1);
    expect(publicRepository.activityCalls, 1);
    expect(publicRepository.replyCalls, 1);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('本人中心以同级温油入口展示余额并复用主题卡片', (tester) async {
    final repository = _FakeMeProfileRepository();
    final publicRepository = _FakePublicUserRepository();
    final walletRepository = _FakeWalletRepository(balance: '41');
    final container = await _authenticatedContainer(
      repository,
      publicUserRepository: publicRepository,
      walletRepository: walletRepository,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('41 升'), findsOneWidget);
    expect(find.byKey(const Key('me-open-wallet')), findsOneWidget);
    expect(find.text('钱包余额'), findsNothing);
    expect(find.textContaining('同一份实时余额'), findsNothing);

    await tester.drag(find.byType(NestedScrollView), const Offset(0, -240));
    await tester.pumpAndSettle();

    expect(publicRepository.replyCalls, 1);
    expect(publicRepository.activityCalls, 1);
    expect(publicRepository.createdCalls, 0);

    await tester.tap(
      find.byKey(const ValueKey('me-content-MeContentTab.createdThreads')),
    );
    await tester.pumpAndSettle();

    expect(find.text('创建的'), findsNothing);
    expect(find.text('参与的'), findsNothing);
    expect(find.text('我创建的星海主题'), findsOneWidget);
    expect(
      find.byKey(const Key('home-thread-card-thread-mine')),
      findsOneWidget,
    );
    expect(find.text('18 升'), findsNothing);
    expect(publicRepository.createdCalls, 1);
    expect(publicRepository.fetchUserCalls, 0);
    expect(walletRepository.walletCalls, 1);
  });

  testWidgets('服务端开启表情能力时我的页展示管理入口', (tester) async {
    final repository = _FakeMeProfileRepository();
    final container = await _authenticatedContainer(
      repository,
      stickersEnabled: true,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('me-open-stickers')));
    final stickers = find.byKey(const Key('me-open-stickers'));
    expect(stickers, findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: stickers),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('me-profile-header')),
        matching: stickers,
      ),
      findsOneWidget,
    );
    final actionWidths = [
      const Key('me-open-edit-profile'),
      const Key('me-open-bookmarks'),
      const Key('me-open-stickers'),
    ].map((key) => tester.getSize(find.byKey(key)).width).toSet();
    expect(actionWidths, hasLength(1));
  });

  testWidgets('用户名独立校验并只提交显式修改', (tester) async {
    final repository = _FakeMeProfileRepository();
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('me-username-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-username-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('me-username-field')), '不 合法');
    await tester.tap(find.byKey(const Key('me-username-save')));
    await tester.pump();
    expect(find.text('用户名只能包含字母、数字和中文'), findsOneWidget);
    expect(repository.updateCalls, 0);

    await tester.enterText(find.byKey(const Key('me-username-field')), '新名字');
    await tester.tap(find.byKey(const Key('me-username-save')));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 1);
    expect(repository.lastPatch?.username, '新名字');
    expect(repository.lastPatch?.bio, isNull);
    expect(find.text('用户名已更新。'), findsOneWidget);
  });

  testWidgets('简介和隐私设置只提交变化字段并采用服务端结果', (tester) async {
    final repository = _FakeMeProfileRepository();
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('用于主题、动态、评论和私聊中的身份识别。'), findsNothing);
    await tester.enterText(find.byKey(const Key('me-bio-field')), '新的移动端简介');
    await tester.ensureVisible(find.byKey(const Key('me-privacy-bookmarks')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-privacy-bookmarks')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('me-settings-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-settings-save')));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 1);
    expect(repository.lastPatch?.bio, '新的移动端简介');
    expect(repository.lastPatch?.showBookmarks, isFalse);
    expect(repository.lastPatch?.showRecentReplies, isNull);
    expect(find.text('资料与隐私设置已保存。'), findsOneWidget);
  });

  testWidgets('选择图片后复用媒体上传并立即采用服务端头像', (tester) async {
    final repository = _FakeMeProfileRepository();
    final picker = _FakeAvatarPicker(_avatarInput);
    final media = _FakeMediaRepository();
    final avatar = _FakeAvatarRepository();
    final container = await _authenticatedContainer(
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

    expect(find.text('选择头像'), findsOneWidget);
    await tester.tap(find.byKey(const Key('me-avatar-change')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('avatar-crop-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();

    expect(media.uploadCalls, 1);
    expect(avatar.setCalls, 1);
    expect(avatar.lastMediaId, 'media-avatar-1');
    expect(find.text('头像已更新。'), findsOneWidget);
    expect(find.text('更换头像'), findsOneWidget);
    expect(find.byKey(const Key('me-avatar-remove')), findsOneWidget);
  });

  testWidgets('头像确认取景后在上传等待期间立即显示本地成品', (tester) async {
    final media = _DeferredMediaGateway();
    final container = await _authenticatedContainer(
      _FakeMeProfileRepository(),
      avatarPicker: _FakeAvatarPicker(_avatarInput),
      mediaRepository: media,
      avatarRepository: _FakeAvatarRepository(),
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
    final container = await _authenticatedContainer(
      _FakeMeProfileRepository(),
      avatarPicker: _FakeAvatarPicker(
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
    expect(find.text('问题编号：avatar-picker-request'), findsOneWidget);
    expect(find.text('重新选择'), findsOneWidget);
    expect(tester.getRect(failure).top, lessThan(480));
  });

  testWidgets('设置失败保留请求 ID，重试只调用设置端点', (tester) async {
    var failOnce = true;
    final repository = _FakeMeProfileRepository();
    final media = _FakeMediaRepository();
    final avatar = _FakeAvatarRepository(
      onSet: (_) async {
        if (failOnce) {
          failOnce = false;
          throw const ApiFailure(
            userMessage: '头像暂时无法设置。',
            requestId: 'avatar-widget-request-id',
          );
        }
        return _avatarSetResult;
      },
    );
    final container = await _authenticatedContainer(
      repository,
      avatarPicker: _FakeAvatarPicker(_avatarInput),
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
    expect(find.text('问题编号：avatar-widget-request-id'), findsOneWidget);
    expect(find.text('重试设置'), findsOneWidget);

    await tester.tap(find.byKey(const Key('me-avatar-retry')));
    await tester.pumpAndSettle();
    expect(media.uploadCalls, 1);
    expect(avatar.setCalls, 2);
    expect(find.text('头像已更新。'), findsOneWidget);
  });

  testWidgets('主页背景可分别调整网页端与手机端取景后再上传', (tester) async {
    final repository = _FakeMeProfileRepository();
    final media = _FakeMediaRepository();
    final coverRepository = _FakeProfileCoverRepository();
    final cropProcessor = _FakeImageCropProcessor();
    final container = await _authenticatedContainer(
      repository,
      profileCoverPicker: _FakeProfileCoverPicker(_avatarInput),
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
    final media = _DeferredMediaGateway();
    final container = await _authenticatedContainer(
      _FakeMeProfileRepository(),
      profileCoverPicker: _FakeProfileCoverPicker(_avatarInput),
      profileCoverRepository: _FakeProfileCoverRepository(),
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
    final repository = _FakeMeProfileRepository();
    final picker = _DeferredProfileCoverPicker();
    final media = _FakeMediaRepository();
    final coverRepository = _FakeProfileCoverRepository();
    final container = await _authenticatedContainer(
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

    picker.complete(_avatarInput);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-cover-crop-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();
    expect(media.uploadCalls, 2);
    expect(coverRepository.setCalls, 1);
    expect(find.text('主页背景已更新。'), findsOneWidget);
  });

  testWidgets('头像选图期间资料刷新替换编辑器后仍继续裁剪和上传', (tester) async {
    final repository = _FakeMeProfileRepository();
    final picker = _DeferredAvatarPicker();
    final media = _FakeMediaRepository();
    final avatar = _FakeAvatarRepository();
    final container = await _authenticatedContainer(
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

    picker.complete(_avatarInput);
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
    final container = await _authenticatedContainer(
      _FakeMeProfileRepository(),
      profileCoverPicker: _FakeProfileCoverPicker(_avatarInput),
      mediaRepository: _FailingProfileCoverUploadGateway(),
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
    expect(find.text('问题编号：cover-upload-request'), findsOneWidget);
    expect(find.text('重试上传'), findsOneWidget);
    expect(tester.getRect(failure).top, lessThan(640));
  });

  testWidgets('主页背景选图失败后主动显示错误并允许重新选择', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = await _authenticatedContainer(
      _FakeMeProfileRepository(),
      profileCoverPicker: const _FakeProfileCoverPicker(
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
    expect(find.text('问题编号：cover-picker-request'), findsOneWidget);
    expect(find.text('重新选择'), findsOneWidget);
    expect(tester.getRect(failure).top, lessThan(640));
  });

  testWidgets('已有头像二次确认后移除并回到默认占位', (tester) async {
    final repository = _FakeMeProfileRepository(
      initialProfile: _profileWithAvatar('https://cdn.example.com/old.png'),
    );
    final avatar = _FakeAvatarRepository();
    final container = await _authenticatedContainer(
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

    await tester.tap(find.byKey(const Key('me-avatar-remove')));
    await tester.pumpAndSettle();
    expect(find.text('移除当前头像？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('me-avatar-remove-confirm')));
    await tester.pumpAndSettle();

    expect(avatar.removeCalls, 1);
    expect(find.text('头像已移除。'), findsOneWidget);
    expect(find.text('选择头像'), findsOneWidget);
    expect(find.byKey(const Key('me-avatar-remove')), findsNothing);
  });

  testWidgets('编辑资料加载失败可重试且已有简介不能伪装清空', (tester) async {
    final repository = _FakeMeProfileRepository(failFetchOnce: true);
    final container = await _authenticatedContainer(repository);
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
    expect(find.textContaining('暂时不能清空已有简介'), findsOneWidget);
    expect(repository.updateCalls, 0);
  });

  testWidgets('账号设置不依赖个人资料读取即可使用安全入口', (tester) async {
    final repository = _FakeMeProfileRepository(failFetchOnce: true);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeSettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 0);
    expect(find.text('账号设置'), findsOneWidget);
    expect(find.text('登录终端'), findsOneWidget);
    expect(find.text('修改密码'), findsOneWidget);
    expect(find.text('更换邮箱'), findsOneWidget);
    expect(find.byKey(const Key('logout-submit')), findsOneWidget);
    expect(find.text('账号状态加载失败'), findsNothing);
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 个人中心、资料编辑和账号设置无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _FakeMeProfileRepository();
      final container = await _authenticatedContainer(repository);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const MePage()),
        ),
      );
      await tester.pumpAndSettle();
      final expectedWidth = width <= 400 ? width - 24 : width - 48;
      expect(
        tester.getSize(find.byKey(const Key('me-profile-header'))).width,
        expectedWidth,
      );
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -240));
      await tester.pumpAndSettle();
      final createdTab = find.byKey(
        const ValueKey('me-content-MeContentTab.createdThreads'),
      );
      final overviewTab = find.byKey(
        const ValueKey('me-content-MeContentTab.overview'),
      );
      final playedTab = find.byKey(
        const ValueKey('me-content-MeContentTab.playedThreads'),
      );
      await tester.ensureVisible(createdTab);
      await tester.pumpAndSettle();
      final mainTabGroup = Rect.fromLTRB(
        tester.getRect(overviewTab).left,
        tester.getRect(overviewTab).top,
        tester.getRect(playedTab).right,
        tester.getRect(playedTab).bottom,
      );
      expect(mainTabGroup.center.dx, closeTo(width / 2, 0.01));

      await tester.tap(createdTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('me-settings-save')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MeSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('后台在线提醒（实验性）'), findsNothing);
      expect(
        find.byKey(const Key('background-online-reminders-switch')),
        findsNothing,
      );
      await tester.ensureVisible(find.byKey(const Key('logout-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Future<ProviderContainer> _authenticatedContainer(
  MeProfileRepository repository, {
  AvatarImagePicker? avatarPicker,
  ProfileCoverImagePicker? profileCoverPicker,
  ProfileCoverRepository? profileCoverRepository,
  ImageCropProcessor? imageCropProcessor,
  MediaUploadGateway? mediaRepository,
  AvatarRepository? avatarRepository,
  PublicUserRepository? publicUserRepository,
  WalletRepository? walletRepository,
  MomentRepository? momentRepository,
  bool stickersEnabled = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      stickersEnabledProvider.overrideWithValue(stickersEnabled),
      meProfileRepositoryProvider.overrideWithValue(repository),
      publicUserRepositoryProvider.overrideWithValue(
        publicUserRepository ?? _FakePublicUserRepository(),
      ),
      walletRepositoryProvider.overrideWithValue(
        walletRepository ?? _FakeWalletRepository(),
      ),
      if (momentRepository != null)
        momentRepositoryProvider.overrideWithValue(momentRepository),
      avatarImagePickerPortProvider.overrideWithValue(
        avatarPicker ?? _FakeAvatarPicker(null),
      ),
      profileCoverImagePickerPortProvider.overrideWithValue(
        profileCoverPicker ?? const _FakeProfileCoverPicker(null),
      ),
      profileCoverRepositoryProvider.overrideWithValue(
        profileCoverRepository ?? _FakeProfileCoverRepository(),
      ),
      imageCropProcessorPortProvider.overrideWithValue(
        imageCropProcessor ?? _FakeImageCropProcessor(),
      ),
      mediaUploadGatewayPortProvider.overrideWithValue(
        mediaRepository ?? _FakeMediaRepository(),
      ),
      if (avatarRepository != null)
        avatarRepositoryProvider.overrideWithValue(avatarRepository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  return container;
}

class _FakeProfileCoverPicker implements ProfileCoverImagePicker {
  const _FakeProfileCoverPicker(this.input, {this.failure});

  final MediaUploadInput? input;
  final Object? failure;

  @override
  Future<MediaUploadInput?> pickProfileCoverFromGallery() async {
    if (failure case final error?) throw error;
    return input;
  }
}

class _DeferredProfileCoverPicker implements ProfileCoverImagePicker {
  final _selection = Completer<MediaUploadInput?>();

  void complete(MediaUploadInput? input) => _selection.complete(input);

  @override
  Future<MediaUploadInput?> pickProfileCoverFromGallery() => _selection.future;
}

class _DeferredAvatarPicker implements AvatarImagePicker {
  final _selection = Completer<MediaUploadInput?>();

  void complete(MediaUploadInput? input) => _selection.complete(input);

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() => _selection.future;
}

class _FakeProfileCoverRepository implements ProfileCoverRepository {
  int setCalls = 0;

  @override
  Future<ProfileCoverUpdateResult> removeProfileCover() async =>
      ProfileCoverUpdateResult(
        profileCover: null,
        updatedAt: DateTime.utc(2026, 8, 16),
      );

  @override
  Future<ProfileCoverUpdateResult> setProfileCover({
    required String webMediaId,
    required String mobileMediaId,
  }) async {
    setCalls += 1;
    return ProfileCoverUpdateResult(
      profileCover: const ProfileCoverModel(
        web: ProfileCoverVariant(url: 'https://cdn.example.com/cover-web.webp'),
        mobile: ProfileCoverVariant(
          url: 'https://cdn.example.com/cover-mobile.webp',
        ),
      ),
      updatedAt: DateTime.utc(2026, 8, 16),
    );
  }
}

class _FakeImageCropProcessor implements ImageCropProcessor {
  int coverCropCalls = 0;
  NormalizedCropRect? lastWebCrop;
  NormalizedCropRect? lastMobileCrop;

  @override
  Future<CropImageSource> prepare(MediaUploadInput input) async {
    return CropImageSource(
      original: input,
      previewBytes: _previewBytes,
      width: 160,
      height: 90,
    );
  }

  @override
  Future<MediaUploadInput> cropAvatar(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async => _croppedPreviewInput;

  @override
  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async => source.original;

  @override
  Future<ProfileCoverImageSelection> cropProfileCover(
    CropImageSource source, {
    required NormalizedCropRect webCrop,
    required NormalizedCropRect mobileCrop,
  }) async {
    coverCropCalls += 1;
    lastWebCrop = webCrop;
    lastMobileCrop = mobileCrop;
    return ProfileCoverImageSelection(
      web: _croppedPreviewInput,
      mobile: _croppedPreviewInput,
    );
  }
}

class _FakeAvatarPicker implements AvatarImagePicker {
  _FakeAvatarPicker(this.input, {this.failure});

  final MediaUploadInput? input;
  final Object? failure;

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async {
    if (failure case final error?) throw error;
    return input;
  }
}

class _FakeMediaRepository implements MediaUploadGateway {
  int uploadCalls = 0;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    uploadCalls += 1;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    return _ImmediateUploadOperation(
      const UploadedEditorImage(
        mediaId: 'media-avatar-1',
        url: 'https://cdn.example.com/avatar.webp',
      ),
    );
  }
}

class _DeferredMediaGateway implements MediaUploadGateway {
  final operations = <Completer<UploadedEditorImage>>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    final completion = Completer<UploadedEditorImage>();
    operations.add(completion);
    return _FutureUploadOperation(completion.future);
  }

  void complete(int index) {
    operations[index].complete(
      UploadedEditorImage(
        mediaId: 'media-preview-${index + 1}',
        url: 'https://cdn.example.com/preview-${index + 1}.webp',
      ),
    );
  }
}

class _FailingProfileCoverUploadGateway implements MediaUploadGateway {
  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    return _FutureUploadOperation(
      Future.error(
        const ApiFailure(
          userMessage: '背景图上传失败，请重试。',
          requestId: 'cover-upload-request',
        ),
      ),
    );
  }
}

class _FutureUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  _FutureUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

class _ImmediateUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  _ImmediateUploadOperation(UploadedEditorImage value)
    : result = Future.value(value);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

class _FakeAvatarRepository implements AvatarRepository {
  _FakeAvatarRepository({this.onSet});

  final Future<AvatarUpdateResult> Function(String mediaId)? onSet;
  int setCalls = 0;
  int removeCalls = 0;
  String? lastMediaId;

  @override
  Future<AvatarUpdateResult> setAvatar(String mediaId) async {
    setCalls += 1;
    lastMediaId = mediaId;
    return onSet?.call(mediaId) ?? _avatarSetResult;
  }

  @override
  Future<AvatarUpdateResult> removeAvatar() async {
    removeCalls += 1;
    return _avatarRemoveResult;
  }
}

class _FakeMeProfileRepository implements MeProfileRepository {
  _FakeMeProfileRepository({
    this.failFetchOnce = false,
    MeProfileModel? initialProfile,
  }) : profile = initialProfile ?? _profile;

  bool failFetchOnce;
  int fetchCalls = 0;
  int updateCalls = 0;
  MeProfilePatch? lastPatch;
  MeProfileModel profile;
  Completer<MeProfileModel>? _nextFetch;

  void deferNextFetch(Completer<MeProfileModel> result) {
    _nextFetch = result;
  }

  @override
  Future<MeProfileModel> fetchMe() async {
    fetchCalls += 1;
    final nextFetch = _nextFetch;
    if (nextFetch != null) {
      _nextFetch = null;
      return nextFetch.future;
    }
    if (failFetchOnce) {
      failFetchOnce = false;
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'me-request-id',
      );
    }
    return profile;
  }

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) async {
    updateCalls += 1;
    lastPatch = patch;
    final result = MeProfileUpdateResult(
      email: profile.email,
      username: patch.username ?? profile.username,
      avatarUrl: profile.avatarUrl,
      bio: patch.bio ?? profile.bio,
      level: profile.level,
      experience: profile.experience,
      currentLevelExperience: profile.currentLevelExperience,
      nextLevelExperience: profile.nextLevelExperience,
      receivedTipTotal: profile.receivedTipTotal,
      receivedTipCount: profile.receivedTipCount,
      showRecentReplies: patch.showRecentReplies ?? profile.showRecentReplies,
      showPlayedThreads: patch.showPlayedThreads ?? profile.showPlayedThreads,
      showBookmarks: patch.showBookmarks ?? profile.showBookmarks,
      updatedAt: profile.updatedAt.add(const Duration(minutes: 1)),
    );
    profile = profile.apply(result);
    return result;
  }
}

class _FakePublicUserRepository implements PublicUserRepository {
  int fetchUserCalls = 0;
  int activityCalls = 0;
  int createdCalls = 0;
  int playedCalls = 0;
  int replyCalls = 0;

  @override
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) async {
    activityCalls += 1;
    return const PublicUserActivitySummary(
      momentCount: 7,
      createdThreadCount: 3,
      playedThreadCount: 2,
      replyCount: 18,
    );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async => const CursorPage(items: [], hasMore: false);

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    createdCalls += 1;
    return CursorPage(
      items: [
        PublicUserThreadModel(
          id: 'thread-mine',
          title: '我创建的星海主题',
          status: PublicUserThreadStatus.recruiting,
          isPrivate: false,
          ownerName: _profile.username,
          ownerLevel: _profile.level,
          createdAt: DateTime.utc(2026, 8, 15),
          memberCount: 3,
          postCount: 8,
        ),
      ],
      hasMore: false,
    );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    playedCalls += 1;
    return const CursorPage(items: [], hasMore: false);
  }

  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) async {
    replyCalls += 1;
    return const [];
  }

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) {
    fetchUserCalls += 1;
    throw UnimplementedError();
  }
}

class _FakeWalletRepository implements WalletRepository {
  _FakeWalletRepository({this.balance = '41'});

  final String balance;
  int walletCalls = 0;

  @override
  Future<WalletSummary> fetchWallet() async {
    walletCalls += 1;
    return WalletSummary(
      balance: balance,
      receivedTipTotal: '18',
      receivedTipCount: 6,
    );
  }

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) async => const CursorPage(items: [], hasMore: false);

  @override
  Future<DailyCheckInResult> checkIn() => throw UnimplementedError();

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) => throw UnimplementedError();
}

class _FakeProfileMomentRepository extends Fake implements MomentRepository {
  int userCalls = 0;

  @override
  Future<CursorPage<MomentCard>> fetchUserMoments({
    required String userId,
    String? cursor,
    int limit = 20,
  }) async {
    userCalls += 1;
    return CursorPage(
      items: [
        for (var index = 0; index < 40; index++) _profileMomentCard(index),
      ],
      hasMore: false,
    );
  }
}

MomentCard _profileMomentCard(int index) {
  final timestamp = DateTime.utc(2026, 8, 20, 12);
  return MomentCard(
    id: 'profile-moment-$index',
    author: const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4),
    title: '动态 $index',
    contentExcerpt: '用于验证个人主页联动滚动的动态内容。',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.mint,
    imageCount: 0,
    likeCount: 0,
    commentCount: 0,
    bookmarkCount: 0,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: false,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

final _profile = MeProfileModel(
  id: 'user-1',
  email: 'owner@example.com',
  username: '温柔测试员',
  bio: '一起写故事。',
  level: 4,
  experience: 150,
  currentLevelExperience: 100,
  nextLevelExperience: 200,
  receivedTipTotal: '18',
  receivedTipCount: 6,
  showRecentReplies: true,
  showPlayedThreads: true,
  showBookmarks: true,
  followingCount: 7,
  followerCount: 9,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 10, 8),
);

MeProfileModel _profileWithAvatar(String avatarUrl) {
  return MeProfileModel(
    id: _profile.id,
    email: _profile.email,
    username: _profile.username,
    avatarUrl: avatarUrl,
    bio: _profile.bio,
    level: _profile.level,
    experience: _profile.experience,
    currentLevelExperience: _profile.currentLevelExperience,
    nextLevelExperience: _profile.nextLevelExperience,
    receivedTipTotal: _profile.receivedTipTotal,
    receivedTipCount: _profile.receivedTipCount,
    showRecentReplies: _profile.showRecentReplies,
    showPlayedThreads: _profile.showPlayedThreads,
    showBookmarks: _profile.showBookmarks,
    followingCount: _profile.followingCount,
    followerCount: _profile.followerCount,
    createdAt: _profile.createdAt,
    updatedAt: _profile.updatedAt,
  );
}

final _avatarInput = MediaUploadInput(
  filename: 'avatar.jpg',
  declaredContentType: 'image/jpeg',
  bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 0, 1]),
);

final _previewBytes = image.encodePng(image.Image(width: 160, height: 90));

final _croppedPreviewInput = MediaUploadInput(
  filename: 'cropped.png',
  declaredContentType: 'image/png',
  bytes: Uint8List.fromList(_previewBytes),
);

final _avatarSetResult = AvatarUpdateResult(
  avatarUrl: 'https://cdn.example.com/avatar.webp',
  updatedAt: DateTime.utc(2026, 8, 10, 11),
);

final _avatarRemoveResult = AvatarUpdateResult(
  avatarUrl: null,
  updatedAt: DateTime.utc(2026, 8, 10, 12),
);

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async => _tokens;
}
