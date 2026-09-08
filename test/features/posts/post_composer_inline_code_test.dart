import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('反馈楼层打开、编辑行内代码、保存及重开保留可见行和样式', (tester) async {
    final repository = _InlineCodePostRepository();
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'root-author',
      markdownAlignment: true,
      markdownImageAlignment: true,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);

    Future<QuillController> openEditor() async {
      await postRepliesPageTestLongPressPostMetadata(tester, 'root');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('post-card-action-root-edit')));
      await postRepliesPageTestPumpUi(tester);
      return tester
          .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
          .controller;
    }

    void checkDocument(Document document, {required bool edited}) {
      final code = edited ? '1423' : '123';
      final expected = '123\n123\n\n$code\n123\n\n123\n123\n';
      expect(document.toPlainText(), expected);
      expect(
        document.collectStyle(9, code.length).attributes['code']?.value,
        true,
      );
      final secondPlain = 10 + code.length;
      expect(document.collectStyle(secondPlain, 3).attributes['code'], isNull);
      expect(
        document.collectStyle(secondPlain + 5, 3).attributes['strike']?.value,
        true,
      );
      expect(
        document.collectStyle(secondPlain + 9, 3).attributes['code']?.value,
        true,
      );
    }

    final controller = await openEditor();
    checkDocument(controller.document, edited: false);
    controller.replaceText(
      10,
      0,
      '4',
      const TextSelection.collapsed(offset: 11),
    );
    await tester.pump();
    checkDocument(controller.document, edited: true);
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(repository.updateRequests.single.content, _editedSource);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is WenyouInlineCodeSurface && widget.text == '1423',
      ),
      findsOneWidget,
    );

    final reopened = await openEditor();
    checkDocument(reopened.document, edited: true);
    expect(repository.updateRequests, hasLength(1));
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    expect(tester.takeException(), isNull);
  });
}

// 精确复用反馈楼层正文；读写均使用本地仓储，不改动线上楼层。
const _source = '> 123\n123\n<br />\n`123`\n123\n<br />\n~~123~~\n`123`';
const _editedSource = '> 123\n123\n<br />\n`1423`\n123\n<br />\n~~123~~\n`123`';

class _InlineCodePostRepository extends PostRepliesPageTestFakePostRepository {
  PostItem root = postRepliesPageTestRootWithContent(_source);

  @override
  Future<PostItem> fetchPost(String postId) =>
      postId == 'root' ? Future.value(root) : super.fetchPost(postId);

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    expect(postId, 'root');
    updateRequests.add((id: postId, content: content, version: version));
    return root = postRepliesPageTestRootWithContent(content);
  }
}
