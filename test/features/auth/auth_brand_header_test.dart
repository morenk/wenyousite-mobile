import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/auth/presentation/auth_brand_header.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('认证页品牌头使用 48dp 装饰标识和可见名称', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: AuthBrandHeader())),
      ),
    );
    await tester.pump();

    final mark = tester.widget<WenyouBrandMark>(
      find.byKey(const Key('auth-brand-mark')),
    );
    expect(mark.size, WenyouBrandContract.authMarkSize);
    expect(mark.semanticLabel, isNull);
    expect(find.text(WenyouBrandContract.name), findsOneWidget);
  });
}
