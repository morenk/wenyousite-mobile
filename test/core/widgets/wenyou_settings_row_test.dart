import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_row.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final dark in [false, true]) {
    for (final width in [320.0, 360.0, 600.0]) {
      testWidgets('设置长值在 $width 宽两倍字号 ${dark ? '黑夜' : '浅色'} 完整换行', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1000);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        var taps = 0;
        const value = '角色扮演与共同创作的长标签、综合讨论';
        await tester.pumpWidget(
          _app(
            dark: dark,
            scale: 2,
            child: WenyouSettingsLink(
              title: '主题标签',
              value: value,
              onTap: () => taps++,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final text = tester.widget<Text>(find.text(value));
        expect(text.maxLines, isNull);
        expect(text.overflow, isNot(TextOverflow.ellipsis));
        expect(tester.getSize(find.text(value)).height, greaterThan(48));
        expect(
          tester.getSize(find.byType(WenyouSettingsLink)).height,
          greaterThan(56),
        );
        await tester.tap(find.text(value));
        expect(taps, 1);
      });
    }
  }

  testWidgets('只读保留正常文字且无箭头，禁用不触发传入操作', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        child: Column(
          children: [
            const WenyouSettingsLink(
              title: '可见范围',
              value: '公开 · 仅楼主可改',
              onTap: null,
            ),
            WenyouSettingsLink(
              title: '所在分区',
              value: '角色扮演',
              enabled: false,
              onTap: () => taps++,
            ),
          ],
        ),
      ),
    );
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles.first.enabled, isTrue);
    expect(tiles.last.enabled, isFalse);
    expect(tiles.every((tile) => tile.trailing == null), isTrue);
    expect(tiles.every((tile) => tile.onTap == null), isTrue);
    await tester.tap(find.text('所在分区'));
    await tester.tap(find.text('可见范围'));
    expect(taps, 0);
  });

  testWidgets('整行选择提供选中和禁用语义，点击空白处也能选择', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      _app(
        child: Column(
          children: [
            WenyouSelectionTile(
              key: const Key('active'),
              label: '亮色',
              selected: true,
              onTap: () => taps++,
            ),
            const WenyouSelectionTile(
              key: Key('disabled'),
              label: '旧分区（已停用）',
              selected: false,
              onTap: null,
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byKey(const Key('active'))),
      matchesSemantics(
        label: '亮色',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byKey(const Key('disabled'))),
      matchesSemantics(
        label: '旧分区（已停用）',
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
      ),
    );
    final active = find.byKey(const Key('active'));
    expect(tester.getSize(active).height, greaterThanOrEqualTo(48));
    await tester.tapAt(tester.getTopLeft(active) + const Offset(250, 24));
    await tester.tap(find.text('旧分区（已停用）'));
    expect(taps, 1);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is WenyouIcon &&
            widget.semanticId == WenyouIconIds.actionConfirm,
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}

Widget _app({required Widget child, bool dark = false, double scale = 1}) =>
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
