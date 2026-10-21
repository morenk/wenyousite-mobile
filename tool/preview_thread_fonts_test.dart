// 手动离线渲染：flutter test tool/preview_thread_fonts_test.dart
// --dart-define=FONT_ASSET_ROOT=<正式资产根> --dart-define=FONT_BATCH=<每批4款的批号>
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_picker.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/text_font_quill_editor.dart';

class _PreviewRuntime extends TextFontRuntime {
  _PreviewRuntime(TextFontCache cache, TextFontDownload download)
    : super(cache: cache, download: download);
  @override
  TextStyle style(String id, TextStyle base) =>
      super.style(id, super.style('source-han-sans', base));
}

class _PreviewService extends TextFontService {
  _PreviewService(this.runtime) : super(WenyouApi());
  final TextFontRuntime runtime;
  @override
  Future<TextFontRuntime> load() async => runtime;
}

Future<Uint8List> _pixels(String text, TextStyle style) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..drawColor(Colors.white, BlendMode.src);
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: style.copyWith(fontSize: 40, color: Colors.black),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    Offset(
      0,
      60 - painter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
    ),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(1200, 100);
  final bytes = (await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  ))!.buffer.asUint8List();
  painter.dispose();
  image.dispose();
  picture.dispose();
  return bytes;
}

Future<void> _previewPicker(
  WidgetTester tester,
  TextFontRuntime runtime,
  Directory output,
) async {
  const preferences = MethodChannel('plugins.flutter.io/shared_preferences');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(preferences, (
    call,
  ) async {
    if (call.method == 'getAll') return <String, Object>{};
    throw StateError('预览只允许读取空的测试偏好');
  });
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      preferences,
      null,
    ),
  );
  await tester.runAsync(
    () => runtime.ensure(
      'source-han-sans',
      '中文日文英文字体默认缺少的字使用显示暂不可最近加载未分类'
          '${runtime.manifest!.fonts.values.map((f) => f.name).join()}',
    ),
  );
  for (final dark in [false, true]) {
    final size = Size(dark ? 320 : 360, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    final key = GlobalKey();
    final controller = QuillController(
      document: Document()..insert(0, '文字'),
      selection: const TextSelection(baseOffset: 0, extentOffset: 2),
    );
    final theme = dark ? AppTheme.dark : AppTheme.light;
    final families = runtime.loadedFamilies('source-han-sans');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          textFontServiceProvider.overrideWithValue(_PreviewService(runtime)),
          appCapabilitiesProvider.overrideWithValue(
            const AppCapabilities(
              textFontSupported: true,
              textFontWriteEnabled: true,
            ),
          ),
          sessionScopeProvider.overrideWithValue(
            const SessionScope(accountId: 'preview', generation: 0),
          ),
        ],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(
                fontFamily: families.first,
                fontFamilyFallback: families.skip(1).toList(),
              ),
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(dark ? 2 : 1)),
              child: child!,
            ),
            home: Scaffold(
              body: Center(
                child: EditorTextFontPicker(
                  controller: controller,
                  enabled: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-font-picker')));
    await tester.pumpAndSettle();
    final list = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .last;
    for (final language in TextFontLanguage.values) {
      await tester.scrollUntilVisible(
        find.byKey(Key('editor-font-group-${language.name}')),
        180,
        scrollable: list,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '${output.path}/picker-${language.name}-${dark ? 'dark-large' : 'light'}.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }
}

void main() {
  const root = String.fromEnvironment('FONT_ASSET_ROOT');
  const batch = int.fromEnvironment('FONT_BATCH');
  const outputPath = String.fromEnvironment(
    'FONT_PREVIEW_OUTPUT',
    defaultValue: '.dart_tool/thread-font-preview-r5',
  );
  testWidgets('正式分片真实 Flutter 阅读与 Quill 预览，批次 $batch', (tester) async {
    if (root.isEmpty) throw StateError('需要正式资产根，不能用系统字体伪造预览');
    final output = Directory(outputPath)..createSync(recursive: true);
    final cache = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('wenyou-font-preview-'),
    ))!;
    final runtime =
        _PreviewRuntime(
            TextFontCache(cache),
            (asset) => File('$root/${asset.path}').readAsBytes(),
          )
          ..assetsAvailable = true
          ..manifest = TextFontManifest(
            File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
          );
    final fonts = runtime.manifest!.fonts.values
        .where((f) => f.ready)
        .skip(batch * 4)
        .take(4)
        .toList();
    expect(fonts, isNotEmpty, reason: '批号必须包含正式就绪字体');
    String sampleFor(TextFontFamily font) => switch (font.language) {
      TextFontLanguage.ja => '旅の記録 あいうカタカナゕゖ 汉语 Hello 123。',
      TextFontLanguage.en => 'Hello 123 Fancy Title 中文。',
      _ => '温油站 中英 Hello 123，汉语书写。 "\'‘’',
    };
    final results = <Object>[];
    final before = ProcessInfo.currentRss;
    await tester.runAsync(() async {
      await runtime.ensure(
        'source-han-sans',
        '${fonts.map(sampleFor).join()} 阅读 编辑 ${fonts.map((f) => f.name).join()}',
      );
      for (final font in fonts) {
        await runtime.ensure(font.id, sampleFor(font));
      }
    });
    for (final font in fonts) {
      final sample = sampleFor(font);
      final kana = sample.runes.where((r) => r >= 0x3040 && r <= 0x30ff);
      final kanaShards = font.shards
          .where((s) => kana.any(s.contains))
          .toList();
      if (font.language == TextFontLanguage.ja) {
        expect(kanaShards, isNotEmpty, reason: '${font.id} 实际假名须有分片');
        expect(kanaShards.every((s) => s.id != 'core'), isTrue);
        for (final shard in kanaShards) {
          expect(
            runtime.loadedFamilies(font.id),
            contains(shard.family),
            reason: '${font.id} 假名必须实际加载额外分片',
          );
        }
      }
      expect(
        runtime.loadedFamilies(font.id),
        isNotEmpty,
        reason: '${font.id} 必须实际注册',
      );
      final native = String.fromCharCodes(
        sample.runes.where(
          (r) => r != 32 && font.shards.any((s) => s.contains(r)),
        ),
      );
      final missing = String.fromCharCodes(
        sample.runes.where((r) => !font.shards.any((s) => s.contains(r))),
      );
      await tester.runAsync(() async {
        final styled = runtime.style(font.id, const TextStyle());
        final fallback = runtime.style('source-han-sans', const TextStyle());
        if (font.id != 'source-han-sans') {
          expect(
            listEquals(
              await _pixels(native, styled),
              await _pixels(native, fallback),
            ),
            isFalse,
            reason: '${font.id} 原生字形必须与回退图像不同',
          );
        }
        if (missing.isNotEmpty) {
          expect(
            listEquals(
              await _pixels(missing, styled),
              await _pixels(missing, fallback),
            ),
            isTrue,
            reason: '${font.id} 缺字必须来自显式回退',
          );
        }
      });
      for (final variant in [(360.0, 1.0, false), (320.0, 2.0, true)]) {
        tester.view.physicalSize = Size(variant.$1, 1100);
        tester.view.devicePixelRatio = 1;
        final controller = QuillController(
          document: Document.fromDelta(
            MarkdownDeltaCodec.decode(
              '<span data-wenyou-font-v1="${font.id}" data-wenyou-color-v1="#D14343">$sample **粗体 Bold** *Italic* `#>*`</span>',
            ).delta,
          ),
          selection: const TextSelection.collapsed(offset: 0),
        )..readOnly = true;
        final focus = FocusNode();
        final scroll = ScrollController();
        final key = GlobalKey();
        final theme = variant.$3 ? AppTheme.dark : AppTheme.light;
        final fallback = runtime.loadedFamilies('source-han-sans').first;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textFontServiceProvider.overrideWithValue(
                _PreviewService(runtime),
              ),
            ],
            child: MaterialApp(
              theme: theme.copyWith(
                textTheme: theme.textTheme.apply(fontFamily: fallback),
              ),
              localizationsDelegates:
                  FlutterQuillLocalizations.localizationsDelegates,
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(variant.$1, 1100),
                  textScaler: TextScaler.linear(variant.$2),
                ),
                child: RepaintBoundary(
                  key: key,
                  child: Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            font.name,
                            style: TextStyle(
                              fontFamily: fallback,
                              fontSize: 24,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '阅读',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Expanded(
                            child: WenyouMarkdown(
                              enableTextFonts: true,
                              data:
                                  '<span data-wenyou-font-v1="${font.id}" data-wenyou-color-v1="#D14343">$sample **粗体 Bold** *Italic* `#>*`</span>',
                            ),
                          ),
                          Divider(color: theme.colorScheme.outlineVariant),
                          Text(
                            '编辑',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) => TextFontQuillEditor(
                                controller: controller,
                                focusNode: focus,
                                scrollController: scroll,
                                config: QuillEditorConfig(
                                  customStyles: wenyouEditorTextStyles(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 80));
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
          await File(
            '${output.path}/${font.id}-${variant.$3 ? 'dark-large' : 'light'}.png',
          ).writeAsBytes(bytes);
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
        focus.dispose();
        scroll.dispose();
      }
      final supported = sample.runes
          .where((r) => font.shards.any((s) => s.contains(r)))
          .length;
      results.add({
        'id': font.id,
        'language': font.language?.name,
        'sample': sample,
        'kanaShards': [
          for (final s in kanaShards)
            {'id': s.id, 'sha256': s.asset.hash, 'bytes': s.asset.bytes},
        ],
        'loadedFamilies': runtime.loadedFamilies(font.id),
        'sampleNativeCodepoints': supported,
        'sampleCodepoints': sample.runes.length,
        'nativeRasterDiffers': font.id != 'source-han-sans',
        'fallbackProbe': missing,
      });
    }
    if (batch == 0) await _previewPicker(tester, runtime, output);
    await tester.runAsync(() async {
      await File('${output.path}/batch-$batch.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'fonts': results,
          'registeredBytes': runtime.registeredBytes,
          'downloadedBytes': runtime.downloadedBytes,
          'originalReservedBytes': runtime.originalReservedBytes,
          'originalDownloadedBytes': runtime.originalDownloadedBytes,
          'originalRegisteredBytes': runtime.originalRegisteredBytes,
          'registeredFaces': runtime.registeredFaces,
          'requests': runtime.requests,
          'rssBefore': before,
          'rssAfter': ProcessInfo.currentRss,
          'fallback': '已验证思源黑体正式分片；此处不是 Android 系统回退或真机 RSS',
        }),
      );
      await cache.delete(recursive: true);
    });
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
