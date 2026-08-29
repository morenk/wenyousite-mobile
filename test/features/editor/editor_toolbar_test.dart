import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dice_input_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

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
    expect(find.text('1d20 = ? · 0/20'), findsOneWidget);
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
    for (final sides in const [4, 6, 8, 10, 12, 20, 100]) {
      expect(find.byKey(Key('editor-dice-quick-d$sides')), findsOneWidget);
    }
    expect(find.byType(PopupMenuButton<int>), findsNothing);
    await tester.tap(find.byKey(const Key('editor-dice-quick-d6')));
    await tester.pumpAndSettle();
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
    expect(find.text('2d6+3 = ? · 0/20'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('editor-dice-sides')),
              matching: find.byType(TextField),
            ),
          )
          .focusNode
          ?.hasFocus,
      isTrue,
    );
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

  testWidgets('320dp 键盘态常用面数在托盘内横滑并保持输入焦点', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pump();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pumpAndSettle();

    final rail = find.byKey(const Key('editor-dice-quick-sides'));
    final horizontalScrollable = find.descendant(
      of: rail,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.right,
      ),
    );
    final d4 = find.byKey(const Key('editor-dice-quick-d4'));
    final d100 = find.byKey(const Key('editor-dice-quick-d100'));
    expect(horizontalScrollable, findsOneWidget);
    expect(find.byType(PopupMenuButton<int>), findsNothing);
    expect(tester.getSize(d4).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(d4).height, greaterThanOrEqualTo(48));
    expect(tester.getBottomRight(rail).dy, lessThanOrEqualTo(500));
    final position = tester
        .state<ScrollableState>(horizontalScrollable)
        .position;
    expect(position.maxScrollExtent, greaterThan(0));

    await tester.drag(rail, const Offset(-240, 0));
    await tester.pump();
    await tester.drag(rail, const Offset(-240, 0));
    await tester.pump();

    expect(position.pixels, greaterThan(0));
    expect(d100.hitTestable(), findsOneWidget);
    await tester.tap(d100);
    await tester.pumpAndSettle();

    final sidesField = find.descendant(
      of: find.byKey(const Key('editor-dice-sides')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(sidesField).controller?.text, '100');
    expect(tester.widget<TextField>(sidesField).focusNode?.hasFocus, isTrue);
    expect(tester.widget<ChoiceChip>(d100).selected, isTrue);
    expect(find.text('1d100 = ? · 0/20'), findsOneWidget);
    expect(tester.getBottomRight(rail).dy, lessThanOrEqualTo(500));
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
    expect(find.text('表达式未完成 · 0/20'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editor-dice-insert')));
    await tester.pump();
    expect(find.byKey(const Key('editor-dice-tray')), findsOneWidget);
    expect(find.text('骰子数需为 1～100'), findsOneWidget);
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
    expect(find.text('骰子数需为 1～100'), findsNothing);
    expect(find.text('1d20 = ? · 0/20'), findsOneWidget);

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
    expect(find.text('修正需为 -10000～10000'), findsOneWidget);
  });

  testWidgets('骰子在当前编辑器会话复用上次成功值且忽略取消输入', (tester) async {
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

    Finder diceField(String key) => find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(TextField),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pump();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(diceField('editor-dice-quantity'))
          .controller
          ?.selection,
      const TextSelection(baseOffset: 0, extentOffset: 1),
    );

    await tester.enterText(diceField('editor-dice-quantity'), '02');
    await tester.enterText(diceField('editor-dice-sides'), '006');
    await tester.enterText(diceField('editor-dice-modifier'), '+03');
    await tester.tap(find.byKey(const Key('editor-dice-insert')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pump();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(diceField('editor-dice-quantity'))
          .controller
          ?.text,
      '2',
    );
    expect(
      tester.widget<TextField>(diceField('editor-dice-sides')).controller?.text,
      '6',
    );
    expect(
      tester
          .widget<TextField>(diceField('editor-dice-modifier'))
          .controller
          ?.text,
      '3',
    );
    expect(find.text('2d6+3 = ? · 1/20'), findsOneWidget);

    await tester.enterText(diceField('editor-dice-quantity'), '101');
    await tester.tap(find.byTooltip('返回格式工具'));
    await tester.pump();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(diceField('editor-dice-quantity'))
          .controller
          ?.text,
      '2',
    );
    expect(find.text('2d6+3 = ? · 1/20'), findsOneWidget);
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
    expect(find.text('已达 20/20，请先删除一个骰子'), findsOneWidget);
    expect(find.byKey(const Key('editor-dice-limit')), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    var insert = tester.widget<FilledButton>(
      find.byKey(const Key('editor-dice-insert')),
    );
    expect(insert.onPressed, isNull);

    controller.replaceText(0, 1, '', const TextSelection.collapsed(offset: 0));
    await tester.pump();

    expect(find.text('1d20 = ? · 19/20'), findsOneWidget);
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

    await tester.tap(find.byKey(const Key('editor-dice-insert')));
    await tester.pumpAndSettle();
    expect(
      RegExp(
        r'\[\[dice:v1:',
      ).allMatches(MarkdownDeltaCodec.encode(controller.document.toDelta())),
      hasLength(20),
    );
  });

  for (final width in const [320.0, 360.0, 600.0]) {
    testWidgets('$width dp、两倍字体和键盘态下骰子任务可滚动且不溢出', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 440);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
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

      final trayScroll = find.byKey(const Key('editor-task-tray-scroll'));
      final scrollable = find.descendant(
        of: trayScroll,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      );
      expect(trayScroll, findsOneWidget);
      expect(scrollable, findsOneWidget);
      expect(find.byKey(const Key('editor-dice-insert')), findsOneWidget);
      expect(find.byKey(const Key('editor-submit')), findsNothing);
      final position = tester.state<ScrollableState>(scrollable).position;
      expect(position.maxScrollExtent, greaterThan(0));
      await tester.drag(trayScroll, const Offset(0, -120));
      await tester.pump();
      expect(position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    });
  }

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

  testWidgets('更多面板使用中性表面并直接设置左、居中和右对齐', (tester) async {
    final controller = QuillController(
      document: Document()..insert(0, '正文'),
      selection: const TextSelection.collapsed(offset: 1),
    );
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
              alignment: true,
              dice: false,
              stickers: false,
              drafts: false,
            ),
            onInsertImage: () async {},
            onSaveDraft: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byType(SegmentedButton<WenyouTextAlignment>), findsNothing);
    expect(find.byKey(const Key('editor-align-left')), findsOneWidget);
    expect(find.byKey(const Key('editor-align-center')), findsOneWidget);
    expect(find.byKey(const Key('editor-align-right')), findsOneWidget);
    final tray = tester.widget<Container>(
      find.byKey(const Key('editor-more-tray')),
    );
    final tokens = AppTheme.light.extension<WenyouThemeTokens>()!;
    expect((tray.decoration! as BoxDecoration).color, tokens.panel);

    await tester.tap(find.byTooltip('居中'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '[wenyousite-align-v1-center]: #\n正文',
    );
    var alignment = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('editor-align-center')),
        matching: find.byType(IconButton),
      ),
    );
    expect(alignment.isSelected, isTrue);
    expect(
      alignment.style!.backgroundColor!.resolve({WidgetState.selected}),
      Colors.transparent,
    );
    expect((alignment.selectedIcon! as WenyouIcon).color, tokens.like);

    await tester.tap(find.byTooltip('右对齐'));
    await tester.pumpAndSettle();
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '[wenyousite-align-v1-right]: #\n正文',
    );
    await tester.tap(find.byTooltip('左对齐'));
    await tester.pumpAndSettle();
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), '正文');
    alignment = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('editor-align-left')),
        matching: find.byType(IconButton),
      ),
    );
    expect(alignment.isSelected, isTrue);
  });

  for (final scenario in [
    (name: 'light', theme: AppTheme.light),
    (name: 'dark', theme: AppTheme.dark),
  ]) {
    testWidgets('360dp ${scenario.name} 更多纯图标托盘保持视觉基线', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 320);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final controller = QuillController(
        document: Document()..insert(0, '正文'),
        selection: const TextSelection.collapsed(offset: 1),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: scenario.theme,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: WenyouEditorToolbar(
                controller: controller,
                enabled: true,
                capabilities:
                    WenyouEditorCapabilities.richMarkdownWithAlignment,
                onInsertImage: () async {},
                onSaveDraft: () async {},
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pumpAndSettle();

      final firstRow = find.byKey(const Key('editor-more-row-0'));
      final secondRow = find.byKey(const Key('editor-more-row-1'));
      expect(firstRow, findsOneWidget);
      expect(secondRow, findsOneWidget);
      for (final key in const [
        Key('editor-align-left'),
        Key('editor-align-center'),
        Key('editor-align-right'),
      ]) {
        expect(
          find.descendant(of: firstRow, matching: find.byKey(key)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: firstRow, matching: find.byType(IconButton)),
        findsNWidgets(5),
      );
      expect(
        find.descendant(of: secondRow, matching: find.byType(IconButton)),
        findsNWidgets(5),
      );

      await expectLater(
        find.byKey(const Key('editor-more-tray')),
        matchesGoldenFile('goldens/editor_more_tray_360_${scenario.name}.png'),
      );
    });
  }
}

String _diceMarkdown(int count) => List.generate(count, (index) {
  final suffix = index.toString().padLeft(12, '0');
  return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
}).join(' ');
