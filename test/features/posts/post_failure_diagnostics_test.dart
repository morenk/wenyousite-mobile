import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/diagnostics/network_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_diagnostics.dart';

class DiagnosticApiAdapter implements HttpClientAdapter {
  DiagnosticApiAdapter(this.statuses, this.body);
  final List<int> statuses;
  final Object body;
  int calls = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final status = statuses[calls.clamp(0, statuses.length - 1)];
    calls++;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-request-id': [options.headers['X-Request-ID'].toString()],
        'x-api-contract-version': ['5.17.0-dev.20260905.2'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FailureDiagnostics diagnostics;
  late FailureDiagnostics previous;
  setUp(() {
    previous = FailureDiagnostics.instance;
    diagnostics = FailureDiagnostics();
    FailureDiagnostics.instance = diagnostics;
  });
  tearDown(() async {
    await diagnostics.settled;
    FailureDiagnostics.instance = previous;
  });

  for (final code in [40000, 40001, 40006, 40009]) {
    test('真实生成客户端保存返回 $code：保稿、明确文案、问题编号和一条诊断', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
      final adapter = DiagnosticApiAdapter(
        [400],
        {'code': code, 'message': 'private-image-url', 'data': null},
      );
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(NetworkDiagnosticInterceptor());
      final repository = ApiPostRepository(
        WenyouApi(dio: dio, interceptors: []).getPostsApi(),
      );
      ApiFailure? failure;
      final flow = PostComposerDiagnostics();
      const content = '私密历史正文\n\n![图片](https://private.invalid/image)';
      await flow.submit(
        kind: PostComposerKind.editPost,
        content: content,
        action: () async {
          try {
            await repository.update(
              postId: 'private-post',
              content: content,
              version: 3,
            );
          } on ApiFailure catch (error) {
            failure = error;
          }
        },
        failure: () => failure,
      );
      await diagnostics.settled;
      expect(adapter.calls, 1);
      expect(failure!.businessCode, code);
      expect(failure!.userMessage, isNot('请求失败，请稍后重试。'));
      expect(failure!.shouldExposeRequestId(treatAsWrite: true), isTrue);
      expect(diagnostics.records, hasLength(1));
      expect(diagnostics.records.single.shouldSend, true);
      expect(diagnostics.records.single.fields['responseReceived'], true);
      expect(
        diagnostics.records.single.fields['requestId'],
        failure!.requestId,
      );
      expect(diagnostics.records.single.fields['images'], 1);
      expect(diagnostics.export(), isNot(contains('私密历史正文')));
      expect(diagnostics.export(), isNot(contains('private.invalid')));
      expect(diagnostics.export(), isNot(contains('private-post')));
      dio.close();
    });
  }

  test('HTTP 200 后生成客户端解析失败被识别为 decode，不误报未发出请求', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    dio.httpClientAdapter = DiagnosticApiAdapter(
      [200],
      {'code': 0, 'data': {}},
    );
    dio.interceptors.add(NetworkDiagnosticInterceptor());
    final repository = ApiPostRepository(
      WenyouApi(dio: dio, interceptors: []).getPostsApi(),
    );
    ApiFailure? failure;
    await PostComposerDiagnostics().submit(
      kind: PostComposerKind.editPost,
      content: '私密正文',
      action: () async {
        try {
          await repository.update(
            postId: 'private-post',
            content: '私密正文',
            version: 3,
          );
        } on ApiFailure catch (error) {
          failure = error;
        }
      },
      failure: () => failure,
    );
    await diagnostics.settled;
    expect(diagnostics.records.single.stage, DiagnosticStage.decode);
    expect(diagnostics.records.single.fields['httpStatus'], 200);
    expect(diagnostics.records.single.fields['apiEnvelopeReceived'], true);
    expect(diagnostics.records.single.fields['requestId'], isNotNull);
    dio.close();
  });

  test('网络自动重试后成功，不生成故障；耗尽重试只生成一条', () async {
    for (final succeeds in [true, false]) {
      await diagnostics.clear();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
      final adapter = DiagnosticApiAdapter(succeeds ? [503, 200] : [503], {
        'code': 50000,
      });
      dio.httpClientAdapter = adapter;
      dio.interceptors.addAll([
        SafeRetryInterceptor(dio, wait: (_) async {}),
        NetworkDiagnosticInterceptor(),
      ]);
      try {
        await dio.get<Object?>('/api/v1/private');
      } on DioException {
        /* Expected terminal failure. */
      }
      await diagnostics.settled;
      expect(diagnostics.records, hasLength(succeeds ? 0 : 1));
      expect(adapter.calls, succeeds ? 2 : 3);
      dio.close();
    }
  });
}
