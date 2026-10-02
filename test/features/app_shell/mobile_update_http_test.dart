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

  for (final path in [
    '/mobile/android/wenyou-1.0.0-43.apk',
    '/releases/43/file',
  ]) {
    test('旧下载器在 $path 先 HEAD 后 GET，完整校验后安装', () async {
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
            _update('/releases/43/file'),
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
        _update('/releases/43/file'),
        onStage: (_) {},
        onProgress: (_) {},
      ),
      throwsA(isA<MobileUpdateException>()),
    );
    expect(fixture.requests.map((r) => r.method), ['HEAD', 'GET']);
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
          _update('/releases/43/file'),
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

MobileUpdateInfo _update(String path) => MobileUpdateInfo(
  kind: MobileUpdateKind.required,
  platform: MobileClientPlatform.android,
  currentVersion: '0.9.0',
  currentBuild: 42,
  targetBuild: 43,
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
  bool partialGet = false;
  String? omitGetHeader;

  Future<void> _respond(HttpRequest request) async {
    requests.add(request);
    final response = request.response;
    if (request.method == failureMethod) {
      response.statusCode = failureStatus;
      response.headers.set('retry-after', '60');
      await response.close();
      return;
    }
    final partial = partialGet && request.method == 'GET';
    final body = partial ? bytes.sublist(0, 64) : bytes;
    response.statusCode = partial ? 206 : 200;
    response.contentLength = body.length;
    final headers = {
      'content-type': 'application/vnd.android.package-archive',
      'content-disposition': 'attachment; filename="wenyou-1.0.0-43.apk"',
      'x-amz-meta-apk-sha256': sha256.convert(bytes).toString(),
      'x-amz-meta-application-id': 'site.wenyou.app',
      'x-amz-meta-version-code': '43',
      'x-amz-meta-version-name': '1.0.0',
      if (partial) 'content-range': 'bytes 0-63/${bytes.length}',
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
