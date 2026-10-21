import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/editor/presentation/text_font_quill_editor.dart';

import '../../core/text_fonts/dynamic_font_fixture.dart';

class _Fonts extends TextFontService {
  _Fonts(this.runtime) : super(WenyouApi(), observePlatform: false);
  final TextFontRuntime runtime;
  int specimens = 0, selections = 0;
  @override
  Future<TextFontRuntime> load() async => runtime;
  @override
  Future<void> checkPasteVersions(Set<String> ids) async {
    selections++;
  }

  @override
  Future<Uint8List?> specimen(
    FontCatalogEntryDto entry, {
    Object? owner,
    bool Function()? isActive,
  }) async {
    specimens++;
    return base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aT1sAAAAASUVORK5CYII=',
    );
  }
}

void main() {
  test('混合字体按实际文字识别，换行不造成假混合', () {
    final controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('甲', {'font': 'wenkai'})
          ..insert('\n\n')
          ..insert('乙', {'font': 'wenkai'})
          ..insert('丙\n'),
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(controller.dispose);
    controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 4),
      ChangeSource.local,
    );
    expect(EditorTextFontPolicy.selection(controller), (
      font: 'wenkai',
      mixed: false,
    ));
    controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 5),
      ChangeSource.local,
    );
    expect(EditorTextFontPolicy.selection(controller), (
      font: null,
      mixed: true,
    ));
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('真实T面板字体选中/取消/恢复默认，选区焦点不丢失 scale=$scale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      final directory = Directory.systemTemp.createTempSync('font-toolbar-');
      final first = DynamicFontFixture(),
          second = DynamicFontFixture(identity: 2);
      late TextFontRuntime runtime;
      late _Fonts service;
      await tester.runAsync(() async {
        runtime = TextFontRuntime(
          cache: TextFontCache(directory),
          download: (_) async => throw StateError('选择器不能下载字库'),
          register: (_, _) async => throw StateError('选择器不能注册字库'),
        )..requiresRuntimePolicy = true;
        service = _Fonts(runtime)..dynamicEnabled = true;
        service.dynamicRuntime = DynamicFontRuntime(
          runtime: runtime,
          window: service.window,
          elapsed: () => Duration.zero,
          cancel: (_) {},
          read: (_, _, _, {etag}) async => TextFontResponse(
            200,
            first.envelope(
              first.page(
                items: [
                  {...first.entry, 'name': '第一款字体'},
                  {...second.entry, 'name': '第二款字体'},
                ],
              ),
            ),
          ),
        );
        await service.dynamicRuntime!.catalog.refresh();
        service.dynamicRuntime!.catalog.acceptVersion(first.dto());
        service.dynamicRuntime!.catalog.acceptVersion(second.dto());
      });
      final session = RichEditorSession(
        initialMarkdown:
            '<span data-wenyou-font-v2="${first.id}">**word**</span> more',
        onMarkdownChanged: (_) {},
      );
      addTearDown(() async {
        session.dispose();
        service.dispose();
        runtime.dispose();
        await directory.delete(recursive: true);
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCapabilitiesProvider.overrideWithValue(
              const AppCapabilities(
                textFontSupported: true,
                textFontV2Supported: true,
                textFontV2WriteEnabled: true,
              ),
            ),
            sessionScopeProvider.overrideWithValue(
              const SessionScope(accountId: 'test', generation: 0),
            ),
            textFontServiceProvider.overrideWithValue(service),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
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
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('editor-font-picker')), findsNothing);
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
      const selected = TextSelection(baseOffset: 0, extentOffset: 4);
      expect(session.controller.selection, selected);
      await tester.tap(find.byKey(const Key('editor-heading')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('editor-font-picker')), findsOneWidget);
      expect(find.text('选中文字后更换字体'), findsNothing);
      await tester.tap(find.byKey(const Key('editor-font-picker')));
      await tester.pumpAndSettle();
      final firstTile = find.byKey(Key('editor-font-${first.id}'));
      expect(tester.widget<ListTile>(firstTile).selected, isTrue);
      expect(
        tester
            .widget<ListTile>(find.byKey(const Key('editor-font-default')))
            .selected,
        isFalse,
      );
      expect(service.specimens, greaterThan(0));
      expect(runtime.ledger.attemptedCount, 0);
      // 模拟平台收起键盘时暂存光标改变，取消工具后必须恢复原选区。
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 8),
        ChangeSource.local,
      );
      Navigator.of(tester.element(firstTile)).pop();
      await tester.pumpAndSettle();
      expect(session.controller.selection, selected);
      expect(session.focusNode.hasFocus, isTrue);
      await tester.tap(find.byKey(const Key('editor-font-picker')));
      await tester.pumpAndSettle();
      final secondTile = find.byKey(Key('editor-font-${second.id}'));
      await tester.ensureVisible(secondTile);
      await tester.pumpAndSettle();
      await tester.tap(secondTile);
      await tester.pumpAndSettle();
      expect(service.selections, 1);
      expect(session.controller.selection, selected);
      expect(session.focusNode.hasFocus, isTrue);
      expect(
        session.controller.document
            .collectStyle(0, 4)
            .attributes['font']
            ?.value,
        second.id,
      );
      expect(
        session.controller.document
            .collectStyle(0, 4)
            .attributes['bold']
            ?.value,
        isTrue,
      );
      await tester.tap(find.byKey(const Key('editor-font-picker')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ListTile>(find.byKey(Key('editor-font-${second.id}')))
            .selected,
        isTrue,
      );
      await tester.tap(find.byKey(const Key('editor-font-default')));
      await tester.pumpAndSettle();
      expect(
        session.controller.document.collectStyle(0, 4).attributes['font'],
        isNull,
      );
      expect(session.controller.document.toPlainText(), 'word more\n');
      await tester.tap(find.byKey(const Key('editor-font-picker')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ListTile>(find.byKey(const Key('editor-font-default')))
            .selected,
        isTrue,
      );
      Navigator.of(
        tester.element(find.byKey(const Key('editor-font-default'))),
      ).pop();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
