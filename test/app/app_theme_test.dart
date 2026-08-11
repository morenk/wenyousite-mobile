import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

void main() {
  test('移动主题完整映射 Foundation v1.2.1 核心 Token', () {
    const tokens = WenyouThemeTokens.light;

    expect(WenyouFoundationVersion.value, '1.2.1');
    expect(WenyouCollectionContract.fillAvailableWidth, isTrue);
    expect(WenyouCollectionContract.contentSizedExceptions, contains('badge'));
    expect(tokens.brand, WenyouFoundationPalette.primary);
    expect(tokens.onBrand, WenyouFoundationPalette.onPrimary);
    expect(tokens.background, WenyouFoundationPalette.background);
    expect(tokens.panel, WenyouFoundationPalette.surface);
    expect(tokens.softPanel, WenyouFoundationPalette.muted);
    expect(tokens.border, WenyouFoundationPalette.border);
    expect(tokens.text, WenyouFoundationPalette.foreground);
    expect(tokens.mutedText, WenyouFoundationPalette.mutedForeground);
    expect(tokens.accentedBackground, WenyouFoundationPalette.accent);
    expect(tokens.focus, WenyouFoundationPalette.brandStrong);
    expect([
      tokens.space4,
      tokens.space8,
      tokens.space12,
      tokens.space16,
      tokens.space20,
      tokens.space24,
      tokens.space32,
    ], WenyouFoundationMobile.spacing);
    expect(
      [tokens.radius12, tokens.radius16, tokens.radius20],
      [
        WenyouFoundationMobile.radiusCompact,
        WenyouFoundationMobile.radiusControl,
        WenyouFoundationMobile.radiusPanel,
      ],
    );
    expect(
      tokens.minimumTouchTarget,
      WenyouFoundationMobile.minimumTouchTarget,
    );
    expect(tokens.feedbackDuration, WenyouFoundationMotion.fast);
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
    expect(
      _contrastRatio(tokens.panel, tokens.focus),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('主题注册 Foundation 色板、字体角色与最小触控高度', () {
    final theme = AppTheme.light;
    final tokens = theme.extension<WenyouThemeTokens>();
    final filledMinimum = theme.filledButtonTheme.style!.minimumSize!.resolve(
      {},
    );
    final textMinimum = theme.textButtonTheme.style!.minimumSize!.resolve({});

    expect(tokens, isNotNull);
    expect(theme.colorScheme.primary, WenyouThemeTokens.light.brand);
    expect(theme.colorScheme.onPrimary, WenyouThemeTokens.light.onBrand);
    expect(theme.colorScheme.secondary, WenyouFoundationPalette.secondary);
    expect(theme.colorScheme.error, WenyouFoundationPalette.destructive);
    expect(
      theme.textTheme.bodyLarge!.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      theme.textTheme.titleLarge!.fontFamily,
      WenyouFoundationTypography.display,
    );
    expect(
      theme.textTheme.labelSmall!.fontFamily,
      WenyouFoundationTypography.utility,
    );
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
