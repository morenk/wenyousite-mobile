import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_font_panel.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    testWidgets('320宽两倍字号四分类可操作，迟到语言只跟随未手选的面板 $dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var language = 'zh';
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return EditorFontPanel(
                  initialLanguage: language,
                  hasOther: true,
                  defaultSelected: false,
                  writeEnabled: true,
                  body: (context, selected) => Text('内容 $selected'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Set<String> selected() => tester
          .widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>))
          .selected;
      expect(selected(), {'zh'});
      update(() => language = 'ja');
      await tester.pumpAndSettle();
      expect(selected(), {'ja'});
      await tester.tap(find.byKey(const Key('editor-font-language-en')));
      update(() => language = 'other');
      await tester.pumpAndSettle();
      expect(selected(), {'en'}, reason: '目录刷新不覆盖用户选择');
      await tester.tap(find.byKey(const Key('editor-font-language-other')));
      await tester.pumpAndSettle();
      expect(selected(), {'other'});
      expect(find.text('内容 other'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('editor-font-close'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
