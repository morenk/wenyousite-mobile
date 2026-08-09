import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_page.dart';

void main() {
  testWidgets('公开用户页展示资料、统计与只读关系状态', (tester) async {
    await tester.pumpWidget(_userApp(_FakePublicUserRepository()));
    await tester.pumpAndSettle();

    expect(find.text('温柔测试员'), findsOneWidget);
    expect(find.text('Lv.4'), findsOneWidget);
    expect(find.text('一起写下温柔的故事。'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('18L'), findsOneWidget);
    expect(find.text('已关注'), findsOneWidget);
    expect(find.text('关注了你'), findsOneWidget);
  });

  testWidgets('公开用户页失败后可重试恢复', (tester) async {
    final repository = _FakePublicUserRepository(failFirstRequest: true);
    await tester.pumpWidget(_userApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('用户资料没有加载完成'), findsOneWidget);
    expect(find.text('请求 ID：user-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('public-user-retry')));
    await tester.pumpAndSettle();

    expect(find.text('温柔测试员'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('404 与已注销资料使用不泄露旧信息的收敛状态', (tester) async {
    await tester.pumpWidget(
      _userApp(_FakePublicUserRepository(notFound: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('用户不存在'), findsOneWidget);
    expect(find.text('温柔测试员'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      _userApp(_FakePublicUserRepository(deactivated: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('已注销用户'), findsOneWidget);
    expect(find.text('温柔测试员'), findsNothing);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 公开用户资料无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_userApp(_FakePublicUserRepository()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

Widget _userApp(PublicUserRepository repository) {
  return ProviderScope(
    overrides: [publicUserRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const PublicUserPage(userId: 'user-1'),
    ),
  );
}

class _FakePublicUserRepository implements PublicUserRepository {
  _FakePublicUserRepository({
    this.failFirstRequest = false,
    this.notFound = false,
    this.deactivated = false,
  });

  final bool failFirstRequest;
  final bool notFound;
  final bool deactivated;
  int calls = 0;

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async {
    calls += 1;
    if (failFirstRequest && calls == 1) {
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'user-request-id',
      );
    }
    if (notFound) {
      throw const ApiFailure(userMessage: '请求没有完成，请稍后重试。', httpStatus: 404);
    }
    return PublicUserProfileModel(
      id: userId,
      username: '温柔测试员',
      bio: '一起写下温柔的故事。',
      level: 4,
      followingCount: 7,
      followerCount: 9,
      receivedTipTotal: '18',
      receivedTipCount: 6,
      isFollowing: true,
      isFollowedBy: true,
      isBlocked: false,
      isBlockedBy: false,
      isDeactivated: deactivated,
      createdAt: DateTime.utc(2026, 8, 10),
    );
  }
}
