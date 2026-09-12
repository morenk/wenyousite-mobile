import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/data/recommended_update_dismiss_store.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

void appShellTestExpectFoundationPictureSize(
  WidgetTester tester,
  String semanticId,
  double expectedSize,
) {
  final icon = find.byWidgetPredicate(
    (widget) => widget is WenyouIcon && widget.semanticId == semanticId,
  );
  final picture = find.descendant(
    of: icon,
    matching: find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == 'SvgPicture',
    ),
  );
  expect(icon, findsOneWidget);
  expect(picture, findsOneWidget);
  expect(tester.getSize(picture), Size.square(expectedSize));
}

class AppShellTestCompatibleMetaRepository implements MetaRepository {
  @override
  Future<ContractInfo> fetch() async {
    return const ContractInfo(
      contractVersion: '5.0.0-dev.test',
      markdownContractVersion: 3,
    );
  }
}

class AppShellTestEmptyHomeRepository implements HomeRepository {
  @override
  Future<List<ThreadCategory>> fetchCategories() async => const [];

  @override
  Future<CursorPage<ThreadFeedCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) async {
    return const CursorPage(items: [], hasMore: false);
  }
}

class AppShellTestFakeMeProfileRepository implements MeProfileRepository {
  @override
  Future<MeProfileModel> fetchMe() async => appShellTestMeProfile;

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) {
    throw UnimplementedError();
  }
}

final appShellTestMeProfile = MeProfileModel(
  id: 'user-1',
  email: 'owner@example.com',
  username: '温柔测试员',
  level: 4,
  experience: 150,
  currentLevelExperience: 100,
  nextLevelExperience: 200,
  receivedTipTotal: '18',
  receivedTipCount: 6,
  showRecentReplies: true,
  showPlayedThreads: true,
  showBookmarks: true,
  followingCount: 7,
  followerCount: 9,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 10),
);

class AppShellTestFixedMetaRepository implements MetaRepository {
  AppShellTestFixedMetaRepository({
    required this.contractVersion,
    this.markdownContractVersion = 3,
    this.android = const MobilePlatformPolicy(),
    this.ios = const MobilePlatformPolicy(),
  });

  final String contractVersion;
  final int markdownContractVersion;
  final MobilePlatformPolicy android;
  final MobilePlatformPolicy ios;

  @override
  Future<ContractInfo> fetch() async {
    return ContractInfo(
      contractVersion: contractVersion,
      markdownContractVersion: markdownContractVersion,
      android: android,
      ios: ios,
    );
  }
}

class AppShellTestFakeMobileUpdateService
    implements MobileUpdateService, MobileUpdateAvailabilityChecker {
  AppShellTestFakeMobileUpdateService({
    required this.build,
    this.clientPlatform = MobileClientPlatform.android,
    this.releaseAvailable = true,
    this.targetVersion,
    this.availabilityCompleter,
  });

  final int build;
  final MobileClientPlatform clientPlatform;
  bool releaseAvailable;
  final String? targetVersion;
  final Completer<MobileUpdateAvailability>? availabilityCompleter;
  int launchCalls = 0;
  int availabilityChecks = 0;

  @override
  MobileClientPlatform get platform => clientPlatform;

  @override
  Future<MobileUpdateAvailability> checkAvailability(
    MobileUpdateInfo update,
  ) async {
    availabilityChecks += 1;
    final pending = availabilityCompleter;
    if (pending != null) return pending.future;
    return releaseAvailable
        ? MobileUpdateAvailability.available(targetVersion: targetVersion)
        : const MobileUpdateAvailability.preparing();
  }

  @override
  Future<InstalledAppInfo> readInstalledApp() async {
    return InstalledAppInfo(platform: platform, version: '0.3.0', build: build);
  }

  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  }) async {
    launchCalls += 1;
    onStage(
      platform == MobileClientPlatform.ios
          ? MobileUpdateStage.openingExternalPage
          : MobileUpdateStage.downloading,
    );
    onProgress(1);
    return platform == MobileClientPlatform.ios
        ? UpdateLaunchResult.externalPageOpened
        : UpdateLaunchResult.installerOpened;
  }
}

class AppShellTestMemoryRecommendedUpdateDismissStore
    implements RecommendedUpdateDismissStore {
  int? dismissedBuild;

  @override
  Future<void> dismiss(MobileClientPlatform platform, int build) async {
    dismissedBuild = build;
  }

  @override
  Future<bool> isDismissed(MobileClientPlatform platform, int build) async {
    return dismissedBuild == build;
  }
}

class AppShellTestRetryMetaRepository implements MetaRepository {
  int calls = 0;

  @override
  Future<ContractInfo> fetch() async {
    calls += 1;
    if (calls == 1) {
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'startup-request-id',
      );
    }
    return const ContractInfo(
      contractVersion: '5.0.0-dev.test',
      markdownContractVersion: 3,
    );
  }
}

class AppShellTestSuccessfulAuthRepository implements AuthRepository {
  String? lastAccount;
  String? lastRegistrationEmail;
  String? lastCode;
  String? lastUsername;

  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) async {
    lastAccount = account;
    return const SessionTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
  }

  @override
  Future<RegistrationCodeInfo> requestRegistrationCode({
    required String email,
  }) async {
    lastRegistrationEmail = email;
    return const RegistrationCodeInfo(expiresIn: Duration(minutes: 15));
  }

  @override
  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  }) async {
    lastRegistrationEmail = email;
    lastCode = code;
    lastUsername = username;
    return const SessionTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
  }
}

const appShellTestTokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

const appShellTestAndroidUpdateUrl =
    'https://wenyou.site/downloads/mobile/android/app.apk';

class AppShellTestMemoryTokenStore implements TokenStore {
  AppShellTestMemoryTokenStore([this.value]);

  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class AppShellTestFakeSessionRemote implements SessionRemote {
  AppShellTestFakeSessionRemote({this.onLogout});

  final Future<void> Function(SessionTokens tokens)? onLogout;
  int logoutCalls = 0;

  @override
  Future<void> logout(SessionTokens tokens) {
    logoutCalls += 1;
    return onLogout?.call(tokens) ?? Future.value();
  }

  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      appShellTestTokens;
}

class AppShellTestEmptyNotificationRepository
    implements NotificationRepository {
  AppShellTestEmptyNotificationRepository({this.unreadCount = 0});

  final int unreadCount;
  int fetchCalls = 0;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilters.all,
    String? cursor,
  }) async {
    fetchCalls += 1;
    return CursorPage(items: const [], hasMore: false);
  }

  @override
  Future<int> fetchUnreadCount() async => unreadCount;

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> setReadStatus(String id, {required bool isRead}) async {}
}

class AppShellTestNoopWalletRepository implements WalletRepository {
  @override
  Future<DailyCheckInResult> checkIn() async {
    return const DailyCheckInResult(
      claimedNow: false,
      date: '2026-08-10',
      rewardAmount: '1',
      experienceAwarded: 0,
      balance: '0',
      progression: WalletProgression(
        level: 1,
        experience: 0,
        currentLevelExperience: 0,
        nextLevelExperience: 100,
      ),
    );
  }

  @override
  Future<WalletSummary> fetchWallet() => throw UnimplementedError();

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) => throw UnimplementedError();
}
