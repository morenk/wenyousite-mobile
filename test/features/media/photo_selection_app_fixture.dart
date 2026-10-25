import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/platform/android_background_notification_gateway.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_instant_keyboard_insets.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';

import '../../app_shell_fixtures.dart';
import '../../support/memory_pending_media_file_store.dart';
import '../../support/moment_test_draft_store.dart';
import '../editor/thread_compose_page_fixtures.dart';
import '../users/me_page_test_support.dart';

/// 使用完整生产装配和真实路由，只替换网络、存储与通知系统 IO。
/// 三种选图端口、协调器、宿主和 DevicePhotoLibrary 均保持生产实现。
class PhotoEntryAppFixture {
  PhotoEntryAppFixture({
    List<Override> overrides = const [],
    bool stickers = false,
    MeProfileRepository? profiles,
    bool readyStartup = true,
  }) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          handler.reject(DioException(requestOptions: request));
        },
      ),
    );
    container = ProviderContainer(
      overrides: [
        ...productionProviderOverrides(),
        if (readyStartup)
          startupControllerProvider.overrideWith((ref) => _ReadyStartup()),
        tokenStoreProvider.overrideWithValue(MePageTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(MePageTestFakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(stickers),
        dioProvider.overrideWithValue(dio),
        androidBackgroundNotificationGatewayProvider.overrideWithValue(
          _Notifications(),
        ),
        apiHomeRepositoryProvider.overrideWithValue(
          AppShellTestEmptyHomeRepository(),
        ),
        apiNotificationRepositoryProvider.overrideWithValue(
          AppShellTestEmptyNotificationRepository(),
        ),
        apiMeProfileRepositoryProvider.overrideWithValue(
          profiles ?? MePageTestFakeMeProfileRepository(),
        ),
        apiPublicUserRepositoryProvider.overrideWithValue(
          MePageTestFakePublicUserRepository(),
        ),
        apiWalletRepositoryProvider.overrideWithValue(
          AppShellTestNoopWalletRepository(),
        ),
        apiThreadComposeRepositoryProvider.overrideWithValue(
          _ComposeRepository(),
        ),
        databaseEditorSnapshotStoreProvider.overrideWithValue(
          ThreadComposePageTestMemorySnapshotStore(),
        ),
        // 后置 IO override 不替换生产选择端口，不触碰真实磁盘或上传。
        memoryPendingMediaFileStoreOverride(),
        momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
        mediaUploadGatewayPortProvider.overrideWithValue(uploads),
        appDatabaseProvider.overrideWith((ref) {
          final database = AppDatabase.forTesting(NativeDatabase.memory());
          ref.onDispose(database.close);
          return database;
        }),
        ...overrides,
      ],
    );
  }
  final dio = Dio();
  final requests = <RequestOptions>[];
  final uploads = MePageTestFakeMediaRepository();
  bool _disposed = false;
  late final ProviderContainer container;
  BuildContext get routeContext => container
      .read(appRouterProvider)
      .routerDelegate
      .navigatorKey
      .currentContext!;
  Future<void> pump(WidgetTester tester, String location) async {
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(
          SessionTokens(
            accessToken:
                'e30.${base64Url.encode(utf8.encode('{"sub":"user-1"}'))}.signature',
            refreshToken: 'fixture-refresh',
          ),
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const WenyouApp()),
    );
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go(location);
    await tester.pumpAndSettle();
  }

  void expectNoWrites() {
    expect(requests.where((request) => request.method != 'GET'), isEmpty);
    expect(uploads.uploadCalls, 0);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    container.dispose();
    dio.close(force: true);
  }
}

Future<void> photoEntryKeyboardTarget(
  WidgetTester tester,
  double bottom,
) async {
  final completed = Completer<void>();
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    WenyouInstantKeyboardInsets.channelName,
    const StandardMethodCodec().encodeMethodCall(
      MethodCall('keyboardInsetTargetChanged', {
        'bottomPhysicalPixels': bottom,
      }),
    ),
    (_) => completed.complete(),
  );
  await completed.future;
  await tester.pumpAndSettle();
}

class _ReadyStartup extends StateNotifier<StartupState>
    implements StartupController {
  _ReadyStartup()
    : super(
        const StartupState.ready(
          ContractInfo(
            contractVersion: '5.44.0-dev.20261024.2',
            markdownContractVersion: 5,
          ),
        ),
      );
  @override
  Future<void> check() async {}
  @override
  Future<void> dismissRecommendedUpdate() async {}
  @override
  Future<void> recheckForUpdate({bool showFailure = false}) async {}
}

class _ComposeRepository extends ThreadComposePageTestFakeRepository {
  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() async =>
      ThreadComposeBootstrap(
        userId: 'user-1',
        categories: (await super.fetchBootstrap()).categories,
      );
}

class _Notifications implements BackgroundNotificationGateway {
  @override
  bool get isSupported => false;
  @override
  Stream<String> get notificationTaps => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> canNotify() async => false;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {}
  @override
  Future<String?> takeLaunchPayload() async => null;
}
