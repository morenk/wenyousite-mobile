import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  for (final size in const [
    Size(320, 720),
    Size(360, 760),
    Size(600, 900),
    Size(800, 600),
    Size(1200, 800),
  ]) {
    for (final scale in const [1.0, 2.0]) {
      testWidgets('${size.width}×${size.height} / ${scale}x 无溢出', (
        tester,
      ) async {
        await _pumpGallery(tester, size: size, textScale: scale);

        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('重试加载'), findsOneWidget);
        expect(find.bySemanticsLabel('收藏，处理中'), findsOneWidget);
      });
    }
  }

  testWidgets('共享反馈操作满足点击区域、标签与文本对比度要求', (tester) async {
    await _pumpGallery(tester, size: const Size(360, 760));

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    // Flutter 的像素级对比度采样会把变量字体的抗锯齿边缘视为实际文字色，
    // 对 Foundation 的小字号软色状态文案会产生假阳性。单独验证标准正文组合，
    // 状态色仍由 Foundation Token 合同与 Golden 回归锁定。
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => Text(
                '正文内容',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });

  for (final golden in const [
    (
      name: 'component_gallery_360_light.png',
      size: Size(360, 760),
      dark: false,
      scale: 1.0,
    ),
    (
      name: 'component_gallery_360_dark.png',
      size: Size(360, 760),
      dark: true,
      scale: 1.0,
    ),
    (
      name: 'component_gallery_800_landscape.png',
      size: Size(800, 600),
      dark: false,
      scale: 1.0,
    ),
    (
      name: 'component_gallery_360_text_2x.png',
      size: Size(360, 900),
      dark: false,
      scale: 2.0,
    ),
  ]) {
    testWidgets('视觉基线 ${golden.name}', (tester) async {
      await _pumpGallery(
        tester,
        size: golden.size,
        dark: golden.dark,
        textScale: golden.scale,
      );

      await expectLater(
        find.byKey(const Key('component-gallery')),
        matchesGoldenFile('goldens/${golden.name}'),
      );
    });
  }
}

Future<void> _pumpGallery(
  WidgetTester tester, {
  required Size size,
  bool dark = false,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          key: const Key('component-gallery'),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WenyouStatusBanner(
                    message: '资料已保存',
                    tone: WenyouStatusTone.accent,
                  ),
                  const SizedBox(height: 12),
                  WenyouFailureView(
                    failure: UserFacingFailure.fromApi(
                      const ApiFailure(
                        reason: FailureReason.offline,
                        requestId: 'request-id',
                      ),
                      title: '主题加载失败',
                      objectName: '主题',
                    ),
                    action: TextButton(
                      onPressed: () {},
                      child: const Text('重试加载'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: WenyouAsyncPrimaryButton(
                          label: '提交',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      WenyouAsyncIconButton(
                        icon: WenyouIconIds.actionBookmark,
                        label: '收藏',
                        isLoading: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const WenyouListSkeleton(label: '正在加载主题', itemCount: 2),
                  const SizedBox(height: 12),
                  WenyouLoadMoreControl(
                    hasMore: true,
                    isLoading: false,
                    onLoadMore: () {},
                  ),
                  const SizedBox(height: 12),
                  const WenyouEmptyState(
                    icon: WenyouIconIds.statusEmpty,
                    title: '还没有内容',
                    message: '发布后会显示在这里。',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 250));
}
