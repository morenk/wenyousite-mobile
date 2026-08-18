import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

/// Foundation semantic title roles.
///
/// Material's title slots are intentionally kept on the body family because
/// they are also consumed by lists, sheets, states, controls and usernames.
/// Display type must be requested through one of these structural roles.
extension WenyouSemanticTextStyles on TextTheme {
  TextStyle get wenyouPageTitle => _displayRole(headlineSmall!);

  TextStyle get wenyouSectionTitle => _displayRole(titleLarge!);

  TextStyle get wenyouSubsectionTitle => _displayRole(titleMedium!);

  TextStyle get wenyouDetailTitle => wenyouPageTitle;

  TextStyle get wenyouListTitle => titleLarge!.copyWith(
    fontFamily: WenyouFoundationTypography.body,
    fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
    fontWeight: FontWeight.w600,
  );

  TextStyle get wenyouOverlayTitle => wenyouListTitle;

  TextStyle get wenyouStatusTitle => titleMedium!.copyWith(
    fontFamily: WenyouFoundationTypography.body,
    fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
    fontWeight: FontWeight.w600,
  );
}

TextStyle _displayRole(TextStyle base) => base.copyWith(
  fontFamily: WenyouFoundationTypography.display,
  fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
  fontWeight: FontWeight.w500,
);
