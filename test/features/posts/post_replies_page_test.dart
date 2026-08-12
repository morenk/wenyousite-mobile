import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('360dp 独立楼中楼悬浮发表入口并完成编辑删除与权限收敛', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(
            threadId: 'thread',
            rootPostId: 'root',
            reportsEnabled: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('原楼层内容'), findsOneWidget);
    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('他人的回复'), findsOneWidget);
    expect(find.byKey(const Key('post-replies-order')), findsOneWidget);
    expect(find.byKey(const Key('post-replies-author')), findsOneWidget);
    expect(find.byKey(const Key('post-replies-count')), findsOneWidget);
    expect(find.text('楼中楼讨论'), findsOneWidget);
    final countCenter = tester.getCenter(
      find.byKey(const Key('post-replies-count')),
    );
    final orderCenter = tester.getCenter(
      find.byKey(const Key('post-replies-order')),
    );
    final authorCenter = tester.getCenter(
      find.byKey(const Key('post-replies-author')),
    );
    expect((countCenter.dy - orderCenter.dy).abs(), lessThan(2));
    expect((orderCenter.dy - authorCenter.dy).abs(), lessThan(2));
    expect(find.byKey(const Key('post-edit-reply-own')), findsNothing);
    expect(find.byKey(const Key('post-edit-reply-other')), findsNothing);
    expect(find.byKey(const Key('post-report-root')), findsNothing);
    expect(find.byKey(const Key('post-report-reply-own')), findsNothing);
    expect(find.byKey(const Key('post-report-reply-other')), findsNothing);
    expect(find.byKey(const Key('post-reply-compose')), findsOneWidget);
    expect(find.text('发表回复…'), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.longPress(find.byKey(const Key('post-card-root')));
    await tester.pumpAndSettle();
    expect(find.text('楼层操作'), findsOneWidget);
    expect(find.text('复制楼层链接'), findsOneWidget);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('post-reply-reply-other')));
    await tester.pumpAndSettle();
    expect(find.text('回复操作'), findsOneWidget);
    expect(find.text('复制'), findsOneWidget);
    expect(find.text('复制楼层链接'), findsOneWidget);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    expect(find.text('回复 @楼层作者'), findsWidgets);
    expect(find.text('回复会平级挂在当前主楼层下。'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('post-composer-sheet'))).height,
      greaterThanOrEqualTo(900),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-composer-canvas'))).height,
      greaterThan(780),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-composer-close'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-composer-submit'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('post-composer-body')),
        matching: find.byType(Card),
      ),
      findsNothing,
    );
    expect(
      tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .focusNode
          .hasFocus,
      isTrue,
    );
    expect(
      tester
          .widget<MentionSuggestions>(find.byType(MentionSuggestions))
          .threadId,
      'thread',
    );
    await _replaceComposerText(tester, '新发表的回复');
    await tester.tap(find.byKey(const Key('post-composer-submit')));
    await tester.pumpAndSettle();

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.parentPostId, 'root');
    expect(repository.createInputs.single.replyToPostId, 'root');
    expect(find.text('新发表的回复'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await tester.longPress(find.byKey(const Key('post-reply-created')));
    await tester.pumpAndSettle();
    expect(find.text('回复操作'), findsOneWidget);
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    final editController = tester
        .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
        .widget
        .controller;
    expect(
      editController.selection.baseOffset,
      editController.document.length - 1,
    );
    await _replaceComposerText(tester, '编辑后的新回复');
    await tester.tap(find.byKey(const Key('post-composer-submit')));
    await tester.pumpAndSettle();

    expect(repository.updateRequests.single.version, 1);
    expect(find.text('编辑后的新回复'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await tester.longPress(find.byKey(const Key('post-reply-created')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除这条回复？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(repository.removedIds, ['created']);
    expect(find.text('编辑后的新回复'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('360dp 回复编辑器保持纯正文画布的视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: Key('post-composer-text-first-visual'),
            child: PostRepliesPage(
              threadId: 'thread',
              rootPostId: 'root',
              reportsEnabled: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('post-composer-sheet')),
      matchesGoldenFile('goldens/post_composer_text_first_360.png'),
    );

    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    expect(editor.config.customStyles?.paragraph?.style.fontSize, 17);
    expect(editor.config.customStyles?.paragraph?.style.height, 1.75);
    expect(editor.focusNode.hasFocus, isTrue);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('post-composer-floating-toolbar')),
      findsOneWidget,
    );
    final formatTools = find.byKey(const Key('editor-format-tools'));
    expect(formatTools, findsOneWidget);
    expect(find.byKey(const Key('editor-heading')), findsNothing);
    expect(editor.focusNode.hasFocus, isTrue);
    final selection = editor.controller.selection;

    await tester.tap(formatTools);
    await tester.pump();

    expect(find.byKey(const Key('editor-heading')), findsOneWidget);
    expect(editor.controller.selection, selection);
    expect(editor.focusNode.hasFocus, isTrue);
  });

  testWidgets('360dp 独立讨论保持正文优先视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const visualKey = Key('post-discussion-text-first-visual');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(_FakePostRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: visualKey,
            child: PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/post_discussion_text_first_360.png'),
    );
  });

  testWidgets('楼中楼阅读顶栏随正文滚动收起并可立即唤回', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('楼中楼讨论').hitTestable(), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('post-replies-list')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('楼中楼讨论').hitTestable(), findsNothing);
    expect(find.byKey(const Key('post-reply-compose')), findsNothing);

    await tester.drag(
      find.byKey(const Key('post-replies-list')),
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();
    expect(find.text('楼中楼讨论').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('post-reply-compose')), findsOneWidget);
  });
}

Future<void> _replaceComposerText(WidgetTester tester, String text) async {
  final editor = find.byKey(const Key('post-composer-body'));
  expect(editor, findsOneWidget);
  final state = tester.state<QuillEditorState>(editor);
  state.widget.focusNode.requestFocus();
  await tester.pump();
  expect(state.widget.focusNode.hasFocus, isTrue);
  final rawEditor = tester.state<QuillRawEditorState>(
    find.descendant(of: editor, matching: find.byType(QuillRawEditor)),
  );
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(
        offset: rawEditor.textEditingValue.text.length,
      ),
    ),
  );
  await tester.idle();
}

class _FakePostRepository implements PostRepository {
  final List<PostItem> replies = [
    _reply('reply-own', '自己的回复', _author),
    _reply('reply-other', '他人的回复', _otherAuthor),
  ];
  final List<PostCreateInput> createInputs = [];
  final List<({String id, String content, int version})> updateRequests = [];
  final List<String> removedIds = [];

  @override
  Future<PostItem> fetchPost(String postId) async {
    if (postId == 'root') return _root;
    return replies.singleWhere((post) => post.id == postId);
  }

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) async {
    final filtered =
        replies
            .where((post) => authorId == null || post.author.id == authorId)
            .toList()
          ..sort(
            (left, right) => order == PostReplyOrder.oldest
                ? left.createdAt.compareTo(right.createdAt)
                : right.createdAt.compareTo(left.createdAt),
          );
    return CursorPage(items: filtered, hasMore: false);
  }

  @override
  Future<PostItem> create(PostCreateInput input) async {
    createInputs.add(input);
    final created = _reply('created', input.content, _author);
    replies.add(created);
    return created;
  }

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    updateRequests.add((id: postId, content: content, version: version));
    final index = replies.indexWhere((post) => post.id == postId);
    final previous = replies[index];
    final updated = _reply(
      postId,
      content,
      previous.author,
      version: version + 1,
    );
    replies[index] = updated;
    return updated;
  }

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) {
    throw UnsupportedError('not used');
  }

  @override
  Future<void> remove(String postId) async {
    removedIds.add(postId);
    replies.removeWhere((post) => post.id == postId);
  }
}

const _author = PostAuthor(id: 'author-1', username: '自己', level: 3);
const _otherAuthor = PostAuthor(id: 'author-2', username: '他人', level: 2);
const _rootAuthor = PostAuthor(id: 'root-author', username: '楼层作者', level: 4);

final _root = PostItem(
  id: 'root',
  threadId: 'thread',
  subthreadId: 'subthread',
  author: _rootAuthor,
  content: '原楼层内容',
  version: 2,
  createdAt: DateTime.utc(2026, 8, 10),
  updatedAt: DateTime.utc(2026, 8, 10),
  isBody: false,
  isDeleted: false,
  floorNumber: 8,
  replyCount: 2,
  threadTitle: '远行主题',
  subthreadTitle: '主线',
);

PostItem _reply(
  String id,
  String content,
  PostAuthor author, {
  int version = 1,
}) {
  return PostItem(
    id: id,
    threadId: 'thread',
    subthreadId: 'subthread',
    author: author,
    content: content,
    version: version,
    createdAt: DateTime.utc(2026, 8, 10, 1, id.hashCode.abs() % 50),
    updatedAt: DateTime.utc(2026, 8, 10, 1, id.hashCode.abs() % 50),
    isBody: false,
    isDeleted: false,
    parentPostId: 'root',
    replyToPostId: 'root',
    replyToAuthor: _rootAuthor,
  );
}

SessionTokens _tokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'e30.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

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
  Future<SessionTokens> refresh(String refreshToken) async =>
      _tokensFor('author-1');
}
