import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/preview_identity.dart';

import '../config/preview_environment_test.dart' show previewEnvironment;

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handle);
  final ResponseBody Function(RequestOptions) handle;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handle(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  test('API 写入前核验双方身份，注入 run 头并禁重定向', () async {
    final environment = previewEnvironment();
    final order = <String>[];
    final probe = Dio()
      ..httpClientAdapter = _Adapter((request) {
        expect(request.followRedirects, isFalse);
        expect(request.headers.containsKey('Authorization'), isFalse);
        final role = request.uri.port == 23080 ? 'backend' : 'media';
        order.add(role);
        return ResponseBody.fromString(
          jsonEncode({
            'version': 1,
            'kind': 'wenyou-dev-preview',
            'sessionId': environment.previewSession,
            'runId': environment.previewRun,
            'role': role,
            'resourceId': environment.previewRun,
            'snapshotSha256': environment.previewSnapshotSha,
          }),
          200,
          headers: {
            'content-type': ['application/json'],
            'X-Wenyou-Preview-Run': [environment.previewRun],
          },
        );
      });
    final business = Dio()
      ..httpClientAdapter = _Adapter((request) {
        order.add('write');
        expect(request.followRedirects, isFalse);
        expect(request.headers['X-Wenyou-Preview-Run'], environment.previewRun);
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'content-type': ['application/json'],
            'X-Wenyou-Preview-Run': [environment.previewRun],
          },
        );
      });
    business.interceptors.add(
      PreviewIdentityInterceptor(PreviewIdentityVerifier(environment, probe)),
    );
    await business.post('${environment.apiOrigin}/api/v1/auth/login');
    expect(order, ['backend', 'media', 'write']);
  });
  test('错误身份或失联禁止登录和上传，不尝试线上目标', () async {
    final environment = previewEnvironment();
    var writes = 0;
    final probe = Dio()
      ..httpClientAdapter = _Adapter(
        (_) => ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
    for (final media in [false, true]) {
      final business = Dio()
        ..httpClientAdapter = _Adapter((_) {
          writes++;
          return ResponseBody.fromString('{}', 200);
        });
      business.interceptors.add(
        PreviewIdentityInterceptor(
          PreviewIdentityVerifier(environment, probe),
          mediaUpload: media,
        ),
      );
      await expectLater(
        business.post(
          '${media ? environment.previewMediaOrigin : environment.apiOrigin}/target',
        ),
        throwsA(isA<DioException>()),
      );
      await expectLater(
        business.post('https://wenyou.site/api/v1/target'),
        throwsA(isA<DioException>()),
      );
    }
    expect(writes, 0);
  });
  test('上传保留原预签名URL，不注入 API 头且逐次重新核验', () async {
    final environment = previewEnvironment();
    var probes = 0;
    final probe = Dio()
      ..httpClientAdapter = _Adapter((request) {
        probes++;
        return ResponseBody.fromString(
          jsonEncode({
            'version': 1,
            'kind': 'wenyou-dev-preview',
            'sessionId': environment.previewSession,
            'runId': environment.previewRun,
            'role': request.uri.port == 23080 ? 'backend' : 'media',
            'resourceId': environment.previewRun,
            'snapshotSha256': environment.previewSnapshotSha,
          }),
          200,
          headers: {
            'content-type': ['application/json'],
            'X-Wenyou-Preview-Run': [environment.previewRun],
          },
        );
      });
    final signed =
        '${environment.previewMediaOrigin}/bucket/key?X-Amz-Signature=test-value';
    final upload = Dio()
      ..httpClientAdapter = _Adapter((request) {
        expect(request.uri.toString(), signed);
        expect(request.headers.containsKey('X-Wenyou-Preview-Run'), isFalse);
        return ResponseBody.fromString('', 200);
      });
    upload.interceptors.add(
      PreviewIdentityInterceptor(
        PreviewIdentityVerifier(environment, probe),
        mediaUpload: true,
      ),
    );
    await upload.put(signed);
    await upload.put(signed);
    expect(probes, 4);
  });
}
