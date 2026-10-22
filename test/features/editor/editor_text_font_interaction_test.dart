import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/editor/presentation/text_font_quill_editor.dart';

import '../../support/deterministic_test_fonts.dart';

class _Fonts extends TextFontService {
  _Fonts() : super(WenyouApi(), observePlatform: false);
  final requests = <Completer<TextFontRuntime>>[];
  int closes = 0;
  @override
  Future<TextFontRuntime> openPicker() {
    final pending = Completer<TextFontRuntime>();
    requests.add(pending);
    return pending.future;
  }

  @override
  void closePicker() {
    closes++;
  }
}

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    testWidgets('真实T空光标立即开面板、慢请求/重试/取消/退出 dark=$dark', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      final service = _Fonts();
      final runtime = TextFontRuntime(
        cache: TextFontCache(Directory.systemTemp),
        download: (_) async => throw StateError('离线测试禁止下载'),
      );
      runtime.assetsAvailable = true;
      runtime.manifest = TextFontManifest(
        File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
      );
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(() {
        session.dispose();
        service.dispose();
        runtime.dispose();
      });
      final capture = Platform.environment['FONT_PICKER_CAPTURE_DIR'];
      final imageKey = GlobalKey();
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
            textFontServiceProvider.overrideWithValue(service),
          ],
          child: RepaintBoundary(
            key: imageKey,
            child: MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
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
        ),
      );
      final c = session.controller;
      session.focusNode.requestFocus();
      await pumpEditorFrames(tester);
      await tester.tap(find.byKey(const Key('editor-heading')));
      await pumpEditorFrames(tester);
      final button = tester.widget<OutlinedButton>(
        find.byKey(const Key('editor-font-picker')),
      );
      expect(button.onPressed, isNotNull, reason: '空编辑器必须能选择后续输入字体');
      button.onPressed!();
      button.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('正在加载字体'), findsOneWidget);
      expect(service.requests, hasLength(1), reason: '连续点击只开一个面板/请求');
      service.requests.single.completeError(StateError('offline'));
      await pumpEditorFrames(tester);
      expect(find.text('字体加载失败'), findsOneWidget);
      await tester.tap(find.text('重新加载字体'));
      await tester.pump();
      expect(service.requests, hasLength(2));
      service.requests.last.complete(runtime);
      await pumpEditorFrames(tester);
      if (capture != null) {
        final boundary =
            imageKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final picture = await boundary.toImage();
          final bytes = await picture.toByteData(
            format: ui.ImageByteFormat.png,
          );
          await Directory(capture).create(recursive: true);
          await File(
            '$capture/font-picker-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          picture.dispose();
        });
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('editor-font-wenkai')),
        100,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .last,
      );
      await pumpEditorFrames(tester);
      await tester.tap(find.byKey(const Key('editor-font-wenkai')));
      await pumpEditorFrames(tester);
      expect(c.selection, const TextSelection.collapsed(offset: 0));
      expect(session.focusNode.hasFocus, isTrue);
      expect(
        EditorTextFontPolicy.selection(c).font,
        'wenkai',
        reason: '关闭面板不能恢复旧快照覆盖新字体',
      );
      for (final value in ['j', 'jia', '甲']) {
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: '$value\n',
            selection: TextSelection.collapsed(offset: value.length),
            composing: TextRange(start: 0, end: value.length),
          ),
        );
        await tester.pump();
      }
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '甲\n',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump();
      expect(c.document.collectStyle(0, 1).attributes['font']?.value, 'wenkai');
      // 第二次工具打开时模拟平台收键盘移位，取消仍恢复入口光标和未落字字体。
      EditorTextFontPolicy.apply(c, c.selection, 'zhuque');
      await tester.tap(find.byKey(const Key('editor-font-picker')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      c.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      await tester.tap(find.byKey(const Key('editor-font-close')));
      await pumpEditorFrames(tester);
      expect(c.selection, const TextSelection.collapsed(offset: 1));
      expect(EditorTextFontPolicy.selection(c).font, 'zhuque');
      expect(service.closes, 2);
      service.requests.last.complete(runtime);
      await pumpEditorFrames(tester);
      expect(
        find.byKey(const Key('editor-font-wenkai')),
        findsNothing,
        reason: '取消后的迟到请求不能重开面板',
      );
      await tester.tap(find.byKey(const Key('editor-font-picker')));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      service.requests.last.complete(runtime);
      await pumpEditorFrames(tester);
      expect(tester.takeException(), isNull, reason: '退出后的迟到请求不能访问已销毁状态');
    });
  }
}

// 下载条持续动画时，只等待路由/焦点动画，不能等待所有帧永久静止。
Future<void> pumpEditorFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}
