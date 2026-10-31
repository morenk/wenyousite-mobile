import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

class _OfflineFonts extends TextFontService {
  _OfflineFonts() : super(WenyouApi());

  @override
  Future<TextFontRuntime> load() async => throw const FormatException('离线');
}

class _Repository extends PostRepliesPageTestFakePostRepository {
  _Repository(this.content);
  String content;

  @override
  Future<PostItem> fetchPost(String postId) async =>
      postRepliesPageTestRootWithContent(content);

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    updateRequests.add((id: postId, content: content, version: version));
    this.content = content;
    return postRepliesPageTestRootWithContent(content);
  }
}

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final (version, font) in [
    (1, 'wenkai'),
    (2, 'tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
  ]) {
    for (final breaks in [5, 6]) {
      testWidgets('先选字体 v$version 再输入 $breaks 次回车，保存阅读和重开保留空段及样式', (
        tester,
      ) async {
        // 按负责人确认的先选字体、连续五六次回车操作复现；没有读取私密楼层。
        String span(String text) =>
            '<span data-wenyou-font-v$version="$font">$text</span>';
        const title = '夜深忽梦少年事，梦啼妆泪红阑干';
        final repository = _Repository('## ${span(title)}\n<br />');
        final fonts = _OfflineFonts();
        addTearDown(fonts.dispose);
        final container = await postRepliesPageTestPostContainer(
          repository,
          userId: 'root-author',
          extraOverrides: [
            textFontServiceProvider.overrideWithValue(fonts),
            appCapabilitiesProvider.overrideWithValue(
              const AppCapabilities(
                textFontSupported: true,
                textFontWriteEnabled: true,
                textFontV2Supported: true,
                textFontV2WriteEnabled: true,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
        await postRepliesPageTestPumpUi(tester);

        Future<QuillController> open() async {
          await postRepliesPageTestLongPressPostMetadata(tester, 'root');
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('post-card-action-root-edit')));
          await postRepliesPageTestPumpUi(tester);
          return tester
              .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
              .controller;
        }

        final controller = await open();
        expect(controller.document.toPlainText(), '$title\n\n');
        controller.updateSelection(
          TextSelection.collapsed(offset: title.length + 1),
          ChangeSource.local,
        );
        expect(
          EditorTextFontPolicy.apply(controller, controller.selection, font),
          isTrue,
        );
        for (final input in ['哈哈哈', ...List.filled(breaks, '\n'), '姐姐']) {
          final offset = controller.selection.extentOffset;
          controller.replaceText(
            offset,
            0,
            input,
            TextSelection.collapsed(offset: offset + input.length),
          );
        }
        final expectedBody = '哈哈哈${'\n' * breaks}姐姐';
        expect(controller.document.toPlainText(), '$title\n$expectedBody\n');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('editor-submit')));
        await tester.pumpAndSettle();
        expect(repository.updateRequests, hasLength(1));
        expect(find.byKey(const Key('post-composer-body')), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText && widget.text.toPlainText() == expectedBody,
          ),
          findsOneWidget,
        );

        final reopened = await open();
        final document = reopened.document;
        expect(document.toPlainText(), '$title\n$expectedBody\n');
        expect(document.root.children, hasLength(breaks + 2));
        expect(
          document.collectStyle(0, title.length).attributes['font']?.value,
          font,
        );
        expect(
          document.collectStyle(0, title.length).attributes['header']?.value,
          2,
        );
        final first = document.toPlainText().indexOf('哈哈哈');
        expect(document.collectStyle(first, 3).attributes['font']?.value, font);
        final last = document.toPlainText().indexOf('姐姐');
        expect(document.collectStyle(last, 2).attributes['font']?.value, font);
        expect(tester.takeException(), isNull);
        await postRepliesPageTestDismissPostComposerFromOutside(tester);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
}
