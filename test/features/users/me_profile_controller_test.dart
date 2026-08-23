import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

void main() {
  test('读取本人资料后进入可编辑状态', () async {
    final repository = _FakeMeProfileRepository();
    final controller = MeProfileController(repository, autoStart: false);

    await controller.load();

    expect(controller.state.phase, MeProfilePhase.ready);
    expect(controller.state.profile?.username, '温柔测试员');
    expect(repository.fetchCalls, 1);
  });

  test('用户名未变化不请求，变化时只提交用户名并合并服务端结果', () async {
    final repository = _FakeMeProfileRepository();
    final controller = MeProfileController(repository, autoStart: false);
    await controller.load();

    expect(await controller.saveUsername(' 温柔测试员 '), isTrue);
    expect(repository.updateCalls, 0);
    expect(controller.state.successMessage, '用户名没有变化。');

    expect(await controller.saveUsername('新名字'), isTrue);
    expect(repository.updateCalls, 1);
    expect(repository.lastPatch?.username, '新名字');
    expect(repository.lastPatch?.bio, isNull);
    expect(controller.state.profile?.username, '新名字');
    expect(controller.state.profile?.followingCount, 7);
  });

  test('隐私表单只提交变化字段，失败时保留原资料并可重试', () async {
    var shouldFail = true;
    final repository = _FakeMeProfileRepository(
      onUpdate: (patch) async {
        if (shouldFail) {
          throw const ApiFailure(
            userMessage: '操作太频繁，请稍后再试。',
            businessCode: 42900,
            requestId: 'settings-request-id',
          );
        }
        return _updatedResult(patch);
      },
    );
    final controller = MeProfileController(repository, autoStart: false);
    await controller.load();

    final failed = await controller.saveSettings(
      bio: '一起写故事。',
      showRecentReplies: true,
      showPlayedThreads: true,
      showBookmarks: false,
    );

    expect(failed, isFalse);
    expect(controller.state.phase, MeProfilePhase.ready);
    expect(controller.state.profile?.showBookmarks, isTrue);
    expect(controller.state.failedAction, MeProfileAction.settings);
    expect(
      controller.state.submissionFailure?.requestId,
      'settings-request-id',
    );
    expect(repository.lastPatch?.showBookmarks, isFalse);
    expect(repository.lastPatch?.showRecentReplies, isNull);

    shouldFail = false;
    final succeeded = await controller.saveSettings(
      bio: '一起写故事。',
      showRecentReplies: true,
      showPlayedThreads: true,
      showBookmarks: false,
    );
    expect(succeeded, isTrue);
    expect(controller.state.profile?.showBookmarks, isFalse);
    expect(controller.state.submissionFailure, isNull);
  });

  test('头像端点结果只替换头像与更新时间', () async {
    final controller = MeProfileController(
      _FakeMeProfileRepository(),
      autoStart: false,
    );
    await controller.load();

    controller.applyAvatarUpdate(
      AvatarUpdateResult(
        avatarUrl: 'https://cdn.example.com/avatar.webp',
        updatedAt: DateTime.utc(2026, 8, 10, 12),
      ),
    );

    expect(
      controller.state.profile?.avatarUrl,
      'https://cdn.example.com/avatar.webp',
    );
    expect(controller.state.profile?.username, _profile.username);
    expect(controller.state.profile?.followingCount, 7);
    expect(controller.state.profile?.updatedAt, DateTime.utc(2026, 8, 10, 12));
  });

  test('刷新期间保留已加载资料并在成功后结束忙碌状态', () async {
    final refreshed = Completer<MeProfileModel>();
    final repository = _FakeMeProfileRepository(
      onFetch: (call) => call == 1 ? Future.value(_profile) : refreshed.future,
    );
    final controller = MeProfileController(repository, autoStart: false);
    await controller.load();

    final operation = controller.refresh();

    expect(controller.state.phase, MeProfilePhase.ready);
    expect(controller.state.profile, same(_profile));
    expect(controller.state.isRefreshing, isTrue);

    refreshed.complete(_profile);
    await operation;

    expect(controller.state.phase, MeProfilePhase.ready);
    expect(controller.state.isRefreshing, isFalse);
    expect(controller.state.refreshFailure, isNull);
  });

  test('刷新失败保留旧资料并记录非阻断问题编号', () async {
    final repository = _FakeMeProfileRepository(
      onFetch: (call) async {
        if (call == 1) return _profile;
        throw const ApiFailure(
          userMessage: '个人资料刷新失败，请稍后重试。',
          requestId: 'profile-refresh-request',
        );
      },
    );
    final controller = MeProfileController(repository, autoStart: false);
    await controller.load();

    await controller.refresh();

    expect(controller.state.phase, MeProfilePhase.ready);
    expect(controller.state.profile, same(_profile));
    expect(controller.state.isRefreshing, isFalse);
    expect(
      controller.state.refreshFailure?.requestId,
      'profile-refresh-request',
    );
  });
}

class _FakeMeProfileRepository implements MeProfileRepository {
  _FakeMeProfileRepository({this.onFetch, this.onUpdate});

  final Future<MeProfileModel> Function(int call)? onFetch;
  final Future<MeProfileUpdateResult> Function(MeProfilePatch patch)? onUpdate;
  int fetchCalls = 0;
  int updateCalls = 0;
  MeProfilePatch? lastPatch;

  @override
  Future<MeProfileModel> fetchMe() async {
    fetchCalls += 1;
    return onFetch?.call(fetchCalls) ?? _profile;
  }

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) async {
    updateCalls += 1;
    lastPatch = patch;
    return onUpdate?.call(patch) ?? _updatedResult(patch);
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
  followingCount: 7,
  followerCount: 9,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 10, 8),
);

MeProfileUpdateResult _updatedResult(MeProfilePatch patch) {
  return MeProfileUpdateResult(
    email: _profile.email,
    username: patch.username ?? _profile.username,
    bio: patch.bio ?? _profile.bio,
    level: _profile.level,
    experience: _profile.experience,
    currentLevelExperience: _profile.currentLevelExperience,
    nextLevelExperience: _profile.nextLevelExperience,
    receivedTipTotal: _profile.receivedTipTotal,
    receivedTipCount: _profile.receivedTipCount,
    showRecentReplies: patch.showRecentReplies ?? _profile.showRecentReplies,
    showPlayedThreads: patch.showPlayedThreads ?? _profile.showPlayedThreads,
    showBookmarks: patch.showBookmarks ?? _profile.showBookmarks,
    updatedAt: DateTime.utc(2026, 8, 10, 10),
  );
}
