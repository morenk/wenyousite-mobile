import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import '../../support/block_boundary_fixtures.dart';
import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  final actualSaves = <Map<String, dynamic>>[];
  tearDownAll(() {
    Directory('build').createSync(recursive: true);
    File('build/mobile-block-boundary-editor-saves.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(actualSaves),
    );
  });
  final fixture = loadBlockBoundaryFixture();
  for (final item
      in (fixture['editCases'] as List).cast<Map<String, dynamic>>()) {
    testWidgets('真实楼层页面 ${item['id']} 输入保存并三轮重开', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository(
        initialReplies: [
          postRepliesPageTestReply(
            'reply-own',
            item['markdown'] as String,
            postRepliesPageTestAuthor,
          ),
        ],
      );
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
        markdownAlignment: true,
        markdownImageAlignment: true,
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await _edit(tester);
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('post-composer-body')),
      );
      final operation = item['operation'] as Map<String, dynamic>;
      final before = editor.controller.document.toPlainText();
      final offset =
          before.indexOf(operation['anchor'] as String) +
          (operation['offset'] as int);
      editor.controller.updateSelection(
        TextSelection.collapsed(offset: offset),
        ChangeSource.local,
      );
      editor.focusNode.requestFocus();
      await tester.pump();
      final inserted = operation['kind'] == 'enter'
          ? '\n'
          : operation['text'] as String;
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: before.replaceRange(offset, offset, inserted),
          selection: TextSelection.collapsed(offset: offset + inserted.length),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        boundaryRows(
          editor.controller.document.toDelta(),
        ).map((row) => row['text']).toList(),
        item['lines'],
      );
      expect(
        boundaryRows(
          editor.controller.document.toDelta(),
        ).map((row) => row['alignment']).toList(),
        item['lineAlignments'],
      );
      for (var round = 0; round < 3; round++) {
        await tester.tap(find.byKey(const Key('editor-submit')));
        await tester.pumpAndSettle();
        expect(repository.updateRequests.last.content, item['serialized']);
        actualSaves.add({
          'id': '${item['id']}-round-$round',
          'markdown': repository.updateRequests.last.content,
          'producer': 'PostRepliesPage-IME-submit',
        });
        expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
        await _edit(tester);
        final controller = tester
            .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
            .controller;
        expect(
          boundaryRows(
            controller.document.toDelta(),
          ).map((row) => row['text']).toList(),
          item['lines'],
        );
        expect(
          boundaryRows(
            controller.document.toDelta(),
          ).map((row) => row['alignment']).toList(),
          item['lineAlignments'],
        );
        expect(
          MarkdownDeltaCodec.encode(
            controller.document.toDelta(),
            imageAlignment: true,
          ),
          item['serialized'],
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
  final original =
      jsonDecode(
            File(
              'test/fixtures/markdown-block-boundary-original-space.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final sources = [
    original['markdown'] as String,
    (fixture['whitespaceCases'] as List).first['markdown'] as String,
    '\u2060  甲  😀 乙　丙  \u2060',
  ];
  for (var i = 0; i < sources.length; i++) {
    testWidgets('真实页面空格排版 $i 编辑再保存保持原字符', (tester) async {
      final source = sources[i];
      final repository = PostRepliesPageTestFakePostRepository(
        initialReplies: [
          postRepliesPageTestReply(
            'reply-own',
            source,
            postRepliesPageTestAuthor,
          ),
        ],
      );
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
        markdownAlignment: true,
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await _edit(tester);
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('post-composer-body')),
      );
      expect(
        MarkdownDeltaCodec.encode(editor.controller.document.toDelta()),
        source,
      );
      final text = editor.controller.document.toPlainText();
      final offset = text.indexOf(i == 0 ? '荒' : '甲') + 1;
      editor.controller.updateSelection(
        TextSelection.collapsed(offset: offset),
        ChangeSource.local,
      );
      editor.focusNode.requestFocus();
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: text.replaceRange(offset, offset, '续'),
          selection: TextSelection.collapsed(offset: offset + 1),
        ),
      );
      await tester.pumpAndSettle();
      final expected = source.replaceFirst(
        i == 0 ? '荒' : '甲',
        i == 0 ? '荒续' : '甲续',
      );
      await tester.tap(find.byKey(const Key('editor-submit')));
      await tester.pumpAndSettle();
      expect(repository.updateRequests.single.content, expected);
      if (i > 0) {
        actualSaves.add({
          'id': 'synthetic-whitespace-$i',
          'markdown': repository.updateRequests.single.content,
          'producer': 'PostRepliesPage-IME-submit',
        });
      }
      await _edit(tester);
      final controller = tester
          .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
          .controller;
      expect(
        MarkdownDeltaCodec.encode(controller.document.toDelta()),
        expected,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _edit(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('post-reply-reply-own')));
  await postRepliesPageTestLongPressPostMetadata(tester, 'reply-own');
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('post-card-action-reply-own-edit')));
  await tester.pumpAndSettle();
}
