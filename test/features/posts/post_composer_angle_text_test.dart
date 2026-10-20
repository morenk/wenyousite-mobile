import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('原片段经实际楼层打开、输入、保存和重开保留文字空段及居中斜体', (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previous = FailureDiagnostics.instance;
    final diagnostics = FailureDiagnostics();
    FailureDiagnostics.instance = diagnostics;
    addTearDown(() {
      FailureDiagnostics.instance = previous;
      diagnostics.dispose();
    });
    final repository = _AnglePostRepository();
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'root-author',
      markdownAlignment: true,
      markdownImageAlignment: true,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);

    void checkReader(String text) {
      final finder = find.text(text, findRichText: true);
      expect(finder, findsOneWidget);
      final rich = tester.widget<RichText>(finder);
      expect(rich.textAlign, TextAlign.center);
      final italicText = StringBuffer();
      void visit(InlineSpan span, FontStyle? inherited) {
        final style = span.style?.fontStyle ?? inherited;
        if (span is TextSpan) {
          if (style == FontStyle.italic) italicText.write(span.text ?? '');
          for (final child in span.children ?? const <InlineSpan>[]) {
            visit(child, style);
          }
        }
      }

      visit(rich.text, null);
      expect(italicText.toString(), text);
      expect(
        find.textContaining('wenyousite-align', findRichText: true),
        findsNothing,
      );
    }

    checkReader('<<Y/N >>');

    Future<QuillController> open() async {
      await postRepliesPageTestLongPressPostMetadata(tester, 'root');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('post-card-action-root-edit')));
      await postRepliesPageTestPumpUi(tester);
      return tester
          .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
          .controller;
    }

    void checkEditor(QuillController controller, String text) {
      expect(controller.readOnly, isFalse);
      expect(controller.document.toPlainText(), '前文\n\n$text\n\n后文\n');
      final style = controller.document.collectStyle(4, text.length).attributes;
      expect(style['italic']?.value, isTrue);
      expect(style['align']?.value, 'center');
      expect(find.text('这段内容暂不支持编辑，原文已保留。'), findsNothing);
      expect(diagnostics.records, isEmpty);
    }

    final controller = await open();
    checkEditor(controller, '<<Y/N >>');
    controller.replaceText(
      6,
      0,
      '确认',
      const TextSelection.collapsed(offset: 8),
    );
    await tester.pump();
    checkEditor(controller, '<<确认Y/N >>');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    final saved = repository.updateRequests.single.content;
    expect(MarkdownContent.unsupportedLineIndexes(saved), isEmpty);
    expect(MarkdownAlignmentContract.analyze(saved).blocks, hasLength(1));
    checkReader('<<确认Y/N >>');
    checkEditor(await open(), '<<确认Y/N >>');
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    expect(repository.updateRequests, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}

// 原反馈片段逐字符保留；上下文为空段边界样例，本地仓储不写线上帖子。
const _source =
    '前文\n<br />\n[wenyousite-align-v1-center]: #\n'
    r'*<\<Y/N \>\>*'
    '\n<br />\n后文';

class _AnglePostRepository extends PostRepliesPageTestFakePostRepository {
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
