import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';

void main() {
  testWidgets('派生图加载失败后按顺序切换到下一地址', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WenyouCachedImage(
          imageUrl: 'https://cdn.example.com/feed.webp',
          fallbackImageUrls: [
            'https://cdn.example.com/thumb.webp',
            'https://cdn.example.com/master.gif',
          ],
        ),
      ),
    );

    var cached = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(cached.imageUrl, 'https://cdn.example.com/feed.webp');
    cached.errorWidget!(
      tester.element(find.byType(CachedNetworkImage)),
      cached.imageUrl,
      StateError('failed'),
    );
    await tester.pump();
    await tester.pump();

    cached = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(cached.imageUrl, 'https://cdn.example.com/thumb.webp');
    cached.errorWidget!(
      tester.element(find.byType(CachedNetworkImage)),
      cached.imageUrl,
      StateError('failed'),
    );
    await tester.pump();
    await tester.pump();

    cached = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(cached.imageUrl, 'https://cdn.example.com/master.gif');
  });

  testWidgets('所有地址失败后才显示最终错误状态', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WenyouCachedImage(
          imageUrl: 'https://cdn.example.com/master.webp',
          errorWidget: _errorWidget,
        ),
      ),
    );

    final cached = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    final error = cached.errorWidget!(
      tester.element(find.byType(CachedNetworkImage)),
      cached.imageUrl,
      StateError('failed'),
    );

    expect(error.key, const Key('final-image-error'));
  });

  testWidgets('组件切换到新图片后从新主地址重新开始', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WenyouCachedImage(
          imageUrl: 'https://cdn.example.com/old-feed.webp',
          fallbackImageUrls: ['https://cdn.example.com/old-master.webp'],
        ),
      ),
    );
    var cached = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    cached.errorWidget!(
      tester.element(find.byType(CachedNetworkImage)),
      cached.imageUrl,
      StateError('failed'),
    );
    await tester.pump();
    await tester.pump();

    await tester.pumpWidget(
      const MaterialApp(
        home: WenyouCachedImage(
          imageUrl: 'https://cdn.example.com/new-feed.webp',
          fallbackImageUrls: ['https://cdn.example.com/new-master.webp'],
        ),
      ),
    );

    cached = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(cached.imageUrl, 'https://cdn.example.com/new-feed.webp');
  });
}

Widget _errorWidget(BuildContext context, String url, Object error) {
  return const SizedBox(key: Key('final-image-error'));
}
