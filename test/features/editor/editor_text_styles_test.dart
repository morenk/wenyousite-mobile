import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

void main() {
  testWidgets('编辑器引用与行内代码消费 Foundation 精确样式', (tester) async {
    late DefaultStyles styles;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            styles = wenyouEditorTextStyles(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final quote = styles.quote!;
    expect(quote.style.fontStyle, FontStyle.normal);
    expect(quote.horizontalSpacing, const HorizontalSpacing(12.75, 12.75));
    expect(quote.lineSpacing, const VerticalSpacing(8.5, 8.5));
    final quoteDecoration = quote.decoration!;
    expect(quoteDecoration.color, WenyouFoundationPalette.muted);
    expect(
      (quoteDecoration.border! as BorderDirectional).start.width,
      WenyouElementContract.quoteMarkerWidth,
    );
    expect(
      (quoteDecoration.borderRadius! as BorderRadiusDirectional).topStart.x,
      0,
    );
    expect(
      (quoteDecoration.borderRadius! as BorderRadiusDirectional).topEnd.x,
      WenyouFoundationMobile.radiusCompact,
    );

    final inlineCode = styles.inlineCode!;
    expect(inlineCode.style.fontSize, closeTo(17 * 0.88, 0.001));
    expect(inlineCode.style.fontFamily, 'monospace');
    expect(inlineCode.backgroundColor, WenyouFoundationPalette.muted);
    expect(inlineCode.radius?.x, closeTo(17 * 0.88 * 0.35, 0.001));
  });
}
