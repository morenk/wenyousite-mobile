import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_picker.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/editor/presentation/text_font_quill_editor.dart';

class _Fonts extends TextFontService {
  _Fonts(this.runtime) : super(WenyouApi());
  final TextFontRuntime runtime;
  @override
  Future<TextFontRuntime> load() async => runtime;
}

class _FontsRuntime extends TextFontRuntime {
  _FontsRuntime()
    : super(
        cache: TextFontCache(Directory.systemTemp),
        download: (_) async => throw StateError('不得请求资产'),
      );
  final requested = <String>{};
  @override
  Future<void> ensure(String id, String text) async => requested.add(id);
}

void main() {
  testWidgets('未知分类显示未分类且不可选，中文名称不决定分组', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final runtime = _FontsRuntime()
      ..assetsAvailable = true
      ..manifest = TextFontManifest(
        File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
      );
    runtime.manifest!.fonts
      ..clear()
      ..['source-han-sans'] = TextFontFamily({
        'id': 'source-han-sans',
        'name': '中文名称',
        'designLanguage': 'future',
        'deliveryMode': 'subset',
        'availability': 'ready',
      });
    final controller = QuillController(
      document: Document()..insert(0, '文字'),
      selection: const TextSelection(baseOffset: 0, extentOffset: 2),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              textFontSupported: true,
              textFontWriteEnabled: true,
            ),
          ),
          sessionScopeProvider.overrideWithValue(
            const SessionScope(accountId: 'account', generation: 0),
          ),
          textFontServiceProvider.overrideWithValue(_Fonts(runtime)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EditorTextFontPicker(controller: controller, enabled: true),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-font-picker')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-font-group-other')), findsOneWidget);
    expect(find.byKey(const Key('editor-font-group-zh')), findsNothing);
    final tile = tester.widget<ListTile>(
      find.byKey(const Key('editor-font-source-han-sans')),
    );
    expect(tile.enabled, isFalse);
    expect(find.text('暂不可用'), findsOneWidget);
    await tester.tap(find.byKey(const Key('editor-font-default')));
    await tester.pumpAndSettle();
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 2),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final writeEnabled in [true, false]) {
    testWidgets('真实选区打开字体工具、更换/恢复默认并返回编辑，写入 $writeEnabled', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final runtime = _FontsRuntime()
        ..assetsAvailable = true
        ..manifest = TextFontManifest(
          File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
        );
      final session = RichEditorSession(
        initialMarkdown:
            '<span data-wenyou-font-v1="zhuque">**word**</span> more',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCapabilitiesProvider.overrideWithValue(
              AppCapabilities(
                textFontSupported: true,
                textFontWriteEnabled: writeEnabled,
              ),
            ),
            sessionScopeProvider.overrideWithValue(
              const SessionScope(accountId: 'account', generation: 0),
            ),
            textFontServiceProvider.overrideWithValue(_Fonts(runtime)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: TextFontQuillEditor(
                      controller: session.controller,
                      focusNode: session.focusNode,
                      scrollController: session.scrollController,
                      config: const QuillEditorConfig(),
                    ),
                  ),
                  WenyouEditorToolbar(
                    controller: session.controller,
                    enabled: true,
                    textFont: true,
                    editorFocusNode: session.focusNode,
                    onInsertImage: () async {},
                    onSaveDraft: () async {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final raw = tester.state<QuillRawEditorState>(
        find.byType(QuillRawEditor),
      );
      await tester.longPressAt(
        raw.renderEditor.localToGlobal(
          raw.renderEditor
              .getLocalRectForCaret(const TextPosition(offset: 2))
              .center,
        ),
      );
      await tester.pumpAndSettle();
      final selection = session.controller.selection;
      expect(selection, const TextSelection(baseOffset: 0, extentOffset: 4));
      await tester.tap(find.byKey(const Key('editor-heading')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('editor-font-picker')));
      await tester.pumpAndSettle();
      if (writeEnabled) {
        final list = find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .last;
        for (final (code, label) in [
          ('zh', '中文'),
          ('ja', '日文'),
          ('en', '英文'),
        ]) {
          final group = find.byKey(Key('editor-font-group-$code'));
          await tester.scrollUntilVisible(group, 200, scrollable: list);
          expect(
            find.descendant(of: group, matching: find.text(label)),
            findsOneWidget,
          );
        }
        // 分类后仍能回到中文选项，不丢失打开工具前的真实选区。
        await tester.scrollUntilVisible(
          find.text('文楷'),
          -200,
          scrollable: list,
        );
        await tester.tap(find.text('文楷'));
      } else {
        expect(find.text('暂时无法更换字体，可恢复默认字体'), findsOneWidget);
        await tester.tap(find.byKey(const Key('editor-font-default')));
      }
      await tester.pumpAndSettle();
      expect(session.controller.selection, selection);
      expect(session.focusNode.hasFocus, isTrue);
      expect(
        session.controller.document
            .collectStyle(0, 4)
            .attributes['font']
            ?.value,
        writeEnabled ? 'wenkai' : null,
      );
      expect(
        session.controller.document
            .collectStyle(0, 4)
            .attributes['bold']
            ?.value,
        true,
      );
      expect(await session.flush(), isTrue);
      expect(runtime.requested, contains(writeEnabled ? 'wenkai' : 'zhuque'));
      if (writeEnabled) {
        expect(
          (await SharedPreferences.getInstance()).getStringList(
            'editor.textFont.v1.account',
          ),
          ['wenkai'],
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
