import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_list_repository.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_list_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';

import '../../support/deterministic_test_fonts.dart';
import 'me_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final startOnHeader in [true, false]) {
    testWidgets('我的从${startOnHeader ? '资料头' : '内容列表'}下拉采用新的关注粉丝数', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = MePageTestFakeMeProfileRepository(
        initialProfile: _profile(following: 3, followers: 13),
      );
      final container = await mePageTestAuthenticatedContainer(repository);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const MePage()),
        ),
      );
      await tester.pumpAndSettle();
      _expectCount('following', '3');
      _expectCount('followers', '13');
      repository.profile = _profile(following: 2, followers: 12);
      final start = startOnHeader
          ? tester.getCenter(find.byKey(const Key('me-profile-header')))
          : const Offset(195, 550);
      await tester.dragFrom(start, const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(repository.fetchCalls, 2);
      _expectCount('following', '2');
      _expectCount('followers', '12');
    });
  }

  for (final staleRefresh in [false, true]) {
    testWidgets('粉丝管理移除后返回我的并再次下拉采用新计数，旧读取迟到=$staleRefresh', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = MePageTestFakeMeProfileRepository(
        initialProfile: _profile(following: 1, followers: 1),
      );
      final relations = _Relations(repository);
      final container = ProviderContainer(
        overrides: [
          ...productionProviderOverrides(),
          startupControllerProvider.overrideWith((ref) => _ReadyStartup()),
          tokenStoreProvider.overrideWithValue(MePageTestMemoryTokenStore()),
          sessionRemoteProvider.overrideWithValue(
            MePageTestFakeSessionRemote(),
          ),
          stickersEnabledProvider.overrideWithValue(false),
          apiMeProfileRepositoryProvider.overrideWithValue(repository),
          apiPublicUserRepositoryProvider.overrideWithValue(
            MePageTestFakePublicUserRepository(),
          ),
          apiWalletRepositoryProvider.overrideWithValue(
            MePageTestFakeWalletRepository(),
          ),
          apiUserRelationListRepositoryProvider.overrideWithValue(relations),
          apiUserRelationRepositoryProvider.overrideWithValue(relations),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(sessionControllerProvider.notifier)
          .authenticate(
            SessionTokens(
              accessToken:
                  'header.${base64Url.encode(utf8.encode('{"sub":"user-1"}'))}.signature',
              refreshToken: 'fixture-refresh',
            ),
          );
      final router = GoRouter(
        initialLocation: '/me',
        routes: [
          GoRoute(path: '/me', builder: (_, _) => const MePage()),
          GoRoute(
            name: 'me-followers',
            path: '/me/followers',
            builder: (_, _) => const UserRelationListPage(
              target: UserRelationListTarget.current(
                kind: UserRelationListKind.followers,
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      _expectCount('following', '1');
      _expectCount('followers', '1');
      final stale = Completer<MeProfileModel>();
      Future<void>? pendingRefresh;
      if (staleRefresh) {
        repository.deferNextFetch(stale);
        pendingRefresh = container
            .read(meProfileControllerProvider.notifier)
            .refresh();
      }
      await tester.tap(find.byKey(const Key('me-open-followers')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('more-peer')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('removeFollower-peer')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-remove-follower')));
      await tester.pumpAndSettle();
      expect(relations.removeCalls, 1);
      expect(find.text('粉丝 0'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      _expectCount('following', '1');
      _expectCount('followers', '0');
      if (staleRefresh) {
        stale.complete(_profile(following: 1, followers: 1));
        await pendingRefresh;
        await tester.pumpAndSettle();
        _expectCount('followers', '0');
      }
      final beforeRefresh = repository.fetchCalls;
      await tester.dragFrom(const Offset(195, 550), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(repository.fetchCalls, beforeRefresh + 1);
      _expectCount('following', '1');
      _expectCount('followers', '0');
    });
  }
}

void _expectCount(String relation, String count) {
  expect(
    find.descendant(
      of: find.byKey(Key('me-open-$relation')),
      matching: find.text(count),
    ),
    findsOneWidget,
  );
}

MeProfileModel _profile({required int following, required int followers}) {
  final original = mePageTestProfile;
  return MeProfileModel(
    id: original.id,
    email: original.email,
    username: original.username,
    level: original.level,
    experience: original.experience,
    currentLevelExperience: original.currentLevelExperience,
    receivedTipTotal: original.receivedTipTotal,
    receivedTipCount: original.receivedTipCount,
    showRecentReplies: original.showRecentReplies,
    showPlayedThreads: original.showPlayedThreads,
    showBookmarks: original.showBookmarks,
    followingCount: following,
    followerCount: followers,
    createdAt: original.createdAt,
    updatedAt: original.updatedAt,
  );
}

class _Relations
    implements
        UserRelationRepository,
        FollowerRemovalRepository,
        UserRelationListRepository {
  _Relations(this.profiles);
  final MePageTestFakeMeProfileRepository profiles;
  int removeCalls = 0;
  bool followedBy = true;
  UserRelationListItem get peer => UserRelationListItem(
    userId: 'peer',
    username: '互关旅人',
    level: 1,
    relatedAt: DateTime.utc(2026),
    viewerIsFollowing: true,
    viewerIsFollowedBy: followedBy,
  );
  @override
  Future<void> removeFollower(String userId) async {
    expect(userId, 'peer');
    removeCalls++;
    followedBy = false;
    profiles.profile = _profile(following: 1, followers: 0);
  }

  @override
  Future<List<UserRelationListItem>> fetchFollowing({String? userId}) async => [
    peer,
  ];
  @override
  Future<List<UserRelationListItem>> fetchFollowers({String? userId}) async =>
      followedBy ? [peer] : [];
  @override
  Future<List<UserRelationListItem>> fetchBlocks() async => [];
  @override
  Future<void> block(String userId) => throw UnimplementedError();
  @override
  Future<void> follow(String userId) => throw UnimplementedError();
  @override
  Future<void> unfollow(String userId) => throw UnimplementedError();
  @override
  Future<void> unblock(String userId) => throw UnimplementedError();
}

class _ReadyStartup extends StateNotifier<StartupState>
    implements StartupController {
  _ReadyStartup()
    : super(
        const StartupState.ready(
          ContractInfo(
            contractVersion: '5.27.0-dev.20260927.1',
            markdownContractVersion: 4,
          ),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
