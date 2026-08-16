import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_profile_header.dart';

void main() {
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
      matching: find.byType(AspectRatio),
    );
    expect(cover, findsOneWidget);
    expect(tester.widget<AspectRatio>(cover).aspectRatio, 2);
    expect(tester.getSize(cover).width / tester.getSize(cover).height, 2);

    final card = find.descendant(of: header, matching: find.byType(Card));
    expect(tester.widget<Card>(card).clipBehavior, Clip.antiAlias);
    expect(tester.getTopLeft(cover).dy, tester.getTopLeft(card).dy);
    expect(tester.takeException(), isNull);
  });
}
