import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';

class OfflineRuntime extends TextFontRuntime {
  OfflineRuntime()
    : super(
        cache: TextFontCache(Directory.systemTemp),
        download: (_) async => throw StateError('offline'),
      );
  @override
  Future<void> ensure(String id, String text) async {}
  @override
  TextStyle style(String id, TextStyle base) =>
      base.copyWith(fontFamily: 'Roboto');
}

class OfflineService extends TextFontService {
  OfflineService() : super(WenyouApi(), observePlatform: false);
  final runtime = OfflineRuntime();
  @override
  Future<TextFontRuntime> load() async => runtime;
}

Future<void> pump(
  WidgetTester tester,
  List<Widget> children, {
  double scale = 1,
  bool dark = false,
  double width = 320,
  TextScaler? textScaler,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1200);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final service = OfflineService();
  addTearDown(service.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [textFontServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1200),
            textScaler: textScaler ?? TextScaler.linear(scale),
          ),
          child: Scaffold(
            body: RepaintBoundary(
              key: const Key('capture'),
              child: ColoredBox(
                color: dark ? Colors.black : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextStyle leafStyle(WidgetTester tester, String needle) {
  TextStyle? result;
  void visit(InlineSpan span, TextStyle inherited) {
    final effective = inherited.merge(span.style);
    if (span is TextSpan) {
      if (span.text == needle) result = effective;
      for (final child in span.children ?? <InlineSpan>[]) {
        visit(child, effective);
      }
    }
  }

  for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
    visit(text.text, const TextStyle());
  }
  return result!;
}
