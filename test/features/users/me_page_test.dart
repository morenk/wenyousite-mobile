import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/users/data/avatar_repository.dart';
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
    expect(find.text('Lv.4'), findsOneWidget);
    expect(find.text('150 / 200 经验'), findsOneWidget);
    expect(find.byKey(const Key('me-profile-header')), findsOneWidget);
    expect(find.byKey(const Key('me-open-following')), findsOneWidget);
    expect(find.byKey(const Key('me-open-followers')), findsOneWidget);
    expect(find.byKey(const Key('me-open-edit-profile')), findsOneWidget);
    expect(find.byKey(const Key('me-open-settings')), findsOneWidget);
    expect(find.text('我的动态'), findsOneWidget);
    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.text('账号设置'), findsWidgets);
    expect(find.text('注销账号'), findsNothing);
    expect(find.text('公开最近回复'), findsNothing);
    expect(repository.fetchCalls, 1);
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
    expect(find.text('表情包'), findsOneWidget);
  });

  testWidgets('未验证邮箱在账号安全区提供验证入口', (tester) async {
    final repository = _FakeMeProfileRepository(
      initialProfile: _profileWithEmailVerified(false),
    );
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeSettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('me-open-verify-email')));
    expect(find.text('验证当前邮箱'), findsOneWidget);
    expect(find.byKey(const Key('logout-submit')), findsOneWidget);
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

    expect(media.uploadCalls, 1);
    expect(avatar.setCalls, 1);
    expect(avatar.lastMediaId, 'media-avatar-1');
    expect(find.text('头像已更新。'), findsOneWidget);
    expect(find.text('更换头像'), findsOneWidget);
    expect(find.byKey(const Key('me-avatar-remove')), findsOneWidget);
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
    expect(find.text('请求 ID：avatar-widget-request-id'), findsOneWidget);
    expect(find.text('重试设置'), findsOneWidget);

    await tester.tap(find.byKey(const Key('me-avatar-retry')));
    await tester.pumpAndSettle();
    expect(media.uploadCalls, 1);
    expect(avatar.setCalls, 2);
    expect(find.text('头像已更新。'), findsOneWidget);
  });

  testWidgets('未验证邮箱导致设置失败时提供验证入口', (tester) async {
    final avatar = _FakeAvatarRepository(
      onSet: (_) async => throw const ApiFailure(
        userMessage: '请先验证邮箱。',
        businessCode: 40107,
        requestId: 'avatar-verify-request-id',
      ),
    );
    final container = await _authenticatedContainer(
      _FakeMeProfileRepository(
        initialProfile: _profileWithEmailVerified(false),
      ),
      avatarPicker: _FakeAvatarPicker(_avatarInput),
      mediaRepository: _FakeMediaRepository(),
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

    expect(find.text('请求 ID：avatar-verify-request-id'), findsOneWidget);
    expect(find.byKey(const Key('me-avatar-verify-email')), findsOneWidget);
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

    expect(find.text('资料没有加载完成'), findsOneWidget);
    expect(find.byKey(const Key('logout-submit')), findsNothing);
    await tester.tap(find.byKey(const Key('me-edit-retry')));
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
      await tester.ensureVisible(find.byKey(const Key('logout-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Future<ProviderContainer> _authenticatedContainer(
  MeProfileRepository repository, {
  AvatarImagePicker? avatarPicker,
  MediaUploadGateway? mediaRepository,
  AvatarRepository? avatarRepository,
  bool stickersEnabled = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      stickersEnabledProvider.overrideWithValue(stickersEnabled),
      meProfileRepositoryProvider.overrideWithValue(repository),
      avatarImagePickerPortProvider.overrideWithValue(
        avatarPicker ?? _FakeAvatarPicker(null),
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

class _FakeAvatarPicker implements AvatarImagePicker {
  _FakeAvatarPicker(this.input);

  final MediaUploadInput? input;

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async => input;
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

MeProfileModel _profileWithEmailVerified(bool emailVerified) {
  return MeProfileModel(
    id: _profile.id,
    email: _profile.email,
    username: _profile.username,
    avatarUrl: _profile.avatarUrl,
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
    emailVerified: emailVerified,
    followingCount: _profile.followingCount,
    followerCount: _profile.followerCount,
    createdAt: _profile.createdAt,
    updatedAt: _profile.updatedAt,
  );
}

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
    emailVerified: _profile.emailVerified,
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
