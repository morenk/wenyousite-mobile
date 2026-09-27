import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_release_repository.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

import 'mobile_release_test_support.dart';

void main() {
  late _Adapter adapter;
  late ApiMobileReleaseRepository repository;
  setUp(() {
    adapter = _Adapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    repository = ApiMobileReleaseRepository(
      WenyouApi(dio: dio).getMobileReleasesApi(),
    );
    addTearDown(() => dio.close(force: true));
  });

  test('真实生成客户端按公开请求策略映射说明，保留纯文本与确认revision', () async {
    final release = await repository.fetch(releaseTarget);
    expect(adapter.requests.single.path, '/api/v1/mobile-releases/android/100');
    expect(
      adapter.requests.single.extra,
      containsPair(
        ApiRequestPolicy.public.extra.keys.first,
        ApiRequestPolicy.public.extra.values.first,
      ),
    );
    expect(release!.summary, '**纯文本** <b>摘要</b>');
    expect(release.items, ['第一条\n继续阅读', '第二条']);
    expect(release.revision, 3);
    expect(release.target, releaseTarget);
  });

  test('非Android身份不读取或复用Android说明', () async {
    await expectLater(
      repository.fetch((
        platform: MobileClientPlatform.ios,
        build: 100,
        version: '0.9.0',
      )),
      throwsA(isA<ApiFailure>()),
    );
    expect(adapter.requests, isEmpty);
  });

  test('业务404为空；网络/服务失败、缺data和版本身份错配均不伪装空说明', () async {
    adapter.status = 404;
    adapter.body = {'code': 40400, 'message': 'not found'};
    expect(await repository.fetch(releaseTarget), isNull);
    adapter.status = 503;
    adapter.body = {'code': 50000, 'message': 'unavailable'};
    await expectLater(
      repository.fetch(releaseTarget),
      throwsA(isA<ApiFailure>()),
    );
    adapter.status = 200;
    for (final dto in [
      null,
      _dto()..['versionName'] = '0.9.1',
      _dto()..['buildNumber'] = 100.5,
      _dto()..['platform'] = 'ios',
    ]) {
      adapter.body = {'code': 0, 'message': 'ok', 'data': dto};
      await expectLater(
        repository.fetch(releaseTarget),
        throwsA(isA<ApiFailure>()),
      );
    }
  });
}

Map<String, Object> _dto() => {
  'platform': 'android',
  'versionName': '0.9.0',
  'buildNumber': 100,
  'summary': '**纯文本** <b>摘要</b>',
  'items': ['第一条\n继续阅读', '第二条'],
  'revision': 3,
  'publishedAt': '2026-09-27T00:00:00.000Z',
};

class _Adapter implements HttpClientAdapter {
  int status = 200;
  Map<String, Object?> body = {'code': 0, 'message': 'ok', 'data': _dto()};
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
