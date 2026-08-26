import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_opening.dart';

void main() {
  test('同一基线版本的本机草稿可安全恢复，正文分叉才要求选择', () {
    const baseline = PostComposerBaseline(
      content: '服务端正文',
      postId: 'floor',
      version: 4,
    );

    expect(
      resolvePostComposerDraft(
        draft: const PostComposerDraft(
          content: '本机修改',
          baseContent: '服务端正文',
          basePostId: 'floor',
          baseVersion: 4,
        ),
        baseline: baseline,
      ),
      PostComposerDraftResolution.restore,
    );
    expect(
      resolvePostComposerDraft(
        draft: const PostComposerDraft(
          content: '本机修改',
          baseContent: '更早正文',
          basePostId: 'floor',
          baseVersion: 3,
        ),
        baseline: baseline,
      ),
      PostComposerDraftResolution.diverged,
    );
  });

  testWidgets('编辑已有正文时先读取最新版作为编辑基线', (tester) async {
    final repository = _FakePostRepository(
      latest: _post(content: '最新版', version: 4),
    );
    PreparedPostComposer? prepared;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Scaffold(
            body: PostComposerOpening(
              target: _target,
              builder: (context, composer) {
                prepared = composer;
                return const Text('编辑器已打开');
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('正在读取最新正文…'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.fetches, ['floor']);
    expect(prepared?.target.version, 4);
    expect(prepared?.target.initialContent, '最新版');
    expect(prepared?.baseline.version, 4);
    expect(prepared?.baseline.content, '最新版');
  });

  testWidgets('本机草稿和最新版分叉时先要求选择再打开编辑器', (tester) async {
    final repository = _FakePostRepository(
      latest: _post(content: '最新版', version: 4),
    );
    PreparedPostComposer? prepared;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Scaffold(
            body: PostComposerOpening(
              target: _target,
              initialDraft: const PostComposerDraft(
                content: '本机修改',
                baseContent: '旧正文',
                basePostId: 'floor',
                baseVersion: 1,
              ),
              builder: (context, composer) {
                prepared = composer;
                return const Text('编辑器已打开');
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('post-composer-draft-diverged')), findsOne);
    expect(prepared, isNull);

    await tester.tap(find.byKey(const Key('post-composer-keep-local')));
    await tester.pump();

    expect(prepared?.target.initialContent, '本机修改');
    expect(prepared?.target.version, 4);
    expect(prepared?.baseline.content, '最新版');
  });

  testWidgets('回读正文已经等于本机草稿时清除草稿并使用当前版本', (tester) async {
    final repository = _FakePostRepository(
      latest: _post(content: '本机修改', version: 3),
    );
    final draftEvents = <PostComposerDraft?>[];
    PreparedPostComposer? prepared;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Scaffold(
            body: PostComposerOpening(
              target: _target,
              initialDraft: const PostComposerDraft(
                content: '本机修改',
                baseContent: '旧正文',
                basePostId: 'floor',
                baseVersion: 1,
              ),
              onDraftChanged: draftEvents.add,
              builder: (context, composer) {
                prepared = composer;
                return const Text('编辑器已打开');
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(draftEvents, [null]);
    expect(prepared?.target.version, 3);
    expect(prepared?.target.initialContent, '本机修改');
  });

  testWidgets('最新版读取失败时保留在入口并可重试', (tester) async {
    final repository = _FakePostRepository(
      latest: _post(content: '最新版', version: 4),
      failures: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Scaffold(
            body: PostComposerOpening(
              target: _target,
              builder: (context, composer) => const Text('编辑器已打开'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('post-composer-opening-failure')),
      findsOneWidget,
    );
    expect(find.text('编辑器已打开'), findsNothing);

    await tester.tap(find.byKey(const Key('post-composer-opening-retry')));
    await tester.pumpAndSettle();

    expect(repository.fetches, ['floor', 'floor']);
    expect(find.text('编辑器已打开'), findsOneWidget);
  });
}

const PostComposerTarget _target = (
  kind: PostComposerKind.editPost,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: 'floor',
  parentPostId: null,
  replyToPostId: null,
  version: 1,
  initialContent: '旧正文',
  label: '编辑楼层',
);

PostItem _post({required String content, required int version}) => PostItem(
  id: 'floor',
  threadId: 'thread',
  subthreadId: 'subthread',
  author: const PostAuthor(id: 'author', username: '作者', level: 1),
  content: content,
  version: version,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  isBody: false,
  isDeleted: false,
);

class _FakePostRepository implements PostRepository {
  _FakePostRepository({required this.latest, this.failures = 0});

  final PostItem latest;
  final int failures;
  final fetches = <String>[];

  @override
  Future<PostItem> fetchPost(String postId) async {
    fetches.add(postId);
    if (fetches.length <= failures) {
      throw const ApiFailure(userMessage: '正文加载失败，请重试。');
    }
    return latest;
  }

  @override
  Future<PostItem> create(PostCreateInput input) => throw UnimplementedError();

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) => throw UnimplementedError();

  @override
  Future<void> remove(String postId) => throw UnimplementedError();

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) => throw UnimplementedError();

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) => throw UnimplementedError();
}
