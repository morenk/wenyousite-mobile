import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import '../../features/threads/thread_detail_page_test_support.dart';
import '../../support/foundation_test_fonts.dart';

// 2026-09-09 匿名读取“浮陆之国”首个子贴 BODY v3 的原始引用；
// 保留反引号、斜体与空 > 分隔，不能用省略号短句替代换行场景。
const quoteSource = '''> *`璃氏已勘破长生之妙，浮陆国主璃司寿四百九十九，貌如少女，青春不老。`*
>
> *`特邀天下豪杰，较武为祝，贺国主五百大寿，魁首赐寿丹一枚，服之可延寿一甲子。`*
>
> *`有意者，请持此帖渡海登台。`*''';

void main() {
  setUpAll(loadFoundationTestFonts);
  setUpAll(() async {
    final loader = FontLoader('Noto Sans SC')
      ..addFont(
        rootBundle.load(
          'packages/wenyousite_foundation/fonts/NotoSansSC-Variable.ttf',
        ),
      );
    await loader.load();
    final monospace = FontLoader('monospace')
      ..addFont(
        File(
          'C:/Windows/Fonts/consola.ttf',
        ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
    await monospace.load();
  });

  testWidgets('原始引用在真实主题子贴正文首次打开及重开均不覆盖', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final detail = ThreadDetailModel(
      id: 'thread-1',
      title: '浮陆之国',
      owner: threadDetailPageTestAuthor,
      status: ThreadDetailStatus.closed,
      isPrivate: false,
      isPinned: false,
      viewCount: 0,
      likeCount: 0,
      tipTotal: '0',
      memberCount: 0,
      playerCount: 0,
      postCount: 0,
      tags: const [],
      defaultSubthreadId: 'subthread-1',
      createdAt: DateTime.utc(2026, 8, 25),
      updatedAt: DateTime.utc(2026, 9, 9),
      subthreads: const [
        ThreadSubthreadModel(
          id: 'subthread-1',
          title: '浮陆之国',
          sortOrder: 0,
          postCount: 0,
          postingPolicyLabel: '参与者发言',
          body: ThreadBodyModel(
            markdown: quoteSource,
            postId: 'body-1',
            version: 3,
          ),
        ),
      ],
    );
    for (var opening = 0; opening < 2; opening++) {
      await tester.pumpWidget(
        threadDetailPageTestDetailApp(
          ThreadDetailPageTestFakeThreadDetailRepository(
            detail: detail,
            mainFloors: [],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final surfaces = find.byType(WenyouInlineCodeSurface);
      expect(surfaces, findsNWidgets(3));
      for (var index = 0; index < 2; index++) {
        expect(
          tester.getRect(surfaces.at(index)).bottom,
          lessThanOrEqualTo(tester.getRect(surfaces.at(index + 1)).top),
        );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  for (final width in [360.0, 400.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final dark in [false, true]) {
        testWidgets('原帖引用完整显示 width=$width scale=$scale dark=$dark', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 1000);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: Key('quote-overflow'),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: WenyouMarkdown(data: quoteSource),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final surfaces = find.byType(WenyouInlineCodeSurface);
          expect(surfaces, findsNWidgets(3));
          for (var index = 0; index < 3; index++) {
            final surface = surfaces.at(index);
            final paragraphFinder = find.descendant(
              of: surface,
              matching: find.byType(RichText),
            );
            final paragraph = tester.renderObject<RenderParagraph>(
              paragraphFinder,
            );
            expect(
              paragraph.text.toPlainText(),
              [
                '璃氏已勘破长生之妙，浮陆国主璃司寿四百九十九，貌如少女，青春不老。',
                '特邀天下豪杰，较武为祝，贺国主五百大寿，魁首赐寿丹一枚，服之可延寿一甲子。',
                '有意者，请持此帖渡海登台。',
              ][index],
            );
            expect(paragraph.text.style?.fontStyle, FontStyle.italic);
            final boxes = paragraph.getBoxesForSelection(
              TextSelection(
                baseOffset: 0,
                extentOffset: paragraph.text.toPlainText().length,
              ),
            );
            for (final box in boxes) {
              expect(
                box.bottom,
                lessThanOrEqualTo(paragraph.size.height + 0.01),
              );
            }
            if (index < 2) expect(boxes.length, greaterThan(1));
            final parent = find
                .ancestor(of: surface, matching: find.byType(RichText))
                .first;
            final parentRect = tester.getRect(parent);
            final surfaceBox = tester.renderObject<RenderBox>(surface);
            final surfaceRect = MatrixUtils.transformRect(
              surfaceBox.getTransformTo(null),
              Offset.zero & surfaceBox.size,
            );
            expect(
              surfaceRect.bottom,
              lessThanOrEqualTo(parentRect.bottom + 0.5),
            );
            expect(surfaceRect.top, greaterThanOrEqualTo(parentRect.top - 0.5));
            if (index < 2) {
              expect(
                surfaceRect.bottom,
                lessThanOrEqualTo(tester.getRect(surfaces.at(index + 1)).top),
              );
            }
          }
          expect(tester.takeException(), isNull);
          if (width == 400 && scale == 1) {
            await expectLater(
              find.byKey(const Key('quote-overflow')),
              matchesGoldenFile(
                'goldens/markdown_quote_overflow_400_${dark ? 'dark' : 'light'}.png',
              ),
            );
          }
        });
      }
    }
  }
}
