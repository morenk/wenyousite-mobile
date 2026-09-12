import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final ordered in [true, false]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 1.5, 2.0]) {
        for (final scenario in [
          'single',
          'wrapped',
          'nested',
          'two-digit',
          'nested-wide',
        ]) {
          testWidgets('$ordered $dark $scale $scenario 列表标记对齐正文首行基线', (
            tester,
          ) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = const Size(360, 2600);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetPhysicalSize);
            final count = switch (scenario) {
              'two-digit' => 12,
              'nested-wide' => 14,
              _ => 3,
            };
            final controller = QuillController(
              document: Document.fromJson([
                for (var i = 0; i < count; i++) ...[
                  {
                    'insert': scenario == 'wrapped'
                        ? '正文 $i 中文 Abg 123 自动折行后的编号仍然应该对齐第一行，不跟随整项高度居中。'
                        : '正文 $i 到几点结束就 Abg 123',
                    if (i == 1) 'attributes': {'bold': true},
                  },
                  {
                    'insert': '\n',
                    'attributes': {
                      'list': ordered ? 'ordered' : 'bullet',
                      if (scenario == 'nested') 'indent': i,
                      if (scenario == 'nested-wide') 'indent': i < 2 ? i : 2,
                    },
                  },
                ],
              ]),
              selection: const TextSelection.collapsed(offset: 0),
            );
            final focus = FocusNode();
            final scroll = ScrollController();
            addTearDown(controller.dispose);
            addTearDown(focus.dispose);
            addTearDown(scroll.dispose);
            await tester.pumpWidget(
              MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                home: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: Scaffold(
                      body: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Builder(
                          builder: (editorContext) => QuillEditor(
                            controller: controller,
                            focusNode: focus,
                            scrollController: scroll,
                            config: QuillEditorConfig(
                              customStyles: wenyouEditorTextStyles(
                                editorContext,
                              ),
                              // Quill 自定义列表前导的现有公开实验入口。
                              // ignore: experimental_member_use
                              customLeadingBlockBuilder:
                                  wenyouEditorLeadingBlockBuilder(
                                    editorContext,
                                  ),
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
            final markers = find.byType(
              ordered ? QuillNumberPoint : QuillBulletPoint,
            );
            expect(markers, findsNWidgets(count));
            for (var i = 0; i < count; i++) {
              final body = tester.renderObject<RenderParagraph>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is RichText &&
                      widget.text.toPlainText().startsWith('正文 $i '),
                ),
              );
              final marker = tester.renderObject<RenderParagraph>(
                find.descendant(
                  of: markers.at(i),
                  matching: find.byType(RichText),
                ),
              );
              final difference = _baseline(marker) - _baseline(body);
              expect(
                difference,
                closeTo(0, 0.1),
                reason: '第 ${i + 1} 项：负值代表标记高于正文，必须按实际首行基线对齐',
              );
              final markerBoxes = marker.getBoxesForSelection(
                TextSelection(
                  baseOffset: 0,
                  extentOffset: marker.text.toPlainText().length,
                ),
              );
              expect(
                markerBoxes.map((box) => box.top).toSet(),
                hasLength(1),
                reason: '缩放后编号和句点仍是完整单行，不能用换行或裁切迁就旧缩进',
              );
              for (final box in markerBoxes) {
                expect(
                  box.right,
                  lessThanOrEqualTo(marker.constraints.maxWidth + 0.1),
                );
              }
              if (scenario == 'wrapped') {
                expect(body.size.height, greaterThan(marker.size.height * 1.5));
              }
            }
            if (ordered && scenario == 'two-digit') {
              expect(find.text('12.'), findsOneWidget);
            }
            if (ordered && scenario == 'nested-wide') {
              expect(find.text('xii.'), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }
}

double _baseline(RenderParagraph paragraph) => paragraph
    .localToGlobal(
      Offset(
        0,
        paragraph.getDryBaseline(
          paragraph.constraints,
          TextBaseline.alphabetic,
        )!,
      ),
    )
    .dy;
