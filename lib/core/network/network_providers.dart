import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.fromDefines(),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => SecureTokenStore(ref.watch(secureStorageProvider)),
);

final refreshDioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: environment.apiBaseUri.toString(),
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final sessionRemoteProvider = Provider<SessionRemote>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final api = WenyouApi(
    dio: ref.watch(refreshDioProvider),
    basePathOverride: environment.apiOrigin,
    interceptors: const [],
  );
  return ApiSessionRemote(api.getAuthApi());
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      return SessionController(
        ref.watch(tokenStoreProvider),
        ref.watch(sessionRemoteProvider),
      );
    });

final dioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: environment.apiBaseUri.toString(),
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([
    RequestContextInterceptor(
      dio,
      ref.read(sessionControllerProvider.notifier),
    ),
    SafeRetryInterceptor(dio),
  ]);
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final wenyouApiProvider = Provider<WenyouApi>((ref) {
  return WenyouApi(
    dio: ref.watch(dioProvider),
    basePathOverride: ref.watch(appEnvironmentProvider).apiOrigin,
    interceptors: const [],
  );
});
