import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/network_recovery.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  for (final write in _RecoveryWrite.values) {
    test('后台冷却不阻断同 ID ${write.label}，40101 续期后仍需手动继续', () async {
      final fixture = _Fixture(write);
      await fixture.initialize();
      addTearDown(fixture.close);
      final task = fixture.task;
      final scope = fixture.session.scope;

      // 先从真实上传链路取得未完成的媒体身份。
      expect(await task.uploadInput(fixture.input), isNull);
      expect(task.state.pendingUpload?.mediaId, _mediaId);
      expect(fixture.adapter.allocations, 1);
      expect(fixture.adapter.puts, 1);
      fixture.adapter.failInitialOperation = false;
      fixture.adapter.expireNextWrite = true;
      fixture.adapter.holdNextQuery = true;

      await fixture.failBackgroundRead();
      final retry = task.retryUpload();
      await fixture.adapter.queryEntered.future.timeout(_signalTimeout);
      expect(fixture.adapter.queries, 1);
      await fixture.expectBackgroundSuppressed();

      // 查询仍在途时，下一轮后台读取再次失败。旧查询的成功不能
      // 清掉较新的冷却；随后显式 POST 的续期也不能被该冷却吞掉。
      fixture.elapsed += fixture.recovery.remaining;
      await fixture.failBackgroundRead();
      fixture.adapter.releaseQuery.complete();
      await fixture.remote.refreshEntered.future.timeout(_signalTimeout);
      expect(fixture.recovery.isCoolingDown, isTrue);
      expect(fixture.remote.startedDuringCooldown, isTrue);
      expect(fixture.remote.refreshCalls, 1);
      expect(fixture.remote.refreshTokens, ['refresh-old']);
      await fixture.expectBackgroundSuppressed();
      expect(
        fixture.adapter.recoveryWrites,
        write == _RecoveryWrite.reissue ? 1 : 2,
      );

      fixture.remote.releaseRefresh.complete();
      expect(await retry, isNull);
      expect(task.state.pendingUpload?.mediaId, _mediaId);
      expect(task.state.failure?.failure.businessCode, 40101);
      expect(task.state.failure?.canRetry, isTrue);
      expect(
        task.state.failure?.presentation.recoveryAction,
        FailureRecoveryAction.retry,
      );
      expect(fixture.session.scope, scope);
      expect(fixture.store.value?.refreshToken, 'refresh-new');
      expect(fixture.adapter.allocations, 1);
      expect(fixture.adapter.puts, 1);
      // 续期成功不代表用户批准再次发送重签或确认 POST。
      expect(
        fixture.adapter.recoveryWrites,
        write == _RecoveryWrite.reissue ? 1 : 2,
      );

      final result = await task.retryUpload();
      expect(result?.mediaId, _mediaId);
      expect(task.state.phase, MediaUploadTaskPhase.idle);
      expect(fixture.adapter.allocations, 1);
      expect(fixture.adapter.queries, 2);
      expect(fixture.adapter.puts, write == _RecoveryWrite.reissue ? 2 : 1);
      expect(fixture.adapter.reissues, write == _RecoveryWrite.reissue ? 2 : 0);
      expect(
        fixture.adapter.confirmations,
        write == _RecoveryWrite.reissue ? 1 : 3,
      );
      expect(fixture.adapter.confirmedIds, everyElement(_mediaId));
      expect(
        fixture.adapter.recoveryAuthorization.last,
        'Bearer ${_newTokens.accessToken}',
      );
      expect(fixture.remote.refreshCalls, 1);
      expect(fixture.session.scope, scope);
      expect(fixture.adapter.backgroundReads, 2);
    });
  }
}

const _mediaId = 'media-one';
const _signalTimeout = Duration(seconds: 5);
final _oldTokens = _tokens('old');
final _newTokens = _tokens('new');

SessionTokens _tokens(String version) {
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({'sub': 'user-one', 'exp': 4102444800, 'v': version}),
        ),
      )
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-$version',
  );
}

enum _RecoveryWrite {
  reissue('重签'),
  confirm('确认');

  const _RecoveryWrite(this.label);
  final String label;
}

class _Fixture {
  _Fixture(this.write);

  final _RecoveryWrite write;
  Duration elapsed = Duration.zero;
  late final recovery = NetworkRecovery(elapsed: () => elapsed);
  final store = _MemoryTokenStore();
  late final remote = _SessionRemote(recovery);
  late final session = SessionController(store, remote, recovery: recovery);
  late final input = MediaUploadInput(
    filename: 'original.gif',
    declaredContentType: 'image/gif',
    bytes: File(
      'test/fixtures/animation-webp-all-surfaces/original.gif',
    ).readAsBytesSync(),
  );
  late final adapter = _MediaAdapter(write, input.bytes.length);
  late final apiDio = Dio(BaseOptions(baseUrl: 'https://api.invalid'))
    ..httpClientAdapter = adapter;
  late final putDio = Dio()..httpClientAdapter = adapter;
  final provider = mediaUploadTaskControllerProvider(Object());
  late final ProviderContainer container;
  late final ProviderSubscription<MediaUploadTaskState> subscription;

  MediaUploadTaskController get task => container.read(provider.notifier);

  Future<void> initialize() async {
    await session.authenticate(_oldTokens);
    apiDio.interceptors.addAll([
      RequestContextInterceptor(apiDio, session),
      SafeRetryInterceptor(apiDio, wait: (_) async {}),
    ]);
    final coordinator = MediaUploadWorkCoordinator();
    final gateway = RepositoryMediaUploadGateway(
      ApiMediaUploadRepository(
        WenyouApi(dio: apiDio, interceptors: const []).getMediaApi(),
        putDio,
        workCoordinator: coordinator,
        maxPollAttempts: 1,
        delay: (_) async {},
      ),
      workCoordinator: coordinator,
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
    subscription = container.listen(provider, (_, _) {});
  }

  Future<void> failBackgroundRead() async {
    final before = adapter.backgroundReads;
    await expectLater(
      runAutomaticNetworkRequests(() => apiDio.get<Object?>('/background')),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          '实际后台错误',
          503,
        ),
      ),
    );
    expect(adapter.backgroundReads, before + 1);
    expect(recovery.isCoolingDown, isTrue);
  }

  Future<void> expectBackgroundSuppressed() async {
    final before = adapter.backgroundReads;
    await expectLater(
      runAutomaticNetworkRequests(() => apiDio.get<Object?>('/background')),
      throwsA(
        isA<DioException>().having(
          (error) => ApiFailure.fromDio(error).isCancellation,
          '冷却中未发送',
          isTrue,
        ),
      ),
    );
    expect(adapter.backgroundReads, before);
  }

  void close() {
    if (!adapter.releaseQuery.isCompleted) adapter.releaseQuery.complete();
    if (!remote.releaseRefresh.isCompleted) remote.releaseRefresh.complete();
    subscription.close();
    container.dispose();
    apiDio.close(force: true);
    putDio.close(force: true);
  }
}

/// 两个 Dio 均使用此内存适配器；任何未列出的路径直接失败，无网络回退。
class _MediaAdapter implements HttpClientAdapter {
  _MediaAdapter(this.write, this.inputSize);

  final _RecoveryWrite write;
  final int inputSize;
  final queryEntered = Completer<void>();
  final releaseQuery = Completer<void>();
  bool failInitialOperation = true;
  bool expireNextWrite = false;
  bool holdNextQuery = false;
  int allocations = 0, puts = 0, queries = 0, reissues = 0;
  int confirmations = 0, backgroundReads = 0;
  final confirmedIds = <String>[];
  final recoveryAuthorization = <String?>[];

  int get recoveryWrites =>
      write == _RecoveryWrite.reissue ? reissues : confirmations;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    if (options.method == 'GET' && path == '/background') {
      backgroundReads++;
      return _failure(503, 50000);
    }
    if (options.method == 'GET' && path == '/api/v1/media/$_mediaId') {
      queries++;
      if (holdNextQuery) {
        holdNextQuery = false;
        queryEntered.complete();
        await releaseQuery.future;
      }
      return _success(_media(completed: false));
    }
    if (options.method == 'PUT' && options.uri.host == 'storage.invalid') {
      puts++;
      if (failInitialOperation && write == _RecoveryWrite.reissue) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      }
      return ResponseBody.fromString('OK', 200);
    }
    if (options.method == 'POST' && path == '/api/v1/media/upload-url') {
      allocations++;
      return _success(_upload);
    }
    final reissue = path == '/api/v1/media/$_mediaId/upload-url';
    final confirm = path == '/api/v1/media/upload-done';
    if (options.method == 'POST' && (reissue || confirm)) {
      if (reissue) reissues++;
      if (confirm) {
        confirmations++;
        final data = options.data;
        final body = data is String ? jsonDecode(data) : data;
        confirmedIds.add((body as Map)['mediaId'] as String);
      }
      final selected = write == _RecoveryWrite.reissue ? reissue : confirm;
      if (selected) {
        recoveryAuthorization.add(options.headers['Authorization'] as String?);
        if (failInitialOperation) return _failure(503, 50000);
        if (expireNextWrite) {
          expireNextWrite = false;
          return _failure(401, 40101);
        }
      }
      return reissue
          ? _success(_upload)
          : _success({'processing': false, 'media': _media(completed: true)});
    }
    throw StateError('未登记的测试请求：${options.method} $path');
  }

  Map<String, Object> get _upload => {
    'uploadUrl': 'https://storage.invalid/original.gif',
    'mediaId': _mediaId,
    'objectKey': 'original.gif',
    'publicUrl': 'https://cdn.invalid/original.gif',
  };

  Map<String, Object> _media({required bool completed}) => {
    'id': _mediaId,
    'userId': 'user-one',
    'url': 'https://cdn.invalid/original.gif',
    'key': 'original.gif',
    'contentType': 'image/gif',
    'size': inputSize,
    'width': 320,
    'height': 180,
    'purpose': 'RICH_CONTENT',
    'animated': true,
    'status': completed ? 'COMPLETED' : 'UPLOADING',
    'createdAt': '2026-09-12T00:00:00Z',
    if (completed)
      'display': {
        'url': 'https://cdn.invalid/full.webp',
        'contentType': 'image/webp',
        'width': 320,
        'height': 180,
        'bytes': 180,
        'animated': true,
        'frameCount': 2,
        'durationMs': 360,
        'loopCount': 2,
      },
  };

  ResponseBody _success(Object data) =>
      _json({'code': 0, 'message': 'ok', 'data': data}, 200);
  ResponseBody _failure(int status, int code) =>
      _json({'code': code, 'message': 'fixture failure'}, status);

  ResponseBody _json(Object body, int status) => ResponseBody.fromString(
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
  _SessionRemote(this.recovery);

  final NetworkRecovery recovery;
  final refreshEntered = Completer<void>();
  final releaseRefresh = Completer<void>();
  final refreshTokens = <String>[];
  int refreshCalls = 0;
  bool startedDuringCooldown = false;

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    refreshCalls++;
    refreshTokens.add(refreshToken);
    startedDuringCooldown = recovery.isCoolingDown;
    if (!refreshEntered.isCompleted) refreshEntered.complete();
    await releaseRefresh.future;
    return _newTokens;
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
