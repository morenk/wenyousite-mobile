import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

@immutable
class WenyouThemeTokens extends ThemeExtension<WenyouThemeTokens> {
  const WenyouThemeTokens({
    required this.brandSurface,
    required this.brandForeground,
    required this.onBrandSurface,
    required this.background,
    required this.panel,
    required this.softPanel,
    required this.border,
    required this.text,
    required this.mutedText,
    required this.accentedBackground,
    required this.onAccentedBackground,
    required this.focus,
    required this.like,
    required this.likeSoft,
    required this.bookmark,
    required this.bookmarkSoft,
    required this.space4,
    required this.space8,
    required this.space12,
    required this.space16,
    required this.space20,
    required this.space24,
    required this.space32,
    required this.radius12,
    required this.radius16,
    required this.radius20,
    required this.radiusPill,
    required this.minimumTouchTarget,
    required this.compactHorizontalPadding,
    required this.regularHorizontalPadding,
    required this.regularHorizontalPaddingFrom,
    required this.pageContentMaxWidth,
    required this.wideContainerMaxWidth,
    required this.feedbackDuration,
  });

  static const light = WenyouThemeTokens(
    brandSurface: WenyouFoundationPalette.primary,
    brandForeground: WenyouFoundationPalette.brandStrong,
    onBrandSurface: WenyouFoundationPalette.onPrimary,
    background: WenyouFoundationPalette.background,
    panel: WenyouFoundationPalette.surface,
    softPanel: WenyouFoundationPalette.muted,
    border: WenyouFoundationPalette.border,
    text: WenyouFoundationPalette.foreground,
    mutedText: WenyouFoundationPalette.mutedForeground,
    accentedBackground: WenyouFoundationPalette.accent,
    onAccentedBackground: WenyouFoundationPalette.onAccent,
    focus: WenyouFoundationPalette.brandStrong,
    like: WenyouFoundationPalette.like,
    likeSoft: WenyouFoundationPalette.likeSoft,
    bookmark: WenyouFoundationPalette.bookmark,
    bookmarkSoft: WenyouFoundationPalette.bookmarkSoft,
    space4: WenyouFoundationMobile.space4,
    space8: WenyouFoundationMobile.space8,
    space12: WenyouFoundationMobile.space12,
    space16: WenyouFoundationMobile.space16,
    space20: WenyouFoundationMobile.space20,
    space24: WenyouFoundationMobile.space24,
    space32: WenyouFoundationMobile.space32,
    radius12: WenyouFoundationMobile.radiusCompact,
    radius16: WenyouFoundationMobile.radiusControl,
    radius20: WenyouFoundationMobile.radiusPanel,
    radiusPill: WenyouFoundationMobile.radiusPill,
    minimumTouchTarget: WenyouFoundationMobile.minimumTouchTarget,
    compactHorizontalPadding: WenyouFoundationMobile.compactHorizontalPadding,
    regularHorizontalPadding: WenyouFoundationMobile.regularHorizontalPadding,
    regularHorizontalPaddingFrom:
        WenyouFoundationMobile.regularHorizontalPaddingFrom,
    pageContentMaxWidth: WenyouFoundationMobile.pageContentMaxWidth,
    wideContainerMaxWidth: WenyouFoundationMobile.wideContainerMaxWidth,
    feedbackDuration: WenyouFoundationMotion.fast,
  );

  final Color brandSurface;
  final Color brandForeground;
  final Color onBrandSurface;
  final Color background;
  final Color panel;
  final Color softPanel;
  final Color border;
  final Color text;
  final Color mutedText;
  final Color accentedBackground;
  final Color onAccentedBackground;
  final Color focus;
  final Color like;
  final Color likeSoft;
  final Color bookmark;
  final Color bookmarkSoft;

  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space32;

  final double radius12;
  final double radius16;
  final double radius20;
  final double radiusPill;
  final double minimumTouchTarget;
  final double compactHorizontalPadding;
  final double regularHorizontalPadding;
  final double regularHorizontalPaddingFrom;
  final double pageContentMaxWidth;
  final double wideContainerMaxWidth;
  final Duration feedbackDuration;

  @override
  WenyouThemeTokens copyWith({
    Color? brandSurface,
    Color? brandForeground,
    Color? onBrandSurface,
    Color? background,
    Color? panel,
    Color? softPanel,
    Color? border,
    Color? text,
    Color? mutedText,
    Color? accentedBackground,
    Color? onAccentedBackground,
    Color? focus,
    Color? like,
    Color? likeSoft,
    Color? bookmark,
    Color? bookmarkSoft,
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space20,
    double? space24,
    double? space32,
    double? radius12,
    double? radius16,
    double? radius20,
    double? radiusPill,
    double? minimumTouchTarget,
    double? compactHorizontalPadding,
    double? regularHorizontalPadding,
    double? regularHorizontalPaddingFrom,
    double? pageContentMaxWidth,
    double? wideContainerMaxWidth,
    Duration? feedbackDuration,
  }) {
    return WenyouThemeTokens(
      brandSurface: brandSurface ?? this.brandSurface,
      brandForeground: brandForeground ?? this.brandForeground,
      onBrandSurface: onBrandSurface ?? this.onBrandSurface,
      background: background ?? this.background,
      panel: panel ?? this.panel,
      softPanel: softPanel ?? this.softPanel,
      border: border ?? this.border,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      accentedBackground: accentedBackground ?? this.accentedBackground,
      onAccentedBackground: onAccentedBackground ?? this.onAccentedBackground,
      focus: focus ?? this.focus,
      like: like ?? this.like,
      likeSoft: likeSoft ?? this.likeSoft,
      bookmark: bookmark ?? this.bookmark,
      bookmarkSoft: bookmarkSoft ?? this.bookmarkSoft,
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space20: space20 ?? this.space20,
      space24: space24 ?? this.space24,
      space32: space32 ?? this.space32,
      radius12: radius12 ?? this.radius12,
      radius16: radius16 ?? this.radius16,
      radius20: radius20 ?? this.radius20,
      radiusPill: radiusPill ?? this.radiusPill,
      minimumTouchTarget: minimumTouchTarget ?? this.minimumTouchTarget,
      compactHorizontalPadding:
          compactHorizontalPadding ?? this.compactHorizontalPadding,
      regularHorizontalPadding:
          regularHorizontalPadding ?? this.regularHorizontalPadding,
      regularHorizontalPaddingFrom:
          regularHorizontalPaddingFrom ?? this.regularHorizontalPaddingFrom,
      pageContentMaxWidth: pageContentMaxWidth ?? this.pageContentMaxWidth,
      wideContainerMaxWidth:
          wideContainerMaxWidth ?? this.wideContainerMaxWidth,
      feedbackDuration: feedbackDuration ?? this.feedbackDuration,
    );
  }

  @override
  WenyouThemeTokens lerp(covariant WenyouThemeTokens? other, double t) {
    if (other == null) return this;
    return WenyouThemeTokens(
      brandSurface: Color.lerp(brandSurface, other.brandSurface, t)!,
      brandForeground: Color.lerp(brandForeground, other.brandForeground, t)!,
      onBrandSurface: Color.lerp(onBrandSurface, other.onBrandSurface, t)!,
      background: Color.lerp(background, other.background, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      softPanel: Color.lerp(softPanel, other.softPanel, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accentedBackground: Color.lerp(
        accentedBackground,
        other.accentedBackground,
        t,
      )!,
      onAccentedBackground: Color.lerp(
        onAccentedBackground,
        other.onAccentedBackground,
        t,
      )!,
      focus: Color.lerp(focus, other.focus, t)!,
      like: Color.lerp(like, other.like, t)!,
      likeSoft: Color.lerp(likeSoft, other.likeSoft, t)!,
      bookmark: Color.lerp(bookmark, other.bookmark, t)!,
      bookmarkSoft: Color.lerp(bookmarkSoft, other.bookmarkSoft, t)!,
      space4: _lerpDouble(space4, other.space4, t),
      space8: _lerpDouble(space8, other.space8, t),
      space12: _lerpDouble(space12, other.space12, t),
      space16: _lerpDouble(space16, other.space16, t),
      space20: _lerpDouble(space20, other.space20, t),
      space24: _lerpDouble(space24, other.space24, t),
      space32: _lerpDouble(space32, other.space32, t),
      radius12: _lerpDouble(radius12, other.radius12, t),
      radius16: _lerpDouble(radius16, other.radius16, t),
      radius20: _lerpDouble(radius20, other.radius20, t),
      radiusPill: _lerpDouble(radiusPill, other.radiusPill, t),
      minimumTouchTarget: _lerpDouble(
        minimumTouchTarget,
        other.minimumTouchTarget,
        t,
      ),
      compactHorizontalPadding: _lerpDouble(
        compactHorizontalPadding,
        other.compactHorizontalPadding,
        t,
      ),
      regularHorizontalPadding: _lerpDouble(
        regularHorizontalPadding,
        other.regularHorizontalPadding,
        t,
      ),
      regularHorizontalPaddingFrom: _lerpDouble(
        regularHorizontalPaddingFrom,
        other.regularHorizontalPaddingFrom,
        t,
      ),
      pageContentMaxWidth: _lerpDouble(
        pageContentMaxWidth,
        other.pageContentMaxWidth,
        t,
      ),
      wideContainerMaxWidth: _lerpDouble(
        wideContainerMaxWidth,
        other.wideContainerMaxWidth,
        t,
      ),
      feedbackDuration: t < 0.5 ? feedbackDuration : other.feedbackDuration,
    );
  }
}

extension WenyouThemeContext on BuildContext {
  WenyouThemeTokens get wenyouTokens =>
      Theme.of(this).extension<WenyouThemeTokens>() ?? WenyouThemeTokens.light;
}

double _lerpDouble(double begin, double end, double t) {
  return begin + (end - begin) * t;
}
