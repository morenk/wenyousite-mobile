import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_content_dashboard.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import 'me_page_test_support.dart';

void registerMePageDashboardProfileCases() {
  testWidgets('游客我的页提供登录入口且不读取私有资料', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
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
    final repository = MePageTestFakeMeProfileRepository();
    final container = await mePageTestAuthenticatedContainer(repository);
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

  testWidgets('本人创作概览可切换对应内容页签并定位最近回复', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final publicRepository = MePageTestFakePublicUserRepository();
    final container = await mePageTestAuthenticatedContainer(
      MePageTestFakeMeProfileRepository(),
      publicUserRepository: publicRepository,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MePage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(NestedScrollView), const Offset(0, -240));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('me-activity-created-threads')));
    await tester.pumpAndSettle();
    expect(find.text('我创建的星海主题'), findsOneWidget);
    expect(publicRepository.createdCalls, 1);

    await tester.tap(
      find.byKey(const ValueKey('me-content-MeContentTab.overview')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-activity-played-threads')));
    await tester.pumpAndSettle();
    expect(publicRepository.playedCalls, 1);

    await tester.tap(
      find.byKey(const ValueKey('me-content-MeContentTab.overview')),
    );
    await tester.pumpAndSettle();
    final recentReplies = find.byKey(const Key('me-recent-replies'));
    final repliesTopBefore = tester.getTopLeft(recentReplies).dy;
    await tester.tap(find.byKey(const Key('me-activity-replies')));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(recentReplies).dy, lessThan(repliesTopBefore));

    await tester.ensureVisible(find.byKey(const Key('me-activity-moments')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-activity-moments')));
    await tester.pumpAndSettle();
    expect(find.text('我的动态'), findsOneWidget);
  });

  testWidgets('动态列表回到顶部后继续展开资料头并只从整页顶部刷新', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final profileRepository = MePageTestFakeMeProfileRepository();
    final publicRepository = MePageTestFakePublicUserRepository();
    final walletRepository = MePageTestFakeWalletRepository();
    final momentRepository = MePageTestFakeProfileMomentRepository();
    final container = await mePageTestAuthenticatedContainer(
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
    final repository = MePageTestFakeMeProfileRepository();
    final publicRepository = MePageTestFakePublicUserRepository();
    final walletRepository = MePageTestFakeWalletRepository(balance: '41');
    final container = await mePageTestAuthenticatedContainer(
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
    final repository = MePageTestFakeMeProfileRepository();
    final container = await mePageTestAuthenticatedContainer(
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

  testWidgets('新用户资料编辑以可点背景舞台引导并只保留一个主保存', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final container = await mePageTestAuthenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('添加主页背景'), findsOneWidget);
    expect(find.byType(WenyouSettingsTypography), findsOneWidget);
    expect(find.text('选择图片后可调整取景'), findsOneWidget);
    expect(find.bySemanticsLabel('添加主页背景'), findsOneWidget);
    expect(find.bySemanticsLabel('添加头像'), findsOneWidget);
    expect(find.text('主页公开内容'), findsOneWidget);
    expect(find.text('资料图片'), findsNothing);
    expect(find.text('基本信息'), findsNothing);
    expect(find.text('公开范围'), findsNothing);
    expect(find.textContaining('支持 JPG'), findsNothing);

    final saveButton = find.descendant(
      of: find.byKey(const Key('me-settings-save')),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('me-bio-field')), '尚未保存的新简介');
    await tester.pump();
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
  });

  testWidgets('用户名独立校验并只提交显式修改', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final container = await mePageTestAuthenticatedContainer(repository);
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
    final repository = MePageTestFakeMeProfileRepository();
    final container = await mePageTestAuthenticatedContainer(repository);
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
    expect(find.text('资料已保存。'), findsOneWidget);
  });

  testWidgets('选择图片后复用媒体上传并立即采用服务端头像', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final picker = MePageTestFakeAvatarPicker(mePageTestAvatarInput);
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

    expect(find.bySemanticsLabel('添加头像'), findsOneWidget);
    await tester.tap(find.byKey(const Key('me-avatar-change')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('avatar-crop-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();

    expect(media.uploadCalls, 1);
    expect(avatar.setCalls, 1);
    expect(avatar.lastMediaId, 'media-avatar-1');
    expect(find.text('头像已更新。'), findsOneWidget);
    expect(find.bySemanticsLabel('更换头像'), findsOneWidget);
  });

  testWidgets('更新头像不会覆盖尚未保存的简介草稿', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final container = await mePageTestAuthenticatedContainer(
      repository,
      avatarPicker: MePageTestFakeAvatarPicker(mePageTestAvatarInput),
      mediaRepository: MePageTestFakeMediaRepository(),
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

    await tester.enterText(find.byKey(const Key('me-bio-field')), '先写好的简介草稿');
    await tester.tap(find.byKey(const Key('me-avatar-change')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('image-crop-confirm')));
    await tester.pumpAndSettle();

    final bio = tester.widget<TextFormField>(
      find.byKey(const Key('me-bio-field')),
    );
    expect(bio.controller!.text, '先写好的简介草稿');
    await tester.tap(find.byKey(const Key('me-settings-save')));
    await tester.pumpAndSettle();
    expect(repository.lastPatch?.bio, '先写好的简介草稿');
  });
}
