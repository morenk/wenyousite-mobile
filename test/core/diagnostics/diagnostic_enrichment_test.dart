import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_error_details.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_request.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_routes.g.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_runtime.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/diagnostics/network_diagnostics.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('已捕获 Error 未显式传栈时采用原始 throw 位置', () async {
    final diagnostics = FailureDiagnostics();
    try {
      throw StateError('private-body');
    } on Object catch (error) {
      diagnostics.capture(error);
    }
    await diagnostics.settled;
    final fields = diagnostics.records.single.fields;
    expect(fields['stackOrigin'], 'error');
    expect(fields['stackStatus'], 'captured');
    expect(fields['stack'], isNotEmpty);
    expect(diagnostics.export(), isNot(contains('private-body')));
  });

  test('缺失、过滤和未配符号的地址栈明确标注，不伪造采集位置', () async {
    final diagnostics = FailureDiagnostics();
    for (final stack in [
      null,
      StackTrace.fromString('private-body'),
      StackTrace.fromString(
        'isolate_instructions: 1234\n#00 abs 00001 virt 001',
      ),
    ]) {
      diagnostics.capture(Exception('private'), stackTrace: stack);
    }
    await diagnostics.settled;
    expect(diagnostics.records.map((r) => r.fields['stackStatus']).toList(), [
      'requiresSymbols',
      'filtered',
      'missing',
    ]);
    expect(
      diagnostics.records.every((r) => (r.fields['stack']! as List).isEmpty),
      isTrue,
    );
  });

  test('扩充帧格式仍拒绝 URL、绝对路径、穿越路径、零行和私密函数文本', () {
    final stack = safeDiagnosticStack(
      StackTrace.fromString(
        '#0 private-content (package:riverpod/src/framework.dart:2)\n'
        '#1 private-content (file:///private/account.dart:1:1)\n'
        '#2 private-content (https://private.invalid/body.dart:1:1)\n'
        '#3 private-content (package:foo/../../private.dart:1:1)\n'
        '#4 private-content (package:foo/bar.dart:0:1)\n'
        '#5 private-content (package:foo/bar.dart:1:0)\n'
        '#6 private-content (package:foo/bar.dart:1:1?token=private)\n',
      ),
    );
    expect(stack, ['package:riverpod/src/framework.dart:2']);
    expect(sanitizeDiagnosticStackLines(stack), stack);
  });

  test('Codec 固定原因可定位，动态属性名和未知错误文本不出站', () async {
    final diagnostics = FailureDiagnostics();
    for (final message in [
      '行内代码不能与其他行内格式组合',
      '遇到不支持的富文本属性：private-account',
      'private-body',
    ]) {
      diagnostics.capture(
        MarkdownCodecException(message),
        operation: DiagnosticOperation.editorEncode,
        stage: DiagnosticStage.encode,
      );
    }
    await diagnostics.settled;
    expect(
      diagnostics.records.map((r) => r.fields['diagnosticCode']).toList(),
      [
        'markdown.unclassified',
        'markdown.unknown_attribute',
        'markdown.inline_code_attributes',
      ],
    );
    for (final record in diagnostics.records) {
      final envelope = jsonEncode(diagnosticSentryEvent(record).toJson());
      expect(envelope, isNot(contains('private-')));
    }
    expect(
      markdownDiagnosticCode('secret embed 载荷不是对象'),
      'markdown.embed_payload',
    );
  });

  test('网络最终失败保留端点、超时类型和耗时，不保留路径参数与请求内容', () async {
    final diagnostics = FailureDiagnostics()
      ..screen = 'thread-detail'
      ..lifecycle = () => 'resumed';
    final dio = Dio()
      ..interceptors.add(
        NetworkDiagnosticInterceptor(diagnostics: diagnostics),
      );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.receiveTimeout,
            ),
            true,
          );
        },
      ),
    );
    try {
      await dio.patch<Object?>(
        '/api/v1/posts/private-id',
        data: {'body': 'private-body', 'password': 'private-password'},
        queryParameters: {'token': 'private-token'},
      );
    } on DioException {
      /* 检查上报，不执行真实请求。 */
    }
    await diagnostics.settled;
    final fields = diagnostics.records.single.fields;
    expect(fields['apiOperation'], 'postsUpdate');
    expect(fields['dioType'], 'receiveTimeout');
    expect(fields['httpMethod'], 'PATCH');
    expect(fields['requestElapsedMs'], isA<int>());
    expect(fields['screen'], 'thread-detail');
    expect(fields['lifecycle'], 'resumed');
    expect(diagnostics.export(), isNot(contains('private-')));
    dio.close();
  });

  test('端点静态匹配优先，不把查询词、未知地址或 ID 当成分组键', () {
    expect(
      diagnosticApiOperation(RequestOptions(path: '/api/v1/users/me')),
      'usersGetMe',
    );
    expect(
      diagnosticApiOperation(RequestOptions(path: '/api/v1/users/private-id')),
      'usersGetUser',
    );
    expect(
      diagnosticApiOperation(
        RequestOptions(
          path: 'https://host.invalid/api/v1/search/threads?q=secret',
        ),
      ),
      'searchSearchThreads',
    );
    expect(
      diagnosticApiOperation(RequestOptions(path: '/private/token')),
      isNull,
    );
  });

  test('端点索引与固定 OpenAPI 一致，契约新增时需要重新生成', () {
    final schema =
        jsonDecode(File('contracts/openapi.json').readAsStringSync()) as Map;
    final expected = <String, String>{};
    for (final path in (schema['paths'] as Map).entries) {
      for (final method in (path.value as Map).entries) {
        if (method.value is Map &&
            (method.value as Map)['operationId'] is String) {
          expected['${method.key.toString().toUpperCase()} ${path.key}'] =
              (method.value as Map)['operationId'] as String;
        }
      }
    }
    expect(diagnosticApiRoutes, expected);
  });

  test('业务诊断码与 OS 错误数字保留，错误文本及任意新增字段丢弃', () {
    final detail = diagnosticErrorDetails(
      const ApiFailure.invalidResponse(diagnosticCode: 'posts.empty_response'),
      const ApiFailure.invalidResponse(diagnosticCode: 'posts.empty_response'),
    );
    expect(detail['diagnosticCode'], 'posts.empty_response');
    final socket = diagnosticErrorDetails(
      const SocketException(
        'private-host',
        osError: OSError('private-message', 111),
      ),
      null,
    );
    expect(socket['osErrorCode'], 111);
    final safe = sanitizeDiagnosticFields({
      ...detail,
      ...socket,
      'body': 'private-body',
      'screen': '/users/private-id',
      'diagnosticCode': 'https://private.invalid',
      'lifecycle': 'private-body',
    });
    expect(jsonEncode(safe), isNot(contains('private')));
  });

  const channel = MethodChannel('site.wenyou.app/runtime_diagnostics');
  test('Android 版本与厂商机型来自原生明确字段，任意系统文本不扩散', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {
        'operatingSystem': 'Android 15 (API 35)',
        'deviceModel': 'Google Pixel 9',
        'renderer': 'skia-opengles-requested',
      },
    );
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    expect(await loadDiagnosticAndroidRuntime(), {
      'osVersion': '15',
      'androidApi': 35,
      'deviceModel': 'Google Pixel 9',
      'renderer': 'skia-opengles-requested',
    });
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {
        'operatingSystem': 'private-user 2507 kernel',
        'renderer': 'private-renderer',
      },
    );
    expect(await loadDiagnosticAndroidRuntime(), isEmpty);
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'unavailable'),
    );
    expect(await loadDiagnosticAndroidRuntime(), isEmpty);
  });
}
