import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

void main() {
  testWidgets('设置界面保留语义字阶并统一使用 Foundation 正文字体', (tester) async {
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
      base.textTheme.wenyouPageTitle.fontFamily,
      WenyouFoundationTypography.display,
    );
    expect(
      scoped.textTheme.wenyouPageTitle.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      scoped.textTheme.wenyouSectionTitle.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      scoped.textTheme.wenyouSubsectionTitle.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      scoped.textTheme.wenyouPageTitle.fontSize,
      base.textTheme.wenyouPageTitle.fontSize,
    );
    expect(
      scoped.textTheme.wenyouSectionTitle.height,
      base.textTheme.wenyouSectionTitle.height,
    );
    expect(
      scoped.textTheme.wenyouSectionTitle.fontWeight,
      base.textTheme.wenyouSectionTitle.fontWeight,
    );
    expect(
      scoped.appBarTheme.titleTextStyle?.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      scoped.dialogTheme.titleTextStyle?.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      scoped.textTheme.wenyouUtilityCaption.fontFamily,
      WenyouFoundationTypography.utility,
    );
  });
}
