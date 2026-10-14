import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  for (final status in ['no_release', 'withdrawn', 'paused', 'unavailable']) {
    test('下载契约 $status 的空制品与建议等待可解码', () async {
      final adapter = _ContractAdapter({
        'status': status,
        'release': null,
        'retryAfterSeconds': status == 'unavailable' ? 120 : null,
      });
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));
      final api = WenyouApi(dio: dio).getAppDownloadsApi();
      final response = await api.appDownloadsInfo();
      expect(
        response.data!.data.status.name,
        status == 'no_release' ? 'noRelease' : status,
      );
      expect(response.data!.data.release, isNull);
      expect(
        response.data!.data.retryAfterSeconds,
        status == 'unavailable' ? 120 : isNull,
      );
      expect(adapter.requests.single.uri.path, '/api/v1/app-downloads/android');
      expect(adapter.requests.single.extra['secure'], isEmpty);
    });
  }

  test('可下载契约将身份与本站固定文件地址解码为同一制品', () async {
    final adapter = _ContractAdapter({
      'status': 'available',
      'release': {
        'platform': 'android',
        'applicationId': 'site.wenyou.app',
        'versionName': '1.0.0',
        'buildNumber': 100,
        'sizeBytes': 4096,
        'sha256': 'a' * 64,
        'fileName': 'wenyou-1.0.0-100.apk',
        'publishedAt': '2026-10-03T00:00:00.000Z',
        'downloadUrl':
            'https://wenyou.site/api/v1/app-downloads/android/100/file',
        'releaseNotesUrl':
            'https://wenyou.site/api/v1/mobile-releases/android/100',
      },
      'retryAfterSeconds': null,
    });
    final dio = Dio()..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    final response = await WenyouApi(
      dio: dio,
    ).getAppDownloadsApi().appDownloadsInfo();
    final release = response.data!.data.release!;
    expect(release.buildNumber, 100);
    expect(release.sizeBytes, 4096);
    expect(release.applicationId, 'site.wenyou.app');
    expect(release.sha256, 'a' * 64);
    expect(release.downloadUrl, endsWith('/android/100/file'));
    expect(adapter.requests, hasLength(1));
  });

  test('生成文件接口保留匿名 HEAD/GET 与单 Range 请求参数', () async {
    final adapter = _ContractAdapter(null);
    final dio = Dio()..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    final api = WenyouApi(dio: dio).getAppDownloadsApi();
    await api.appDownloadsHead(buildNumber: 100);
    final response = await api.appDownloadsFile(
      buildNumber: 100,
      range: 'bytes=0-3',
      ifRange: '"fixture-sha"',
    );
    expect(adapter.requests.map((r) => r.method), ['HEAD', 'GET']);
    expect(adapter.requests.last.headers['Range'], 'bytes=0-3');
    expect(adapter.requests.last.headers['If-Range'], '"fixture-sha"');
    expect(adapter.requests.every((r) => r.extra['secure'].isEmpty), isTrue);
    expect(response.data, [1, 2, 3, 4]);
    expect(response.statusCode, 206);
  });
}

class _ContractAdapter implements HttpClientAdapter {
  _ContractAdapter(this.info);
  final Map<String, Object?>? info;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path.endsWith('/file')) {
      return ResponseBody.fromBytes(
        options.method == 'HEAD' ? [] : [1, 2, 3, 4],
        options.method == 'HEAD' ? 200 : 206,
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'code': 0, 'message': 'ok', 'data': info}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
