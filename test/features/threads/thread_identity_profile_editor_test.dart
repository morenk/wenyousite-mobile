import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_profile.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';

const _link = 'https://wenyou.site/threads/thread?post=post';
final _field = find.byKey(const Key('thread-identity-profile-link'));
final _save = find.byKey(const Key('thread-identity-save'));

void main() {
  testWidgets('旧服务隐藏资料字段且保存不带新字段', (tester) async {
    final repo = _Repository();
    await _pump(tester, repo, supported: false);
    expect(_field, findsNothing);
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(repo.saves.single.profilePostId, isNull);
    expect(repo.saves.single.clearProfilePost, isFalse);
  });

  testWidgets('已有保存操作校验稳定帖子ID并绑定，无需另一个保存按钮', (tester) async {
    final repo = _Repository();
    final lookedUp = <String>[];
    await _pump(
      tester,
      repo,
      lookup: (id) async {
        lookedUp.add(id);
        // 不按资料楼层作者限制身份，允许楼主代贴。
        return IdentityProfilePostTarget(id: id, threadId: 'thread');
      },
    );
    await tester.enterText(_field, _link);
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(lookedUp, ['post']);
    expect(repo.saves.single.profilePostId, 'post');
    expect(repo.saves.single.version, 1);
    expect(repo.saves.single.clearProfilePost, isFalse);
    expect(_field, findsNothing);
  });

  for (final link in [
    'https://external.example/threads/thread?post=post',
    '/threads/other?post=post',
  ]) {
    testWidgets('非法或跨主题链接保留输入且不发写请求 $link', (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      await tester.enterText(_field, link);
      await tester.tap(_save);
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(_field);
      expect(field.controller!.text, link);
      expect(field.decoration!.errorText, isNotNull);
      expect(repo.saves, isEmpty);
    });
  }

  testWidgets('不能只信链接主题，实际读取跨主题仍拒绝', (tester) async {
    final repo = _Repository();
    await _pump(
      tester,
      repo,
      lookup: (id) async =>
          IdentityProfilePostTarget(id: id, threadId: 'other'),
    );
    await tester.enterText(_field, _link);
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(_field).decoration!.errorText,
      '请选择本主题内的楼层',
    );
    expect(repo.saves, isEmpty);
  });

  testWidgets('本人不可读原绑定仍回显；清空才显式解绑，不删除帖子', (tester) async {
    final repo = _Repository()..state = _state(bound: 'private-post');
    await _pump(tester, repo);
    expect(
      tester.widget<TextField>(_field).controller!.text,
      contains('private-post'),
    );
    await tester.enterText(_field, '');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(repo.saves.single.clearProfilePost, isTrue);
    expect(repo.saves.single.profilePostId, isNull);
  });

  testWidgets('未改链接时省略资料字段，保留服务端原绑定', (tester) async {
    final repo = _Repository()..state = _state(bound: 'private-post');
    await _pump(tester, repo);
    await tester.enterText(
      find.byKey(const Key('thread-identity-nickname')),
      '新昵称',
    );
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(repo.saves.single.clearProfilePost, isFalse);
    expect(repo.saves.single.profilePostId, isNull);
  });

  testWidgets('读取失败保留链接并在输入框下重试，不误标新建结果不明', (tester) async {
    final repo = _Repository();
    await _pump(
      tester,
      repo,
      creating: true,
      lookup: (_) async => throw const ApiFailure(httpStatus: 503),
    );
    await tester.enterText(
      find.byKey(const Key('thread-identity-nickname')),
      '角色',
    );
    await tester.enterText(_field, _link);
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(_field).controller!.text, _link);
    expect(
      tester.widget<TextField>(_field).decoration!.errorText,
      '资料读取失败，请重试',
    );
    expect(find.text('返回身份列表'), findsNothing);
    expect(repo.saves, isEmpty);
  });

  testWidgets('权限在校验与保存间撤销，绑定错误仍显示在输入框', (tester) async {
    final repo = _Repository()
      ..failure = const ApiFailure(httpStatus: 404, businessCode: 40403);
    await _pump(
      tester,
      repo,
      lookup: (id) async =>
          IdentityProfilePostTarget(id: id, threadId: 'thread'),
    );
    await tester.enterText(_field, _link);
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(_field).controller!.text, _link);
    expect(tester.widget<TextField>(_field).decoration!.errorText, '资料暂不可用');
  });

  testWidgets('版本冲突保留资料输入，明确确认后按新版本提交', (tester) async {
    final repo = _Repository()
      ..failure = const ApiFailure(httpStatus: 409, businessCode: 40002);
    await _pump(
      tester,
      repo,
      lookup: (id) async =>
          IdentityProfilePostTarget(id: id, threadId: 'thread'),
    );
    await tester.enterText(_field, _link);
    repo.state = _state(version: 2, bound: 'someone-else-edit');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(_field).controller!.text, _link);
    repo.failure = null;
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(find.text('保存你的修改？'), findsOneWidget);
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(repo.saves.last.version, 2);
    expect(repo.saves.last.profilePostId, 'post');
  });
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repo, {
  bool supported = true,
  bool creating = false,
  IdentityProfilePostLookup? lookup,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        threadIdentityRepositoryProvider.overrideWithValue(repo),
        appCapabilitiesProvider.overrideWithValue(
          AppCapabilities(rpIdentityProfileSupported: supported),
        ),
        sessionScopeProvider.overrideWithValue(
          const SessionScope(accountId: 'user', generation: 1),
        ),
        identityProfilePostLookupProvider.overrideWithValue(
          lookup ?? (_) async => throw StateError('不应读取资料'),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showThreadIdentityEditor(
                context,
                'thread',
                identityId: creating ? null : 'rp',
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

ThreadIdentityState _state({int version = 1, String? bound}) =>
    ThreadIdentityState(
      threadId: 'thread',
      userId: 'user',
      enabled: true,
      eligible: true,
      canEdit: true,
      accountName: '站内账号',
      identityId: 'rp',
      nickname: '白夜',
      version: version,
      display: const RpIdentity(id: 'rp', nickname: '白夜'),
      editableProfilePostId: bound,
      profilePostStatus: bound == null
          ? IdentityProfilePostStatus.none
          : IdentityProfilePostStatus.unavailable,
    );

class _Repository extends Fake implements ThreadIdentityRepository {
  ThreadIdentityState state = _state();
  ApiFailure? failure;
  final saves = <ThreadIdentityUpdate>[];
  @override
  Future<ThreadIdentityState> find(String threadId, String identityId) async =>
      state;
  @override
  Future<ThreadIdentityCollection> list(String threadId) async =>
      ThreadIdentityCollection(account: _state(), identities: []);
  @override
  Future<ThreadIdentityState> updateRole(
    String threadId,
    String identityId,
    ThreadIdentityUpdate input,
  ) async {
    saves.add(input);
    if (failure != null) throw failure!;
    return state;
  }

  @override
  Future<ThreadIdentityState> create(
    String threadId,
    ThreadIdentityUpdate input,
  ) => updateRole(threadId, 'new', input);
}
