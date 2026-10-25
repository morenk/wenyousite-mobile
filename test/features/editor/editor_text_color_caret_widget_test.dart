import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_heading_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/text_color_assertions.dart';

const _red = '#D14343';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final apply in [false, true]) {
    testWidgets('真实RGB数字焦点与临时选区变化后${apply ? '应用' : '取消'}恢复原光标及输入色', (
      tester,
    ) async {
      final session = _session('甲乙');
      final store = _Colors();
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 2),
        ChangeSource.local,
      );
      await _pump(tester, session, store);
      await _openHeading(tester);
      await tester.tap(find.byKey(const Key('editor-text-color-#D14343')));
      await tester.pumpAndSettle();
      final before = session.controller.document.toDelta();
      expect(session.controller.document.history.stack.undo, isEmpty);
      await _openHeading(tester);
      await tester.tap(find.byKey(const Key('editor-color-custom')));
      await tester.pumpAndSettle();
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      for (final field in {'r': '17', 'g': '34', 'b': '51'}.entries) {
        await tester.enterText(
          find.byKey(Key('editor-color-${field.key}')),
          field.value,
        );
      }
      await tester.tap(
        apply
            ? find.byKey(const Key('editor-color-apply'))
            : find.text(WenyouEditorTextColorContract.cancelLabel),
      );
      await tester.pumpAndSettle();
      expect(session.focusNode.hasFocus, isTrue);
      expect(
        session.controller.selection,
        const TextSelection.collapsed(offset: 2),
      );
      expect(session.controller.document.toDelta(), before);
      expect(session.controller.document.history.stack.undo, isEmpty);
      expect(
        EditorTextColorPolicy.selection(session.controller).color,
        apply ? '#112233' : _red,
      );
      expect(store.colors, apply ? ['#112233'] : isEmpty);
      for (final value in ['n', 'ni', '你']) {
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: '甲乙$value\n',
            selection: TextSelection.collapsed(offset: 2 + value.length),
            composing: TextRange(start: 2, end: 2 + value.length),
          ),
        );
        await tester.pump();
      }
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '甲乙你\n',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      await tester.pump();
      expect(
        colorDeltaUnits(session.controller.document.toDelta()),
        colorExpectedUnits([
          ('甲乙', {}),
          ('你', {'color': apply ? '#112233' : _red}),
        ]),
      );
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('空正文先加粗选色，再点默认T，保留待输入粗体而不修改正文', (tester) async {
    final session = _session('');
    await _pump(tester, session, _Colors());
    session.controller.formatSelection(Attribute.bold);
    await _openHeading(tester);
    await tester.tap(find.byKey(const Key('editor-text-color-#D14343')));
    await tester.pumpAndSettle();
    await _openHeading(tester);
    await tester.tap(find.byKey(const Key('editor-color-default')));
    await tester.pumpAndSettle();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '粗体\n',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.pump();
    expect(
      colorDeltaUnits(session.controller.document.toDelta()),
      colorExpectedUnits([
        ('粗体', {'bold': true}),
      ]),
    );
    expect(await session.flush(), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  for (final width in [320, 360]) {
    for (final dark in [false, true]) {
      testWidgets('$width ${dark ? 'dark' : 'light'} 空正文光标选色键盘态', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), 640);
        tester.view.viewInsets = const FakeViewPadding(bottom: 220);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewInsets);
        final session = _session('');
        await _pump(
          tester,
          session,
          _Colors()..colors = ['#112233', '#445566', '#778899', '#AABBCC'],
          dark: dark,
          scale: width == 320 ? 1.5 : 1,
        );
        await _openHeading(tester);
        await tester.tap(find.byKey(const Key('editor-text-color-#D14343')));
        await tester.pumpAndSettle();
        await _openHeading(tester);
        expect(EditorTextColorPolicy.selection(session.controller).color, _red);
        expect(session.controller.document.toPlainText(), '\n');
        expect(
          tester.getSize(find.byKey(const Key('editor-color-default'))),
          const Size(48, 48),
        );
        expect(find.text('默认'), findsNothing);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const Key('caret-color-preview')),
          matchesGoldenFile(
            'goldens/editor_caret_color_${width}_${dark ? 'dark' : 'light'}.png',
          ),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
}

RichEditorSession _session(String source) {
  final session = RichEditorSession(
    initialMarkdown: source,
    onMarkdownChanged: (_) {},
  );
  addTearDown(session.dispose);
  return session;
}

Future<void> _openHeading(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('editor-heading')));
  await tester.pumpAndSettle();
}

Future<void> _pump(
  WidgetTester tester,
  RichEditorSession session,
  _Colors store, {
  bool dark = false,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(
          key: const Key('caret-color-preview'),
          child: child!,
        ),
      ),
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: QuillEditor.basic(
                controller: session.controller,
                focusNode: session.focusNode,
              ),
            ),
            WenyouEditorToolbar(
              controller: session.controller,
              editorFocusNode: session.focusNode,
              onInsertImage: () async {},
              onSaveDraft: () async {},
              enabled: true,
              textColor: EditorTextColorConfiguration(
                presets: [
                  for (final id in WenyouEditorTextColorContract.presetOrder)
                    (
                      label: WenyouEditorTextColorContract.presetLabels[id]!,
                      rgb: WenyouEditorTextColorContract.presets[id]!,
                    ),
                ],
                maximumRecentColors:
                    WenyouEditorTextColorContract.maximumRecentColors,
                accountId: 'account',
                store: store,
                writeEnabled: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  session.focusNode.requestFocus();
  await tester.pumpAndSettle();
}

class _Colors implements EditorTextColorPreferenceStore {
  List<String> colors = [];
  @override
  Future<List<String>> read(String accountId) async => colors;
  @override
  Future<void> write(String accountId, List<String> values) async =>
      colors = values;
}
