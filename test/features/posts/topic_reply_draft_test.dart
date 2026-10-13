import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_drafts.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_opening.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('主题内从 A 回复切到 B 回复继续输入并向 B 发表，成功后清空', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository();
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestReplaceComposerText(tester, 'A 楼写到一半\n继续第二段');
    await postRepliesPageTestDismissPostComposerFromOutside(tester);

    final otherReply = find.byKey(const Key('post-card-reply-other'));
    await tester.ensureVisible(otherReply);
    await tester.tap(otherReply);
    await postRepliesPageTestPumpUi(tester);
    final controller = tester
        .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
        .widget
        .controller;
    expect(controller.document.toPlainText(), 'A 楼写到一半\n继续第二段\n');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);
    expect(repository.createInputs.single.parentPostId, 'root');
    expect(repository.createInputs.single.replyToPostId, 'reply-other');
    expect(repository.createInputs.single.content, 'A 楼写到一半\n继续第二段');

    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    expect(
      tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller
          .document
          .toPlainText(),
      '\n',
    );
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
  });

  testWidgets('退出楼中楼页面后跨子贴恢复主题草稿并向新楼层发表', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository(
      initialReplies: [],
      onFetchPost: (id) async => PostItem(
        id: id,
        threadId: 'thread',
        subthreadId: id == 'root' ? 'subthread' : 'subthread-two',
        author: postRepliesPageTestRootAuthor,
        content: '楼层 $id',
        version: 1,
        createdAt: postRepliesPageTestRootCreatedAt,
        updatedAt: postRepliesPageTestRootCreatedAt,
        isBody: false,
        isDeleted: false,
        floorNumber: 1,
      ),
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    Future<void> openPage(String id) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: PostRepliesPage(
              key: ValueKey(id),
              threadId: 'thread',
              rootPostId: id,
            ),
          ),
        ),
      );
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await postRepliesPageTestPumpUi(tester);
    }

    await openPage('root');
    await postRepliesPageTestReplaceComposerText(tester, '跨页粗体\n下一段');
    _editor(tester).formatText(0, 4, Attribute.bold);
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    // 也覆盖新进程只剩本机记录的恢复路径，不能依赖页面 Map。
    container.invalidate(postComposerDraftsProvider);
    await openPage('floor-b');
    expect(_editor(tester).document.toPlainText(), '跨页粗体\n下一段\n');
    expect(_editor(tester).document.toDelta().toJson().first['attributes'], {
      'bold': true,
    });
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);
    expect(repository.createInputs.single.subthreadId, 'subthread-two');
    expect(repository.createInputs.single.parentPostId, 'floor-b');
    expect(repository.createInputs.single.replyToPostId, 'floor-b');
    expect(repository.createInputs.single.content, '**跨页粗体**\n下一段');
  });

  for (final ambiguous in [false, true]) {
    testWidgets(ambiguous ? '未知结果阻止换目标并在原入口复用载荷' : '明确失败保留正文并允许换目标发表', (
      tester,
    ) async {
      var fail = true;
      final repository = PostRepliesPageTestFakePostRepository(
        onCreate: (input) async {
          if (fail) {
            throw ApiFailure(
              userMessage: '发表失败',
              httpStatus: ambiguous ? 503 : 400,
            );
          }
          return postRepliesPageTestReply(
            'created',
            input.content,
            postRepliesPageTestAuthor,
          );
        },
      );
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await postRepliesPageTestPumpUi(tester);
      await postRepliesPageTestReplaceComposerText(tester, '失败后保留的内容');
      await tester.tap(find.byKey(const Key('editor-submit')));
      await postRepliesPageTestPumpUi(tester);
      final original = repository.createInputs.single;
      await postRepliesPageTestDismissPostComposerFromOutside(tester);
      container.invalidate(postComposerDraftsProvider);
      final otherReply = find.byKey(const Key('post-card-reply-other'));
      await tester.ensureVisible(otherReply);
      await tester.tap(otherReply);
      await postRepliesPageTestPumpUi(tester);
      if (ambiguous) {
        expect(find.text(postDraftTargetBlockedMessage), findsOneWidget);
        expect(find.byKey(const Key('post-composer-body')), findsNothing);
        expect(repository.createInputs, hasLength(1));
        await tester.tap(find.text('关闭'));
        await postRepliesPageTestPumpUi(tester);
        await tester.tap(find.byKey(const Key('post-reply-compose')));
        await postRepliesPageTestPumpUi(tester);
        expect(find.byTooltip('重试发表'), findsOneWidget);
      }
      expect(_editor(tester).document.toPlainText(), '失败后保留的内容\n');
      fail = false;
      await tester.tap(find.byKey(const Key('editor-submit')));
      await postRepliesPageTestPumpUi(tester);
      final retried = repository.createInputs.last;
      expect(repository.createInputs, hasLength(2));
      expect(retried.replyToPostId, ambiguous ? 'root' : 'reply-other');
      expect(retried.content, original.content);
      expect(
        retried.clientRequestId,
        ambiguous ? original.clientRequestId : isNot(original.clientRequestId),
      );
    });
  }
}

QuillController _editor(WidgetTester tester) => tester
    .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
    .widget
    .controller;
