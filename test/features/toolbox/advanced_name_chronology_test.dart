import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_catalog.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/toolbox_test_fonts.dart';
import 'advanced_name_widget_test.dart' as helpers;

// 逐项核对已提交词库的起止年；预期不由待测排序实现生成。
const _chronologicalIds = {
  'cn': [
    'cn-wei-jin',
    'cn-tang-literati',
    'cn-ming-literati-period',
    'cn-qing-literati-period',
  ],
  'jp': [
    'jp-heian-court',
    'jp-sengoku-warrior',
    'jp-meiji-period',
    'jp-meiji-lineage',
    'jp-taisho-period',
    'jp-taisho-lineage',
  ],
  'gb': [
    'gb-anglo-norman',
    'gb-tudor-england-period',
    'gb-tudor-england-lineage',
    'gb-georgian-england-period',
    'gb-georgian-england-lineage',
    'gb-victorian-aristocracy',
  ],
  'fr': [
    'fr-renaissance-court',
    'fr-louis-xiv-period',
    'fr-louis-xiv-lineage',
    'fr-eighteenth-century-period',
    'fr-eighteenth-century-lineage',
    'fr-enlightenment-letters',
  ],
  'de': [
    'de-reformation',
    'de-weimar-classic-period',
    'de-weimar-classic-lineage',
    'de-romantic-circle',
    'de-prussia-nineteenth-period',
    'de-prussia-nineteenth-lineage',
  ],
  'ru': [
    'ru-muscovite-court',
    'ru-imperial-18-period',
    'ru-imperial-18-lineage',
    'ru-imperial-19-period',
    'ru-imperial-19-lineage',
    'ru-silver-age',
  ],
};

const _countries = {
  'cn': '中国',
  'jp': '日本',
  'gb': '英国',
  'fr': '法国',
  'de': '德国',
  'ru': '俄国',
};

void main() {
  setUpAll(loadDeterministicTestFonts);
  setUpAll(loadToolboxTestFonts);
  final catalog = AdvancedNameCatalog();
  for (final entry in _chronologicalIds.entries) {
    test('${entry.key} 按起始年、结束年排序，同期原序与默认保留', () {
      final original = catalog.forCountry(entry.key, 'historical');
      final originalIds = original.map((style) => style.id).toList();
      expect(
        catalog
            .chronologicalOptions(entry.key, 'historical')
            .map((style) => style.id),
        entry.value,
      );
      expect(
        catalog.forCountry(entry.key, 'historical').map((style) => style.id),
        originalIds,
      );
      expect(
        catalog
            .chronologicalOptions(entry.key, 'literary')
            .map((style) => style.id),
        catalog.forCountry(entry.key, 'literary').map((style) => style.id),
      );
    });

    testWidgets('${entry.key} 进阶选项显示历史顺序，默认和文学选项保持', (tester) async {
      await helpers.pumpNames(tester);
      if (entry.key != 'cn') {
        await helpers.selectNameOption(tester, '国家', _countries[entry.key]!);
      }
      await helpers.toggleAdvanced(tester);
      expect(helpers.controls(tester).styles.keys, entry.value);
      expect(
        helpers.controls(tester).styleId,
        catalog.forCountry(entry.key, 'historical').first.id,
      );
      await helpers.selectNameOption(tester, '类型', '文学创作');
      expect(
        helpers.controls(tester).styles.keys,
        catalog.forCountry(entry.key, 'literary').map((style) => style.id),
      );
    });
  }
  for (final dark in [false, true]) {
    for (final narrow in [false, true]) {
      final state = '${narrow ? '320_2x' : '400'}_${dark ? 'dark' : 'light'}';
      testWidgets('时间阶段选择抽屉 $state', (tester) async {
        await helpers.pumpNames(
          tester,
          dark: dark,
          narrow: narrow,
          theme: toolboxGoldenTheme(dark ? AppTheme.dark : AppTheme.light),
        );
        await helpers.toggleAdvanced(tester);
        await helpers.tapVisible(tester, find.text('风格').last);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Overlay).first,
          matchesGoldenFile('goldens/advanced_chronology_$state.png'),
        );
      });
    }
  }
}
