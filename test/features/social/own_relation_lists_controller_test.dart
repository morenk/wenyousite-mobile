import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/own_relation_lists_controller.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';

void main() {
  test('互关取消只移出关注页，粉丝保留并可回关，两页计数同步', () async {
    final fixture = _Fixture();
    await fixture.ready();
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.unfollow),
      true,
    );
    expect(fixture.controller.state.following.items, isEmpty);
    expect(
      fixture.controller.state.followers.items.single.viewerIsFollowing,
      false,
    );
    expect(
      await fixture.controller.act(
        fixture.controller.state.followers.items.single,
        OwnRelationAction.follow,
      ),
      true,
    );
    expect(fixture.controller.state.following.items, hasLength(1));
    expect(
      fixture.controller.state.followers.items.single.viewerIsFollowing,
      true,
    );
    expect(fixture.invalidations, ['u', 'u']);
  });

  test('移除互关粉丝仅移出粉丝页，自己的关注保留', () async {
    final fixture = _Fixture();
    await fixture.ready();
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.removeFollower),
      true,
    );
    expect(fixture.controller.state.followers.items, isEmpty);
    expect(
      fixture.controller.state.following.items.single.viewerIsFollowing,
      true,
    );
    expect(
      fixture.controller.state.following.items.single.viewerIsFollowedBy,
      false,
    );
    expect(fixture.relations.writes, ['remove:u']);
  });

  test('行锁跨页签共享，成功前不移行，其他用户仍可操作', () async {
    final fixture = _Fixture();
    fixture.lists.following.add(_item(id: 'v'));
    fixture.lists.followers.add(_item(id: 'v'));
    await fixture.ready();
    await fixture.controller.refreshAll();
    final pending = Completer<void>();
    fixture.relations.pause = pending.future;
    final first = fixture.controller.act(_item(), OwnRelationAction.unfollow);
    expect(fixture.controller.state.following.items, hasLength(2));
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.removeFollower),
      false,
    );
    fixture.relations.pause = null;
    expect(
      await fixture.controller.act(
        _item(id: 'v'),
        OwnRelationAction.removeFollower,
      ),
      true,
    );
    pending.complete();
    expect(await first, true);
    expect(fixture.relations.writes, ['unfollow:u', 'remove:v']);
    expect(fixture.controller.state.pending, isEmpty);
  });

  test('明确失败保留原行与两方向，允许用户重新操作', () async {
    final fixture = _Fixture();
    await fixture.ready();
    fixture.relations.failure = const ApiFailure(
      httpStatus: 403,
      userMessage: '操作失败',
    );
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.removeFollower),
      false,
    );
    expect(fixture.controller.state.following.items, hasLength(1));
    expect(fixture.controller.state.followers.items, hasLength(1));
    expect(fixture.controller.state.failures['u'], isNotNull);
    expect(fixture.controller.state.pending, isEmpty);
    expect(fixture.controller.state.unconfirmed, isEmpty);
  });

  test('移除超时但只读粉丝列表证实已移除，不重复写入', () async {
    final fixture = _Fixture();
    await fixture.ready();
    fixture.relations.failure = const ApiFailure(
      httpStatus: 503,
      reason: FailureReason.timeout,
    );
    fixture.lists.followers.clear();
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.removeFollower),
      true,
    );
    expect(fixture.relations.writes, ['remove:u']);
    expect(fixture.lists.followerReads, 2);
    expect(fixture.controller.state.followers.items, isEmpty);
  });

  test('超时只读仍为反向状态时保留原行，刷新两页成功前禁止重试', () async {
    final fixture = _Fixture();
    await fixture.ready();
    fixture.relations.failure = const ApiFailure(
      httpStatus: 503,
      reason: FailureReason.timeout,
    );
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.removeFollower),
      false,
    );
    expect(fixture.controller.state.unconfirmed, {'u'});
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.removeFollower),
      false,
    );
    fixture.lists.failFollowers = true;
    await fixture.controller.refreshAll();
    expect(fixture.controller.state.unconfirmed, {'u'});
    fixture.lists.failFollowers = false;
    await fixture.controller.refreshAll();
    expect(fixture.controller.state.unconfirmed, isEmpty);
    expect(fixture.relations.writes, ['remove:u']);
  });

  test('先发旧刷新不能覆盖后发操作，刷新保留已有列表', () async {
    final fixture = _Fixture();
    await fixture.ready();
    final stale = Completer<List<UserRelationListItem>>();
    fixture.lists.nextFollowing = stale.future;
    final refresh = fixture.controller.load(UserRelationListKind.following);
    expect(fixture.controller.state.following.items, hasLength(1));
    expect(
      await fixture.controller.act(_item(), OwnRelationAction.unfollow),
      true,
    );
    stale.complete([_item()]);
    await refresh;
    expect(fixture.controller.state.following.items, isEmpty);
    expect(fixture.controller.state.following.loading, false);
  });

  test('会话释放后迟到写入不更新资料或触发只读核对', () async {
    final fixture = _Fixture(autoDispose: false);
    await fixture.ready();
    final pending = Completer<void>();
    fixture.relations.pause = pending.future;
    final action = fixture.controller.act(_item(), OwnRelationAction.unfollow);
    fixture.container.dispose();
    pending.completeError(
      const ApiFailure(httpStatus: 503, reason: FailureReason.timeout),
    );
    expect(await action, false);
    expect(fixture.invalidations, isEmpty);
    expect(fixture.lists.followingReads, 1);
  });

  test('首次粉丝加载未完成时关注写失败也恢复被丢弃的粉丝加载', () async {
    final delayed = Completer<List<UserRelationListItem>>();
    final lists = _Lists()..nextFollowers = delayed.future;
    final relations = _Relations()..failure = const ApiFailure(httpStatus: 403);
    final fixture = _Fixture(lists: lists, relations: relations);
    final controller = fixture.controller;
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.following.loaded, true);
    expect(controller.state.followers.loaded, false);
    expect(await controller.act(_item(), OwnRelationAction.unfollow), false);
    await Future<void>.delayed(Duration.zero);
    expect(lists.followerReads, 2);
    expect(controller.state.followers.loaded, true);
    delayed.complete([]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.followers.items, hasLength(1));
  });

  test('旧契约缺字段保持未知，不根据所在列表猜测写操作', () async {
    final fixture = _Fixture();
    final unknown = UserRelationListItem(
      userId: 'u',
      username: '未知',
      level: 1,
      relatedAt: DateTime(2026),
    );
    fixture.lists.following = [unknown];
    fixture.lists.followers = [unknown];
    await fixture.ready();
    await fixture.controller.refreshAll();
    expect(
      await fixture.controller.act(unknown, OwnRelationAction.follow),
      false,
    );
    expect(
      await fixture.controller.act(unknown, OwnRelationAction.removeFollower),
      false,
    );
    expect(fixture.relations.writes, isEmpty);
  });
}

UserRelationListItem _item({String id = 'u'}) => UserRelationListItem(
  userId: id,
  username: '温柔旅人',
  level: 4,
  relatedAt: DateTime(2026, 9, 22),
  viewerIsFollowing: true,
  viewerIsFollowedBy: true,
);

class _Fixture {
  _Fixture({bool autoDispose = true, _Lists? lists, _Relations? relations})
    : lists = lists ?? _Lists(),
      relations = relations ?? _Relations() {
    container = ProviderContainer(
      overrides: [
        userRelationListRepositoryProvider.overrideWithValue(this.lists),
        userRelationRepositoryProvider.overrideWithValue(this.relations),
        profileCacheInvalidatorProvider.overrideWithValue((id) {
          if (id != null) invalidations.add(id);
        }),
      ],
    );
    container.listen(ownRelationListsControllerProvider, (_, _) {});
    controller = container.read(ownRelationListsControllerProvider.notifier);
    if (autoDispose) addTearDown(container.dispose);
  }
  final _Lists lists;
  final _Relations relations;
  final invalidations = <String>[];
  late final ProviderContainer container;
  late final OwnRelationListsController controller;
  Future<void> ready() => Future<void>.delayed(Duration.zero);
}

class _Lists implements UserRelationListRepository {
  List<UserRelationListItem> following = [_item()];
  List<UserRelationListItem> followers = [_item()];
  Future<List<UserRelationListItem>>? nextFollowing;
  Future<List<UserRelationListItem>>? nextFollowers;
  bool failFollowers = false;
  int followingReads = 0;
  int followerReads = 0;
  @override
  Future<List<UserRelationListItem>> fetchFollowing({String? userId}) async {
    followingReads++;
    final next = nextFollowing;
    nextFollowing = null;
    return next ?? List.of(following);
  }

  @override
  Future<List<UserRelationListItem>> fetchFollowers({String? userId}) async {
    followerReads++;
    final next = nextFollowers;
    nextFollowers = null;
    if (next != null) return next;
    if (failFollowers) throw const ApiFailure(reason: FailureReason.offline);
    return List.of(followers);
  }

  @override
  Future<List<UserRelationListItem>> fetchBlocks() async => [];
}

class _Relations implements UserRelationRepository, FollowerRemovalRepository {
  final writes = <String>[];
  Future<void>? pause;
  ApiFailure? failure;
  Future<void> write(String action) async {
    writes.add(action);
    if (pause != null) await pause;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> removeFollower(String userId) => write('remove:$userId');

  @override
  Future<void> follow(String userId) => write('follow:$userId');
  @override
  Future<void> unfollow(String userId) => write('unfollow:$userId');
  @override
  Future<void> block(String userId) async {}
  @override
  Future<void> unblock(String userId) async {}
}
