import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

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
    expect(repository.fetchCalls, 0);
  });

  testWidgets('本人资料展示真实成长、邮箱和隐私设置', (tester) async {
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
    expect(find.text('o***@example.com'), findsOneWidget);
    expect(find.text('Lv.4 成长进度'), findsOneWidget);
    expect(find.text('150 / 200 经验'), findsOneWidget);
    expect(find.text('关注 7'), findsOneWidget);
    expect(find.text('公开最近回复'), findsOneWidget);
    expect(find.text('公开参与主题'), findsOneWidget);
    expect(find.text('公开收藏'), findsOneWidget);
    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.text('我关注的人'), findsOneWidget);
    expect(find.text('我的粉丝'), findsOneWidget);
    expect(find.text('管理黑名单'), findsOneWidget);
    expect(find.text('登录终端'), findsOneWidget);
    expect(repository.fetchCalls, 1);
  });

  testWidgets('用户名独立校验并只提交显式修改', (tester) async {
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

    await tester.ensureVisible(find.byKey(const Key('me-username-edit')));
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
        child: MaterialApp(theme: AppTheme.light, home: const MePage()),
      ),
    );
    await tester.pumpAndSettle();

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

  testWidgets('已有简介不能伪装清空，加载失败可重试且仍可退出', (tester) async {
    final repository = _FakeMeProfileRepository(failFetchOnce: true);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本人资料没有加载完成'), findsOneWidget);
    expect(find.byKey(const Key('logout-submit')), findsOneWidget);
    await tester.tap(find.byKey(const Key('me-profile-retry')));
    await tester.pumpAndSettle();
    expect(find.text('温柔测试员'), findsWidgets);

    await tester.enterText(find.byKey(const Key('me-bio-field')), '');
    await tester.ensureVisible(find.byKey(const Key('me-settings-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-settings-save')));
    await tester.pump();
    expect(find.textContaining('暂不支持清空已有简介'), findsOneWidget);
    expect(repository.updateCalls, 0);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 本人资料和设置无布局溢出', (tester) async {
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

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('me-settings-save')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Future<ProviderContainer> _authenticatedContainer(
  MeProfileRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      meProfileRepositoryProvider.overrideWithValue(repository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  return container;
}

class _FakeMeProfileRepository implements MeProfileRepository {
  _FakeMeProfileRepository({this.failFetchOnce = false});

  bool failFetchOnce;
  int fetchCalls = 0;
  int updateCalls = 0;
  MeProfilePatch? lastPatch;
  MeProfileModel profile = _profile;

  @override
  Future<MeProfileModel> fetchMe() async {
    fetchCalls += 1;
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
      emailVerified: profile.emailVerified,
      updatedAt: profile.updatedAt.add(const Duration(minutes: 1)),
    );
    profile = profile.apply(result);
    return result;
  }
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
  emailVerified: true,
  followingCount: 7,
  followerCount: 9,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 10, 8),
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
