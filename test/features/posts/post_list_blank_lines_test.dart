import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';

import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  for (final suffix in ['', '（二）\nccc', '（二）\nccc\nddd']) {
    testWidgets(
      '视频操作：有序列表后留空行${suffix.isEmpty
          ? '结束'
          : suffix.contains('ddd')
          ? '接列表'
          : '续写'}可发布及重新编辑',
      (tester) async {
        final repository = PostRepliesPageTestFakePostRepository();
        final container = await postRepliesPageTestPostContainer(
          repository,
          userId: 'author-1',
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
        await postRepliesPageTestPumpUi(tester);
        await tester.tap(find.byKey(const Key('post-reply-compose')));
        await tester.pumpAndSettle();
        final controller = _controller(tester);
        const text = '一、\n（一）\naaa\nbbb';
        controller.replaceText(
          0,
          0,
          text,
          const TextSelection(baseOffset: 7, extentOffset: 14),
        );
        WenyouEditorFormatPolicy.toggle(controller, Attribute.ol);
        controller.updateSelection(
          const TextSelection.collapsed(offset: 14),
          ChangeSource.local,
        );
        for (var i = 0; i < 3; i++) {
          final offset = controller.selection.start;
          controller.replaceText(
            offset,
            0,
            '\n',
            TextSelection.collapsed(offset: offset + 1),
          );
          await tester.pumpAndSettle();
          expect(find.textContaining('不能安全保存'), findsNothing);
        }
        if (suffix.isNotEmpty) {
          final offset = controller.selection.start;
          controller.replaceText(
            offset,
            0,
            suffix,
            TextSelection.collapsed(offset: offset + suffix.length),
          );
          if (suffix.contains('ddd')) {
            controller.updateSelection(
              TextSelection(baseOffset: offset + 4, extentOffset: offset + 11),
              ChangeSource.local,
            );
            WenyouEditorFormatPolicy.toggle(controller, Attribute.ol);
          }
        }
        await tester.pumpAndSettle();
        final expectedText = controller.document.toPlainText();
        expect(expectedText, contains('aaa\nbbb\n\n'));
        await tester.tap(find.byKey(const Key('editor-submit')));
        await tester.pumpAndSettle();
        expect(repository.createInputs, hasLength(1));
        expect(repository.createInputs.single.content, contains('<br />'));
        expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
        await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
        await postRepliesPageTestLongPressPostMetadata(tester, 'created');
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('post-card-action-created-edit')),
        );
        await tester.pumpAndSettle();
        expect(_controller(tester).document.toPlainText(), expectedText);
        expect(find.textContaining('不能安全保存'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

QuillController _controller(WidgetTester tester) => tester
    .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
    .widget
    .controller;
