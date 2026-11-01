import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

import '../../support/deterministic_test_fonts.dart';

const _portal = '[传送门](/threads/cmsewdo0h000x7qv6aa77ll1v)';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('不同对齐段的传送门仍指向各自目标，代码中的链接保持字面内容', (tester) async {
    const first = '/threads/cmsewdo0h000x7qv6aa77ll1v';
    const second = '/threads/cmsewdo0h000x7qv6aa77ll2v';
    final opened = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data:
                '左侧 [甲]($first)\n\n'
                '[wenyousite-align-v1-center]: #\n中间 [乙]($second)\n\n'
                '[wenyousite-align-v1-right]: #\n右侧 `[$first]($first)`',
            onInternalLink: opened.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('markdown-internal-reference-0')),
    );
    await tester.tap(
      find.byKey(const ValueKey('markdown-internal-reference-1')),
    );
    expect(opened.map((uri) => uri.path), [first, second]);
    expect(find.byType(WenyouInternalReferenceChip), findsNWidgets(2));
    expect(find.text('[$first]($first)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final direction in ['center', 'right']) {
    for (final prefix in ['', '## ', '### ']) {
      testWidgets('$prefix$direction 正文同行传送门保存重开和阅读保持整行对齐', (tester) async {
        final source =
            '[wenyousite-align-v1-$direction]: #\n$prefix埃克塞丘 $_portal';
        final delta = MarkdownDeltaCodec.decode(source).delta;
        final saved = MarkdownDeltaCodec.encode(delta);
        expect(saved, source);
        expect(MarkdownDeltaCodec.decode(saved).delta, delta);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SizedBox(width: 320, child: WenyouMarkdown(data: saved)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final text = tester
            .widgetList<RichText>(find.byType(RichText))
            .singleWhere((text) => text.text.toPlainText().contains('埃克塞丘'));
        expect(
          text.textAlign,
          direction == 'center' ? TextAlign.center : TextAlign.end,
        );
        final paragraph = tester.renderObject<RenderParagraph>(
          find.byWidget(text),
        );
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(
            baseOffset: 0,
            extentOffset: text.text.toPlainText().length,
          ),
        );
        final bounds = boxes
            .map((box) => box.toRect())
            .reduce((a, b) => a.expandToInclude(b))
            .shift(paragraph.localToGlobal(Offset.zero));
        expect(
          direction == 'center' ? bounds.center.dx : bounds.right,
          closeTo(direction == 'center' ? 160 : 320, 1),
        );
        expect(find.text('传送门'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final fontSize in [13.0, 15.0, 19.0]) {
    for (final direction in ['', 'center', 'right']) {
      for (final plain in [false, true]) {
        for (final dark in [false, true]) {
          for (final scale in [1.0, 2.0]) {
            testWidgets(
              '连续正文编辑与阅读行距相符 plain=$plain align=$direction dark=$dark scale=$scale size=$fontSize',
              (tester) async {
                tester.view.devicePixelRatio = 1;
                tester.view.physicalSize = const Size(320, 1000);
                addTearDown(tester.view.resetDevicePixelRatio);
                addTearDown(tester.view.resetPhysicalSize);
                final marker = direction.isEmpty
                    ? ''
                    : '[wenyousite-align-v1-$direction]: #\n';
                final source =
                    '$marker${plain ? '甲\n乙\n丙' : '甲 $_portal\n乙 $_portal\n丙 $_portal'}';
                final controller = QuillController(
                  document: Document.fromDelta(
                    MarkdownDeltaCodec.decode(source).delta,
                  ),
                  selection: const TextSelection.collapsed(offset: 0),
                );
                final focus = FocusNode();
                final scroll = ScrollController();
                addTearDown(controller.dispose);
                addTearDown(focus.dispose);
                addTearDown(scroll.dispose);
                Future<List<Rect>> measure(bool editing) async {
                  await tester.pumpWidget(
                    MaterialApp(
                      theme: dark ? AppTheme.dark : AppTheme.light,
                      home: Builder(
                        builder: (context) => MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaler: TextScaler.linear(scale)),
                          child: Scaffold(
                            body: editing
                                ? Builder(
                                    builder: (context) => QuillEditor(
                                      controller: controller,
                                      focusNode: focus,
                                      scrollController: scroll,
                                      config: QuillEditorConfig(
                                        padding: EdgeInsets.zero,
                                        scrollable: false,
                                        showCursor: false,
                                        customStyles: wenyouEditorTextStyles(
                                          context,
                                          bodyFontSize: fontSize,
                                        ),
                                        embedBuilders:
                                            wenyouEditorEmbedBuilders(),
                                      ),
                                    ),
                                  )
                                : WenyouMarkdown(
                                    data: source,
                                    bodyFontSize: fontSize,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                  await tester.pumpAndSettle();
                  if (plain) {
                    return ['甲', '乙', '丙'].map((text) {
                      final paragraph = tester.allRenderObjects
                          .whereType<RenderParagraph>()
                          .toSet()
                          .singleWhere(
                            (p) => p.text.toPlainText().contains(text),
                          );
                      final start = paragraph.text.toPlainText().indexOf(text);
                      return paragraph
                          .getBoxesForSelection(
                            TextSelection(
                              baseOffset: start,
                              extentOffset: start + 1,
                            ),
                          )
                          .first
                          .toRect()
                          .shift(paragraph.localToGlobal(Offset.zero));
                    }).toList();
                  }
                  return tester
                      .widgetList<WenyouInternalReferenceSurface>(
                        find.byType(WenyouInternalReferenceSurface),
                      )
                      .map((surface) => tester.getRect(find.byWidget(surface)))
                      .toList();
                }

                final edited = await measure(true);
                final read = await measure(false);
                expect(edited, hasLength(3));
                expect(read, hasLength(3));
                for (var i = 1; i < 3; i++) {
                  expect(
                    edited[i].top - edited[i - 1].bottom,
                    greaterThan(1),
                    reason: 'edit=$edited read=$read',
                  );
                  expect(
                    edited[i].top - edited[i - 1].top,
                    closeTo(read[i].top - read[i - 1].top, .1),
                    reason: 'edit=$edited read=$read',
                  );
                }
                expect(tester.takeException(), isNull);
              },
            );
          }
        }
      }
    }
  }
}
