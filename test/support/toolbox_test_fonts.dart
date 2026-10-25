import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 仅用于离线 Golden 的数学字母/装饰，不代表 Android 字体覆盖。
Future<void> loadToolboxTestFonts() async {
  for (final name in [
    'Math',
    'Symbols2',
    'ToolboxText',
    'Latin',
    'Oriya',
    'Javanese',
    'Yi',
    'Canadian',
    'Hebrew',
    'Thai',
    'Georgian',
    'Cherokee',
    'Lisu',
  ]) {
    final bytes = await File(
      'test/support/fonts/WenyouGolden$name.ttf',
    ).readAsBytes();
    await (FontLoader(
      'WenyouGolden$name',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}

ThemeData toolboxGoldenTheme(ThemeData theme) => theme.copyWith(
  textTheme: theme.textTheme.apply(
    fontFamilyFallback: const [
      'WenyouGoldenToolboxText',
      'WenyouGoldenMath',
      'WenyouGoldenSymbols2',
      'WenyouGoldenLatin',
      'WenyouGoldenOriya',
      'WenyouGoldenJavanese',
      'WenyouGoldenYi',
      'WenyouGoldenCanadian',
      'WenyouGoldenHebrew',
      'WenyouGoldenThai',
      'WenyouGoldenGeorgian',
      'WenyouGoldenCherokee',
      'WenyouGoldenLisu',
    ],
  ),
);
