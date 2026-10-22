import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dynamic_font_list.dart';

import 'package:wenyousite_mobile/features/editor/presentation/editor_font_specimen.dart';

import '../../core/text_fonts/dynamic_font_fixture.dart';

class _Service extends TextFontService {
  _Service() : super(WenyouApi(), observePlatform: false);
  final attempts = <String, int>{};
  final cancelled = <Object>{};
  bool failFirst = false;
  static final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aT1sAAAAASUVORK5CYII=',
  );
  @override
  Future<Uint8List?> specimen(
    FontCatalogEntryDto entry, {
    Object? owner,
    bool Function()? isActive,
  }) async {
    final count = attempts.update(
      entry.versionId,
      (n) => n + 1,
      ifAbsent: () => 1,
    );
    return failFirst && count == 1 ? null : png;
  }

  @override
  void cancelSpecimen(Object owner) => cancelled.add(owner);
}

void main() {
  late Directory directory;
  late _Service service;
  late TextFontRuntime runtime;
  late List<DynamicFontFixture> fonts;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('font-picker-v2-');
    service = _Service();
    runtime = TextFontRuntime(
      cache: TextFontCache(directory),
      download: (_) async => throw StateError('选择器不得下载字体'),
      register: (_, _) async => throw StateError('选择器不得注册字体'),
    );
    fonts = List.generate(4, (i) => DynamicFontFixture(identity: i + 1));
    final rows = [
      for (var i = 0; i < fonts.length; i++)
        {
          ...fonts[i].entry,
          'name': '样例$i',
          'designLanguage': ['zh', 'ja', 'en', 'other'][i],
        },
    ];
    service.dynamicRuntime = DynamicFontRuntime(
      runtime: runtime,
      window: service.window,
      elapsed: () => Duration.zero,
      cancel: (_) {},
      read: (_, _, _, {etag}) async => TextFontResponse(
        200,
        fonts.first.envelope(fonts.first.page(items: rows)),
      ),
    );
    await service.dynamicRuntime!.catalog.refresh();
  });
  tearDown(() async {
    service.dispose();
    runtime.dispose();
    await directory.delete(recursive: true);
  });
  Widget screen({String? selectedFont}) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: EditorDynamicFontList(
        service: service,
        runtime: runtime,
        writeEnabled: true,
        recent: const [],
        selectedFont: selectedFont,
      ),
    ),
  );
  testWidgets('动态目录按中日英其他分组，预览只使用PNG', (tester) async {
    await tester.binding.setSurfaceSize(const Size(700, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    for (final label in ['中文', '日文', '英文', '其他']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(EditorFontSpecimen), findsOneWidget);
    expect(service.attempts.keys, [fonts.first.id]);
    for (final language in ['ja', 'en', 'other']) {
      await tester.tap(find.byKey(Key('editor-font-language-$language')));
      await tester.pumpAndSettle();
      expect(find.byType(EditorFontSpecimen), findsOneWidget);
    }
    expect(runtime.ledger.attemptedCount, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(service.cancelled.length, 4);
  });
  testWidgets('初始优先当前日文字体，筛选固定且选中态明确', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(screen(selectedFont: fonts[1].id));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>))
          .selected,
      {'ja'},
    );
    expect(
      tester
          .widget<Semantics>(find.byKey(Key('editor-font-${fonts[1].id}')))
          .properties
          .selected,
      isTrue,
    );
    expect(find.byKey(Key('editor-font-${fonts.first.id}')), findsNothing);
    expect(find.byKey(const Key('editor-font-close')), findsOneWidget);
    expect(find.byKey(const Key('editor-font-default')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('首次样张失败后同SHA自动重试，离屏销毁取消后不再重试', (tester) async {
    service.failFirst = true;
    await tester.pumpWidget(screen());
    await tester.pump();
    expect(find.byType(EditorFontSpecimen), findsNothing);
    final id = fonts.first.id;
    final tile = find.byKey(Key('editor-font-$id'));
    final heightBefore = tester.getSize(tile).height;
    expect(service.attempts[id], 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(service.attempts[id], 2);
    expect(find.byType(EditorFontSpecimen), findsWidgets);
    expect(tester.getSize(tile).height, heightBefore, reason: '样张加载前后行高不跳动');
    await tester.pumpWidget(const SizedBox.shrink());
    final attempts = Map.of(service.attempts);
    await tester.pump(const Duration(minutes: 2));
    expect(service.attempts, attempts);
    expect(service.cancelled, isNotEmpty);
  });
}
