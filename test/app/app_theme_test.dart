import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';

void main() {
  test('移动主题完整映射 Foundation 核心 Token', () {
    const tokens = WenyouThemeTokens.light;

    expect(WenyouFoundationVersion.value, '6.4.0');
    expect(WenyouFoundationVersion.schema, 2);
    expect(WenyouEditorContract.surfaces, [
      'page',
      'expandableSheet',
      'inline',
    ]);
    expect(
      WenyouEditorContract.keyboardToolbarPlacement,
      'above-keyboard-dock',
    );
    expect(WenyouEditorContract.morePresentation, 'inline');
    expect(WenyouCollectionContract.fillAvailableWidth, isTrue);
    expect(WenyouCollectionContract.contentSizedExceptions, contains('badge'));
    expect(
      WenyouCollectionContract.mobileDomainLayoutExceptions['moments-feed'],
      'two-column-waterfall',
    );
    expect(
      WenyouEditorContract.mobileRenderingExceptions,
      contains('inline-code-padding-uses-flutter-quill-native-bounds'),
    );
    expect(WenyouControlContract.minimumTarget, 48);
    expect(WenyouLevelContract.resolve(4)?.id, 'rose');
    expect(tokens.brandSurface, WenyouFoundationPalette.primary);
    expect(tokens.brandForeground, WenyouFoundationPalette.brandStrong);
    expect(tokens.onBrandSurface, WenyouFoundationPalette.onPrimary);
    expect(tokens.background, WenyouFoundationPalette.background);
    expect(tokens.panel, WenyouFoundationPalette.surface);
    expect(tokens.softPanel, WenyouFoundationPalette.muted);
    expect(tokens.border, WenyouFoundationPalette.border);
    expect(tokens.text, WenyouFoundationPalette.foreground);
    expect(tokens.mutedText, WenyouFoundationPalette.mutedForeground);
    expect(tokens.accentedBackground, WenyouFoundationPalette.accent);
    expect(tokens.onAccentedBackground, WenyouFoundationPalette.onAccent);
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
    expect(
      tokens.compactHorizontalPadding,
      WenyouFoundationMobile.compactHorizontalPadding,
    );
    expect(
      tokens.regularHorizontalPadding,
      WenyouFoundationMobile.regularHorizontalPadding,
    );
    expect(
      tokens.regularHorizontalPaddingFrom,
      WenyouFoundationMobile.regularHorizontalPaddingFrom,
    );
    expect(
      tokens.pageContentMaxWidth,
      WenyouFoundationMobile.pageContentMaxWidth,
    );
    expect(
      tokens.wideContainerMaxWidth,
      WenyouFoundationMobile.wideContainerMaxWidth,
    );
    expect(tokens.feedbackDuration, WenyouFoundationMotion.fast);
  });

  test('所有可用作文字或图标前景的语义色满足普通文字 AA 对比度', () {
    const tokens = WenyouThemeTokens.light;

    expect(
      _contrastRatio(tokens.brandSurface, tokens.onBrandSurface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(tokens.panel, tokens.brandForeground),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(tokens.accentedBackground, tokens.onAccentedBackground),
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
    final segmentedMinimum = theme.segmentedButtonTheme.style!.minimumSize!
        .resolve({});

    expect(tokens, isNotNull);
    expect(theme.colorScheme.primary, WenyouThemeTokens.light.brandForeground);
    expect(theme.colorScheme.onPrimary, WenyouThemeTokens.light.panel);
    expect(
      theme.colorScheme.primaryContainer,
      WenyouThemeTokens.light.brandSurface,
    );
    expect(
      theme.colorScheme.onPrimaryContainer,
      WenyouThemeTokens.light.onBrandSurface,
    );
    expect(theme.colorScheme.secondary, WenyouFoundationPalette.secondary);
    expect(theme.colorScheme.error, WenyouFoundationPalette.destructive);
    expect(
      theme.textTheme.bodyLarge!.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      theme.textTheme.titleLarge!.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      theme.textTheme.wenyouPageTitle.fontFamily,
      WenyouFoundationTypography.display,
    );
    expect(
      theme.textTheme.wenyouSectionTitle.fontFamily,
      WenyouFoundationTypography.display,
    );
    expect(
      theme.textTheme.wenyouListTitle.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      theme.textTheme.wenyouOverlayTitle.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      theme.textTheme.wenyouStatusTitle.fontFamily,
      WenyouFoundationTypography.body,
    );
    expect(
      theme.appBarTheme.titleTextStyle!.fontFamily,
      WenyouFoundationTypography.display,
    );
    expect(
      theme.textTheme.labelSmall!.fontFamily,
      WenyouFoundationTypography.utility,
    );
    expect(filledMinimum!.height, 48);
    expect(textMinimum!.height, 48);
    expect(segmentedMinimum!.height, 48);
    expect(filledMinimum.width, 0);
    expect(
      theme.chipTheme.selectedColor,
      WenyouThemeTokens.light.accentedBackground,
    );
    expect(
      theme.listTileTheme.minVerticalPadding,
      WenyouThemeTokens.light.space12,
    );
    expect(
      theme.badgeTheme.backgroundColor,
      WenyouThemeTokens.light.brandForeground,
    );
    expect(
      theme.dialogTheme.elevation,
      WenyouOverlayContract.elevation['popup'],
    );
    expect(
      theme.bottomSheetTheme.modalElevation,
      WenyouOverlayContract.elevation['floating'],
    );
    expect(
      theme.popupMenuTheme.elevation,
      WenyouOverlayContract.elevation['popup'],
    );
    final androidTransition =
        theme.pageTransitionsTheme.builders[TargetPlatform.android];
    expect(androidTransition, isA<WenyouPageTransitionsBuilder>());
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
