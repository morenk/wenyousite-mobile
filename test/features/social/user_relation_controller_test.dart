import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_controller.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

void main() {
  test('关注与取消关注串行切换并同步粉丝数', () async {
    final repository = _FakeUserRelationRepository();
    final controller = UserRelationController(repository, _target);

    expect(await controller.toggleFollow(), isTrue);
    expect(controller.state.isFollowing, isTrue);
    expect(controller.state.followerCount, 10);
    expect(repository.followCalls, 1);

    expect(await controller.toggleFollow(), isTrue);
    expect(controller.state.isFollowing, isFalse);
    expect(controller.state.followerCount, 9);
    expect(repository.unfollowCalls, 1);
  });

  test('同一目标在途时忽略快速重复操作', () async {
    final completer = Completer<void>();
    final repository = _FakeUserRelationRepository(
      onFollow: () => completer.future,
    );
    final controller = UserRelationController(repository, _target);

    final first = controller.toggleFollow();
    final second = await controller.toggleFollow();

    expect(second, isFalse);
    expect(repository.followCalls, 1);
    completer.complete();
    expect(await first, isTrue);
  });

  test('拉黑失败保留关注和原拉黑状态并暴露请求 ID', () async {
    final repository = _FakeUserRelationRepository(
      onBlock: () => throw const ApiFailure(
        userMessage: '请求没有完成，请稍后重试。',
        requestId: 'block-request-id',
      ),
    );
    final controller = UserRelationController(
      repository,
      const UserRelationTarget(
        userId: 'user-1',
        username: '目标用户',
        isFollowing: true,
        isBlocked: false,
        isBlockedBy: true,
        followerCount: 9,
      ),
    );

    expect(await controller.toggleBlock(), isFalse);
    expect(controller.state.isFollowing, isTrue);
    expect(controller.state.isBlocked, isFalse);
    expect(controller.state.isBlockedBy, isTrue);
    expect(controller.state.failure?.requestId, 'block-request-id');
  });
}

class _FakeUserRelationRepository implements UserRelationRepository {
  _FakeUserRelationRepository({this.onFollow, this.onBlock});

  final Future<void> Function()? onFollow;
  final Future<void> Function()? onBlock;
  int followCalls = 0;
  int unfollowCalls = 0;
  int blockCalls = 0;
  int unblockCalls = 0;

  @override
  Future<void> follow(String userId) {
    followCalls += 1;
    return onFollow?.call() ?? Future.value();
  }

  @override
  Future<void> unfollow(String userId) async {
    unfollowCalls += 1;
  }

  @override
  Future<void> block(String userId) {
    blockCalls += 1;
    return onBlock?.call() ?? Future.value();
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
