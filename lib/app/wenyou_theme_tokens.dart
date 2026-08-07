import 'package:flutter/material.dart';

@immutable
class WenyouThemeTokens extends ThemeExtension<WenyouThemeTokens> {
  const WenyouThemeTokens({
    required this.brand,
    required this.onBrand,
    required this.background,
    required this.panel,
    required this.softPanel,
    required this.border,
    required this.text,
    required this.mutedText,
    required this.accentedBackground,
    required this.focus,
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
    required this.feedbackDuration,
  });

  static const light = WenyouThemeTokens(
    brand: Color(0xFFFB7299),
    onBrand: Color(0xFF35272C),
    background: Color(0xFFFFF7FA),
    panel: Color(0xFFFFFFFF),
    softPanel: Color(0xFFFFF0F5),
    border: Color(0xFFF2DDE5),
    text: Color(0xFF35272C),
    mutedText: Color(0xFF806A73),
    accentedBackground: Color(0x26FB7299),
    focus: Color(0x4DFB7299),
    space4: 4,
    space8: 8,
    space12: 12,
    space16: 16,
    space20: 20,
    space24: 24,
    space32: 32,
    radius12: 12,
    radius16: 16,
    radius20: 20,
    radiusPill: 999,
    minimumTouchTarget: 48,
    feedbackDuration: Duration(milliseconds: 120),
  );

  final Color brand;
  final Color onBrand;
  final Color background;
  final Color panel;
  final Color softPanel;
  final Color border;
  final Color text;
  final Color mutedText;
  final Color accentedBackground;
  final Color focus;

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
  final Duration feedbackDuration;

  @override
  WenyouThemeTokens copyWith({
    Color? brand,
    Color? onBrand,
    Color? background,
    Color? panel,
    Color? softPanel,
    Color? border,
    Color? text,
    Color? mutedText,
    Color? accentedBackground,
    Color? focus,
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
    Duration? feedbackDuration,
  }) {
    return WenyouThemeTokens(
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      background: background ?? this.background,
      panel: panel ?? this.panel,
      softPanel: softPanel ?? this.softPanel,
      border: border ?? this.border,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      accentedBackground: accentedBackground ?? this.accentedBackground,
      focus: focus ?? this.focus,
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
      feedbackDuration: feedbackDuration ?? this.feedbackDuration,
    );
  }

  @override
  WenyouThemeTokens lerp(covariant WenyouThemeTokens? other, double t) {
    if (other == null) return this;
    return WenyouThemeTokens(
      brand: Color.lerp(brand, other.brand, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
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
      focus: Color.lerp(focus, other.focus, t)!,
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
