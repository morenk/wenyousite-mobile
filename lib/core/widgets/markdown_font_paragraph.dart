import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_scope.dart';

/// 字体片段的内容先交给段落合并器，异步字体不再独占一个 Wrap 子项。
class MarkdownFontInline extends StatelessWidget {
  const MarkdownFontInline({
    required this.texts,
    required this.baseStyle,
    required this.buildText,
    super.key,
  });

  final Map<String, String> texts;
  final TextStyle baseStyle;
  final Text Function(BuildContext, TextFontRuntime?) buildText;

  @override
  Widget build(BuildContext context) =>
      TextFontScope(texts: texts, builder: buildText);
}

/// 上游只合并直接返回的 Text，自定义字体的异步 Scope 会把段落截断。
/// 在块布局前合并同段文字，再用一个 Scope 更新字体，保留换行、选区与折行。
List<Widget> mergeMarkdownFontInlines(
  List<Widget> children, {
  required WrapAlignment alignment,
  required Widget Function(Widget) adaptText,
}) {
  if (!children.any((child) => child is MarkdownFontInline)) return children;
  final result = <Widget>[];
  final run = <Widget>[];
  void flush() {
    if (run.isEmpty) return;
    final parts = List<Widget>.of(run);
    run.clear();
    if (!parts.any((child) => child is MarkdownFontInline)) {
      result.addAll(parts);
      return;
    }
    final texts = <String, String>{};
    for (final scope in parts.whereType<MarkdownFontInline>()) {
      for (final entry in scope.texts.entries) {
        texts.update(
          entry.key,
          (text) => '$text${entry.value}',
          ifAbsent: () => entry.value,
        );
      }
    }
    result.add(
      TextFontScope(
        texts: texts,
        builder: (context, runtime) {
          final resolved = [
            for (final part in parts)
              part is MarkdownFontInline
                  ? part.buildText(context, runtime)
                  : part as Text,
          ];
          final template = resolved.firstWhere(
            (text) => text.strutStyle != null,
            orElse: () => resolved.first,
          );
          final spans = [
            for (final text in resolved)
              TextSpan(
                style: text.style,
                children: [text.textSpan ?? TextSpan(text: text.data)],
              ),
          ];
          final base =
              template.strutStyle ??
              StrutStyle.fromTextStyle(
                parts.whereType<MarkdownFontInline>().first.baseStyle,
                forceStrutHeight: true,
              );
          return adaptText(
            Text.rich(
              TextSpan(children: spans),
              strutStyle: base,
              textAlign: switch (alignment) {
                WrapAlignment.center => TextAlign.center,
                WrapAlignment.end => TextAlign.end,
                WrapAlignment.start => TextAlign.start,
                _ => TextAlign.justify,
              },
              textScaler: template.textScaler,
              textWidthBasis: template.textWidthBasis,
              textHeightBehavior: template.textHeightBehavior,
            ),
          );
        },
      ),
    );
  }

  for (final child in children) {
    if (child is Text || child is MarkdownFontInline) {
      run.add(child);
    } else {
      flush();
      result.add(child);
    }
  }
  flush();
  return result;
}
