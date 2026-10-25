// 手动离线真实组件预览；FONT_ASSET_ROOT和FONT_SOURCE_SHA必须与本次来源一致。
import 'dart:async';
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
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_atomic_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';

class _Fonts extends TextFontService {
  _Fonts(this.runtime) : super(WenyouApi());
  final TextFontRuntime runtime;
  int loads = 0;
  @override
  Future<TextFontRuntime> load() async {
    loads++;
    return runtime;
  }
}

class _Gateway implements EditorClipboardGateway {
  _Gateway(this.text);
  final String text;
  @override
  Future<EditorClipboardSnapshot> read() async =>
      EditorClipboardSnapshot(text: text, marker: 'offline');
  @override
  Future<void> write({required String text, required String marker}) async {}
}

void main() {
  const root = String.fromEnvironment('FONT_ASSET_ROOT');
  const sourceSha = String.fromEnvironment('FONT_SOURCE_SHA');
  const outputPath = String.fromEnvironment(
    'FONT_SCOPE_OUTPUT',
    defaultValue: '.dart_tool/thread-font-product-flow-r5/scope',
  );
  testWidgets('最终作用域、静默冷暖加载和主题到动态传送门粘贴', (tester) async {
    if (root.isEmpty || sourceSha.isEmpty) throw StateError('需固定资产与源码摘要');
    final output = Directory(outputPath)..createSync(recursive: true);
    final cache = Directory('${output.path}/cache-$pid');
    Completer<void>? gate;
    var reads = 0;
    final runtime =
        TextFontRuntime(
            cache: TextFontCache(cache),
            download: (asset) async {
              await gate?.future;
              reads++;
              return File('$root/${asset.path}').readAsBytes();
            },
          )
          ..manifest = TextFontManifest(
            File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
          )
          ..assetsAvailable = true;
    const source =
        '<span data-wenyou-font-v1="wenkai" data-wenyou-color-v1="#D14343">**温油站 Hello 123**</span>\n\n[传送门](/threads/aaaaaaaaaaaaaaaaaaaaaaaa)';
    await tester.runAsync(
      () => runtime.ensure('source-han-sans', '温油站 Hello 123 传送门输入动态'),
    );
    final service = _Fonts(runtime);
    final fallback = runtime.loadedFamilies('source-han-sans');
    final rows = <Object>[];
    for (final dark in [false, true]) {
      final variant = dark ? 'dark-large' : 'light';
      tester.view.physicalSize = Size(dark ? 320 : 360, 740);
      tester.view.devicePixelRatio = 1;
      final key = GlobalKey();
      final theme = dark ? AppTheme.dark : AppTheme.light;
      Widget wrap(Widget body) => ProviderScope(
        overrides: [textFontServiceProvider.overrideWithValue(service)],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates:
                FlutterQuillLocalizations.localizationsDelegates,
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(
                fontFamily: fallback.first,
                fontFamilyFallback: fallback.skip(1).toList(),
              ),
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(dark ? 2 : 1)),
              child: child!,
            ),
            home: Scaffold(
              body: Padding(padding: const EdgeInsets.all(16), child: body),
            ),
          ),
        ),
      );
      Future<void> capture(String stage) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '${output.path}/$variant-$stage.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      final loadsBefore = service.loads;
      final readsBefore = reads;
      await tester.pumpWidget(wrap(const WenyouMarkdown(data: source)));
      await capture('default');
      expect(service.loads, loadsBefore);
      expect(reads, readsBefore);
      if (!dark) gate = Completer<void>();
      await tester.pumpWidget(
        wrap(const WenyouMarkdown(data: source, enableTextFonts: true)),
      );
      await capture(!dark ? 'cold-default' : 'warm');
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      if (!dark) {
        expect(runtime.loadedFamilies('wenkai'), isEmpty);
        gate!.complete();
        gate = null;
        // FontLoader回调由测试绑定泵送；不能在真实异步区等待假时钟队列。
        for (
          var attempt = 0;
          attempt < 60 && runtime.loadedFamilies('wenkai').isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pump();
        }
        await capture('loaded');
        expect(runtime.loadedFamilies('wenkai'), isNotEmpty);
      } else {
        expect(reads, readsBefore);
      }
      final store = WenyouEditorClipboardStore();
      final delta = MarkdownDeltaCodec.decode(source).delta;
      final text = WenyouEditorClipboardStore.visibleText(delta);
      store.capture(
        delta: delta,
        plainTextFallback: text,
        operation: WenyouEditorClipboardOperation.copy,
        marker: 'offline',
        scope: 'preview',
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async =>
            call.method == 'Clipboard.getData' ? {'text': text} : null,
      );
      final controller = WenyouAtomicTextController(
        initialMarkdown: '',
        maximumMarkdownLength: 1000,
        readStructuredClipboard: (text) => readAtomicEditorClipboard(
          text,
          scope: 'preview',
          store: store,
          gateway: _Gateway(text),
        ),
      );
      await controller.pasteClipboard();
      await tester.pump();
      expect(
        controller.markdown,
        '温油站 Hello 123\n[传送门](/threads/aaaaaaaaaaaaaaaaaaaaaaaa)',
      );
      await tester.pumpWidget(
        wrap(
          WenyouAtomicTextEditor(
            controller: controller,
            editorKey: const Key('moment-font-paste'),
            placeholder: '输入动态',
            semanticLabel: '动态正文',
            autofocus: false,
          ),
        ),
      );
      await capture('moment-paste');
      if (dark && controller.scrollController.hasClients) {
        controller.scrollController.jumpTo(
          controller.scrollController.position.maxScrollExtent,
        );
        await capture('compact-paste-scrolled');
      }
      await tester.pumpWidget(
        wrap(
          WenyouAtomicTextEditor(
            controller: controller,
            editorKey: const Key('moment-font-paste-expanded'),
            placeholder: '输入动态',
            semanticLabel: '动态正文',
            autofocus: false,
            expands: true,
          ),
        ),
      );
      await capture('moment-paste-expanded');
      rows.add({
        'variant': variant,
        'defaultFontLoads': 0,
        'defaultFontReads': 0,
        'loadedFamilies': runtime.loadedFamilies('wenkai'),
        'assetReads': reads,
        'registeredBytes': runtime.registeredBytes,
        'requests': runtime.requests,
        'pastedMarkdown': controller.markdown,
        'sourceMarkdown': source,
      });
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
    await tester.runAsync(
      () => File('${output.path}/evidence.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'sourceSha256': sourceSha,
          'processId': pid,
          'api': null,
          'device': 'Windows flutter_tester，无Android设备',
          'cache': cache.absolute.path,
          'dataScope': '自造正文、内存剪贴板；无账号、HTTP或业务写入',
          'cases': rows,
        }),
      ),
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
