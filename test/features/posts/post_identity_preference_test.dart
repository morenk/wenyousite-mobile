import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_preference_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/posts/data/shared_preferences_post_identity_store.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

class _Repository extends Mock implements ThreadIdentityRepository {}

class _Preferences extends Mock implements PostIdentityPreferenceStore {}

ThreadIdentityCollection _roles({
  String account = 'user',
  String thread = 'thread',
  bool enabled = true,
  bool eligible = true,
  bool includeRole = true,
  bool configured = true,
  String token = 'latest-token',
}) => ThreadIdentityCollection(
  account: ThreadIdentityState(
    threadId: thread,
    userId: account,
    enabled: enabled,
    eligible: eligible,
    canEdit: true,
    accountName: '账号',
  ),
  identities: [
    if (includeRole)
      ThreadIdentityState(
        threadId: thread,
        userId: account,
        enabled: enabled,
        eligible: eligible,
        canEdit: true,
        accountName: '账号',
        identityId: 'role',
        identityToken: token,
        display: configured
            ? const RpIdentity(id: 'role', nickname: '白夜')
            : null,
      ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Repository repo;
  late MemoryPostIdentityPreferenceStore store;
  late ThreadIdentityCollection current;
  PostIdentitySelection open({
    String account = 'user',
    String thread = 'thread',
    PostIdentityPreferenceStore? preferences,
  }) {
    final selection = PostIdentitySelection(
      repo,
      thread,
      accountId: account,
      preferences: preferences ?? store,
    );
    addTearDown(selection.dispose);
    return selection;
  }

  setUp(() {
    repo = _Repository();
    store = MemoryPostIdentityPreferenceStore();
    current = _roles();
    when(() => repo.list(any())).thenAnswer((_) async => current);
  });

  test('新编辑器沿用上次角色，重新获取当前 token，明确选站内后也记住', () async {
    final first = open();
    await first.refresh();
    expect(first.mode, PostIdentityMode.account);
    first.select(PostIdentityMode.rp, id: 'role');
    current = _roles(token: 'updated-token');
    final second = open();
    await second.refresh();
    expect(second.identityId, 'role');
    expect(second.acceptedToken, 'updated-token');
    expect(second.changed, isFalse);
    second.select(PostIdentityMode.account);
    final third = open();
    await third.refresh();
    expect(third.mode, PostIdentityMode.account);
    expect(third.identityId, isNull);
  });

  test('账号与主题分别隔离，其他编辑器不跟随选择变化', () async {
    final first = open();
    await first.refresh();
    first.select(PostIdentityMode.rp, id: 'role');
    current = _roles(thread: 'other-thread');
    final otherThread = open(thread: 'other-thread');
    await otherThread.refresh();
    expect(otherThread.mode, PostIdentityMode.account);
    current = _roles(account: 'other-user');
    final otherAccount = open(account: 'other-user');
    await otherAccount.refresh();
    expect(otherAccount.mode, PostIdentityMode.account);
    expect(first.identityId, 'role');
  });

  for (final unavailable in [
    _roles(includeRole: false),
    _roles(enabled: false),
    _roles(eligible: false),
    _roles(configured: false),
  ]) {
    test(
      '记住的角色删除、关闭、撤权或清空后，新会话使用站内身份 ${unavailable.identities.length}/${unavailable.account.enabled}/${unavailable.account.eligible}/${unavailable.identities.firstOrNull?.hasRp}',
      () async {
        await store.write('user', 'thread', 'role');
        current = unavailable;
        final selection = open();
        await selection.refresh();
        expect(selection.mode, PostIdentityMode.account);
        expect(selection.changed, isFalse);
        expect(selection.acceptedToken, isNull);
      },
    );
  }

  test('已有草稿与未知结果请求保留原选择及旧 token，不套用新偏好', () async {
    await store.write('user', 'thread', 'role');
    final draft = open()
      ..restore(
        selected: PostIdentityMode.rp,
        id: 'removed-role',
        token: 'draft-token',
      );
    await draft.refresh();
    expect(draft.identityId, 'removed-role');
    expect(draft.acceptedToken, 'draft-token');
    expect(draft.changed, isTrue);
    final accountDraft = open()..restore(selected: PostIdentityMode.account);
    await accountDraft.refresh();
    expect(accountDraft.mode, PostIdentityMode.account);
    expect(await store.read('user', 'thread'), 'role');
  });

  test('新建角色成为下次选择，编辑非当前角色不改变偏好', () async {
    final selection = open();
    await selection.refresh();
    selection.acceptSaved(current.identities.single, created: false);
    expect(await store.read('user', 'thread'), isNull);
    selection.acceptSaved(current.identities.single, created: true);
    expect(await store.read('user', 'thread'), 'role');
  });

  test('发表旧草稿或重试冻结请求后记住实际发言身份', () async {
    final selection = open();
    await selection.refresh();
    selection.select(PostIdentityMode.rp, id: 'role');
    selection.rememberPublishedIdentity('published-role');
    expect(await store.read('user', 'thread'), 'published-role');
    selection.rememberPublishedIdentity(null);
    expect(await store.read('user', 'thread'), isNull);
  });

  test('偏好读取晚到不能覆盖已恢复的草稿', () async {
    final pending = Completer<String?>();
    final preferences = _Preferences();
    when(
      () => preferences.read('user', 'thread'),
    ).thenAnswer((_) => pending.future);
    final selection = open(preferences: preferences);
    final loading = selection.refresh();
    await Future<void>.delayed(Duration.zero);
    selection.restore(selected: PostIdentityMode.account);
    pending.complete('role');
    await loading;
    expect(selection.mode, PostIdentityMode.account);
  });

  test('偏好读写失败不阻止当前身份加载和手动选择', () async {
    final preferences = _Preferences();
    when(() => preferences.read('user', 'thread')).thenThrow(Exception('disk'));
    when(
      () => preferences.write('user', 'thread', 'role'),
    ).thenThrow(Exception('disk'));
    final selection = open(preferences: preferences);
    expect(await selection.refresh(), isTrue);
    selection.select(PostIdentityMode.rp, id: 'role');
    await Future<void>.delayed(Duration.zero);
    expect(selection.identityId, 'role');
    expect(selection.failure, isNull);
  });

  test('持久化只保存角色 ID，重建存储仍按账号主题恢复，快速切换以最后一次为准', () async {
    SharedPreferences.setMockInitialValues({});
    final persistent = SharedPreferencesPostIdentityStore();
    final first = persistent.write('user', 'thread', 'role');
    final second = persistent.write('user', 'thread', 'new-role');
    expect(await persistent.read('user', 'thread'), 'new-role');
    await Future.wait([first, second]);
    final reopened = SharedPreferencesPostIdentityStore();
    expect(await reopened.read('user', 'thread'), 'new-role');
    expect(await reopened.read('other-user', 'thread'), isNull);
    expect(await reopened.read('user', 'other-thread'), isNull);
    final values = await SharedPreferences.getInstance();
    expect(values.getKeys(), hasLength(1));
    expect(values.getString(values.getKeys().single), 'new-role');
    await reopened.write('user', 'thread', null);
    expect(
      await SharedPreferencesPostIdentityStore().read('user', 'thread'),
      isNull,
    );
  });
}
