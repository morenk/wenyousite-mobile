import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

import '../../support/thread_identity_fixtures.dart';
import 'post_replies_page_test_support.dart';

class _Identities extends Mock implements ThreadIdentityRepository {
  ThreadIdentityState current = _identity();
  bool fail = false;

  @override
  Future<ThreadIdentityCollection> list(String threadId) async {
    if (fail) throw const ApiFailure(userMessage: '加载失败');
    return identityTestCollection(current);
  }
}

ThreadIdentityState _identity({
  String token = 'current-token',
  bool enabled = true,
  bool eligible = true,
  bool deleted = false,
}) => ThreadIdentityState(
  threadId: 'thread',
  userId: 'author-1',
  enabled: enabled,
  eligible: eligible,
  canEdit: enabled && eligible,
  accountName: '站内账号',
  identityToken: token,
  display: deleted ? null : const RpIdentity(id: 'rp', nickname: '白鸦'),
);

const _target = (
  kind: PostComposerKind.createFloor,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: null,
  parentPostId: null,
  replyToPostId: null,
  version: null,
  initialContent: '',
  label: '发表楼层',
);

Future<void> _open(
  WidgetTester tester,
  PostRepliesPageTestFakePostRepository posts,
  _Identities identities, {
  PostIdentityMode mode = PostIdentityMode.rp,
  PendingPostCreate? pending,
}) async {
  final container = await postRepliesPageTestPostContainer(
    posts,
    userId: 'author-1',
    identityRepository: identities,
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPostComposerSheet(
                context: context,
                target: _target,
                supportsRpIdentity: true,
                initialDraft: PostComposerDraft(
                  content: '保留的正文',
                  baseContent: '',
                  basePostId: null,
                  baseVersion: null,
                  publishDraft: PostPublishDraft(
                    mode: mode,
                    identityId: mode == PostIdentityMode.rp ? 'rp' : null,
                    identityToken: 'old-token',
                    pending: pending,
                  ),
                ),
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await postRepliesPageTestPumpUi(tester);
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('editor-submit')));
  await postRepliesPageTestPumpUi(tester);
}

void main() {
  testWidgets('同一角色资料更新后一次点击发表，无身份确认弹窗', (tester) async {
    final posts = PostRepliesPageTestFakePostRepository();
    await _open(tester, posts, _Identities());
    await _submit(tester);
    expect(find.text('发表身份发生变化'), findsNothing);
    expect(find.text('确认身份'), findsNothing);
    expect(posts.createInputs, hasLength(1));
    expect(posts.createInputs.single.identityMode, PostIdentityMode.rp);
    expect(posts.createInputs.single.identityId, 'rp');
    expect(posts.createInputs.single.identityToken, 'current-token');
    expect(posts.createInputs.single.content, '保留的正文');
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
  });

  testWidgets('首次发送只显示发表按钮进度，不显示待确认卡片', (tester) async {
    final completer = Completer<PostItem>();
    final posts = PostRepliesPageTestFakePostRepository(
      createCompleter: completer,
    );
    await _open(tester, posts, _Identities(), mode: PostIdentityMode.account);
    await _submit(tester);
    expect(posts.createInputs, hasLength(1));
    expect(find.byTooltip('正在发布…，处理中'), findsOneWidget);
    expect(find.text('本次发表需要确认。'), findsNothing);
    expect(find.text('重试确认发表'), findsNothing);
    completer.complete(
      postRepliesPageTestReply('created', '保留的正文', postRepliesPageTestAuthor),
    );
    await postRepliesPageTestPumpUi(tester);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
  });

  for (final reason in ['删除', '关闭', '撤权']) {
    testWidgets('$reason原角色后保留草稿并回到账号，不弹窗或自动换身份发布', (tester) async {
      final identities = _Identities();
      final posts = PostRepliesPageTestFakePostRepository();
      await _open(tester, posts, identities);
      identities.current = _identity(
        deleted: reason == '删除',
        enabled: reason != '关闭',
        eligible: reason != '撤权',
      );
      await _submit(tester);
      expect(find.text('发表身份发生变化'), findsNothing);
      expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
      expect(find.text('站内账号'), findsOneWidget);
      expect(posts.createInputs, isEmpty);
      await _submit(tester);
      expect(posts.createInputs, hasLength(1));
      expect(posts.createInputs.single.identityMode, PostIdentityMode.account);
      expect(posts.createInputs.single.identityId, isNull);
      expect(posts.createInputs.single.content, '保留的正文');
    });
  }

  testWidgets('身份读取失败保留草稿和当前选择，下次点击仍可发表', (tester) async {
    final identities = _Identities();
    final posts = PostRepliesPageTestFakePostRepository();
    await _open(tester, posts, identities);
    identities.fail = true;
    await _submit(tester);
    expect(posts.createInputs, isEmpty);
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    identities.fail = false;
    await _submit(tester);
    expect(posts.createInputs.single.identityMode, PostIdentityMode.rp);
    expect(posts.createInputs.single.content, '保留的正文');
  });

  testWidgets('发送期间身份冲突保留草稿，不弹确认或自动重发，按钮直接重试', (tester) async {
    final identities = _Identities();
    var attempts = 0;
    final posts = PostRepliesPageTestFakePostRepository(
      onCreate: (input) async {
        if (attempts++ == 0) {
          identities.current = _identity(token: 'changed-during-send');
          throw const ApiFailure(
            httpStatus: 400,
            businessCode: 40011,
            userMessage: '请重新确认身份',
          );
        }
        return postRepliesPageTestReply(
          'created',
          input.content,
          postRepliesPageTestAuthor,
        );
      },
    );
    await _open(tester, posts, identities);
    await _submit(tester);
    expect(posts.createInputs, hasLength(1));
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    expect(find.text('发表失败，请重试。'), findsOneWidget);
    expect(find.text('发表身份发生变化'), findsNothing);
    expect(find.text('请重新确认身份'), findsNothing);
    await _submit(tester);
    expect(posts.createInputs, hasLength(2));
    expect(posts.createInputs.last.identityToken, 'changed-during-send');
    expect(posts.createInputs.last.content, '保留的正文');
    expect(
      posts.createInputs.last.clientRequestId,
      isNot(posts.createInputs.first.clientRequestId),
    );
  });

  testWidgets('未知结果重试仍发送原载荷和幂等键，不同步新身份', (tester) async {
    final identities = _Identities();
    final posts = PostRepliesPageTestFakePostRepository();
    await _open(
      tester,
      posts,
      identities,
      pending: PendingPostCreate(
        input: PostCreateInput(
          subthreadId: 'subthread',
          content: '保留的正文',
          clientRequestId: 'original-request',
          identityMode: PostIdentityMode.rp,
          identityId: 'rp',
          identityToken: 'original-token',
        ),
      ),
    );
    identities.fail = true;
    expect(find.byTooltip('重试发表'), findsOneWidget);
    expect(find.text('本次发表需要确认。'), findsNothing);
    await _submit(tester);
    expect(posts.createInputs, hasLength(1));
    expect(posts.createInputs.single.clientRequestId, 'original-request');
    expect(posts.createInputs.single.identityToken, 'original-token');
    expect(posts.createInputs.single.content, '保留的正文');
  });
}
