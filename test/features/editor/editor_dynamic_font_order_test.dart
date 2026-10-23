import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_sheet.dart';

import '../../core/text_fonts/dynamic_font_fixture.dart';

class _Service extends TextFontService {
  _Service(this.pickerRuntime) : super(WenyouApi(), observePlatform: false);
  final TextFontRuntime pickerRuntime;
  final previews = <String>[];
  @override
  Future<TextFontRuntime> openPicker() async => pickerRuntime;
  @override
  Future<Uint8List?> specimen(
    FontCatalogEntryDto entry, {
    Object? owner,
    bool Function()? isActive,
  }) async {
    previews.add(entry.versionId);
    return base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aT1sAAAAASUVORK5CYII=',
    );
  }
}

void main() {
  late Directory directory;
  late TextFontRuntime runtime;
  late _Service service;
  late List<DynamicFontFixture> fonts;
  late List<List<Map<String, Object?>>> pages;
  late int revision;
  late List<String> loadedRecent;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('font-catalog-order-');
    runtime = TextFontRuntime(
      cache: TextFontCache(directory),
      download: (_) async => throw StateError('目录排序不得下载字体'),
      register: (_, _) async => throw StateError('目录排序不得注册字体'),
    );
    service = _Service(runtime)..dynamicEnabled = true;
    fonts = List.generate(5, (i) => DynamicFontFixture(identity: i + 1));
    revision = 1;
    loadedRecent = [];
    Map<String, Object?> row(int index, int order, String language) => {
      ...fonts[index].entry,
      'sortOrder': order,
      'name': ['A', 'B', 'Z', '日文', 'English'][index],
      'designLanguage': language,
    };
    // 受控输入按正式协议 sortOrder/familyId 返回，名称与 ID 顺序相反。
    // 页面不足 limit 也必须合并；期望由响应顺序给出，不由 UI 比较器推导。
    pages = [
      [row(2, 0, 'zh'), row(3, 1, 'ja')],
      [row(1, 10, 'zh'), row(4, 11, 'en'), row(0, 20, 'zh')],
    ];
    SharedPreferences.setMockInitialValues({
      'editor.textFont.v1.order-test': [fonts[0].id, fonts[1].id],
    });
    service.dynamicRuntime = DynamicFontRuntime(
      runtime: runtime,
      window: service.window,
      elapsed: () => Duration.zero,
      cancel: (_) {},
      read: (path, _, _, {etag}) async {
        final index = Uri.parse(path).queryParameters['cursor'] == null ? 0 : 1;
        return TextFontResponse(
          200,
          fonts.first.envelope(
            fonts.first.page(
              revision: revision,
              items: pages[index],
              cursor: index + 1 < pages.length ? 'next' : null,
            ),
          ),
        );
      },
    );
    await service.dynamicRuntime!.catalog.refresh();
  });
  tearDown(() async {
    service.dispose();
    runtime.dispose();
    await directory.delete(recursive: true);
  });

  Future<void> open(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(700, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EditorTextFontSheet(
            service: service,
            account: 'order-test',
            writeEnabled: true,
            selectedFont: (font: fonts[0].id, mixed: false),
            onRecentLoaded: (value) => loadedRecent = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> visibleOrder(WidgetTester tester) => tester
      .widgetList<Semantics>(find.byType(Semantics))
      .map((widget) => widget.key)
      .whereType<ValueKey<String>>()
      .map((key) => key.value)
      .where((key) => key.startsWith('editor-font-tfv_'))
      .map((key) => key.substring('editor-font-'.length))
      .toList();

  testWidgets('跨页目录按服务端顺序分组，最近使用和已选项均不置顶', (tester) async {
    await open(tester);
    expect(loadedRecent, [fonts[0].id, fonts[1].id]);
    expect(visibleOrder(tester), [fonts[2].id, fonts[1].id, fonts[0].id]);
    expect(
      tester
          .widget<Semantics>(find.byKey(Key('editor-font-${fonts[0].id}')))
          .properties
          .selected,
      isTrue,
    );
    for (final (language, index) in [('ja', 3), ('en', 4)]) {
      await tester.tap(find.byKey(Key('editor-font-language-$language')));
      await tester.pumpAndSettle();
      expect(visibleOrder(tester), [fonts[index].id]);
    }
    expect(runtime.ledger.attemptedCount, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('同版本ID仅目录revision和顺序变化，原面板更新且保留选中标记', (tester) async {
    await open(tester);
    final sheet = tester.state(find.byType(EditorTextFontSheet));
    revision = 2;
    final oldRows = pages.expand((page) => page).toList();
    pages = [
      [
        for (final index in [1, 2, 0, 3, 4])
          {
            ...oldRows.singleWhere(
              (row) => row['versionId'] == fonts[index].id,
            ),
            'sortOrder': [1, 2, 0, 3, 4].indexOf(index),
          },
      ],
    ];
    await tester.runAsync(
      () => service.dynamicRuntime!.catalog.refresh(force: true),
    );
    await tester.pumpAndSettle();
    expect(service.dynamicRuntime!.catalog.revision, 2);
    expect(tester.state(find.byType(EditorTextFontSheet)), same(sheet));
    expect(visibleOrder(tester), [fonts[1].id, fonts[2].id, fonts[0].id]);
    expect(
      tester
          .widget<Semantics>(find.byKey(Key('editor-font-${fonts[0].id}')))
          .properties
          .selected,
      isTrue,
    );
    expect(runtime.ledger.attemptedCount, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('正式orderCases双语言重排更新原会话，手选语言不被覆盖', (tester) async {
    final fixture =
        jsonDecode(
              File(
                'contracts/admin-font-management-v1-fixtures.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final orderCase = (fixture['orderCases'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((row) => row['id'] == 'two-language-atomic');
    final input = orderCase['input'] as Map<String, dynamic>;
    final groups = (input['groups'] as List).cast<Map<String, dynamic>>();
    List<String> expectedVersions(Map<String, dynamic> group) =>
        (group['items'] as List)
            .map(
              (item) =>
                  (item['familyId'] as String).replaceFirst('tff_', 'tfv_'),
            )
            .toList();
    List<Map<String, Object?>> rows({required bool before}) =>
        [
          for (final group in groups)
            for (final (order, id)
                in (before
                        ? expectedVersions(group).reversed.toList()
                        : expectedVersions(group))
                    .indexed)
              {
                ...fonts.singleWhere((font) => font.id == id).entry,
                'designLanguage': group['language'],
                'sortOrder': order,
              },
        ]..sort((a, b) {
          // 仅构造公开目录的跨语言分页顺序；各组期望直接来自共享 fixture。
          final order = (a['sortOrder'] as int).compareTo(
            b['sortOrder'] as int,
          );
          return order != 0
              ? order
              : (a['familyId'] as String).compareTo(b['familyId'] as String);
        });
    revision = input['expectedCatalogRevision'] as int;
    pages = [rows(before: true)];
    await tester.runAsync(
      () => service.dynamicRuntime!.catalog.refresh(force: true),
    );
    await open(tester);
    final sheet = tester.state(find.byType(EditorTextFontSheet));
    await tester.tap(find.byKey(const Key('editor-font-language-ja')));
    await tester.pumpAndSettle();
    final japanese = groups.singleWhere((group) => group['language'] == 'ja');
    expect(visibleOrder(tester), expectedVersions(japanese).reversed.toList());

    revision += orderCase['expectedCatalogIncrements'] as int;
    pages = [rows(before: false)];
    await tester.runAsync(
      () => service.dynamicRuntime!.catalog.refresh(force: true),
    );
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(EditorTextFontSheet)), same(sheet));
    expect(
      tester
          .widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>))
          .selected,
      {'ja'},
    );
    expect(visibleOrder(tester), expectedVersions(japanese));
    for (final group in groups) {
      await tester.tap(
        find.byKey(Key('editor-font-language-${group['language']}')),
      );
      await tester.pumpAndSettle();
      expect(visibleOrder(tester), expectedVersions(group));
    }
    expect(runtime.ledger.attemptedCount, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
