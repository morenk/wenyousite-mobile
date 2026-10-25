import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/presentation/local_photo_thumbnail.dart';

import 'fake_photo_library.dart';

void main() {
  testWidgets('缩略图解码失败可原地重试，重试成功恢复图片', (tester) async {
    final library = FakePhotoLibrary()..corruptThumbnail = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: LocalPhotoThumbnail(
            library: library,
            photo: const LocalPhoto('0'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final failedImage = tester.widget<Image>(find.byType(Image));
    final stream = failedImage.image.resolve(ImageConfiguration.empty);
    final decoded = Completer<void>();
    final listener = ImageStreamListener(
      (_, _) {
        if (!decoded.isCompleted) decoded.complete();
      },
      onError: (Object error, StackTrace? stack) {
        if (!decoded.isCompleted) decoded.complete();
      },
    );
    stream.addListener(listener);
    await tester.runAsync(() => decoded.future);
    stream.removeListener(listener);
    await tester.pumpAndSettle();
    expect(find.byTooltip('图片加载失败，重试'), findsOneWidget);
    library.corruptThumbnail = false;
    await tester.tap(find.byTooltip('图片加载失败，重试'));
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    final context = tester.element(find.byType(LocalPhotoThumbnail));
    await tester.runAsync(() => precacheImage(image.image, context));
    await tester.pumpAndSettle();
    expect(find.byTooltip('图片加载失败，重试'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
