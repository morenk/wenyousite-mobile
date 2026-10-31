import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/text_fonts/text_font_scope.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';

class MarkdownTextColorBuilder extends MarkdownElementBuilder {
  MarkdownTextColorBuilder({
    required this.onLink,
    required this.registerRecognizer,
    this.enableTextFonts = false,
  });
  final ValueChanged<String> onLink;
  final ValueChanged<TapGestureRecognizer> registerRecognizer;
  final bool enableTextFonts;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final rgb = element.attributes['color'];
    final color = rgb == null
        ? null
        : Color(int.parse('FF${rgb.substring(1)}', radix: 16));
    final base = (parentStyle ?? DefaultTextStyle.of(context).style).copyWith(
      color: color,
    );
    // 字体分片逐步到达会重建 span；同一 AST 链接只登记一个手势对象。
    // 其生命周期仍由外层 Markdown 渲染树统一释放。
    final links = <md.Element, TapGestureRecognizer>{};
    List<InlineSpan> render(
      List<md.Node> nodes,
      TextStyle style,
      TapGestureRecognizer? recognizer,
    ) => nodes.expand<InlineSpan>((node) {
      if (node is md.Text) {
        return [
          TextSpan(text: node.text, style: style, recognizer: recognizer),
        ];
      }
      final child = node as md.Element;
      var nested = style;
      if (child.tag == 'strong') {
        nested = nested.copyWith(fontWeight: FontWeight.bold);
      }
      if (child.tag == 'em') {
        nested = nested.copyWith(fontStyle: FontStyle.italic);
      }
      if (child.tag == 'del') {
        nested = nested.copyWith(
          decoration: TextDecoration.combine([
            if (nested.decoration != null) nested.decoration!,
            TextDecoration.lineThrough,
          ]),
        );
      }
      var tap = recognizer;
      if (child.tag == 'a') {
        nested = nested.copyWith(
          decoration: TextDecoration.combine([
            if (nested.decoration != null) nested.decoration!,
            TextDecoration.underline,
          ]),
        );
        tap = links.putIfAbsent(child, () {
          final value = TapGestureRecognizer()
            ..onTap = () => onLink(child.attributes['href']!);
          registerRecognizer(value);
          return value;
        });
      }
      if (child.tag == 'code') {
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: MediaQuery.withNoTextScaling(
              child: GestureDetector(
                onTap: tap?.onTap,
                child: WenyouInlineCodeSurface(
                  text: child.textContent,
                  style: nested,
                  foregroundColor: color,
                  preserveTextFont:
                      enableTextFonts && element.attributes.containsKey('font'),
                ),
              ),
            ),
          ),
        ];
      }
      return render(child.children!, nested, tap);
    }).toList();
    final font = element.attributes['font'];
    if (font == null || !enableTextFonts) {
      return Text.rich(
        TextSpan(children: render(element.children!, base, null)),
      );
    }
    return TextFontScope(
      texts: {font: element.textContent},
      builder: (context, runtime) => Text.rich(
        TextSpan(
          children: render(
            element.children!,
            runtime?.style(font, base) ?? base,
            null,
          ),
        ),
      ),
    );
  }
}
