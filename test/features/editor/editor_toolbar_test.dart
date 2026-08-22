import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dice_input_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';

void main() {
  test('骰子三字段生成 canonical 表达式并省略零修正', () {
    expect(
      canonicalDiceNotation(quantity: '02', sides: '006', modifier: '+03'),
      '2d6+3',
    );
    expect(
      canonicalDiceNotation(quantity: '1', sides: '20', modifier: ''),
      '1d20',
    );
    expect(
      canonicalDiceNotation(quantity: '2', sides: '10', modifier: '-4'),
      '2d10-4',
    );
    expect(
      canonicalDiceNotation(quantity: '101', sides: '6', modifier: '0'),
      isNull,
    );
  });

  for (final width in const [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 工具栏按可用宽度提升常用命令', (tester) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final document = Document()..insert(0, '第一段正文');
      final controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 2),
      );
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: WenyouEditorToolbar(
                controller: controller,
                editorFocusNode: focusNode,
                enabled: true,
                onInsertImage: () async {},
                onSaveDraft: () async {},
                onSubmit: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('editor-toolbar-dock'))).width,
        width,
      );
      expect(find.byKey(const Key('editor-heading')), findsOneWidget);
      expect(find.byKey(const Key('editor-submit')), findsOneWidget);
      final promotedKeys = switch (width) {
        320 => const <String>[],
        360 => const ['editor-content-drafts'],
        400 => const ['editor-content-drafts', 'editor-quote'],
        _ => const [
          'editor-content-drafts',
          'editor-quote',
          'editor-horizontal-rule',
        ],
      };
      final controlKeys = <String>[
        'editor-heading',
        'editor-bold',
        'editor-italic',
        'editor-image',
        ...promotedKeys.where((key) => key != 'editor-content-drafts'),
        if (promotedKeys.contains('editor-content-drafts'))
          'editor-content-drafts',
        'editor-more',
        'editor-submit',
      ];
      for (final key in promotedKeys) {
        expect(find.byKey(Key(key)), findsOneWidget);
      }
      final centers = controlKeys
          .map((key) => tester.getCenter(find.byKey(Key(key))).dx)
          .toList();
      final gaps = <double>[
        for (var index = 1; index < centers.length; index++)
          centers[index] - centers[index - 1],
      ];
      expect(gaps.every((gap) => gap >= 48), isTrue);
      final widestGap = gaps.reduce((a, b) => a > b ? a : b);
      final narrowestGap = gaps.reduce((a, b) => a < b ? a : b);
      expect(widestGap - narrowestGap, lessThan(0.1));

      await tester.tap(find.byKey(const Key('editor-heading')));
      await tester.pump();
      expect(find.byKey(const Key('editor-heading-tray')), findsOneWidget);
      expect(find.byType(AnimatedSize), findsNothing);
      await tester.tap(find.text('H2'));
      await tester.pumpAndSettle();
      expect(controller.getSelectionStyle().attributes['header']?.value, 2);
      expect(find.byKey(const Key('editor-heading-tray')), findsNothing);

      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
      for (final key in promotedKeys) {
        final label = switch (key) {
          'editor-content-drafts' => '正文草稿',
          'editor-quote' => '引用',
          'editor-horizontal-rule' => '分隔线',
          _ => throw StateError('未知提升命令 $key'),
        };
        expect(find.byTooltip(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('无提交按钮时 400dp 提升草稿、引用和分隔线并从更多去重', (tester) async {
    tester.view.physicalSize = const Size(400, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = QuillController.basic();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              editorFocusNode: focusNode,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('editor-content-drafts')), findsOneWidget);
    expect(find.byKey(const Key('editor-quote')), findsOneWidget);
    expect(find.byKey(const Key('editor-horizontal-rule')), findsOneWidget);

    await tester.tap(find.byKey(const Key('editor-quote')));
    await tester.pump();
    expect(
      controller.getSelectionStyle().attributes[Attribute.blockQuote.key],
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('editor-horizontal-rule')));
    await tester.pump();
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      contains('---'),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('正文草稿'), findsOneWidget);
    expect(find.byTooltip('引用'), findsOneWidget);
    expect(find.byTooltip('分隔线'), findsOneWidget);
    expect(find.byTooltip('无序列表'), findsOneWidget);
  });

  testWidgets('链接和骰子在编辑器内部输入并保持 Markdown 往返', (tester) async {
    final document = Document()..insert(0, '查看资料');
    final controller = QuillController(
      document: document,
      selection: const TextSelection(baseOffset: 0, extentOffset: 4),
    );
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              editorFocusNode: focusNode,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('链接'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-link-tray')), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('editor-link-tray')),
        matching: find.widgetWithText(TextField, '显示文字'),
      ),
      '查看资料',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '链接地址'),
      'https://wenyou.site/help',
    );
    expect(find.byKey(const Key('editor-submit')), findsNothing);
    await tester.tap(find.byKey(const Key('editor-link-insert')));
    await tester.pumpAndSettle();
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      contains('[查看资料](https://wenyou.site/help)'),
    );

    controller.updateSelection(
      TextSelection.collapsed(offset: controller.document.length - 1),
      ChangeSource.local,
    );
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-dice-tray')), findsOneWidget);
    expect(find.text('预览：1d20 = ?'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('editor-dice-quantity')),
        matching: find.byType(TextField),
      ),
      '2',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('editor-dice-modifier')),
        matching: find.byType(TextField),
      ),
      '3',
    );
    await tester.tap(find.byKey(const Key('editor-dice-quick-d6')));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('editor-dice-quantity')),
              matching: find.byType(TextField),
            ),
          )
          .controller
          ?.text,
      '2',
    );
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('editor-dice-modifier')),
              matching: find.byType(TextField),
            ),
          )
          .controller
          ?.text,
      '3',
    );
    expect(find.text('预览：2d6+3 = ?'), findsOneWidget);
    expect(find.byKey(const Key('editor-submit')), findsNothing);
    await tester.tap(find.byKey(const Key('editor-dice-insert')));
    await tester.pumpAndSettle();
    final markdown = MarkdownDeltaCodec.encode(controller.document.toDelta());
    final insertedDice = RegExp(
      r'\[\[dice:v1:([0-9a-f-]{36}):2d6\+3\]\]',
    ).firstMatch(markdown);
    expect(insertedDice, isNotNull);
    expect(insertedDice!.group(1), isNotEmpty);
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(markdown).delta),
      markdown,
    );
  });

  testWidgets('骰子字段无效时保留插入器并给出任务内错误', (tester) async {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('editor-dice-quantity')),
        matching: find.byType(TextField),
      ),
      '101',
    );
    await tester.pump();
    expect(find.text('预览：—'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editor-dice-insert')));
    await tester.pump();
    expect(find.byKey(const Key('editor-dice-tray')), findsOneWidget);
    expect(find.text('需为 1～100'), findsOneWidget);
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      isNot(contains('[[dice:')),
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('editor-dice-quantity')),
        matching: find.byType(TextField),
      ),
      '1',
    );
    await tester.pump();
    expect(find.text('需为 1～100'), findsNothing);
    expect(find.text('预览：1d20 = ?'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('editor-dice-modifier')),
        matching: find.byType(TextField),
      ),
      '10001',
    );
    await tester.tap(find.byKey(const Key('editor-dice-insert')));
    await tester.pump();
    expect(find.byKey(const Key('editor-dice-tray')), findsOneWidget);
    expect(find.text('需为 -10000～10000'), findsOneWidget);
  });

  testWidgets('骰子任务只保留深品牌色插入操作，并按当前正文限制 20 个', (tester) async {
    final decoded = MarkdownDeltaCodec.decode(_diceMarkdown(20));
    final controller = QuillController(
      document: Document.fromDelta(decoded.delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pump();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pump();

    expect(find.byKey(const Key('editor-submit')), findsNothing);
    expect(find.text('当前正文 20/20'), findsOneWidget);
    expect(find.byKey(const Key('editor-dice-limit')), findsOneWidget);
    var insert = tester.widget<FilledButton>(
      find.byKey(const Key('editor-dice-insert')),
    );
    expect(insert.onPressed, isNull);

    controller.replaceText(0, 1, '', const TextSelection.collapsed(offset: 0));
    await tester.pump();

    expect(find.text('当前正文 19/20'), findsOneWidget);
    insert = tester.widget<FilledButton>(
      find.byKey(const Key('editor-dice-insert')),
    );
    expect(insert.onPressed, isNotNull);
    expect(
      insert.style?.backgroundColor?.resolve(<WidgetState>{}),
      AppTheme.light.colorScheme.primary,
    );
    expect(
      insert.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppTheme.light.colorScheme.onPrimary,
    );
  });

  testWidgets('320dp 与两倍字体下骰子字段改为纵向并保持任务可滚动', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pump();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pump();

    expect(find.byKey(const Key('editor-task-tray-scroll')), findsOneWidget);
    expect(find.byKey(const Key('editor-dice-insert')), findsOneWidget);
    expect(find.byKey(const Key('editor-submit')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('可扩展面板在键盘收起时为系统导航区保留空间', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              surface: WenyouComposerSurface.expandableSheet,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );

    final dock = find.byKey(const Key('editor-toolbar-dock'));
    expect(tester.getSize(dock).height, 80);
    expect(
      tester.getBottomRight(find.byKey(const Key('editor-submit'))).dy,
      lessThanOrEqualTo(616),
    );

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(tester.getSize(dock).height, 56);
  });

  testWidgets('工具栏按能力集合隐藏业务上下文不支持的命令', (tester) async {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouEditorToolbar(
            controller: controller,
            enabled: true,
            capabilities: const WenyouEditorCapabilities(
              headings: false,
              inlineStyles: false,
              images: false,
              links: false,
              blockStyles: false,
              dice: false,
              stickers: false,
              drafts: false,
            ),
            onInsertImage: () async {},
            onSaveDraft: () async {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('editor-heading')), findsNothing);
    expect(find.byKey(const Key('editor-image')), findsNothing);
    expect(find.byKey(const Key('editor-more')), findsNothing);
    expect(find.byKey(const Key('editor-submit')), findsOneWidget);
  });
}

String _diceMarkdown(int count) => List.generate(count, (index) {
  final suffix = index.toString().padLeft(12, '0');
  return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
}).join(' ');
