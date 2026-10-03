import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

void main() {
  late _DownloadFixture fixture;

  setUp(() async => fixture = await _DownloadFixture.start());
  tearDown(() async => fixture.close());

  const dailyMessages = {
    'device_daily_limit': '此设备今日下载次数已用完，请在北京时间次日零点后重试。',
    'ip_daily_limit': '当前网络今日下载次数已用完，请在北京时间次日零点后重试。',
  };
  for (final entry in dailyMessages.entries) {
    for (final method in ['HEAD', 'GET']) {
      test('$method 空正文 429 ${entry.key} 按原因提示并等待到北京时间次日', () async {
        fixture.now = DateTime.utc(2026, 10, 3, 14);
        fixture.failureMethod = method;
        fixture.failureStatus = 429;
        fixture.limitReason = entry.key;
        fixture.retryAfter = '7200';
        final update = _update('/api/v1/app-downloads/android/43/file');
        if (method == 'HEAD') {
          final availability = await fixture.service.checkAvailability(update);
          expect(availability.isAvailable, isFalse);
          expect(availability.userMessage, entry.value);
        } else {
          expect(
            (await fixture.service.checkAvailability(update)).isAvailable,
            isTrue,
          );
          await expectLater(
            fixture.service.launchUpdate(
              update,
              onStage: (_) {},
              onProgress: (_) {},
            ),
            throwsA(
              isA<MobileUpdateException>().having(
                (e) => e.userMessage,
                '当天额度提示',
                entry.value,
              ),
            ),
          );
        }
        final initialRequests = method == 'HEAD' ? 1 : 2;
        fixture.failureMethod = null;
        fixture.now = fixture.now.add(const Duration(seconds: 7199));
        final other = _update(
          '/api/v1/app-downloads/android/44/file',
          build: 44,
        );
        expect(
          (await fixture.service.checkAvailability(other)).userMessage,
          entry.value,
        );
        await expectLater(
          fixture.service.launchUpdate(
            update,
            onStage: (_) {},
            onProgress: (_) {},
          ),
          throwsA(isA<MobileUpdateException>()),
        );
        expect(fixture.requests, hasLength(initialRequests));
        expect(fixture.bridge.paths, isEmpty);
        expect(await fixture.cachedFiles(), isEmpty);
        fixture.now = fixture.now.add(const Duration(seconds: 1));
        expect(fixture.now, DateTime.utc(2026, 10, 3, 16));
        // 到期不会自动下载；用户下一次操作才恢复 HEAD→GET。
        expect(fixture.requests, hasLength(initialRequests));
        expect(
          (await fixture.service.checkAvailability(update)).isAvailable,
          isTrue,
        );
        await fixture.service.launchUpdate(
          update,
          onStage: (_) {},
          onProgress: (_) {},
        );
        expect(fixture.requests, hasLength(initialRequests + 2));
        expect(fixture.bridge.builds, [43]);
      });
    }
  }

  for (final reason in <String?>[
    'byte_budget',
    'request_rate',
    'concurrency',
    'bandwidth',
    'future_reason',
    null,
  ]) {
    for (final method in ['HEAD', 'GET']) {
      test('$method 空正文 429 $reason 保留通用提示与等待', () async {
        fixture.failureMethod = method;
        fixture.failureStatus = 429;
        fixture.limitReason = reason;
        final update = _update('/api/v1/app-downloads/android/43/file');
        for (var attempt = 0; attempt < 2; attempt++) {
          await expectLater(
            fixture.service.launchUpdate(
              update,
              onStage: (_) {},
              onProgress: (_) {},
            ),
            throwsA(
              isA<MobileUpdateException>().having(
                (e) => e.userMessage,
                '兼容提示',
                '下载请求较多，请稍后重试。',
              ),
            ),
          );
        }
        expect(
          fixture.requests.map((r) => r.method),
          method == 'HEAD' ? ['HEAD'] : ['HEAD', 'GET'],
        );
        expect(fixture.bridge.paths, isEmpty);
        expect(await fixture.cachedFiles(), isEmpty);
      });
    }
  }

  test('503 不将附带的次数原因误判为每日额度耗尽', () async {
    fixture.failureMethod = 'HEAD';
    fixture.limitReason = 'ip_daily_limit';
    final availability = await fixture.service.checkAvailability(
      _update('/api/v1/app-downloads/android/43/file'),
    );
    expect(availability.userMessage, '安装包暂时无法下载，请稍后重试。');
  });

  test('429 后重新预检和手动下载共用等待期限，不重复访问下载地址', () async {
    fixture.failureMethod = 'HEAD';
    fixture.failureStatus = 429;
    final update = _update('/api/v1/app-downloads/android/43/file');
    expect(
      (await fixture.service.checkAvailability(update)).isAvailable,
      isFalse,
    );
    expect(
      (await fixture.service.checkAvailability(update)).isAvailable,
      isFalse,
    );
    await expectLater(
      fixture.service.launchUpdate(update, onStage: (_) {}, onProgress: (_) {}),
      throwsA(isA<MobileUpdateException>()),
    );
    expect(fixture.requests.map((r) => r.method), ['HEAD']);
    expect(fixture.bridge.paths, isEmpty);
  });

  for (final status in [429, 503]) {
    test('$status 遵守整数 Retry-After，跨构建预检不绕过，到期后可显式恢复', () async {
      fixture.failureMethod = 'HEAD';
      fixture.failureStatus = status;
      fixture.retryAfter = '120';
      final update = _update('/api/v1/app-downloads/android/43/file');
      final availability = await fixture.service.checkAvailability(update);
      expect(availability.userMessage, _failureMessage(status));
      fixture.failureMethod = null;
      fixture.now = fixture.now.add(const Duration(seconds: 119));
      final other = _update('/api/v1/app-downloads/android/44/file', build: 44);
      expect(
        (await fixture.service.checkAvailability(other)).isAvailable,
        isFalse,
      );
      expect(fixture.requests, hasLength(1));
      fixture.now = fixture.now.add(const Duration(seconds: 1));
      expect(
        (await fixture.service.checkAvailability(update)).isAvailable,
        isTrue,
      );
      await fixture.service.launchUpdate(
        update,
        onStage: (_) {},
        onProgress: (_) {},
      );
      expect(fixture.requests.map((r) => r.method), ['HEAD', 'HEAD', 'GET']);
      expect(fixture.bridge.builds, [43]);
    });

    test('GET $status 后缓存的预检结果不能绕过等待', () async {
      final update = _update('/api/v1/app-downloads/android/43/file');
      await fixture.service.checkAvailability(update);
      fixture.failureMethod = 'GET';
      fixture.failureStatus = status;
      for (var i = 0; i < 2; i++) {
        await expectLater(
          fixture.service.launchUpdate(
            update,
            onStage: (_) {},
            onProgress: (_) {},
          ),
          throwsA(
            isA<MobileUpdateException>().having(
              (e) => e.userMessage,
              '提示',
              _failureMessage(status),
            ),
          ),
        );
      }
      expect(fixture.requests.map((r) => r.method), ['HEAD', 'GET']);
      expect(await fixture.cachedFiles(), isEmpty);
    });
  }

  for (final retryAfter in <String?>[null, 'invalid', '-1']) {
    test('429 Retry-After 为 $retryAfter 时保守等待一分钟', () async {
      fixture.failureMethod = 'HEAD';
      fixture.failureStatus = 429;
      fixture.retryAfter = retryAfter;
      final update = _update('/api/v1/app-downloads/android/43/file');
      await fixture.service.checkAvailability(update);
      fixture.failureMethod = null;
      fixture.now = fixture.now.add(const Duration(seconds: 59));
      expect(
        (await fixture.service.checkAvailability(update)).isAvailable,
        isFalse,
      );
      expect(fixture.requests, hasLength(1));
      fixture.now = fixture.now.add(const Duration(seconds: 1));
      expect(
        (await fixture.service.checkAvailability(update)).isAvailable,
        isTrue,
      );
    });
  }

  for (final reason in <String?>[null, ...dailyMessages.keys]) {
    test('已验证 APK 的继续安装不受 $reason 下载等待影响', () async {
      final update = _update('/api/v1/app-downloads/android/43/file');
      await fixture.service.launchUpdate(
        update,
        onStage: (_) {},
        onProgress: (_) {},
      );
      fixture.failureMethod = 'HEAD';
      fixture.failureStatus = 429;
      fixture.limitReason = reason;
      fixture.retryAfter = '7200';
      await fixture.service.checkAvailability(update);
      await fixture.service.launchUpdate(
        update,
        onStage: (_) {},
        onProgress: (_) {},
      );
      expect(fixture.requests.map((r) => r.method), ['HEAD', 'GET', 'HEAD']);
      expect(fixture.bridge.builds, [43, 43]);
    });
  }

  for (final path in [
    '/mobile/android/wenyou-1.0.0-43.apk',
    '/api/v1/app-downloads/android/43/file',
  ]) {
    test('无 Cookie 旧下载器在 $path 先 HEAD 后 GET，完整校验后安装', () async {
      fixture.responseCookie =
          '__Host-wenyou-download-device=fixture-signed-id; '
          'Path=/; HttpOnly; SameSite=Lax; Secure';
      final update = _update(path);
      final availability = await fixture.service.checkAvailability(update);
      expect(availability.isAvailable, isTrue);
      expect(fixture.requests.map((r) => r.method), ['HEAD']);

      final result = await fixture.service.launchUpdate(
        update,
        onStage: (_) {},
        onProgress: (_) {},
      );

      expect(result, UpdateLaunchResult.installerOpened);
      expect(fixture.requests.map((r) => r.method), ['HEAD', 'GET']);
      expect(fixture.requests.every((r) => r.uri.path == path), isTrue);
      expect(
        fixture.requests.every(
          (r) => r.headers.value(HttpHeaders.cookieHeader) == null,
        ),
        isTrue,
      );
      expect(
        fixture.requests.every(
          (r) => r.headers.value(HttpHeaders.rangeHeader) == null,
        ),
        isTrue,
      );
      expect(fixture.bridge.builds, [43]);
      expect(
        await File(fixture.bridge.paths.single).readAsBytes(),
        fixture.bytes,
      );
    });
  }

  for (final method in ['HEAD', 'GET']) {
    for (final status in [429, 503]) {
      test('$method 返回 $status 时不重试、不回退对象桶、不安装', () async {
        fixture.failureMethod = method;
        fixture.failureStatus = status;
        await expectLater(
          fixture.service.launchUpdate(
            _update('/api/v1/app-downloads/android/43/file'),
            onStage: (_) {},
            onProgress: (_) {},
          ),
          throwsA(isA<MobileUpdateException>()),
        );
        expect(
          fixture.requests.map((r) => r.method),
          method == 'HEAD' ? ['HEAD'] : ['HEAD', 'GET'],
        );
        expect(fixture.bridge.paths, isEmpty);
        expect(await fixture.cachedFiles(), isEmpty);
      });
    }
  }

  test('收到非预期单 Range 的 206 部分正文不得交给安装器', () async {
    fixture.partialGet = true;
    await expectLater(
      fixture.service.launchUpdate(
        _update('/api/v1/app-downloads/android/43/file'),
        onStage: (_) {},
        onProgress: (_) {},
      ),
      throwsA(isA<MobileUpdateException>()),
    );
    expect(fixture.requests.map((r) => r.method), ['HEAD', 'GET']);
    expect(fixture.bridge.paths, isEmpty);
    expect(await fixture.cachedFiles(), isEmpty);
  });

  test('未请求 Range 时，即使 206 携带全部正确字节也不安装', () async {
    fixture.fullRangeGet = true;
    await expectLater(
      fixture.service.launchUpdate(
        _update('/api/v1/app-downloads/android/43/file'),
        onStage: (_) {},
        onProgress: (_) {},
      ),
      throwsA(isA<MobileUpdateException>()),
    );
    expect(fixture.bridge.paths, isEmpty);
    expect(await fixture.cachedFiles(), isEmpty);
  });

  for (final header in [
    'content-disposition',
    'x-amz-meta-application-id',
    'x-amz-meta-version-code',
    'x-amz-meta-version-name',
    'x-amz-meta-apk-sha256',
  ]) {
    test('GET 缺失 $header 时拒绝安装并清理临时文件', () async {
      fixture.omitGetHeader = header;
      await expectLater(
        fixture.service.launchUpdate(
          _update('/api/v1/app-downloads/android/43/file'),
          onStage: (_) {},
          onProgress: (_) {},
        ),
        throwsA(isA<MobileUpdateException>()),
      );
      expect(fixture.bridge.paths, isEmpty);
      expect(await fixture.cachedFiles(), isEmpty);
    });
  }
}

String _failureMessage(int status) =>
    status == 429 ? '下载请求较多，请稍后重试。' : '安装包暂时无法下载，请稍后重试。';

MobileUpdateInfo _update(String path, {int build = 43}) => MobileUpdateInfo(
  kind: MobileUpdateKind.required,
  platform: MobileClientPlatform.android,
  currentVersion: '0.9.0',
  currentBuild: 42,
  targetBuild: build,
  updateUri: Uri.https('download.invalid', path),
);

class _DownloadFixture {
  _DownloadFixture(this.server, this.directory) {
    dio = Dio()..httpClientAdapter = _LoopbackAdapter(server.port);
    service = DeviceMobileUpdateService.withDependencies(
      dio,
      platformBridge: bridge,
      platformOverride: MobileClientPlatform.android,
      temporaryDirectoryProvider: () async => directory,
      now: () => now,
    );
    server.listen(_respond);
  }

  static Future<_DownloadFixture> start() async => _DownloadFixture(
    await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    await Directory.systemTemp.createTemp('wenyou-update-http-'),
  );

  final HttpServer server;
  final Directory directory;
  final bridge = _Installer();
  final requests = <HttpRequest>[];
  final bytes = Uint8List.fromList(List.generate(4096, (i) => i % 251));
  late final Dio dio;
  late final DeviceMobileUpdateService service;
  String? failureMethod;
  int failureStatus = 503;
  String? retryAfter = '60';
  String? limitReason;
  String? responseCookie;
  DateTime now = DateTime.utc(2026, 10, 3);
  bool partialGet = false;
  bool fullRangeGet = false;
  String? omitGetHeader;

  Future<void> _respond(HttpRequest request) async {
    requests.add(request);
    final response = request.response;
    if (responseCookie != null) {
      response.headers.set(HttpHeaders.setCookieHeader, responseCookie!);
    }
    if (request.method == failureMethod) {
      response.statusCode = failureStatus;
      response.contentLength = 0;
      if (retryAfter != null) response.headers.set('retry-after', retryAfter!);
      if (limitReason != null) {
        response.headers.set('X-Download-Limit-Reason', limitReason!);
      }
      await response.close();
      return;
    }
    final partial = partialGet && request.method == 'GET';
    final body = partial ? bytes.sublist(0, 64) : bytes;
    response.statusCode = partial || (fullRangeGet && request.method == 'GET')
        ? 206
        : 200;
    response.contentLength = body.length;
    final headers = {
      'content-type': 'application/vnd.android.package-archive',
      'content-disposition': 'attachment; filename="wenyou-1.0.0-43.apk"',
      'x-amz-meta-apk-sha256': sha256.convert(bytes).toString(),
      'x-amz-meta-application-id': 'site.wenyou.app',
      'x-amz-meta-version-code': '43',
      'x-amz-meta-version-name': '1.0.0',
      'cache-control': 'private, no-store',
      if (partial) 'content-range': 'bytes 0-63/${bytes.length}',
      if (fullRangeGet && request.method == 'GET')
        'content-range': 'bytes 0-${bytes.length - 1}/${bytes.length}',
    };
    for (final header in headers.entries) {
      if (request.method == 'GET' && header.key == omitGetHeader) continue;
      response.headers.set(header.key, header.value);
    }
    if (request.method != 'HEAD') response.add(body);
    await response.close();
  }

  Future<List<File>> cachedFiles() async => directory
      .list(recursive: true)
      .where((entry) => entry is File)
      .cast<File>()
      .toList();

  Future<void> close() async {
    dio.close(force: true);
    await server.close(force: true);
    await directory.delete(recursive: true);
  }
}

// 生产 URL 仍经过 HTTPS 检查；仅测试传输映射到本机随机端口，不访问 DNS/公网。
// 这验证实际 HTTP 响应解析和落盘，不声称验证了网关部署或 TLS。
class _LoopbackAdapter implements HttpClientAdapter {
  _LoopbackAdapter(this.port);
  final int port;
  final _transport = IOHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (options.uri.host != 'download.invalid') {
      throw StateError('测试禁止访问未登记地址');
    }
    return _transport.fetch(
      options.copyWith(
        path: options.uri
            .replace(scheme: 'http', host: '127.0.0.1', port: port)
            .toString(),
        followRedirects: false,
      ),
      requestStream,
      cancelFuture,
    );
  }

  @override
  void close({bool force = false}) => _transport.close(force: force);
}

class _Installer implements MobileUpdatePlatformBridge {
  final paths = <String>[];
  final builds = <int>[];

  @override
  Future<String?> installApk({
    required String filePath,
    required int expectedBuild,
  }) async {
    paths.add(filePath);
    builds.add(expectedBuild);
    return 'installerOpened';
  }

  @override
  Future<InstalledAppInfo> readInstalledApp(MobileClientPlatform platform) =>
      throw UnimplementedError();
}
