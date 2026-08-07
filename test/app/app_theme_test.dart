import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

void main() {
  test('粉白视觉 Token 保持稳定', () {
    const tokens = WenyouThemeTokens.light;

    expect(tokens.brand, const Color(0xFFFB7299));
    expect(tokens.onBrand, const Color(0xFF35272C));
    expect(tokens.background, const Color(0xFFFFF7FA));
    expect(tokens.panel, const Color(0xFFFFFFFF));
    expect(tokens.softPanel, const Color(0xFFFFF0F5));
    expect(tokens.border, const Color(0xFFF2DDE5));
    expect(tokens.text, const Color(0xFF35272C));
    expect(tokens.mutedText, const Color(0xFF806A73));
    expect(
      [
        tokens.space4,
        tokens.space8,
        tokens.space12,
        tokens.space16,
        tokens.space20,
        tokens.space24,
        tokens.space32,
      ],
      [4, 8, 12, 16, 20, 24, 32],
    );
    expect([tokens.radius12, tokens.radius16, tokens.radius20], [12, 16, 20]);
    expect(tokens.minimumTouchTarget, 48);
  });

  test('品牌主按钮和正文颜色满足普通文字 AA 对比度', () {
    const tokens = WenyouThemeTokens.light;

    expect(
      _contrastRatio(tokens.brand, tokens.onBrand),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(tokens.panel, tokens.text),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(tokens.panel, tokens.mutedText),
      greaterThanOrEqualTo(4.5),
    );
    expect(_contrastRatio(tokens.brand, Colors.white), lessThan(4.5));
  });

  test('主题注册 Token 并固定按钮最小触控高度', () {
    final theme = AppTheme.light;
    final tokens = theme.extension<WenyouThemeTokens>();
    final filledMinimum = theme.filledButtonTheme.style!.minimumSize!.resolve(
      {},
    );
    final textMinimum = theme.textButtonTheme.style!.minimumSize!.resolve({});

    expect(tokens, isNotNull);
    expect(theme.colorScheme.primary, WenyouThemeTokens.light.brand);
    expect(theme.colorScheme.onPrimary, WenyouThemeTokens.light.onBrand);
    expect(filledMinimum!.height, 48);
    expect(textMinimum!.height, 48);
    expect(filledMinimum.width, 0);
  });
}

double _contrastRatio(Color first, Color second) {
  final lighter = first.computeLuminance() > second.computeLuminance()
      ? first
      : second;
  final darker = identical(lighter, first) ? second : first;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}
