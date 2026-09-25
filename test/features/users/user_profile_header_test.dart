import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';
import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final visual in const [
    (width: 320.0, scale: 2.0, dark: false, suffix: '320_2x_light'),
    (width: 320.0, scale: 2.0, dark: true, suffix: '320_2x_dark'),
    (width: 400.0, scale: 1.0, dark: false, suffix: '400_light'),
    (width: 400.0, scale: 1.0, dark: true, suffix: '400_dark'),
    (width: 600.0, scale: 1.0, dark: false, suffix: '600_light'),
    (width: 600.0, scale: 1.0, dark: true, suffix: '600_dark'),
  ]) {
    testWidgets('共享资料头视觉基线 ${visual.suffix}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(visual.width, 960);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          theme: visual.dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(visual.scale)),
            child: child!,
          ),
          home: RepaintBoundary(
            key: const Key('profile-visual-golden'),
            child: Scaffold(
              backgroundColor: visual.dark
                  ? WenyouThemeTokens.dark.background
                  : WenyouThemeTokens.light.softPanel,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: WenyouConstrainedWidth(
                    child: UserProfileHeader(
                      username: '温柔测试员',
                      level: 4,
                      levelProgress: .75,
                      levelProgressLabel: '150 / 200 经验',
                      stats: const [
                        UserProfileStatItem(label: '关注', value: '7'),
                        UserProfileStatItem(label: '粉丝', value: '9'),
                        UserProfileStatItem(label: '温油', value: '12 升'),
                      ],
                      actions: WenyouIconLabelActionBar(
                        actions: [
                          WenyouIconLabelAction(
                            onPressed: () {},
                            icon: WenyouIconIds.actionEdit,
                            label: '编辑资料',
                          ),
                          WenyouIconLabelAction(
                            onPressed: () {},
                            icon: WenyouIconIds.actionBookmark,
                            label: '收藏',
                          ),
                        ],
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
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('profile-visual-golden')),
        matchesGoldenFile('goldens/user_profile_header_${visual.suffix}.png'),
      );
    });
  }

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    for (final dark in [false, true]) {
      testWidgets('$width dp ${dark ? '黑夜' : '浅色'} 两倍字号资料头保留可读操作', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 960);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: UserProfileHeader(
                    username: '温柔测试员',
                    level: 4,
                    stats: [
                      UserProfileStatItem(label: '关注', value: '7'),
                      UserProfileStatItem(label: '粉丝', value: '9'),
                      UserProfileStatItem(label: '温油', value: '12 升'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('加入温油站'), findsNothing);
        expect(find.textContaining('还没有填写'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('没有背景图时移除封面舞台并使用紧凑资料行', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(12),
            child: UserProfileHeader(
              username: '无背景用户',
              level: 2,
              stats: [UserProfileStatItem(label: '关注', value: '0')],
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
    expect(tester.takeException(), isNull);
  });

  testWidgets('个人资料背景以 2 比 1 直接展示并裁切在卡片圆角内', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Padding(
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
    expect(tester.widget<Card>(card).clipBehavior, Clip.antiAlias);
    final shape = tester.widget<Card>(card).shape! as RoundedRectangleBorder;
    expect(
      shape.borderRadius,
      BorderRadius.circular(WenyouFoundationMobile.radiusCard),
    );
    expect(shape.side, BorderSide.none);
    expect(tester.getTopLeft(cover).dy, tester.getTopLeft(card).dy);
    expect(tester.takeException(), isNull);
  });
}
