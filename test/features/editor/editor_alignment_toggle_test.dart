import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final markdown in [
    '正文',
    '## 二级标题',
    '### 三级标题',
    '![图片](https://cdn.example.com/image.webp)',
  ]) {
    for (final direction in ['center', 'right']) {
      testWidgets('$markdown 的 $direction 按钮反选清除标记且保留选区', (tester) async {
        final controller = _controller(markdown);
        addTearDown(controller.dispose);
        final selection = controller.selection;
        await _pumpToolbar(tester, controller);

        expect(find.byKey(const Key('editor-align-left')), findsNothing);
        _expectSelection(tester);
        await _tapAlignment(tester, direction);
        _expectSelection(tester, direction);
        expect(
          _markdown(controller),
          '[wenyousite-align-v1-$direction]: #\n$markdown',
        );
        expect(controller.selection, selection);

        await _tapAlignment(tester, direction);
        _expectSelection(tester);
        expect(_markdown(controller), markdown);
        expect(controller.selection, selection);
        final reopened = _controller(_markdown(controller));
        addTearDown(reopened.dispose);
        await _pumpToolbar(tester, reopened);
        _expectSelection(tester);
      });
    }
  }

  for (final reverse in [false, true]) {
    testWidgets('混合多段选区统一、切换及反选保持${reverse ? '反向' : '正向'}选区', (tester) async {
      final controller = _controller(
        '[wenyousite-align-v1-center]: #\n第一段\n\n'
        '[wenyousite-align-v1-right]: #\n第二段',
      );
      addTearDown(controller.dispose);
      final end = controller.document.length - 1;
      final selection = TextSelection(
        baseOffset: reverse ? end : 0,
        extentOffset: reverse ? 0 : end,
      );
      controller.updateSelection(selection, ChangeSource.local);
      await _pumpToolbar(tester, controller);
      _expectSelection(tester);

      for (final direction in ['center', 'right', 'center']) {
        await _tapAlignment(tester, direction);
        _expectSelection(tester, direction);
        expect(
          _markdown(controller),
          '[wenyousite-align-v1-$direction]: #\n第一段\n\n'
          '[wenyousite-align-v1-$direction]: #\n第二段',
        );
        expect(controller.selection, selection);
      }
      await _tapAlignment(tester, 'center');
      _expectSelection(tester);
      expect(_markdown(controller), '第一段\n\n第二段');
      expect(controller.selection, selection);
    });
  }

  for (final direction in ['center', 'right']) {
    testWidgets('$direction 反选可单步撤销重做并更新按钮状态', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '[wenyousite-align-v1-$direction]: #\n正文',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      const selection = TextSelection(baseOffset: 0, extentOffset: 2);
      controller.updateSelection(selection, ChangeSource.local);
      await _pumpToolbar(tester, controller);
      _expectSelection(tester, direction);

      await _tapAlignment(tester, direction);
      expect(_markdown(controller), '正文');
      _expectSelection(tester);
      controller.undo();
      await tester.pumpAndSettle();
      expect(_markdown(controller), '[wenyousite-align-v1-$direction]: #\n正文');
      _expectSelection(tester, direction);
      expect(controller.selection, selection);
      controller.redo();
      await tester.pumpAndSettle();
      expect(_markdown(controller), '正文');
      _expectSelection(tester);
      expect(controller.selection, selection);
      await tester.pumpWidget(const SizedBox.shrink());
      await session.flush();
    });
  }

  for (final markdown in [
    '- 列表项',
    '> 引用',
    '---',
    '![图片](https://cdn.example.com/image.webp)',
  ]) {
    testWidgets('v4 不可对齐块保留禁用状态：$markdown', (tester) async {
      final controller = _controller(markdown);
      addTearDown(controller.dispose);
      final original = controller.document.toDelta().toJson();
      await _pumpToolbar(
        tester,
        controller,
        capabilities: WenyouEditorCapabilities.richMarkdownWithAlignment,
      );
      for (final direction in ['center', 'right']) {
        expect(_button(tester, direction).onPressed, isNull);
        await _tapAlignment(tester, direction);
      }
      expect(controller.document.toDelta().toJson(), original);
    });
  }

  testWidgets('编辑器整体禁用时不可反选已有对齐', (tester) async {
    final controller = _controller('[wenyousite-align-v1-center]: #\n正文');
    addTearDown(controller.dispose);
    final enabled = ValueNotifier(true);
    addTearDown(enabled.dispose);
    await _pumpToolbar(tester, controller, enabled: enabled);
    enabled.value = false;
    await tester.pumpAndSettle();
    expect(_button(tester, 'center').onPressed, isNull);
    expect(_button(tester, 'right').onPressed, isNull);
    await _tapAlignment(tester, 'center');
    expect(_markdown(controller), '[wenyousite-align-v1-center]: #\n正文');
  });
}

QuillController _controller(String markdown) => QuillController(
  document: Document.fromDelta(
    MarkdownDeltaCodec.decode(markdown, imageAlignment: true).delta,
  ),
  selection: const TextSelection.collapsed(offset: 0),
);

String _markdown(QuillController controller) => MarkdownDeltaCodec.encode(
  controller.document.toDelta(),
  imageAlignment: true,
);

Future<void> _pumpToolbar(
  WidgetTester tester,
  QuillController controller, {
  WenyouEditorCapabilities capabilities =
      WenyouEditorCapabilities.richMarkdownWithImageAlignment,
  ValueNotifier<bool>? enabled,
}) async {
  Widget toolbar(bool isEnabled) => WenyouEditorToolbar(
    key: ObjectKey(controller),
    controller: controller,
    enabled: isEnabled,
    capabilities: capabilities,
    onInsertImage: () async {},
    onSaveDraft: () async {},
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: enabled == null
            ? toolbar(true)
            : ValueListenableBuilder<bool>(
                valueListenable: enabled,
                builder: (_, value, _) => toolbar(value),
              ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('editor-more')));
  await tester.pumpAndSettle();
}

IconButton _button(WidgetTester tester, String direction) =>
    tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(Key('editor-align-$direction')),
        matching: find.byType(IconButton),
      ),
    );

void _expectSelection(WidgetTester tester, [String? selected]) {
  for (final direction in ['center', 'right']) {
    expect(_button(tester, direction).isSelected, direction == selected);
  }
}

Future<void> _tapAlignment(WidgetTester tester, String direction) async {
  await tester.tap(find.byKey(Key('editor-align-$direction')));
  await tester.pumpAndSettle();
}
