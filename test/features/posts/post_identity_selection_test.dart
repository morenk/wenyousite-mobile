import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

import '../../support/thread_identity_fixtures.dart';

class _Repository extends Mock implements ThreadIdentityRepository {
  @override
  Future<ThreadIdentityCollection> list(String threadId) async =>
      identityTestCollection(await mine(threadId));
}

ThreadIdentityState _identity({
  String token = 'one',
  bool enabled = true,
  bool eligible = true,
}) => ThreadIdentityState(
  threadId: 'thread',
  userId: 'user',
  enabled: enabled,
  eligible: eligible,
  canEdit: enabled && eligible,
  accountName: '账号',
  identityToken: token,
  display: const RpIdentity(id: 'rp', nickname: '白鸦'),
);

void main() {
  test('无历史偏好的新编辑器使用站内身份，选择只改变当前编辑会话', () async {
    final repo = _Repository();
    when(() => repo.mine('thread')).thenAnswer((_) async => _identity());
    final first = PostIdentitySelection(repo, 'thread');
    final second = PostIdentitySelection(repo, 'thread');
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    await first.refresh();
    expect(first.mode, PostIdentityMode.account);
    first.select(PostIdentityMode.rp, id: 'rp');
    await second.refresh();
    expect(second.mode, PostIdentityMode.account);
    final draft =
        const PostComposerBaseline(
          content: '',
          postId: null,
          version: null,
        ).draftFor(
          '',
          publishDraft: PostPublishDraft(
            mode: first.mode,
            identityId: first.identityId,
            identityToken: first.acceptedToken,
          ),
        );
    expect(draft, isNotNull);
    expect(
      resolvePostComposerDraft(
        draft: draft,
        baseline: const PostComposerBaseline(
          content: '',
          postId: null,
          version: null,
        ),
      ),
      PostComposerDraftResolution.restore,
    );
    expect(draft!.publishDraft!.mode, PostIdentityMode.rp);
    expect(draft.publishDraft!.identityId, 'rp');
  });

  test('改名刷新保留草稿token，发表准备同步同一角色的新token', () async {
    final repo = _Repository();
    var identity = _identity();
    when(() => repo.mine('thread')).thenAnswer((_) async => identity);
    final selection = PostIdentitySelection(repo, 'thread');
    addTearDown(selection.dispose);
    await selection.refresh();
    selection.select(PostIdentityMode.rp, id: 'rp');
    identity = _identity(token: 'two');
    await selection.refresh();
    expect(selection.changed, isTrue);
    expect(selection.acceptedToken, 'one');
    selection.useCurrentIdentity();
    expect(selection.changed, isFalse);
    expect(selection.mode, PostIdentityMode.rp);
    expect(selection.acceptedToken, 'two');
  });

  for (final revoked in [false, true]) {
    test('${revoked ? '撤权' : '关闭'}保留RP草稿选择，发表准备回到账号', () async {
      final repo = _Repository();
      when(() => repo.mine('thread')).thenAnswer(
        (_) async => _identity(enabled: revoked, eligible: !revoked),
      );
      final selection = PostIdentitySelection(repo, 'thread')
        ..restore(selected: PostIdentityMode.rp, token: 'old');
      addTearDown(selection.dispose);
      await selection.refresh();
      expect(selection.mode, PostIdentityMode.rp);
      expect(selection.changed, isTrue);
      selection.useCurrentIdentity();
      expect(selection.mode, PostIdentityMode.account);
      expect(selection.changed, isFalse);
    });
  }

  test('ACCOUNT草稿不受RP改名或开关变化影响', () async {
    final repo = _Repository();
    when(
      () => repo.mine('thread'),
    ).thenAnswer((_) async => _identity(token: 'new', enabled: false));
    final selection = PostIdentitySelection(repo, 'thread')
      ..restore(selected: PostIdentityMode.account, token: 'old');
    addTearDown(selection.dispose);
    await selection.refresh();
    expect(selection.mode, PostIdentityMode.account);
    expect(selection.changed, isFalse);
  });

  test('较早请求迟到不覆盖最新资格', () async {
    final repo = _Repository();
    final old = Completer<ThreadIdentityState>();
    var calls = 0;
    when(() => repo.mine('thread')).thenAnswer(
      (_) =>
          ++calls == 1 ? old.future : Future.value(_identity(enabled: false)),
    );
    final selection = PostIdentitySelection(repo, 'thread');
    addTearDown(selection.dispose);
    final pending = selection.refresh();
    await selection.refresh();
    old.complete(_identity());
    await pending;
    expect(selection.identity!.enabled, isFalse);
    expect(selection.mode, PostIdentityMode.account);
  });
}
