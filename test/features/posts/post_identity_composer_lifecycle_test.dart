import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_preference_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_identity_composer_bar.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';

import '../../support/thread_identity_fixtures.dart';
import 'post_replies_page_test_support.dart';

class _IdentityRepository extends Mock implements ThreadIdentityRepository {
  @override
  Future<ThreadIdentityCollection> list(String threadId) async =>
      identityTestCollection(await mine(threadId));
}

void main() {
  testWidgets('关闭后重新打开其他发表入口沿用选择，站内选择也会覆盖记忆', (tester) async {
    final repo = _IdentityRepository();
    when(() => repo.mine('thread')).thenAnswer(
      (_) async => const ThreadIdentityState(
        threadId: 'thread',
        userId: 'author-1',
        enabled: true,
        eligible: true,
        canEdit: true,
        accountName: '站内用户',
        identityToken: 'current-token',
        display: RpIdentity(id: 'rp', nickname: '白夜'),
      ),
    );
    final container = await postRepliesPageTestPostContainer(
      PostRepliesPageTestFakePostRepository(),
      userId: 'author-1',
      identityRepository: repo,
    );
    addTearDown(container.dispose);
    var opening = 0;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  opening++;
                  showPostComposerSheet(
                    context: context,
                    supportsRpIdentity: true,
                    target: (
                      kind: PostComposerKind.createFloor,
                      threadId: 'thread',
                      subthreadId: 'subthread-${opening == 1 ? 1 : 2}',
                      postId: null,
                      parentPostId: null,
                      replyToPostId: null,
                      version: null,
                      initialContent: '',
                      label: '发表楼层',
                    ),
                  );
                },
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );
    Future<void> open() async {
      await tester.tap(find.text('打开'));
      await postRepliesPageTestPumpUi(tester);
    }

    Future<void> choose(String option) async {
      await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(find.byKey(Key('post-identity-option-$option')));
      await postRepliesPageTestPumpUi(tester);
    }

    PostIdentitySelection currentSelection() => tester
        .widget<PostIdentityComposerBar>(find.byType(PostIdentityComposerBar))
        .selection;
    await open();
    await choose('rp-rp');
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    await open();
    expect(currentSelection().identityId, 'rp');
    expect(currentSelection().acceptedToken, 'current-token');
    await choose('account');
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    // 再回到第一个入口，其空白本机草稿不能把最新的站内选择改回 RP。
    opening = 0;
    await open();
    expect(currentSelection().mode, PostIdentityMode.account);
    expect(
      await container
          .read(postIdentityPreferenceStoreProvider)
          .read('author-1', 'thread'),
      isNull,
    );
    expect(tester.takeException(), isNull);
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
  });

  const sameNameIdentity = ThreadIdentityState(
    threadId: 'thread',
    userId: 'author-1',
    enabled: true,
    eligible: true,
    canEdit: true,
    accountName: '同名用户',
    nickname: '私密角色',
    identityToken: 'confirmed',
    display: RpIdentity(id: 'rp', nickname: '同名用户'),
  );
  testWidgets('常驻栏隐藏模式副标题，读屏仍区分同名账号和角色', (tester) async {
    final semantics = tester.ensureSemantics();
    final repo = _IdentityRepository();
    when(() => repo.mine('thread')).thenAnswer((_) async => sameNameIdentity);
    final selection = PostIdentitySelection(repo, 'thread');
    addTearDown(selection.dispose);
    await selection.refresh();
    selection.select(PostIdentityMode.rp, id: 'rp');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PostIdentityComposerBar(
            selection: selection,
            locked: false,
            onSettings: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('帖内身份'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('以帖内身份「同名用户」发表')), findsOneWidget);
    expect(find.text('同名用户'), findsOneWidget);
    selection.select(PostIdentityMode.account);
    await tester.pump();
    expect(find.text('站内身份'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('以站内身份「同名用户」发表')), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
  testWidgets('退出账号时立即关闭身份资料Sheet，不残留私帖输入', (tester) async {
    final repo = _IdentityRepository();
    when(() => repo.mine('thread')).thenAnswer((_) async => sameNameIdentity);
    final container = await postRepliesPageTestPostContainer(
      PostRepliesPageTestFakePostRepository(),
      userId: 'author-1',
      identityRepository: repo,
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
                onPressed: () => showThreadIdentityEditor(context, 'thread'),
                child: const Text('设置'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('设置'));
    await postRepliesPageTestPumpUi(tester);
    expect(find.byKey(const Key('thread-identity-nickname')), findsOneWidget);
    await container.read(sessionControllerProvider.notifier).logoutLocally();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-identity-nickname')), findsNothing);
    expect(find.textContaining('私密角色'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('打开带冻结请求的RP草稿不在build期间写provider，保留原身份与正文', (tester) async {
    final identity = _IdentityRepository();
    when(() => identity.mine('thread')).thenAnswer(
      (_) async => const ThreadIdentityState(
        threadId: 'thread',
        userId: 'author-1',
        enabled: true,
        eligible: true,
        canEdit: true,
        accountName: '账号',
        identityToken: 'new-token',
        display: RpIdentity(id: 'rp', nickname: '现在的名字'),
      ),
    );
    final posts = PostRepliesPageTestFakePostRepository();
    final container = await postRepliesPageTestPostContainer(
      posts,
      userId: 'author-1',
      identityRepository: identity,
    );
    addTearDown(container.dispose);
    const target = (
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
    final draft = PostComposerDraft(
      content: '冻结正文',
      baseContent: '',
      basePostId: null,
      baseVersion: null,
      publishDraft: PostPublishDraft(
        mode: PostIdentityMode.rp,
        identityToken: 'old-token',
        pending: PendingPostCreate(
          input: PostCreateInput(
            subthreadId: 'subthread',
            content: '冻结正文',
            clientRequestId: 'same-request',
            identityMode: PostIdentityMode.rp,
            identityToken: 'old-token',
          ),
        ),
      ),
    );
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
                  target: target,
                  initialDraft: draft,
                  supportsRpIdentity: true,
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
    expect(tester.takeException(), isNull);
    expect(find.text('重试确认发表'), findsWidgets);
    final dropdown = tester.widget<WenyouSelectionMenu>(
      find.byKey(const Key('post-composer-identity-mode')),
    );
    expect(dropdown.enabled, isFalse);
    expect(posts.createInputs, isEmpty);
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    expect(tester.takeException(), isNull);
  });
}
