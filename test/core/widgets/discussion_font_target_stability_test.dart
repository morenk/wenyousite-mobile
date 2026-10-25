import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_cover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('目标稳定时后续楼层字体连续改变高度不能阻塞定位', (tester) async {
    final fonts = _Service();
    final scroll = ScrollController();
    final targetKey = GlobalKey(), listKey = GlobalKey();
    addTearDown(fonts.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [textFontServiceProvider.overrideWithValue(fonts)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DiscussionTargetCover(
              scope: 'font-target',
              targetId: 'target',
              loadingLabel: '正在定位目标楼层',
              revealedLabel: '已定位到目标楼层',
              targetKey: targetKey,
              itemListKey: listKey,
              scrollController: scroll,
              targetIndex: 1,
              itemCount: 3,
              canLocate: true,
              isLoadingPage: false,
              hasMore: false,
              onLoadMore: () {},
              onRetry: () {},
              onBack: () {},
              child: CustomScrollView(
                controller: scroll,
                slivers: [
                  SliverList.list(
                    key: listKey,
                    children: [
                      const SizedBox(height: 100),
                      SizedBox(
                        key: targetKey,
                        height: 200,
                        child: const WenyouMarkdown(
                          enableTextFonts: true,
                          data:
                              '<span data-wenyou-font-v1="source-han-sans">目标楼层</span>',
                        ),
                      ),
                      WenyouMarkdown(
                        enableTextFonts: true,
                        data:
                            '<span data-wenyou-font-v1="wenkai">${List.filled(120, '字体正文 A').join(' ')}</span>',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final targetTop = tester.getTopLeft(find.byKey(targetKey)).dy;
    for (var i = 0; i < 15; i++) {
      fonts.runtime.advance(i.isEven ? 18 : 20);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.getTopLeft(find.byKey(targetKey)).dy,
        closeTo(targetTop, 1),
      );
    }
    expect(fonts.runtime.styles, greaterThan(1));
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _Service extends TextFontService {
  _Service() : super(WenyouApi(), observePlatform: false);
  final runtime = _Runtime();
  @override
  Future<TextFontRuntime> load() async => runtime;
}

class _Runtime extends TextFontRuntime {
  _Runtime()
    : super(
        cache: TextFontCache(Directory.systemTemp),
        download: (_) async => throw StateError('不应联网'),
      );
  double size = 18;
  int styles = 0;
  void advance(double value) {
    size = value;
    notifyListeners();
  }

  @override
  TextStyle style(String id, TextStyle base) {
    styles++;
    return base.copyWith(
      fontFamily: 'Roboto',
      fontSize: id == 'wenkai' ? size : base.fontSize,
    );
  }
}
