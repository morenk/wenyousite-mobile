import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_demand_queue.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_snapshot.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_font_download_progress.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/editor/presentation/text_font_quill_editor.dart';

import '../../core/text_fonts/font_test_fixture.dart';
import '../../support/deterministic_test_fonts.dart';

class _Fonts extends TextFontService {
  _Fonts(this.runtime) : super(WenyouApi(), observePlatform: false);
  final TextFontRuntime runtime;
  final demands = <Map<String, String>>[];
  @override
  Future<TextFontRuntime> retain(
    Object owner,
    Map<String, String> texts,
  ) async {
    demands.add(texts);
    runtime.setDemand(owner, texts);
    return runtime;
  }

  @override
  void release(Object owner) => runtime.release(owner);
}

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final selected in [false, true]) {
    testWidgets('主动选择/字节更新不重建正文或打断组合输入 selected=$selected', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final imageKey = GlobalKey();
      final f = FontTestFixture(shardBytes: 3000000), cache = MemoryFontCache();
      final transfer = Completer<void>(), registration = Completer<void>();
      final runtime = TextFontRuntime(
        cache: cache,
        download: (_) async => throw StateError('unused'),
      )..manifest = f.manifest;
      final queue = runtime.demandQueue = TextFontDemandQueue(
        cache: cache,
        download: (asset) async {
          if (asset.hash == f.a.hash) await transfer.future;
          return f.data[asset.hash]!;
        },
        register: (_, _) => registration.future,
        snapshot: TextFontNativeSnapshot(
          manifest: f.manifest,
          assetCount: 2,
          totalBytes: 6000000,
        ),
        window: TextFontDownloadWindow(
          period: const Duration(minutes: 1),
          maximumBytes: 24 * 1024 * 1024,
          maximumRequests: 64,
        ),
      )..updateSource(f.manifest, downloadable: true);
      addTearDown(queue.dispose);
      final service = _Fonts(runtime);
      final session = RichEditorSession(
        initialMarkdown: selected ? 'A' : '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(() {
        session.dispose();
        service.dispose();
        runtime.dispose();
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [textFontServiceProvider.overrideWithValue(service)],
          child: RepaintBoundary(
            key: imageKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: selected ? AppTheme.dark : AppTheme.light,
              home: Scaffold(
                appBar: AppBar(title: const Text('编辑正文')),
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
      session.focusNode.requestFocus();
      await tester.pumpAndSettle();
      final c = session.controller;
      if (selected) {
        c.updateSelection(
          const TextSelection(baseOffset: 0, extentOffset: 1),
          ChangeSource.local,
        );
      }
      EditorTextFontPolicy.apply(c, c.selection, 'wenkai');
      if (selected) {
        c.updateSelection(
          const TextSelection.collapsed(offset: 1),
          ChangeSource.local,
        );
      }
      c.beginFontApplication('wenkai');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      if (!selected) {
        expect(
          find.byKey(const Key('editor-font-download-progress')),
          findsNothing,
        );
      }
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'A\n',
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange(start: 0, end: 1),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(c.document.collectStyle(0, 1).attributes['font']?.value, 'wenkai');
      await tester.pump(const Duration(milliseconds: 300));
      final editorBefore = tester.widget<QuillEditor>(find.byType(QuillEditor));
      final rawBefore = tester.state<QuillRawEditorState>(
        find.byType(QuillRawEditor),
      );
      final editingBefore = tester.testTextInput.editingState;
      queue.reportReceived(f.a.path, 1000000);
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.fontApplication, 'wenkai');
      expect(service.demands, isNotEmpty);
      expect(queue.requests, 2, reason: service.demands.toString());
      expect(
        tester
            .widget<EditorFontDownloadProgress>(
              find.byType(EditorFontDownloadProgress),
            )
            .runtime,
        same(runtime),
      );
      expect(queue.requests, 2);
      expect(queue.progressFor('wenkai', 'A', {}).receivedBytes, 1000000);
      expect(find.text('下载字体'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        1 / 3,
      );
      expect(
        identical(
          tester.widget<QuillEditor>(find.byType(QuillEditor)),
          editorBefore,
        ),
        isTrue,
      );
      expect(
        identical(
          tester.state<QuillRawEditorState>(find.byType(QuillRawEditor)),
          rawBefore,
        ),
        isTrue,
      );
      expect(tester.testTextInput.editingState, editingBefore);
      expect(session.focusNode.hasFocus, isTrue);
      expect(c.selection, const TextSelection.collapsed(offset: 1));
      await captureProgress(
        tester,
        imageKey,
        '${selected ? 'dark-selection' : 'light-caret'}-downloading',
      );
      transfer.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text('正在应用'), findsOneWidget);
      await captureProgress(
        tester,
        imageKey,
        '${selected ? 'dark-selection' : 'light-caret'}-applying',
      );
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        isNull,
      );
      registration.complete();
      await tester.pump();
      await tester.pump();
      expect(
        find.byKey(const Key('editor-font-download-progress')),
        findsNothing,
      );
      c.beginFontApplication(null);
      await tester.pump();
      queue.progress.start(f.b);
      queue.reportReceived(f.b.path, 1);
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const Key('editor-font-download-progress')),
        findsNothing,
        reason: '其他阅读需求不能冒充当前主动应用',
      );
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'A\n',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      session.focusNode.unfocus();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('快速切换清除旧目标；缓存静默；未知元数据与终止状态明确', (tester) async {
    final f = FontTestFixture();
    final runtime = TextFontRuntime(
      cache: MemoryFontCache(),
      download: (_) async => throw StateError('unused'),
    );
    addTearDown(runtime.dispose);
    Future<void> show(String? font, {int generation = 1}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: EditorFontDownloadProgress(
              runtime: runtime,
              font: font,
              text: 'A',
              generation: generation,
            ),
          ),
        ),
      );
    }

    await show('wenkai');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('准备字体'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      isNull,
    );
    await show('zhuque', generation: 2);
    expect(
      find.byKey(const Key('editor-font-download-progress')),
      findsNothing,
    );
    runtime.fontUnavailable = (_) => true;
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('字体暂不可用'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    runtime.fontUnavailable = null;
    runtime.manifest = f.manifest;
    await show('wenkai', generation: 3);
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.byKey(const Key('editor-font-download-progress')),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> captureProgress(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  final path = Platform.environment['FONT_PROGRESS_CAPTURE_DIR'];
  if (path == null) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final picture = await boundary.toImage();
    final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
    await Directory(path).create(recursive: true);
    await File('$path/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    picture.dispose();
  });
}
