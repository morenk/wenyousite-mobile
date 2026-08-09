import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_controller.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_list_repository.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';

void main() {
  test('按目标类型加载公开关注列表', () async {
    final listRepository = _FakeListRepository();
    final controller = UserRelationListController(
      listRepository,
      _FakeRelationRepository(),
      const UserRelationListTarget.public(
        kind: UserRelationListKind.following,
        userId: 'user-1',
      ),
    );
    addTearDown(controller.dispose);

    await _flush();

    expect(controller.state.phase, UserRelationListPhase.ready);
    expect(controller.state.items.single.userId, 'following-1');
    expect(listRepository.lastFollowingUserId, 'user-1');
  });

  test('后发刷新胜过先发旧响应', () async {
    final first = Completer<List<UserRelationListItem>>();
    final listRepository = _FakeListRepository(firstFollowing: first.future);
    final controller = UserRelationListController(
      listRepository,
      _FakeRelationRepository(),
      const UserRelationListTarget.current(
        kind: UserRelationListKind.following,
      ),
    );
    addTearDown(controller.dispose);
    await _flush();

    final refresh = controller.load();
    await refresh;
    first.complete([_item('stale', '旧结果')]);
    await _flush();

    expect(controller.state.items.single.userId, 'following-1');
  });

  test('取消拉黑成功后才移除且防止并发写入', () async {
    final unblock = Completer<void>();
    final relationRepository = _FakeRelationRepository(
      unblockFuture: unblock.future,
    );
    final controller = UserRelationListController(
      _FakeListRepository(),
      relationRepository,
      const UserRelationListTarget.current(kind: UserRelationListKind.blocks),
    );
    addTearDown(controller.dispose);
    await _flush();

    final first = controller.unblock('blocked-1');
    final second = await controller.unblock('blocked-1');
    expect(second, isFalse);
    expect(controller.state.items, hasLength(1));
    expect(relationRepository.unblockCalls, 1);

    unblock.complete();
    expect(await first, isTrue);
    expect(controller.state.items, isEmpty);
  });

  test('取消拉黑失败保留列表并暴露请求 ID', () async {
    final controller = UserRelationListController(
      _FakeListRepository(),
      _FakeRelationRepository(
        unblockFailure: const ApiFailure(
          userMessage: '取消失败',
          requestId: 'unblock-request-id',
        ),
      ),
      const UserRelationListTarget.current(kind: UserRelationListKind.blocks),
    );
    addTearDown(controller.dispose);
    await _flush();

    expect(await controller.unblock('blocked-1'), isFalse);

    expect(controller.state.items.single.userId, 'blocked-1');
    expect(controller.state.actionFailure?.requestId, 'unblock-request-id');
    expect(controller.state.isMutating, isFalse);
  });
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

class _FakeListRepository implements UserRelationListRepository {
  _FakeListRepository({this.firstFollowing});

  final Future<List<UserRelationListItem>>? firstFollowing;
  String? lastFollowingUserId;
  var followingCalls = 0;

  @override
  Future<List<UserRelationListItem>> fetchFollowing({String? userId}) {
    followingCalls += 1;
    lastFollowingUserId = userId;
    if (followingCalls == 1 && firstFollowing != null) return firstFollowing!;
    return Future.value([_item('following-1', '被关注者')]);
  }

  @override
  Future<List<UserRelationListItem>> fetchFollowers({String? userId}) async {
    return [_item('follower-1', '关注者')];
  }

  @override
  Future<List<UserRelationListItem>> fetchBlocks() async {
    return [_item('blocked-1', '被拉黑用户')];
  }
}

class _FakeRelationRepository implements UserRelationRepository {
  _FakeRelationRepository({this.unblockFuture, this.unblockFailure});

  final Future<void>? unblockFuture;
  final ApiFailure? unblockFailure;
  var unblockCalls = 0;

  @override
  Future<void> unblock(String userId) async {
    unblockCalls += 1;
    if (unblockFailure != null) throw unblockFailure!;
    if (unblockFuture != null) await unblockFuture;
  }

  @override
  Future<void> block(String userId) async {}

  @override
  Future<void> follow(String userId) async {}

  @override
  Future<void> unfollow(String userId) async {}
}

UserRelationListItem _item(String id, String username) {
  return UserRelationListItem(
    userId: id,
    username: username,
    level: 4,
    relatedAt: DateTime.utc(2026, 8, 10),
  );
}
