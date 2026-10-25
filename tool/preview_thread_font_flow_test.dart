// 手动离线产品组件验证；每个 FONT_BATCH 启动新进程，最多四款。
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_configuration.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/editor/presentation/text_font_quill_editor.dart';

import '../test/support/text_color_assertions.dart';

class _LocalRuntime extends TextFontRuntime {
  _LocalRuntime(TextFontCache cache, TextFontDownload download)
    : super(cache: cache, download: download);
  @override
  TextStyle style(String id, TextStyle base) =>
      super.style(id, super.style('source-han-sans', base));
}

class _LocalFonts extends TextFontService {
  _LocalFonts(this.runtime) : super(WenyouApi());
  final TextFontRuntime runtime;
  @override
  Future<TextFontRuntime> load() async => runtime;
}

class _MemoryColors implements EditorTextColorPreferenceStore {
  @override
  Future<List<String>> read(String accountId) async => [];
  @override
  Future<void> write(String accountId, List<String> colors) async {}
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String path) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(path).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  const root = String.fromEnvironment('FONT_ASSET_ROOT');
  const batch = int.fromEnvironment('FONT_BATCH');
  const outputPath = String.fromEnvironment(
    'FONT_FLOW_OUTPUT',
    defaultValue: '.dart_tool/thread-font-product-flow-r5',
  );
  const sourceSha = String.fromEnvironment('FONT_SOURCE_SHA');
  testWidgets('真实字体工具栏、颜色、阅读、重开：批次 $batch', (tester) async {
    if (root.isEmpty) throw StateError('必须提供已核验正式字体资产');
    if (sourceSha.isEmpty) throw StateError('必须提供本次实际应用源码摘要');
    const preferences = MethodChannel('plugins.flutter.io/shared_preferences');
    final memory = <String, Object?>{};
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      preferences,
      (call) async {
        if (call.method == 'getAll') return memory;
        if (call.method == 'setStringList') {
          final arguments = call.arguments as Map;
          memory[arguments['key'] as String] = arguments['value'];
          return true;
        }
        throw StateError('离线预览禁止其他偏好操作：${call.method}');
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        preferences,
        null,
      ),
    );
    final output = Directory(outputPath)..createSync(recursive: true);
    final cache = Directory('${output.path}/cache-$batch');
    final reads = <String>[];
    final runtime =
        _LocalRuntime(TextFontCache(cache), (asset) async {
            reads.add(asset.hash);
            return File('$root/${asset.path}').readAsBytes();
          })
          ..assetsAvailable = true
          ..manifest = TextFontManifest(
            File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
          );
    final fonts = runtime.manifest!.fonts.values
        .skip(batch * 4)
        .take(4)
        .toList();
    expect(fonts, isNotEmpty);
    String sample(TextFontFamily font) => switch (font.language) {
      TextFontLanguage.ja => '旅の記録 あいうカタカナゕゖ 汉语 Hello 123。',
      TextFontLanguage.en => 'Hello 123 Fancy Title 中文。',
      _ => '温油站 中英 Hello 123，汉语书写。 "\'‘’',
    };
    await tester.runAsync(() async {
      await runtime.ensure(
        'source-han-sans',
        '${fonts.map(sample).join()} Hello Italic link 第二段 '
            '正文编辑阅读重新编辑字体默认中文日文英文最近使用保存草稿'
            '${runtime.manifest!.fonts.values.map((f) => f.name).join()}',
      );
      for (final font in fonts) {
        await runtime.ensure(font.id, '${sample(font)} Hello Italic link 第二段');
        expect(runtime.loadedFamilies(font.id), isNotEmpty);
      }
    });
    final cases = <Object>[];
    for (final font in fonts) {
      for (final dark in [false, true]) {
        final variant = dark ? 'dark-large' : 'light';
        final prefix = '${output.path}/${font.id}-$variant';
        tester.view.physicalSize = Size(dark ? 320 : 360, 900);
        tester.view.devicePixelRatio = 1;
        final key = GlobalKey();
        final theme = dark ? AppTheme.dark : AppTheme.light;
        final fallback = runtime.loadedFamilies('source-han-sans');
        Widget wrap(Widget body) => ProviderScope(
          overrides: [
            textFontServiceProvider.overrideWithValue(_LocalFonts(runtime)),
            appCapabilitiesProvider.overrideWithValue(
              const AppCapabilities(
                textFontSupported: true,
                textFontWriteEnabled: true,
                textColorSupported: true,
                textColorWriteEnabled: true,
              ),
            ),
            sessionScopeProvider.overrideWithValue(
              const SessionScope(
                accountId: 'offline-font-fixture',
                generation: 0,
              ),
            ),
            editorTextColorPreferenceStoreProvider.overrideWithValue(
              _MemoryColors(),
            ),
          ],
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme.copyWith(
                textTheme: theme.textTheme.apply(
                  fontFamily: fallback.first,
                  fontFamilyFallback: fallback.skip(1).toList(),
                ),
              ),
              localizationsDelegates:
                  FlutterQuillLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(dark ? 2 : 1)),
                child: child!,
              ),
              home: Scaffold(body: SafeArea(child: body)),
            ),
          ),
        );
        Widget editor(RichEditorSession session) => Consumer(
          builder: (context, ref, child) => Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFontQuillEditor(
                    controller: session.controller,
                    focusNode: session.focusNode,
                    scrollController: session.scrollController,
                    config: QuillEditorConfig(
                      customStyles: wenyouEditorTextStyles(context),
                    ),
                  ),
                ),
              ),
              WenyouEditorToolbar(
                controller: session.controller,
                enabled: true,
                textFont: true,
                textColor: ref.watch(editorTextColorConfigurationProvider),
                editorFocusNode: session.focusNode,
                onInsertImage: () async => throw StateError('离线预览禁止上传'),
                onSaveDraft: () async {
                  await session.flush();
                },
              ),
            ],
          ),
        );
        final initial =
            '**Hello** *Italic* [link](https://example.com/)\n\n'
            '<br />\n\n第二段 ${sample(font)}';
        final session = RichEditorSession(
          initialMarkdown: initial,
          onMarkdownChanged: (_) {},
        );
        final plain = session.controller.document.toPlainText();
        expect(plain, 'Hello Italic link\n\n第二段 ${sample(font)}\n');
        await tester.pumpWidget(wrap(editor(session)));
        await tester.pumpAndSettle();
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
        expect(
          session.controller.selection,
          const TextSelection(baseOffset: 0, extentOffset: 5),
        );
        // 长按选词已验证；显式扩展测试选区以覆盖链接、空段与跨段格式。
        final selection = TextSelection(
          baseOffset: 0,
          extentOffset: plain.length - 1,
        );
        session.controller.updateSelection(selection, ChangeSource.local);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('editor-heading')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('editor-font-picker')));
        await tester.pumpAndSettle();
        final list = find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .last;
        final choice = find.byKey(Key('editor-font-${font.id}'));
        await tester.scrollUntilVisible(choice, 220, scrollable: list);
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(tester.element(choice), alignment: .5);
        await _capture(tester, key, '$prefix-picker.png');
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(session.controller.selection, selection);
        expect(
          session.controller.document
              .collectStyle(0, 5)
              .attributes['font']
              ?.value,
          font.id,
        );
        final color = find.byKey(const Key('editor-text-color-#D14343'));
        if (color.evaluate().isEmpty) {
          await tester.tap(find.byKey(const Key('editor-heading')));
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(color);
        await tester.tap(color);
        await tester.pumpAndSettle();
        expect(session.controller.selection, selection);
        expect(await session.flush(), isTrue);
        final saved = session.localMarkdown;
        expect(
          saved,
          contains(
            'data-wenyou-font-v1="${font.id}" data-wenyou-color-v1="#D14343"',
          ),
        );
        expect(saved, contains('<br />'));
        expect(session.controller.document.toPlainText(), plain);
        expect(
          session.controller.document
              .collectStyle(0, 5)
              .attributes['bold']
              ?.value,
          true,
        );
        expect(
          session.controller.document
              .collectStyle(6, 6)
              .attributes['italic']
              ?.value,
          true,
        );
        expect(
          session.controller.document
              .collectStyle(13, 4)
              .attributes['link']
              ?.value,
          'https://example.com/',
        );
        session.controller.updateSelection(
          const TextSelection.collapsed(offset: 0),
          ChangeSource.local,
        );
        session.focusNode.unfocus();
        await _capture(tester, key, '$prefix-editor.png');
        final units = colorDeltaUnits(session.controller.document.toDelta());
        final blocks = saved
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();
        expect(blocks, hasLength(3));
        expect(blocks[1], '<br />');
        expect([
          ...colorReaderUnits(colorReaderNodes(blocks[0])),
          ...colorReaderUnits(colorReaderNodes(blocks[2])),
        ], units);
        await tester.pumpWidget(
          wrap(
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: WenyouMarkdown(data: saved, enableTextFonts: true),
            ),
          ),
        );
        await _capture(tester, key, '$prefix-reader.png');
        final renderedParagraphs = tester.allRenderObjects
            .whereType<RenderParagraph>()
            .toSet();
        expect(
          renderedParagraphs.map((p) => p.text.toPlainText()),
          containsAll(['Hello Italic link', '第二段 ${sample(font)}']),
        );
        expect(
          renderedParagraphs.any(
            (p) => p.text.toPlainText().trim().isEmpty && p.size.height > 0,
          ),
          isTrue,
          reason: '阅读空段必须实际占据布局高度',
        );
        expect(find.textContaining('<br', findRichText: true), findsNothing);
        final reopened = RichEditorSession(
          initialMarkdown: saved,
          onMarkdownChanged: (_) {},
        );
        expect(reopened.controller.document.toPlainText(), plain);
        expect(colorDeltaUnits(reopened.controller.document.toDelta()), units);
        await tester.pumpWidget(wrap(editor(reopened)));
        await _capture(tester, key, '$prefix-reopened.png');
        expect(await reopened.flush(), isTrue);
        expect(reopened.localMarkdown, saved);
        cases.add({
          'fontId': font.id,
          'language': font.language?.name,
          'variant': variant,
          'inputMarkdown': initial,
          'markdown': saved,
          'plainText': plain,
          'visibleUnits': units,
          'delta': reopened.controller.document.toDelta().toJson(),
          'reexportedMarkdown': reopened.localMarkdown,
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        session.dispose();
        reopened.dispose();
      }
    }
    final before = reads.length;
    final requests = runtime.requests;
    await tester.runAsync(() async {
      for (final font in fonts) {
        await runtime.ensure(font.id, '${sample(font)} Hello Italic link 第二段');
      }
      expect(reads.length, before, reason: '同进程重开不重复读取正式资产');
      expect(runtime.requests, requests);
      expect(runtime.requests, lessThanOrEqualTo(64));
      expect(runtime.registeredFaces, lessThanOrEqualTo(32));
      expect(runtime.families.length, lessThanOrEqualTo(8));
      expect(runtime.downloadedBytes, lessThanOrEqualTo(24 * 1024 * 1024));
      expect(runtime.registeredBytes, lessThanOrEqualTo(24 * 1024 * 1024));
      expect(runtime.originalReservedBytes, lessThanOrEqualTo(18410600));
      final bytes = await cache
          .list()
          .where((f) => f is File)
          .cast<File>()
          .asyncMap((f) => f.length())
          .fold<int>(0, (a, b) => a + b);
      expect(bytes, lessThanOrEqualTo(64 * 1024 * 1024));
      await File('${output.path}/batch-$batch.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'format': 'wenyou-mobile-font-product-flow-v1',
          'processId': pid,
          'sourceSha256': sourceSha,
          'backendRevision': '102b825379eb5da462f0ff765b29dc8fd7fb93ad',
          'dataScope': '自造文本、内存偏好、本任务缓存；无HTTP、账号启动或业务写入',
          'cacheBytes': bytes,
          'cachePath': cache.absolute.path,
          'requests': runtime.requests,
          'registeredBytes': runtime.registeredBytes,
          'downloadedBytes': runtime.downloadedBytes,
          'faces': runtime.registeredFaces,
          'originalReservedBytes': runtime.originalReservedBytes,
          'originalRegisteredBytes': runtime.originalRegisteredBytes,
          'repeatReads': reads.length - before,
          'cases': cases,
        }),
      );
    });
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
