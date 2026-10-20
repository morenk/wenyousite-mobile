import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/editor_link_toolbar.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final target in const [
    '/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd',
    '/threads/cmsewdo0h000x7qv6aa77ll1v?subthread=cmsewdp4i00147qv6gjc85l9p&post=cmsewdqcr001a7qv6cy0y38bd',
    '/threads/cmsewdo0h000x7qv6aa77ll1v',
    '/threads/cmsewdo0h000x7qv6aa77ll1v?subthread=cmsewdp4i00147qv6gjc85l9p',
    '/threads/cmsewdo0h000x7qv6aa77ll1v/posts/cmsewdqcr001a7qv6cy0y38bd/replies?post=cmsewdt0w001n7qv6f6ttylff',
    '/join/AbCdEfGh_123-XYZ',
  ]) {
    for (final selected in [false, true]) {
      testWidgets('工具栏站内链接 $target 选区=$selected 保存并重开', (tester) async {
        final session = RichEditorSession(
          initialMarkdown: selected ? '前文你好后文' : '',
          onMarkdownChanged: (_) {},
        );
        addTearDown(session.dispose);
        final controller = session.controller;
        final before = controller.document.toDelta().toJson();
        final selection = selected
            ? const TextSelection(baseOffset: 4, extentOffset: 2)
            : const TextSelection.collapsed(offset: 0);
        controller.updateSelection(selection, ChangeSource.local);
        await _pumpEditor(tester, session);
        await insertToolbarLink(tester, '你好', 'https://wenyou.site$target');

        expect(await session.flush(), isTrue, reason: session.codecFailure);
        final canonical = target.replaceFirst(
          'subthread=cmsewdp4i00147qv6gjc85l9p&',
          '',
        );
        final expected = selected ? '前文[你好]($canonical)后文' : '[你好]($canonical)';
        expect(session.localMarkdown, expected);
        final node = controller.document.toDelta().operations.firstWhere(
          (op) => op.data is Map,
        );
        expect(node.attributes, isNull);
        expect(node.data, {
          MarkdownDeltaCodec.internalReferenceEmbed: {
            'version': 1,
            'label': '你好',
            'location': canonical,
          },
        });
        expect(
          find.byKey(const Key('editor-internal-reference')),
          findsOneWidget,
        );
        expect(find.byType(WenyouInternalReferenceSurface), findsOneWidget);
        expect(controller.document.root.children, hasLength(1));
        expect(
          controller.selection,
          TextSelection.collapsed(offset: selected ? 3 : 1),
        );
        final reopened = RichEditorSession(
          initialMarkdown: session.localMarkdown,
          onMarkdownChanged: (_) {},
        );
        addTearDown(reopened.dispose);
        expect(
          reopened.controller.document.toPlainText(),
          selected ? '前文\uFFFC后文\n' : '\uFFFC\n',
        );
        expect(reopened.controller.document.root.children, hasLength(1));
        expect(await reopened.flush(), isTrue);

        controller.undo();
        expect(controller.document.toDelta().toJson(), before);
        expect(controller.selection, selection);
        controller.redo();
        expect(await session.flush(), isTrue);
        expect(session.localMarkdown, expected);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final source in const [
    '首段\n\n尾段',
    '首段\n<br />\n尾段',
    '前文[现有](/threads/cmsewdo0h000x7qv6aa77ll1v)后文',
  ]) {
    testWidgets('站内链接拒绝跨段或原子选区并保留全部正文：$source', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      final before = controller.document.toDelta().toJson();
      final selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.document.length - 1,
      );
      controller.updateSelection(selection, ChangeSource.local);
      await _pumpEditor(tester, session);
      await insertToolbarLink(
        tester,
        '你好',
        'https://wenyou.site/threads/cmsewdo0h000x7qv6aa77ll1v',
      );
      expect(find.text('站内链接请选择同一行的普通文字'), findsOneWidget);
      expect(controller.document.toDelta().toJson(), before);
      expect(controller.selection, selection);
      expect(await session.flush(), isTrue);
      expect(session.localMarkdown, source);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('站内链接不继承待应用粗体和外链，保留段落和空行', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '首段\n<br />\n前文后文',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    final offset = controller.document.toPlainText().indexOf('后文');
    controller.updateSelection(
      TextSelection.collapsed(offset: offset),
      ChangeSource.local,
    );
    controller.formatSelection(Attribute.bold);
    controller.formatSelection(const LinkAttribute('https://example.com'));
    await _pumpEditor(tester, session);
    await insertToolbarLink(
      tester,
      '你好',
      'https://wenyou.site/threads/cmsewdo0h000x7qv6aa77ll1v',
    );
    expect(await session.flush(), isTrue);
    expect(
      session.localMarkdown,
      '首段\n<br />\n前文[你好](/threads/cmsewdo0h000x7qv6aa77ll1v)后文',
    );
    final embed = controller.document.toDelta().operations.singleWhere(
      (op) => op.data is Map,
    );
    expect(embed.attributes, isNull);
    expect(controller.document.toPlainText(), '首段\n\n前文\uFFFC后文\n');
    expect(controller.document.root.children, hasLength(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('外链保留普通 link 属性和下划线，保存重开不变', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    await _pumpEditor(tester, session);
    await insertToolbarLink(tester, '你好', 'https://example.com');
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, '[你好](https://example.com)');
    expect(session.controller.document.toPlainText(), '你好\n');
    expect(
      session.controller.document
          .toDelta()
          .operations
          .first
          .attributes?['link'],
      'https://example.com',
    );
    expect(find.byType(WenyouInternalReferenceSurface), findsNothing);
    expect(
      tester
          .widget<QuillEditor>(find.byType(QuillEditor))
          .config
          .customStyles!
          .link!
          .decoration,
      TextDecoration.underline,
    );
  });

  for (final dark in [false, true]) {
    testWidgets('320dp ${dark ? 'dark' : 'light'} 工具栏插入后阅读编辑传送门一致', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      await _pumpEditor(tester, session, dark: dark);
      await insertToolbarLink(
        tester,
        '你好',
        'https://wenyou.site/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd',
      );
      expect(await session.flush(), isTrue);
      await _pumpEditor(
        tester,
        session,
        dark: dark,
        reader: session.localMarkdown,
      );
      await tester.pumpAndSettle();
      expect(find.byType(WenyouInternalReferenceSurface), findsNWidgets(2));
      await expectLater(
        find.byKey(const Key('link-preview')),
        matchesGoldenFile(
          'goldens/link_insertion_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpEditor(
  WidgetTester tester,
  RichEditorSession session, {
  bool dark = false,
  String? reader,
}) => tester.pumpWidget(
  MaterialApp(
    theme: dark ? AppTheme.dark : AppTheme.light,
    home: Builder(
      builder: (context) => Scaffold(
        body: Column(
          children: [
            RepaintBoundary(
              key: const Key('link-preview'),
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('编辑态'),
                      SizedBox(
                        height: 100,
                        child: QuillEditor(
                          controller: session.controller,
                          focusNode: session.focusNode,
                          scrollController: session.scrollController,
                          config: QuillEditorConfig(
                            customStyles: wenyouEditorTextStyles(context),
                            embedBuilders: wenyouEditorEmbedBuilders(),
                          ),
                        ),
                      ),
                      if (reader != null) ...[
                        const Text('阅读态'),
                        WenyouMarkdown(data: reader),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            WenyouEditorToolbar(
              controller: session.controller,
              onInsertImage: () async {},
              onSaveDraft: () async {},
              enabled: true,
            ),
          ],
        ),
      ),
    ),
  ),
);
