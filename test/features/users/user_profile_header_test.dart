import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final themeCase in [
    (name: '亮色', theme: AppTheme.light, golden: 'profile_header_360_light.png'),
    (name: '黑夜', theme: AppTheme.dark, golden: 'profile_header_360_dark.png'),
  ]) {
    testWidgets('个人资料在${themeCase.name}模式使用 10dp 卡片外框', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: themeCase.theme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UserProfileHeader(
                  username: '无背景用户',
                  level: 2,
                  stats: [UserProfileStatItem(label: '关注', value: '0')],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final identity = find.byKey(const Key('profile-identity-without-cover'));
      expect(identity, findsOneWidget);
      expect(find.bySemanticsLabel('无背景用户 的主页背景图'), findsNothing);
      expect(tester.getSize(identity).height, 92);
      expect(find.text('无背景用户'), findsOneWidget);
      final card = tester.widget<Card>(find.byType(Card));
      expect(
        (card.shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(10),
      );
      expect((card.shape! as RoundedRectangleBorder).side, BorderSide.none);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(UserProfileHeader),
        matchesGoldenFile('goldens/${themeCase.golden}'),
      );
    });
  }

  for (final themeCase in [
    (name: '亮色', theme: AppTheme.light, golden: 'profile_cover_360_light.png'),
    (name: '黑夜', theme: AppTheme.dark, golden: 'profile_cover_360_dark.png'),
  ]) {
    testWidgets('个人资料背景在${themeCase.name}模式以 2 比 1 展示并裁切在 10dp 卡片内', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _cacheProfileCover(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: themeCase.theme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UserProfileHeader(
                  key: Key('profile-header'),
                  username: '温柔测试员',
                  level: 4,
                  profileCover: ProfileCoverModel(
                    web: ProfileCoverVariant(
                      url: 'https://cdn.example.com/cover-web.webp',
                    ),
                    mobile: ProfileCoverVariant(
                      url: 'https://cdn.example.com/cover-mobile.webp',
                    ),
                  ),
                  stats: [
                    UserProfileStatItem(label: '关注', value: '7'),
                    UserProfileStatItem(label: '粉丝', value: '9'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final header = find.byKey(const Key('profile-header'));
      final cover = find.descendant(
        of: header,
        matching: find.bySemanticsLabel('温柔测试员 的主页背景图'),
      );
      expect(cover, findsOneWidget);
      expect(tester.getSize(cover).width / tester.getSize(cover).height, 2);

      final card = find.descendant(of: header, matching: find.byType(Card));
      final profileCard = tester.widget<Card>(card);
      expect(profileCard.clipBehavior, Clip.antiAlias);
      expect(
        (profileCard.shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(10),
      );
      expect(
        (profileCard.shape! as RoundedRectangleBorder).side,
        BorderSide.none,
      );
      expect(tester.getTopLeft(cover).dy, tester.getTopLeft(card).dy);
      expect(tester.takeException(), isNull);
      await expectLater(
        header,
        matchesGoldenFile('goldens/${themeCase.golden}'),
      );
    });
  }
}

Future<void> _cacheProfileCover(WidgetTester tester) async {
  await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.teal, BlendMode.src);
    final picture = recorder.endRecording();
    final bitmap = await picture.toImage(16, 8);
    picture.dispose();
    const provider = CachedNetworkImageProvider(
      'https://cdn.example.com/cover-mobile.webp',
    );
    for (final image in <ImageProvider>[
      provider,
      ResizeImage.resizeIfNeeded(1200, 600, provider),
    ]) {
      final key = await image.obtainKey(ImageConfiguration.empty);
      PaintingBinding.instance.imageCache.putIfAbsent(
        key,
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: bitmap.clone())),
        ),
      );
    }
    bitmap.dispose();
  });
  addTearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
}
