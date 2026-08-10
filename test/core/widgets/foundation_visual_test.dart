import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

void main() {
  testWidgets('Foundation 核心色板、圆角和间距保持稳定', (tester) async {
    const visualKey = Key('foundation-visual');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: visualKey,
              child: const _FoundationVisualFixture(),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/foundation_primitives.png'),
    );
  });
}

class _FoundationVisualFixture extends StatelessWidget {
  const _FoundationVisualFixture();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return ColoredBox(
      color: tokens.background,
      child: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: SizedBox(
          width: 208,
          height: 128,
          child: Column(
            children: [
              Row(
                children: [
                  for (final color in [
                    tokens.brand,
                    tokens.accentedBackground,
                    tokens.softPanel,
                    tokens.border,
                  ]) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(tokens.radius12),
                      ),
                    ),
                    if (color != tokens.border) SizedBox(width: tokens.space16),
                  ],
                ],
              ),
              SizedBox(height: tokens.space16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: tokens.panel,
                    border: Border.all(color: tokens.border),
                    borderRadius: BorderRadius.circular(tokens.radius20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.space12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 112,
                        height: tokens.space12,
                        decoration: BoxDecoration(
                          color: tokens.brand,
                          borderRadius: BorderRadius.circular(
                            tokens.radiusPill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
