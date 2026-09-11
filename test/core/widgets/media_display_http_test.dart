import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/image_gallery.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../features/moments/moment_animation_fixture.dart';
import '../../support/foundation_test_fonts.dart';

const sourceUrl = 'https://cdn.example/original.gif';
const displayUrl = 'https://cdn.example/full.webp';
const display = MediaDisplay(
  url: displayUrl,
  width: 320,
  height: 180,
  bytes: 180,
  animated: true,
  frameCount: 2,
  durationMs: 360,
  loopCount: 2,
);

void main() {
  setUpAll(loadFoundationTestFonts);
  final resources = {
    sourceUrl: File(
      'test/fixtures/animation-webp-all-surfaces/original.gif',
    ).readAsBytesSync(),
    displayUrl: File(
      'test/fixtures/animation-webp-all-surfaces/full.webp',
    ).readAsBytesSync(),
  };
  testWidgets('正文→大图→默认保存只用完整 WebP，收藏仍用原始身份', (tester) async {
    final gallery = _Gallery();
    String? imported;
    await MomentAnimationFixture.run(tester, (fixture) async {
      await tester.pumpWidget(
        _app(
          WenyouMarkdown(
            data: '![场景]($sourceUrl)',
            mediaDisplays: const {sourceUrl: display},
            onAddImageToStickers: (uri) async {
              imported = uri.toString();
              return '已收藏';
            },
          ),
          gallery: gallery,
        ),
      );
      await _decode(tester);
      expect(fixture.requests, [displayUrl]);
      expect(fixture.responseBytes[displayUrl], 180);
      await tester.tap(find.byKey(const ValueKey('markdown-image-$sourceUrl')));
      await tester.pumpAndSettle();
      await _decode(tester);
      await tester.tap(find.byKey(const Key('content-image-actions')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存图片'));
      await tester.pumpAndSettle();
      expect(gallery.saved!.url, displayUrl);
      expect(gallery.saved!.fallbackUrls, isEmpty);
      await tester.tap(find.byKey(const Key('content-image-actions')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加到表情收藏'));
      await tester.pumpAndSettle();
      expect(imported, sourceUrl);
      expect(fixture.requests, isNot(contains(sourceUrl)));
    }, resources: resources);
  });
  testWidgets('完整 WebP 失败保持错误，显式重试仍只请求 WebP', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      fixture.failures.add(displayUrl);
      await tester.pumpWidget(
        _app(
          const WenyouMarkdown(
            data: '![场景]($sourceUrl)',
            mediaDisplays: {sourceUrl: display},
          ),
        ),
      );
      await _decode(tester);
      expect(fixture.requests, [displayUrl]);
      expect(find.text('重新加载图片'), findsOneWidget);
      fixture.failures.clear();
      await tester.tap(find.text('重新加载图片'));
      await _decode(tester);
      expect(fixture.requests, [displayUrl, displayUrl]);
      expect(fixture.requests, isNot(contains(sourceUrl)));
    }, resources: resources);
  });
  testWidgets('上传后的图片与表情编辑器使用 display，Markdown 往返保留来源', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    session.insertBlockImage(url: sourceUrl, display: display);
    await session.flush();
    await MomentAnimationFixture.run(tester, (fixture) async {
      await tester.pumpWidget(
        _app(
          QuillEditor(
            controller: session.controller,
            focusNode: session.focusNode,
            scrollController: session.scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(
                mediaDisplays: session.mediaDisplays,
              ),
            ),
          ),
        ),
      );
      await _decode(tester);
      expect(fixture.requests, [displayUrl]);
      String? markdown;
      final reopened = RichEditorSession(
        initialMarkdown: '![图片]($sourceUrl)',
        initialMediaDisplays: session.mediaDisplays,
        onMarkdownChanged: (value) => markdown = value,
      );
      addTearDown(reopened.dispose);
      reopened.insertSticker(
        selection: const TextSelection.collapsed(offset: 0),
        assetId: 'c123456789012345678901234',
        url: sourceUrl,
        display: display,
      );
      await reopened.flush();
      expect(markdown, contains(sourceUrl));
      expect(markdown, isNot(contains(displayUrl)));
      expect(reopened.mediaDisplays[sourceUrl]!.url, displayUrl);
    }, resources: resources);
  });
}

Widget _app(Widget body, {ImageGalleryService? gallery}) => ProviderScope(
  overrides: [
    if (gallery != null) imageGalleryServiceProvider.overrideWithValue(gallery),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: body),
  ),
);
Future<void> _decode(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _Gallery implements ImageGalleryService {
  ImageGallerySource? saved;
  @override
  bool get isSupported => true;
  @override
  Future<void> openSettings() async {}
  @override
  ImageGallerySaveOperation startSave(ImageGallerySource source) {
    saved = source;
    return ImageGallerySaveOperation(result: Future.value(), cancel: () {});
  }
}
