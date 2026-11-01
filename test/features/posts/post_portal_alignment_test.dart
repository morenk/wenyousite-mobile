import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/editor_link_toolbar.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final direction in ['', 'center', 'right']) {
    testWidgets('真实编辑页同行传送门保存重开保持对齐和阅读字号 $direction', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = PostRepliesPageTestFakePostRepository();
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
        markdownAlignment: true,
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      Future<void> open() async {
        await postRepliesPageTestLongPressPostMetadata(tester, 'reply-own');
        await postRepliesPageTestPumpUi(tester);
        await tester.tap(
          find.byKey(const Key('post-card-action-reply-own-edit')),
        );
        await postRepliesPageTestPumpUi(tester);
      }

      QuillEditor editor() => tester.widget<QuillEditor>(
        find.byKey(const Key('post-composer-body')),
      );
      await open();
      expect(editor().config.customStyles!.paragraph!.style.fontSize, 15);
      await postRepliesPageTestReplaceComposerText(tester, '正文你好');
      if (direction.isNotEmpty) {
        await tester.tap(find.byKey(const Key('editor-more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('editor-align-$direction')));
        await tester.pumpAndSettle();
        // 收起当前托盘，让通用链接帮助函数从主工具栏打开。
        await tester.tap(find.byKey(const Key('editor-more')));
        await tester.pumpAndSettle();
      }
      editor().controller.updateSelection(
        const TextSelection(baseOffset: 2, extentOffset: 4),
        ChangeSource.local,
      );
      const target = '/threads/cmsewdo0h000x7qv6aa77ll1v';
      await insertToolbarLink(tester, '你好', 'https://wenyou.site$target');
      expect(editor().controller.document.toPlainText(), '正文\uFFFC\n');
      final expected =
          '${direction.isEmpty ? '' : '[wenyousite-align-v1-$direction]: #\n'}正文[你好]($target)';
      expect(
        MarkdownDeltaCodec.encode(editor().controller.document.toDelta()),
        expected,
      );
      await tester.tap(find.byKey(const Key('editor-submit')));
      await postRepliesPageTestPumpUi(tester);
      expect(
        repository.replies
            .singleWhere((post) => post.id == 'reply-own')
            .content,
        expected,
      );
      expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
      final text = tester
          .widgetList<RichText>(find.byType(RichText))
          .singleWhere((text) => text.text.toPlainText().contains('正文'));
      expect(text.textAlign, switch (direction) {
        'center' => TextAlign.center,
        'right' => TextAlign.end,
        _ => TextAlign.start,
      });
      expect(
        tester
            .widgetList<WenyouMarkdown>(find.byType(WenyouMarkdown))
            .every((body) => body.bodyFontSize == 15),
        isTrue,
      );
      await open();
      expect(editor().controller.document.root.children, hasLength(1));
      expect(
        MarkdownDeltaCodec.encode(editor().controller.document.toDelta()),
        expected,
      );
      for (final preference in [
        ThreadFontPreference.size13,
        ThreadFontPreference.size19,
        ThreadFontPreference.standard,
      ]) {
        await container
            .read(threadFontPreferenceControllerProvider.notifier)
            .select(preference);
        await tester.pumpAndSettle();
        expect(
          editor().config.customStyles!.paragraph!.style.fontSize,
          preference.fontSize,
        );
        expect(
          MarkdownDeltaCodec.encode(editor().controller.document.toDelta()),
          expected,
        );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
