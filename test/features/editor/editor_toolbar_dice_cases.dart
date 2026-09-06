import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'editor_toolbar_test_support.dart';

void registerEditorToolbarDiceCases() {
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
    final decoded = MarkdownDeltaCodec.decode(
      editorToolbarTestDiceMarkdown(20),
    );
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
}
