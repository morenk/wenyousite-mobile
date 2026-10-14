import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';

/// 工具界面使用常规字重，不影响其他页面的文字层级。
class ToolTypography extends StatelessWidget {
  const ToolTypography({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    TextStyle regular(TextStyle style) =>
        style.copyWith(fontWeight: FontWeight.w400);
    final label = WidgetStatePropertyAll(regular(text.wenyouLabel));
    return Theme(
      data: theme.copyWith(
        textTheme: text.copyWith(
          displayLarge: regular(text.wenyouPageTitle),
          headlineMedium: regular(text.wenyouSectionTitle),
          headlineSmall: regular(text.wenyouSubsectionTitle),
          titleLarge: regular(text.wenyouListTitle),
          titleMedium: regular(text.wenyouRowTitle),
          titleSmall: regular(text.wenyouCompactTitle),
          bodyLarge: regular(text.wenyouBody),
          bodyMedium: regular(text.wenyouCompactBody),
          bodySmall: regular(text.wenyouCaption),
          labelLarge: regular(text.wenyouLabel),
          labelMedium: regular(text.wenyouCaptionEmphasis),
        ),
        appBarTheme: theme.appBarTheme.copyWith(
          titleTextStyle: regular(
            theme.appBarTheme.titleTextStyle ?? text.wenyouListTitle,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: (theme.filledButtonTheme.style ?? const ButtonStyle())
              .copyWith(textStyle: label),
        ),
        textButtonTheme: TextButtonThemeData(
          style: (theme.textButtonTheme.style ?? const ButtonStyle()).copyWith(
            textStyle: label,
          ),
        ),
      ),
      child: child,
    );
  }
}
