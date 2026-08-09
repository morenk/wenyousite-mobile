import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

abstract final class AppTheme {
  static const primary = WenyouFoundationPalette.primary;
  static const background = WenyouFoundationPalette.background;

  static ThemeData get light {
    const tokens = WenyouThemeTokens.light;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: tokens.brand,
          brightness: Brightness.light,
          surface: tokens.panel,
        ).copyWith(
          primary: tokens.brand,
          onPrimary: tokens.onBrand,
          primaryContainer: tokens.accentedBackground,
          onPrimaryContainer: WenyouFoundationPalette.onAccent,
          secondary: WenyouFoundationPalette.secondary,
          onSecondary: WenyouFoundationPalette.onSecondary,
          secondaryContainer: WenyouFoundationPalette.infoSoft,
          onSecondaryContainer: WenyouFoundationPalette.info,
          surface: tokens.panel,
          onSurface: tokens.text,
          surfaceContainerLowest: tokens.panel,
          surfaceContainer: tokens.softPanel,
          onSurfaceVariant: tokens.mutedText,
          outline: tokens.border,
          outlineVariant: tokens.border,
          error: WenyouFoundationPalette.destructive,
          onError: WenyouFoundationPalette.onDestructive,
          errorContainer: WenyouFoundationPalette.destructiveSoft,
          onErrorContainer: WenyouFoundationPalette.destructive,
        );
    final baseTextTheme = ThemeData.light().textTheme.apply(
      fontFamily: WenyouFoundationTypography.body,
      fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
      bodyColor: tokens.text,
      displayColor: tokens.text,
    );
    final textTheme = baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: WenyouFoundationTypography.display,
        fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: WenyouFoundationTypography.display,
        fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: WenyouFoundationTypography.display,
        fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.6),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.4,
        color: tokens.mutedText,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: WenyouFoundationTypography.utility,
        fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
    final rounded16 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius16),
    );
    final controlSize = Size(0, tokens.minimumTouchTarget);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: const [tokens],
      scaffoldBackgroundColor: tokens.background,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      focusColor: tokens.focus,
      hoverColor: tokens.accentedBackground,
      splashColor: tokens.accentedBackground,
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background.withValues(alpha: 0.94),
        foregroundColor: tokens.text,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: tokens.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius20),
          side: BorderSide(color: tokens.border),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.brand,
        foregroundColor: tokens.onBrand,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(controlSize),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(rounded16),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.border
                : tokens.brand,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.mutedText
                : tokens.onBrand,
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          animationDuration: tokens.feedbackDuration,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(controlSize),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(rounded16),
          side: WidgetStatePropertyAll(BorderSide(color: tokens.border)),
          foregroundColor: WidgetStatePropertyAll(tokens.text),
          animationDuration: tokens.feedbackDuration,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(controlSize),
          foregroundColor: WidgetStatePropertyAll(tokens.text),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          animationDuration: tokens.feedbackDuration,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size.square(tokens.minimumTouchTarget),
          ),
          foregroundColor: WidgetStatePropertyAll(tokens.text),
          animationDuration: tokens.feedbackDuration,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.panel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: tokens.mutedText),
        helperStyle: TextStyle(color: tokens.mutedText),
        prefixIconColor: tokens.mutedText,
        suffixIconColor: tokens.mutedText,
        border: _inputBorder(tokens.border, tokens.radius16),
        enabledBorder: _inputBorder(tokens.border, tokens.radius16),
        disabledBorder: _inputBorder(
          tokens.border.withValues(alpha: 0.72),
          tokens.radius16,
        ),
        focusedBorder: _inputBorder(tokens.focus, tokens.radius16, width: 2),
        errorBorder: _inputBorder(colorScheme.error, tokens.radius16),
        focusedErrorBorder: _inputBorder(
          colorScheme.error,
          tokens.radius16,
          width: 2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.panel,
        indicatorColor: tokens.accentedBackground,
        height: 68,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? tokens.text
                : tokens.mutedText,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? tokens.brand
                : tokens.mutedText,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.text,
        contentTextStyle: TextStyle(color: tokens.panel),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    Color color,
    double radius, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
