import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

void main() {
  testWidgets('设置与管理标题保持 body 语义的 600 字重并继承系统字体', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WenyouSettingsTypography(
          child: Scaffold(
            key: const Key('settings-scope-probe'),
            appBar: AppBar(title: const Text('设置')),
            body: const SizedBox(),
          ),
        ),
      ),
    );

    final scoped = Theme.of(
      tester.element(find.byKey(const Key('settings-scope-probe'))),
    );
    final base = AppTheme.light;
    expect(
      scoped.textTheme.wenyouPageTitle.fontFamily,
      base.textTheme.wenyouPageTitle.fontFamily,
    );
    expect(
      scoped.textTheme.wenyouSectionTitle.fontFamily,
      base.textTheme.wenyouSectionTitle.fontFamily,
    );
    expect(
      scoped.textTheme.wenyouSubsectionTitle.fontFamily,
      base.textTheme.wenyouSubsectionTitle.fontFamily,
    );
    expect(
      scoped.textTheme.wenyouPageTitle.fontSize,
      base.textTheme.wenyouPageTitle.fontSize,
    );
    expect(
      scoped.textTheme.wenyouSectionTitle.height,
      base.textTheme.wenyouSectionTitle.height,
    );
    expect(scoped.textTheme.wenyouPageTitle.fontWeight, FontWeight.w600);
    expect(scoped.textTheme.wenyouSectionTitle.fontWeight, FontWeight.w600);
    expect(scoped.textTheme.wenyouSubsectionTitle.fontWeight, FontWeight.w600);
    expect(
      scoped.appBarTheme.titleTextStyle?.fontFamily,
      base.appBarTheme.titleTextStyle?.fontFamily,
    );
    expect(scoped.appBarTheme.titleTextStyle?.fontWeight, FontWeight.w600);
    expect(
      scoped.dialogTheme.titleTextStyle?.fontFamily,
      base.dialogTheme.titleTextStyle?.fontFamily,
    );
    expect(
      scoped.textTheme.wenyouUtilityCaption.fontFamily,
      base.textTheme.wenyouUtilityCaption.fontFamily,
    );
    expect(
      scoped.textTheme.wenyouUtilityCaption.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}
