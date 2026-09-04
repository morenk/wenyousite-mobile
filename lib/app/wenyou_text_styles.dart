import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

/// Foundation semantic typography roles.
///
/// Presentation code consumes these roles instead of Material slot names so
/// that hierarchy survives Flutter theme-default changes. Size, line height
/// and family stay centralized here; callers may still adjust state color or
/// a local emphasis weight when the component contract requires it.
extension WenyouSemanticTextStyles on TextTheme {
  TextStyle get wenyouPageTitle => displayLarge!;

  TextStyle get wenyouSectionTitle => headlineMedium!;

  TextStyle get wenyouSubsectionTitle => headlineSmall!;

  TextStyle get wenyouDetailTitle => wenyouPageTitle;

  TextStyle get wenyouListTitle => titleLarge!;

  TextStyle get wenyouOverlayTitle => wenyouListTitle;

  TextStyle get wenyouStatusTitle => titleMedium!;

  TextStyle get wenyouRowTitle => wenyouStatusTitle;

  TextStyle get wenyouCompactTitle => titleSmall!;

  TextStyle get wenyouBody => bodyLarge!;

  TextStyle get wenyouCompactBody => bodyMedium!;

  TextStyle get wenyouCaption => bodySmall!;

  TextStyle get wenyouCaptionEmphasis => labelMedium!;

  TextStyle get wenyouLabel => labelLarge!;

  TextStyle get wenyouReadingBody => bodyLarge!.copyWith(
    fontSize: _typeSize('reading'),
    height: _typeHeight('reading'),
    fontWeight: _typeWeight('reading'),
  );

  TextStyle get wenyouUtilityBody => _utilityRole(wenyouBody);

  TextStyle get wenyouUtilityCompactBody => _utilityRole(wenyouCompactBody);

  TextStyle get wenyouUtilityRowTitle => _utilityRole(wenyouRowTitle);

  TextStyle get wenyouUtilityCompactTitle => _utilityRole(wenyouCompactTitle);

  TextStyle get wenyouUtilityListTitle => _utilityRole(wenyouListTitle);

  TextStyle get wenyouUtilityCaption => _utilityRole(wenyouCaption);

  TextStyle get wenyouUtilityLabel => _utilityRole(wenyouLabel);

  TextStyle get wenyouMetricValue =>
      _utilityRole(wenyouPageTitle).copyWith(fontWeight: FontWeight.w700);
}

TextStyle wenyouFoundationTypeStyle(
  TextStyle base,
  String role, {
  String? fontFamily,
  FontWeight? fontWeight,
  Color? color,
}) {
  return base.copyWith(
    color: color,
    fontFamily: fontFamily ?? _typeFamily(role),
    fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
    fontSize: _typeSize(role),
    height: _typeHeight(role),
    fontWeight: fontWeight ?? _typeWeight(role),
  );
}

TextStyle _utilityRole(TextStyle base) => base.copyWith(
  fontFamily: WenyouFoundationTypography.utility,
  fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
  fontFeatures: const [FontFeature.tabularFigures()],
);

String _typeFamily(String role) {
  return switch (WenyouFoundationTypography.mobileFamilies[role]!) {
    'display' => WenyouFoundationTypography.display,
    'utility' => WenyouFoundationTypography.utility,
    _ => WenyouFoundationTypography.body,
  };
}

double _typeSize(String role) => WenyouFoundationTypography.mobileSizes[role]!;

double _typeHeight(String role) =>
    WenyouFoundationTypography.mobileLineHeights[role]!;

FontWeight _typeWeight(String role) {
  final weight = WenyouFoundationTypography.mobileWeights[role]!;
  return FontWeight.values[(weight ~/ 100) - 1];
}
