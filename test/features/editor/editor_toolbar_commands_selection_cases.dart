import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dice_input_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';

void registerEditorToolbarCommandsSelectionCases() {
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

  test('骰子三字段在边界值外分别给出错误', () {
    expect(
      validateEditorDiceInputs(quantity: '0', sides: '1', modifier: '-10001'),
      (quantity: '需为 1～100', sides: '需为 2～1000', modifier: '需为 -10000～10000'),
    );
    expect(
      validateEditorDiceInputs(
        quantity: '100',
        sides: '1000',
        modifier: '+10000',
      ),
      noEditorDiceInputErrors,
    );
    expect(
      validateEditorDiceInputs(quantity: '', sides: 'abc', modifier: '+'),
      (quantity: '需为 1～100', sides: '需为 2～1000', modifier: '需为 -10000～10000'),
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
                onInsertSticker: (_) async {},
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
        _ => const ['editor-content-drafts', 'editor-quote', 'editor-sticker'],
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
      expect(find.byKey(const Key('editor-horizontal-rule')), findsNothing);
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
      expect(find.byKey(const Key('editor-horizontal-rule')), findsOneWidget);
      final moreTray = find.byKey(const Key('editor-more-tray'));
      expect(
        find.descendant(of: moreTray, matching: find.byTooltip('表情包')),
        promotedKeys.contains('editor-sticker') ? findsNothing : findsOneWidget,
      );
      for (final key in promotedKeys) {
        final label = switch (key) {
          'editor-content-drafts' => '正文草稿',
          'editor-quote' => '引用',
          'editor-sticker' => '表情包',
          'editor-horizontal-rule' => '分隔线',
          _ => throw StateError('未知提升命令 $key'),
        };
        expect(find.byTooltip(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('异步表情选择器收到打开前选区并在取消后恢复该选区', (tester) async {
    tester.view.physicalSize = const Size(600, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = QuillController(
      document: Document()..insert(0, '前文后文'),
      selection: const TextSelection.collapsed(offset: 2),
    );
    final focusNode = FocusNode();
    final pickerClosed = Completer<void>();
    TextSelection? receivedSelection;
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
              onInsertSticker: (selection) async {
                receivedSelection = selection;
                await pickerClosed.future;
              },
              onSaveDraft: () async {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('editor-sticker')));
    await tester.pump();
    expect(receivedSelection, const TextSelection.collapsed(offset: 2));
    controller.updateSelection(
      const TextSelection.collapsed(offset: 4),
      ChangeSource.local,
    );

    pickerClosed.complete();
    await tester.pumpAndSettle();
    expect(controller.selection, const TextSelection.collapsed(offset: 2));
  });

  testWidgets('无提交按钮时分隔线仍固定放在更多面板', (tester) async {
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
    expect(find.byKey(const Key('editor-horizontal-rule')), findsNothing);

    await tester.tap(find.byKey(const Key('editor-quote')));
    await tester.pump();
    expect(
      controller.getSelectionStyle().attributes[Attribute.blockQuote.key],
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('正文草稿'), findsOneWidget);
    expect(find.byTooltip('引用'), findsOneWidget);
    expect(find.byTooltip('分隔线'), findsOneWidget);
    expect(find.byTooltip('无序列表'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editor-horizontal-rule')));
    await tester.pump();
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      contains('---'),
    );
  });

  testWidgets('工具栏真实点击可创建、切换并取消全部正文格式', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = QuillController(
      document: Document()..insert(0, '正文'),
      selection: const TextSelection(baseOffset: 0, extentOffset: 2),
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

    Map<String, dynamic> inlineAttributes() =>
        controller.document.toDelta().operations.first.attributes ?? const {};
    Map<String, dynamic> blockAttributes() =>
        controller.document.toDelta().operations.last.attributes ?? const {};
    Future<void> tapMore(String tooltip) async {
      if (find.byKey(const Key('editor-more-tray')).evaluate().isEmpty) {
        await tester.tap(find.byKey(const Key('editor-more')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
    }

    Future<void> tapQuote() async {
      final promoted = find.byKey(const Key('editor-quote'));
      if (promoted.evaluate().isNotEmpty) {
        await tester.tap(promoted);
        await tester.pump();
      } else {
        await tapMore('引用');
      }
    }

    await tester.tap(find.byKey(const Key('editor-bold')));
    await tester.pump();
    expect(inlineAttributes()['bold'], true);
    final tokens = AppTheme.light.extension<WenyouThemeTokens>()!;
    final boldButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('editor-bold')),
        matching: find.byType(IconButton),
      ),
    );
    expect(
      boldButton.style!.backgroundColor!.resolve({WidgetState.selected}),
      Colors.transparent,
    );
    expect((boldButton.selectedIcon! as WenyouIcon).color, tokens.like);
    await tester.tap(find.byKey(const Key('editor-bold')));
    await tester.pump();
    expect(inlineAttributes(), isNot(contains('bold')));

    await tester.tap(find.byKey(const Key('editor-italic')));
    await tester.pump();
    expect(inlineAttributes()['italic'], true);
    await tester.tap(find.byKey(const Key('editor-italic')));
    await tester.pump();
    expect(inlineAttributes(), isNot(contains('italic')));

    await tester.tap(find.byKey(const Key('editor-heading')));
    await tester.pump();
    await tester.tap(find.text('H2'));
    await tester.pumpAndSettle();
    expect(blockAttributes()['header'], 2);
    await tester.tap(find.byKey(const Key('editor-heading')));
    await tester.pump();
    await tester.tap(find.text('H3'));
    await tester.pumpAndSettle();
    expect(blockAttributes()['header'], 3);
    await tester.tap(find.byKey(const Key('editor-heading')));
    await tester.pump();
    await tester.tap(find.text('正文'));
    await tester.pumpAndSettle();
    expect(blockAttributes(), isNot(contains('header')));

    await tapQuote();
    expect(blockAttributes()['blockquote'], true);
    await tapQuote();
    expect(blockAttributes(), isNot(contains('blockquote')));

    await tapMore('无序列表');
    expect(blockAttributes()['list'], 'bullet');
    await tapMore('有序列表');
    expect(blockAttributes()['list'], 'ordered');
    await tapMore('有序列表');
    expect(blockAttributes(), isNot(contains('list')));

    await tapMore('行内代码');
    expect(inlineAttributes()['code'], true);
    final inlineCodeButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('行内代码'),
        matching: find.byType(IconButton),
      ),
    );
    expect(
      inlineCodeButton.style!.backgroundColor!.resolve({WidgetState.selected}),
      Colors.transparent,
    );
    expect((inlineCodeButton.selectedIcon! as WenyouIcon).color, tokens.like);
    await tester.tap(find.byKey(const Key('editor-bold')));
    await tester.pump();
    expect(inlineAttributes(), isNot(contains('code')));
    expect(inlineAttributes()['bold'], true);
    await tester.tap(find.byKey(const Key('editor-bold')));
    await tester.pump();

    await tapMore('删除线');
    expect(inlineAttributes()['strike'], true);
    await tapMore('删除线');
    expect(inlineAttributes(), isNot(contains('strike')));

    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), '正文');
    expect(tester.takeException(), isNull);
  });
}
