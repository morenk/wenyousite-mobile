import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  for (final phase in ['reissue', 'confirm']) {
    test('$phase 40101 续期成功不重放，第二次明确重试才继续同媒体', () async {
      final fixture = _AuthMediaFixture(phase);
      await fixture.initialize();
      addTearDown(fixture.dispose);
      final scope = fixture.session.scope;
      await fixture.failAtAuthBoundary();
      expect(fixture.remote.refreshCalls, 1);
      expect(fixture.session.scope, scope);
      expect(fixture.session.tokens?.accessToken, 'new-access');
      expect(fixture.state.pendingUpload?.mediaId, 'media-one');
      expect(fixture.state.failure?.failure.businessCode, 40101);
      expect(
        fixture.state.failure?.failure.canRetryAfterSessionRefresh,
        isTrue,
      );
      expect(fixture.state.failure?.canRetry, isTrue);
      expect(
        fixture.state.failure?.presentation.recoveryAction,
        FailureRecoveryAction.retry,
      );
      expect(fixture.state.failure?.presentation.actionLabel, '重试');
      expect(fixture.adapter.authBoundaryCalls, 1);
      expect(fixture.adapter.putCount, 1);
      expect(fixture.adapter.allocateCount, 1);
      // 等待不会触发 POST 重放或另建媒体。
      await Future<void>.delayed(Duration.zero);
      expect(fixture.adapter.authBoundaryCalls, 1);

      expect((await fixture.controller.retryUpload())?.mediaId, 'media-one');
      expect(fixture.adapter.authBoundaryCalls, 2);
      expect(fixture.adapter.allocateCount, 1);
      expect(fixture.adapter.putCount, phase == 'reissue' ? 2 : 1);
      expect(fixture.remote.refreshCalls, 1);
      expect(fixture.adapter.authHeaders, [
        'Bearer old-access',
        'Bearer new-access',
      ]);
      expect(fixture.state.pendingUpload, isNull);
    });

    test('$phase 40101 续期离线失败不能冒充已续期手动恢复', () async {
      final fixture = _AuthMediaFixture(phase)
        ..remote.failure = const ApiFailure(
          source: FailureSource.network,
          reason: FailureReason.offline,
        );
      await fixture.initialize();
      addTearDown(fixture.dispose);
      await fixture.failAtAuthBoundary();
      expect(fixture.remote.refreshCalls, 1);
      expect(fixture.session.tokens?.accessToken, 'old-access');
      expect(fixture.state.pendingUpload?.mediaId, 'media-one');
      expect(
        fixture.state.failure?.failure.canRetryAfterSessionRefresh,
        isFalse,
      );
      expect(fixture.state.failure?.canRetry, isFalse);
      expect(await fixture.controller.retryUpload(), isNull);
      expect(fixture.adapter.authBoundaryCalls, 1);
      expect(fixture.adapter.allocateCount, 1);
    });
  }

  for (final code in [40100, 40103]) {
    test('重签返回 $code 不启用已续期重试入口', () async {
      final fixture = _AuthMediaFixture('reissue')..adapter.authCode = code;
      await fixture.initialize();
      addTearDown(fixture.dispose);
      await fixture.failAtAuthBoundary();
      expect(fixture.remote.refreshCalls, 0);
      expect(
        fixture.state.failure?.failure.canRetryAfterSessionRefresh ?? false,
        isFalse,
      );
      if (code == 40103) {
        expect(fixture.session.state.status, SessionStatus.invalidated);
        expect(fixture.state.pendingUpload, isNull);
      } else {
        expect(fixture.state.failure?.canRetry, isFalse);
        expect(fixture.state.pendingUpload?.mediaId, 'media-one');
      }
      expect(await fixture.controller.retryUpload(), isNull);
      expect(fixture.adapter.authBoundaryCalls, 1);
      expect(fixture.adapter.allocateCount, 1);
    });
  }

  test('续期服务明确判定会话失效，清理原账号任务且禁止继续上传', () async {
    final fixture = _AuthMediaFixture('reissue')
      ..remote.failure = const ApiFailure(
        source: FailureSource.expected,
        reason: FailureReason.sessionInvalid,
        businessCode: 40103,
        httpStatus: 401,
      );
    await fixture.initialize();
    addTearDown(fixture.dispose);
    await fixture.failAtAuthBoundary();
    expect(fixture.remote.refreshCalls, 1);
    expect(fixture.session.state.status, SessionStatus.invalidated);
    expect(fixture.state.pendingUpload, isNull);
    expect(await fixture.controller.retryUpload(), isNull);
    expect(fixture.adapter.authBoundaryCalls, 1);
    expect(fixture.adapter.allocateCount, 1);
  });

  test('新请求清除调用方遗留续期标记，普通401仍不可重试', () async {
    final fixture = _AuthMediaFixture('reissue')..adapter.authCode = 40100;
    await fixture.initialize();
    addTearDown(fixture.dispose);
    DioException? failure;
    try {
      await fixture.apiDio.fetch<Object?>(
        RequestOptions(
          baseUrl: 'https://api.example.test',
          path: '/api/v1/media/media-one/upload-url',
          method: 'POST',
          extra: const {
            ApiRequestExtraKeys.noAutomaticReplay: true,
            ApiRequestExtraKeys.sessionRefreshedWithoutReplay: true,
            'fixture': 'preserved',
          },
        ),
      );
    } on DioException catch (error) {
      failure = error;
    }
    expect(failure, isNotNull);
    expect(
      failure!.requestOptions.extra.containsKey(
        ApiRequestExtraKeys.sessionRefreshedWithoutReplay,
      ),
      isFalse,
    );
    expect(ApiFailure.fromDio(failure).canRetryAfterSessionRefresh, isFalse);
    expect(
      failure.requestOptions.extra[ApiRequestExtraKeys.noAutomaticReplay],
      isTrue,
    );
    expect(failure.requestOptions.extra['fixture'], 'preserved');
  });
}

class _AuthMediaFixture {
  _AuthMediaFixture(String phase) : adapter = _MediaAdapter(phase) {
    session = SessionController(_MemoryTokenStore(), remote);
    apiDio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    apiDio.interceptors.add(RequestContextInterceptor(apiDio, session));
    putDio = Dio()..httpClientAdapter = adapter;
    final gateway = RepositoryMediaUploadGateway(
      ApiMediaUploadRepository(
        WenyouApi(dio: apiDio, interceptors: const []).getMediaApi(),
        putDio,
        delay: (_) async {},
      ),
    );
    container = ProviderContainer(
      overrides: [
        sessionControllerProvider.overrideWith((ref) => session),
        mediaUploadSessionScopePortProvider.overrideWith(
          (ref) => ref.watch(sessionScopeProvider),
        ),
        mediaUploadGatewayPortProvider.overrideWithValue(gateway),
      ],
    );
  }
  final _MediaAdapter adapter;
  final remote = _SessionRemote();
  late final SessionController session;
  late final Dio apiDio;
  late final Dio putDio;
  late final ProviderContainer container;
  late final ProviderSubscription<MediaUploadTaskState> subscription;
  final provider = mediaUploadTaskControllerProvider(Object());
  MediaUploadTaskController get controller => container.read(provider.notifier);
  MediaUploadTaskState get state => container.read(provider);

  Future<void> initialize() async {
    await session.authenticate(
      const SessionTokens(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
      ),
    );
    subscription = container.listen(provider, (_, _) {});
  }

  Future<void> failAtAuthBoundary() async {
    final input = MediaUploadInput(
      filename: 'original.gif',
      declaredContentType: 'image/gif',
      bytes: File(
        'test/fixtures/animation-webp-all-surfaces/original.gif',
      ).readAsBytesSync(),
    );
    expect(await controller.uploadInput(input), isNull);
    if (adapter.phase == 'reissue') {
      expect(state.pendingUpload?.needsTransfer, isTrue);
      expect(await controller.retryUpload(), isNull);
    }
    await container.pump();
  }

  void dispose() {
    subscription.close();
    container.dispose();
    apiDio.close();
    putDio.close();
  }
}

class _MediaAdapter implements HttpClientAdapter {
  _MediaAdapter(this.phase);
  final String phase;
  int authCode = 40101;
  int allocateCount = 0, putCount = 0, authBoundaryCalls = 0;
  final authHeaders = <Object?>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'PUT') {
      putCount++;
      if (phase == 'reissue' && putCount == 1) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      }
      return ResponseBody.fromString('', 200);
    }
    final allocate = options.path.endsWith('/media/upload-url');
    final reissue = options.path.endsWith('/media-one/upload-url');
    final confirm = options.path.endsWith('/media/upload-done');
    if (allocate) allocateCount++;
    if ((phase == 'reissue' && reissue) || (phase == 'confirm' && confirm)) {
      authBoundaryCalls++;
      authHeaders.add(options.headers['Authorization']);
      if (authBoundaryCalls == 1) {
        return _response({'code': authCode, 'message': 'expired'}, status: 401);
      }
    }
    final media = {
      'id': 'media-one',
      'userId': 'user-one',
      'url': 'https://cdn.example/original.gif',
      'key': 'original.gif',
      'contentType': 'image/gif',
      'size': 1383,
      'width': 320,
      'height': 180,
      'purpose': 'RICH_CONTENT',
      'animated': true,
      'status': confirm ? 'COMPLETED' : 'UPLOADING',
      'createdAt': '2026-09-12T00:00:00Z',
    };
    return _response({
      'code': 0,
      'message': 'ok',
      'data': allocate || reissue
          ? {
              'uploadUrl': 'https://storage.example/upload',
              'mediaId': 'media-one',
              'objectKey': 'original.gif',
              'publicUrl': 'https://cdn.example/original.gif',
            }
          : confirm
          ? {'processing': false, 'media': media}
          : media,
    });
  }

  ResponseBody _response(Object body, {int status = 200}) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
  @override
  void close({bool force = false}) {}
}

class _SessionRemote implements SessionRemote {
  int refreshCalls = 0;
  ApiFailure? failure;
  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    refreshCalls++;
    if (failure case final error?) throw error;
    return const SessionTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }

  @override
  Future<void> logout(SessionTokens tokens) async {}
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;
  @override
  Future<void> clear() async => value = null;
  @override
  Future<SessionTokens?> read() async => value;
  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}
