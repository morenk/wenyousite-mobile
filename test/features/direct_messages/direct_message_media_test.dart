import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_media.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('竖图按服务端宽高预留比例且只限制缓存高度', (tester) async {
    await tester.pumpWidget(
      _app(
        const DirectMessageMedia(
          id: 'portrait',
          url: 'https://cdn.example.com/portrait.webp',
          width: 800,
          height: 1169,
          isSticker: false,
        ),
      ),
    );
    await tester.pump();

    final frame = find.byKey(
      const ValueKey('direct-message-image-frame-portrait'),
    );
    expect(tester.getSize(frame).width, closeTo(800 / 1169 * 280, 0.01));
    expect(tester.getSize(frame).height, 280);
    final image = tester.widget<WenyouCachedImage>(
      find.descendant(of: frame, matching: find.byType(WenyouCachedImage)),
    );
    expect(image.width, closeTo(800 / 1169 * 280, 0.01));
    expect(image.height, 280);
    expect(image.cacheWidth, isNull);
    expect(image.cacheHeight, 280);
  });

  testWidgets('横图受实际气泡内容宽度限制且只限制缓存宽度', (tester) async {
    await tester.pumpWidget(
      _app(
        const DirectMessageMedia(
          id: 'landscape',
          url: 'https://cdn.example.com/landscape.webp',
          width: 1600,
          height: 900,
          isSticker: false,
        ),
      ),
    );
    await tester.pump();

    final frame = find.byKey(
      const ValueKey('direct-message-image-frame-landscape'),
    );
    expect(tester.getSize(frame), const Size(264, 148.5));
    final image = tester.widget<WenyouCachedImage>(
      find.descendant(of: frame, matching: find.byType(WenyouCachedImage)),
    );
    expect(image.cacheWidth, 264);
    expect(image.cacheHeight, isNull);
  });

  testWidgets('尺寸未知时不猜测比例并避免双轴缓存', (tester) async {
    await tester.pumpWidget(
      _app(
        const DirectMessageMedia(
          id: 'unknown',
          url: 'https://cdn.example.com/unknown.webp',
          isSticker: false,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('direct-message-image-frame-unknown')),
      findsNothing,
    );
    final image = tester.widget<WenyouCachedImage>(
      find.byType(WenyouCachedImage),
    );
    expect(image.width, isNull);
    expect(image.height, isNull);
    expect(image.cacheWidth, 264);
    expect(image.cacheHeight, isNull);
  });

  testWidgets('收藏表情完整呈现并遵循 128dp 上限', (tester) async {
    await tester.pumpWidget(
      _app(
        const DirectMessageMedia(
          id: 'sticker',
          url: 'https://cdn.example.com/sticker.webp',
          width: 512,
          height: 320,
          isSticker: true,
        ),
      ),
    );
    await tester.pump();

    final frame = find.byKey(
      const ValueKey('direct-message-image-frame-sticker'),
    );
    expect(tester.getSize(frame), const Size(128, 80));
    final image = tester.widget<WenyouCachedImage>(
      find.descendant(of: frame, matching: find.byType(WenyouCachedImage)),
    );
    expect(image.cacheWidth, 128);
    expect(image.cacheHeight, isNull);
  });

  testWidgets('点按私聊图片进入共享全屏原图页', (tester) async {
    await tester.pumpWidget(
      _app(
        const DirectMessageMedia(
          id: 'viewer',
          url: 'https://cdn.example.com/original.webp',
          mediumUrl: 'https://cdn.example.com/medium.webp',
          width: 800,
          height: 1169,
          isSticker: false,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(DirectMessageImage));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byType(ContentImageViewerPage), findsOneWidget);
    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(
      tester
          .widget<ContentImageViewerPage>(find.byType(ContentImageViewerPage))
          .url,
      'https://cdn.example.com/original.webp',
    );
  });

  testWidgets('360dp 私聊竖图比例视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      _app(
        const DirectMessageMedia(
          id: 'golden-portrait',
          url: 'https://cdn.example.com/golden-portrait.webp',
          width: 800,
          height: 1169,
          isSticker: false,
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(DirectMessageImage),
      matchesGoldenFile('goldens/direct_message_portrait_360.png'),
    );
  });
}

Widget _app(DirectMessageMedia media) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 264),
          child: DirectMessageImage(media: media),
        ),
      ),
    ),
  );
}
