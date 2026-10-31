import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/text_fonts/text_font_scope.dart';
import 'package:wenyousite_mobile/core/widgets/markdown_text_color_builder.dart';

void main() {
  testWidgets('字体连续更新不会为相同链接累计手势对象', (tester) async {
    final recognizers = <TapGestureRecognizer>[];
    addTearDown(() {
      for (final value in recognizers) {
        value.dispose();
      }
    });
    final opened = <String>[];
    final link = md.Element.text('a', '链接')
      ..attributes['href'] = 'https://example.com';
    final element = md.Element('text-color', [link])
      ..attributes['font'] = 'wenkai';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final scope =
                MarkdownTextColorBuilder(
                      onLink: opened.add,
                      registerRecognizer: recognizers.add,
                      enableTextFonts: true,
                    ).visitElementAfterWithContext(
                      context,
                      element,
                      null,
                      null,
                    )!
                    as TextFontScope;
            for (var i = 0; i < 100; i++) {
              scope.builder(context, null);
            }
            return const SizedBox();
          },
        ),
      ),
    );
    expect(recognizers, hasLength(1));
    recognizers.single.onTap!();
    expect(opened, ['https://example.com']);
  });
}
