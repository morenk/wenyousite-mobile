import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

class _Runtime extends TextFontRuntime {
  _Runtime()
    : super(
        cache: TextFontCache(Directory.systemTemp),
        download: (_) async => throw StateError('不应请求'),
      );
  final requested = <String>[];
  final active = <Object>{};
  @override
  void setDemand(Object owner, Map<String, String> texts) {
    active.add(owner);
    super.setDemand(owner, texts);
  }

  @override
  void release(Object owner) {
    active.remove(owner);
    super.release(owner);
  }

  @override
  Future<void> ensure(String id, String text) async {
    requested.add(id);
  }

  @override
  TextStyle style(String id, TextStyle base) =>
      base.copyWith(fontFamily: 'fixture-font-$id');
}

class _Service extends TextFontService {
  _Service(this.runtime) : super(WenyouApi());
  final _Runtime runtime;
  int loads = 0;
  Completer<TextFontRuntime>? pending;
  bool fail = false;
  @override
  Future<TextFontRuntime> load() async {
    loads++;
    if (fail) throw const FormatException('离线');
    return pending == null ? runtime : pending!.future;
  }
}

void main() {
  testWidgets('正文保持可见时能力更新会重新检查字体来源', (tester) async {
    final service = _Service(_Runtime());
    final container = ProviderContainer(
      overrides: [
        textFontServiceProvider.overrideWithValue(service),
        appCapabilitiesProvider.overrideWithValue(const AppCapabilities()),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(service.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: WenyouMarkdown(
              enableTextFonts: true,
              data: '<span data-wenyou-font-v1="wenkai">正文</span>',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = service.loads;
    container.updateOverrides([
      textFontServiceProvider.overrideWithValue(service),
      appCapabilitiesProvider.overrideWithValue(
        const AppCapabilities(
          textFontSupported: true,
          textFontV2Supported: true,
        ),
      ),
    ]);
    await tester.pumpAndSettle();
    expect(service.loads, greaterThan(before));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('嵌套滚动由外层移出屏幕后释放需求，返回时恢复', (tester) async {
    final service = _Service(_Runtime());
    final outer = ScrollController();
    addTearDown(outer.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [textFontServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              controller: outer,
              child: const Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          WenyouMarkdown(
                            enableTextFonts: true,
                            data:
                                '<span data-wenyou-font-v1="wenkai">正文</span>',
                          ),
                          SizedBox(height: 1000),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(service.runtime.active, hasLength(1));
    outer.jumpTo(500);
    await tester.pumpAndSettle();
    expect(service.runtime.active, isEmpty);
    outer.jumpTo(0);
    await tester.pumpAndSettle();
    expect(service.runtime.active, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(service.runtime.active, isEmpty);
  });
  testWidgets('正文冷加载自动切换且保持滚动；关闭作用域后不使用已加载家族', (tester) async {
    final service = _Service(_Runtime())
      ..pending = Completer<TextFontRuntime>();
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    Widget build(bool enabled) => ProviderScope(
      overrides: [textFontServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scroll,
            child: Column(
              children: [
                WenyouMarkdown(
                  enableTextFonts: enabled,
                  data: '<span data-wenyou-font-v1="wenkai">正文</span>',
                ),
                const SizedBox(height: 1800),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();
    expect(find.textContaining('正文', findRichText: true), findsWidgets);
    expect(service.runtime.requested, isEmpty);
    scroll.jumpTo(60);
    service.pending!.complete(service.runtime);
    await tester.pumpAndSettle();
    expect(service.runtime.requested, contains('wenkai'));
    expect(scroll.offset, 60);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final loads = service.loads;
    service.runtime.requested.clear();
    await tester.pumpWidget(build(false));
    await tester.pumpAndSettle();
    expect(service.loads, loads);
    expect(service.runtime.requested, isEmpty);
    expect(find.textContaining('正文', findRichText: true), findsWidgets);
  });
  testWidgets('正文加载失败静默保留默认文字，无下载或重试操作', (tester) async {
    final service = _Service(_Runtime())..fail = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [textFontServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: WenyouMarkdown(
              enableTextFonts: true,
              data: '<span data-wenyou-font-v1="wenkai">正文</span>',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('正文', findRichText: true), findsWidgets);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('共享阅读器默认禁止自定义字体和资源加载，保留颜色文字', (tester) async {
    final service = _Service(_Runtime());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [textFontServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: WenyouMarkdown(
              data:
                  '<span data-wenyou-font-v1="wenkai" data-wenyou-color-v1="#D14343">**文字**</span>',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('文字', findRichText: true), findsWidgets);
    expect(service.loads, 0);
    expect(service.runtime.requested, isEmpty);
  });
}
