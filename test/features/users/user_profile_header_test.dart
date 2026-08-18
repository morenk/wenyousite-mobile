import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';

void main() {
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
    expect(tester.getTopLeft(cover).dy, tester.getTopLeft(card).dy);
    expect(tester.takeException(), isNull);
  });
}
