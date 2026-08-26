import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_actions.dart';

void main() {
  testWidgets('关注切换即时更新按钮并展示成功反馈', (tester) async {
    final repository = _FakeUserRelationRepository();
    await tester.pumpWidget(_app(repository));

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('user-relation-follow'))).width,
      tester.getSize(find.byKey(const Key('user-relation-block'))).width,
    );

    await tester.tap(find.byKey(const Key('user-relation-follow')));
    await tester.pumpAndSettle();

    expect(repository.followCalls, 1);
    expect(find.text('已关注'), findsOneWidget);
    expect(find.text('关注成功。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('user-relation-follow')));
    await tester.pumpAndSettle();
    expect(repository.unfollowCalls, 1);
    expect(find.text('关注'), findsOneWidget);
  });

  testWidgets('拉黑必须确认，取消确认不请求，成功后可直接解除', (tester) async {
    final repository = _FakeUserRelationRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('user-relation-block')));
    await tester.pumpAndSettle();
    expect(find.text('拉黑用户？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.blockCalls, 0);

    await tester.tap(find.byKey(const Key('user-relation-block')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('user-relation-block-confirm')));
    await tester.pumpAndSettle();
    expect(repository.blockCalls, 1);
    expect(find.text('取消拉黑'), findsOneWidget);

    await tester.tap(find.byKey(const Key('user-relation-block')));
    await tester.pumpAndSettle();
    expect(repository.unblockCalls, 1);
    expect(find.text('拉黑'), findsOneWidget);
  });

  testWidgets('关系失败保留原按钮状态并显示请求 ID', (tester) async {
    final repository = _FakeUserRelationRepository(failFollow: true);
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('user-relation-follow')));
    await tester.pumpAndSettle();

    expect(find.text('关注'), findsOneWidget);
    expect(find.text('问题编号：follow-request-id'), findsOneWidget);
  });
}

Widget _app(UserRelationRepository repository) {
  return ProviderScope(
    overrides: [userRelationRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: UserRelationActions(target: _target)),
    ),
  );
}

class _FakeUserRelationRepository implements UserRelationRepository {
  _FakeUserRelationRepository({this.failFollow = false});

  final bool failFollow;
  int followCalls = 0;
  int unfollowCalls = 0;
  int blockCalls = 0;
  int unblockCalls = 0;

  @override
  Future<void> follow(String userId) async {
    followCalls += 1;
    if (failFollow) {
      throw const ApiFailure(
        userMessage: '请求没有完成，请稍后重试。',
        requestId: 'follow-request-id',
      );
    }
  }

  @override
  Future<void> unfollow(String userId) async {
    unfollowCalls += 1;
  }

  @override
  Future<void> block(String userId) async {
    blockCalls += 1;
  }

  @override
  Future<void> unblock(String userId) async {
    unblockCalls += 1;
  }
}

const _target = UserRelationTarget(
  userId: 'user-1',
  username: '目标用户',
  isFollowing: false,
  isBlocked: false,
  isBlockedBy: false,
  followerCount: 9,
);
