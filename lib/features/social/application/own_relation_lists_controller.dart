import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

enum OwnRelationAction { follow, unfollow, removeFollower, block }

class OwnRelationList {
  const OwnRelationList({
    this.items = const [],
    this.loaded = false,
    this.loading = false,
    this.failure,
  });

  final List<UserRelationListItem> items;
  final bool loaded;
  final bool loading;
  final ApiFailure? failure;
}

class OwnRelationListsState {
  const OwnRelationListsState({
    this.following = const OwnRelationList(),
    this.followers = const OwnRelationList(),
    this.pending = const {},
    this.failures = const {},
    this.unconfirmed = const {},
    this.blocked = const {},
  });

  final OwnRelationList following;
  final OwnRelationList followers;
  final Map<String, OwnRelationAction> pending;
  final Map<String, ApiFailure> failures;
  final Set<String> unconfirmed;
  final Set<String> blocked;

  OwnRelationList list(UserRelationListKind kind) =>
      kind == UserRelationListKind.following ? following : followers;

  OwnRelationListsState copyWith({
    OwnRelationList? following,
    OwnRelationList? followers,
    Map<String, OwnRelationAction>? pending,
    Map<String, ApiFailure>? failures,
    Set<String>? unconfirmed,
    Set<String>? blocked,
  }) => OwnRelationListsState(
    following: following ?? this.following,
    followers: followers ?? this.followers,
    pending: pending ?? this.pending,
    failures: failures ?? this.failures,
    unconfirmed: unconfirmed ?? this.unconfirmed,
    blocked: blocked ?? this.blocked,
  );
}

/// 本人两页签共享行锁与列表投影，防止切换页签后重复写同一关系。
class OwnRelationListsController
    extends AutoDisposeNotifier<OwnRelationListsState> {
  @override
  OwnRelationListsState build() {
    ref.watch(sessionScopeProvider);
    ref.listen(contentVisibilityRevisionProvider, (_, _) {
      _visibilityRefreshNeeded = true;
      _restoreIncompleteLoads();
    });
    _lists = ref.watch(userRelationListRepositoryProvider);
    _relations = ref.watch(userRelationRepositoryProvider);
    _onProfileChanged = ref.read(profileCacheInvalidatorProvider);
    final generation = ++_generation;
    _active = true;
    _epochs.clear();
    _writeRevision = 0;
    _unknownBlocks.clear();
    _visibilityRefreshNeeded = false;
    _visibilityRefreshRunning = false;
    ref.onDispose(() {
      if (generation == _generation) _active = false;
    });
    Future.microtask(() {
      if (_isCurrent(generation)) unawaited(refreshAll());
    });
    return const OwnRelationListsState();
  }

  late UserRelationListRepository _lists;
  late UserRelationRepository _relations;
  late ProfileCacheInvalidator _onProfileChanged;
  final _reconciler = const WriteReconciler();
  final _epochs = <UserRelationListKind, int>{};
  var _writeRevision = 0;
  var _refreshEpoch = 0;
  var _generation = 0;
  var _active = false;
  var _visibilityRefreshNeeded = false;
  var _visibilityRefreshRunning = false;
  final _unknownBlocks = <String>{};
  bool get isActive => _active;
  bool _isCurrent(int generation) => _active && generation == _generation;

  Future<void> _removeFollower(String userId) {
    final repository = _relations;
    return repository is FollowerRemovalRepository
        ? (repository as FollowerRemovalRepository).removeFollower(userId)
        : Future.error(
            const ApiFailure.invalidResponse(
              diagnosticCode: 'follower_removal_repository_unavailable',
            ),
          );
  }

  Future<void> refreshAll({bool reconcile = true}) async {
    final epoch = ++_refreshEpoch;
    final generation = _generation;
    final revision = _writeRevision;
    await Future.wait([
      load(UserRelationListKind.following),
      load(UserRelationListKind.followers),
    ]);
    final verifiedBlocks = <String, bool>{};
    if (_isCurrent(generation)) {
      for (final id in {...state.blocked, if (reconcile) ..._unknownBlocks}) {
        if (!_isCurrent(generation)) return;
        try {
          verifiedBlocks[id] = (await _fetchRelation(id)).isBlocked;
        } on Object {
          // 保留原写失败和行锁；读取失败不授权重新写入。
        }
      }
    }
    if (_isCurrent(generation) &&
        epoch == _refreshEpoch &&
        revision == _writeRevision &&
        state.pending.isEmpty &&
        state.following.loaded &&
        state.followers.loaded &&
        state.following.failure == null &&
        state.followers.failure == null) {
      if (reconcile) _unknownBlocks.removeAll(verifiedBlocks.keys);
      state = state.copyWith(
        failures: reconcile
            ? {
                for (final entry in state.failures.entries)
                  if (_unknownBlocks.contains(entry.key))
                    entry.key: entry.value,
              }
            : state.failures,
        unconfirmed: reconcile ? {..._unknownBlocks} : state.unconfirmed,
        blocked: {
          ...state.blocked.where((id) => verifiedBlocks[id] != false),
          for (final entry in verifiedBlocks.entries)
            if (entry.value) entry.key,
        },
      );
    }
  }

  Future<void> load(UserRelationListKind kind) async {
    if (!_active || state.pending.isNotEmpty) return;
    final generation = _generation;
    final epoch = (_epochs[kind] ?? 0) + 1;
    _epochs[kind] = epoch;
    final revision = _writeRevision;
    final before = state.list(kind);
    _setList(
      kind,
      OwnRelationList(
        items: before.items,
        loaded: before.loaded,
        loading: true,
      ),
    );
    try {
      final items = await _fetch(kind);
      if (!_isCurrent(generation) || epoch != _epochs[kind]) return;
      if (revision != _writeRevision) return;
      _setList(kind, OwnRelationList(items: items, loaded: true));
    } on Object catch (error) {
      if (!_isCurrent(generation) ||
          epoch != _epochs[kind] ||
          revision != _writeRevision) {
        return;
      }
      _setList(
        kind,
        OwnRelationList(
          items: before.items,
          loaded: before.loaded,
          failure: mapApplicationFailure(error, '列表加载失败，请稍后重试。'),
        ),
      );
    }
  }

  Future<List<UserRelationListItem>> _fetch(UserRelationListKind kind) =>
      kind == UserRelationListKind.following
      ? _lists.fetchFollowing()
      : _lists.fetchFollowers();

  void _setList(UserRelationListKind kind, OwnRelationList list) {
    state = kind == UserRelationListKind.following
        ? state.copyWith(following: list)
        : state.copyWith(followers: list);
  }

  Future<bool> act(UserRelationListItem item, OwnRelationAction action) async {
    final generation = _generation;
    final id = item.userId;
    if (!_active ||
        state.pending.containsKey(id) ||
        state.unconfirmed.contains(id) ||
        (action == OwnRelationAction.block && state.blocked.contains(id)) ||
        !item.hasRelationState) {
      return false;
    }
    final current = [
      ...state.following.items,
      ...state.followers.items,
    ].where((candidate) => candidate.userId == id).firstOrNull;
    if (current == null ||
        !current.hasRelationState ||
        (action == OwnRelationAction.follow &&
            current.viewerIsFollowing != false) ||
        (action == OwnRelationAction.unfollow &&
            current.viewerIsFollowing != true) ||
        (action == OwnRelationAction.removeFollower &&
            current.viewerIsFollowedBy != true)) {
      return false;
    }
    _writeRevision++;
    // 旧刷新不能覆盖已经开始的写入，也不保留失效的刷新指示。
    state = state.copyWith(
      following: OwnRelationList(
        items: state.following.items,
        loaded: state.following.loaded,
      ),
      followers: OwnRelationList(
        items: state.followers.items,
        loaded: state.followers.loaded,
      ),
      pending: {...state.pending, id: action},
      failures: {...state.failures}..remove(id),
    );
    if (action == OwnRelationAction.block) {
      return _block(id, generation);
    }
    final kind = action == OwnRelationAction.removeFollower
        ? UserRelationListKind.followers
        : UserRelationListKind.following;
    final outcome = await _reconciler.run<void, List<UserRelationListItem>>(
      write: () => switch (action) {
        OwnRelationAction.follow => _relations.follow(id),
        OwnRelationAction.unfollow => _relations.unfollow(id),
        OwnRelationAction.removeFollower => _removeFollower(id),
        OwnRelationAction.block => throw StateError('拉黑有独立关系核实流程。'),
      },
      read: () => _fetch(kind),
      targetReached: (items) => action == OwnRelationAction.follow
          ? items.any(
              (entry) => entry.userId == id && entry.viewerIsFollowing == true,
            )
          : !items.any((entry) => entry.userId == id),
      failureMessage: '操作失败，请稍后重试。',
      isCurrent: () => _isCurrent(generation),
    );
    if (!_isCurrent(generation) || outcome.isDiscarded) return false;
    _writeRevision++;
    state = state.copyWith(pending: {...state.pending}..remove(id));
    if (outcome.status == WriteOutcomeStatus.completed) {
      final authoritative = outcome.projection
          ?.where((item) => item.userId == id)
          .firstOrNull;
      _apply(authoritative ?? current, action);
      _onProfileChanged(id);
      _restoreIncompleteLoads();
      return true;
    }
    final unknown = outcome.status == WriteOutcomeStatus.indeterminate;
    state = state.copyWith(
      failures: {
        ...state.failures,
        // 保留原失败分类与诊断信息，不再合成带页面文案的网络异常。
        id: ?outcome.failure,
      },
      unconfirmed: unknown ? {...state.unconfirmed, id} : state.unconfirmed,
    );
    if (unknown) _onProfileChanged(id);
    _restoreIncompleteLoads();
    return false;
  }

  void _restoreIncompleteLoads() {
    if (state.pending.isNotEmpty) return;
    if (_visibilityRefreshNeeded) {
      if (!_visibilityRefreshRunning) unawaited(_refreshVisibility());
      return;
    }
    if (!state.following.loaded) {
      unawaited(load(UserRelationListKind.following));
    }
    if (!state.followers.loaded) {
      unawaited(load(UserRelationListKind.followers));
    }
  }

  Future<void> _refreshVisibility() async {
    final generation = _generation;
    final revision = _writeRevision;
    _visibilityRefreshNeeded = false;
    _visibilityRefreshRunning = true;
    await refreshAll(reconcile: false);
    if (!_isCurrent(generation)) return;
    _visibilityRefreshRunning = false;
    if (revision != _writeRevision) _visibilityRefreshNeeded = true;
    if (_visibilityRefreshNeeded) _restoreIncompleteLoads();
  }

  Future<UserRelationProjection> _fetchRelation(String id) {
    final repository = _relations;
    return repository is UserRelationProjectionReader
        ? (repository as UserRelationProjectionReader).fetchRelation(id)
        : Future.error(
            const ApiFailure.invalidResponse(
              diagnosticCode: 'relation_projection_reader_unavailable',
            ),
          );
  }

  Future<bool> _block(String id, int generation) async {
    final outcome = await _reconciler.run<void, UserRelationProjection>(
      write: () => _relations.block(id),
      read: () => _fetchRelation(id),
      targetReached: (projection) => projection.isBlocked,
      failureMessage: '拉黑失败，请稍后重试。',
      isCurrent: () => _isCurrent(generation),
    );
    if (!_isCurrent(generation) || outcome.isDiscarded) return false;
    _writeRevision++;
    final completed = outcome.status == WriteOutcomeStatus.completed;
    final unknown = outcome.status == WriteOutcomeStatus.indeterminate;
    if (unknown) _unknownBlocks.add(id);
    state = state.copyWith(
      pending: {...state.pending}..remove(id),
      blocked: completed ? {...state.blocked, id} : state.blocked,
      failures: {...state.failures, id: ?outcome.failure},
      unconfirmed: unknown ? {...state.unconfirmed, id} : state.unconfirmed,
    );
    if (completed || unknown) {
      _onProfileChanged(id);
      ref.read(visibilityCacheInvalidatorProvider)();
    }
    _restoreIncompleteLoads();
    return completed;
  }

  void _apply(UserRelationListItem item, OwnRelationAction action) {
    final updated = switch (action) {
      OwnRelationAction.follow => item.withRelation(following: true),
      OwnRelationAction.unfollow => item.withRelation(following: false),
      OwnRelationAction.removeFollower => item.withRelation(followedBy: false),
      OwnRelationAction.block => item,
    };
    for (final kind in [
      UserRelationListKind.following,
      UserRelationListKind.followers,
    ]) {
      final list = state.list(kind);
      final shouldInclude = kind == UserRelationListKind.following
          ? updated.viewerIsFollowing == true
          : updated.viewerIsFollowedBy == true;
      final exists = list.items.any((entry) => entry.userId == item.userId);
      _setList(
        kind,
        OwnRelationList(
          loaded: list.loaded,
          items: [
            for (final entry in list.items)
              if (entry.userId != item.userId)
                entry
              else if (shouldInclude)
                updated,
            if (!exists && shouldInclude && list.loaded) updated,
          ],
        ),
      );
    }
  }
}

final ownRelationListsControllerProvider =
    NotifierProvider.autoDispose<
      OwnRelationListsController,
      OwnRelationListsState
    >(
      OwnRelationListsController.new,
      dependencies: [
        sessionScopeProvider,
        contentVisibilityRevisionProvider,
        visibilityCacheInvalidatorProvider,
        userRelationRepositoryProvider,
        userRelationListRepositoryProvider,
        profileCacheInvalidatorProvider,
      ],
    );
