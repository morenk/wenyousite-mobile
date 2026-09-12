import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/diagnostics/network_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

const requestId = '550e8400-e29b-41d4-a716-446655440000';

class MemoryStore implements DiagnosticStore {
  String? value;
  bool broken = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    if (broken) throw StateError('private-path');
    value = data;
  }
}

class RecordingSender implements DiagnosticSender {
  final received = <DiagnosticRecord>[];
  bool succeeds = true;
  Completer<bool>? result;
  @override
  bool get available => true;
  @override
  Future<bool> send(DiagnosticRecord record) async {
    received.add(record);
    return result == null ? succeeds : result!.future;
  }

  @override
  void cancel() {
    if (result != null && !result!.isCompleted) result!.complete(false);
  }
}

void main() {
  test('账号清除后普通请求迟到失败不会重新生成记录', () async {
    final diagnostics = FailureDiagnostics();
    final gate = Completer<void>();
    final started = Completer<void>();
    final dio = Dio()
      ..interceptors.add(
        NetworkDiagnosticInterceptor(diagnostics: diagnostics),
      );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          started.complete();
          gate.future.then(
            (_) => handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
              true,
            ),
          );
        },
      ),
    );
    final request = dio
        .get<Object?>('https://private.invalid/')
        .then<void>((_) {}, onError: (Object _) {});
    await started.future;
    await diagnostics.clear();
    gate.complete();
    await request;
    await diagnostics.settled;
    expect(diagnostics.records, isEmpty);
    dio.close();
  });

  test('本地输入校验只在本机保留', () async {
    final sender = RecordingSender();
    final diagnostics = FailureDiagnostics(sender: sender);
    diagnostics.capture(
      const ApiFailure(reason: FailureReason.validation),
      operation: DiagnosticOperation.mediaUpload,
    );
    await diagnostics.settled;
    expect(diagnostics.records, hasLength(1));
    expect(sender.received, isEmpty);
  });

  test('编辑拒绝仍上报且保留真实编号，权限和普通断网仅本地记录', () async {
    final sender = RecordingSender();
    final diagnostics = FailureDiagnostics(sender: sender);
    for (final code in [40000, 40001, 40006, 40009]) {
      await diagnostics.attempt(DiagnosticOperation.postEdit).run(() async {
        final error = DioException.badResponse(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/private'),
          response: Response(
            requestOptions: RequestOptions(path: '/private'),
            headers: Headers.fromMap({
              'x-request-id': [requestId],
            }),
            statusCode: 400,
            data: {'code': code, 'message': '私密正文'},
          ),
        );
        diagnostics.capture(error);
      });
    }
    diagnostics.capture(
      const ApiFailure(
        source: FailureSource.expected,
        reason: FailureReason.permissionDenied,
        businessCode: 40300,
      ),
      operation: DiagnosticOperation.postEdit,
    );
    diagnostics.capture(
      const ApiFailure(
        source: FailureSource.network,
        reason: FailureReason.offline,
      ),
      operation: DiagnosticOperation.apiRead,
    );
    await diagnostics.settled;
    expect(sender.received, hasLength(4));
    expect(diagnostics.records, hasLength(6));
    expect(sender.received.first.fields['requestId'], requestId);
    expect(diagnostics.export(), isNot(contains('私密正文')));
    expect(diagnostics.export(), isNot(contains('/private')));
  });

  test('记录与 Sentry 事件都按白名单过滤正文、地址、身份和伪堆栈', () async {
    final diagnostics = FailureDiagnostics()
      ..environment = {
        'appVersion': '0.7.0',
        'build': '94',
        'body': 'private-body',
        'osVersion': 'phone-owner-name',
        'accountId': 'private-account',
      };
    final error = StateError('private-body https://example.test/?token=secret');
    diagnostics.capture(
      error,
      stackTrace: StackTrace.fromString(
        '#0 secret (package:wenyousite_mobile/main.dart:21:3)\n'
        '#1 private-body (file:///private/account.dart:1:1)\n'
        'Authorization: secret',
      ),
    );
    await diagnostics.settled;
    final event = jsonEncode(
      diagnosticSentryEvent(diagnostics.records.single).toJson(),
    );
    for (final secret in [
      'private-body',
      'private-account',
      'example.test',
      'secret',
      'phone-owner-name',
      'file:///private',
    ]) {
      expect(event, isNot(contains(secret)));
      expect(diagnostics.export(), isNot(contains(secret)));
    }
    expect(event, contains('main.dart'));
    expect(event, contains('StateError'));
    expect(event, isNot(contains('"user"')));
    expect(jsonDecode(event) as Map, isNot(contains('request')));
  });

  test('发送失败跨重启保留，可复制；重新发送不会重试业务请求', () async {
    final store = MemoryStore();
    final sender = RecordingSender()..succeeds = false;
    final first = FailureDiagnostics(store: store, sender: sender);
    first.capture(StateError('discard me'));
    await first.settled;
    final id = first.records.single.id;
    expect(first.records.single.pending, isTrue);
    final restored = FailureDiagnostics(store: store, sender: sender);
    await restored.initialize();
    expect(restored.export(id: id), contains(id));
    sender.succeeds = true;
    restored.retryPending();
    await restored.settled;
    expect(restored.records.single.pending, isFalse);
    expect(sender.received.map((record) => record.id).toSet(), {id});
  });

  test('关闭开关会取消在途发送，清除队列且重启不恢复发送', () async {
    final store = MemoryStore();
    final sender = RecordingSender()..result = Completer<bool>();
    final diagnostics = FailureDiagnostics(store: store, sender: sender);
    diagnostics.capture(StateError('secret'));
    await Future<void>.delayed(Duration.zero);
    await diagnostics.setAutomaticSending(false);
    expect(diagnostics.records.single.pending, isFalse);
    final restored = FailureDiagnostics(store: store, sender: sender);
    await restored.initialize();
    restored.retryPending();
    await restored.settled;
    expect(restored.automaticSending, isFalse);
    expect(sender.received, hasLength(1));
  });

  test('退出清除记录和上下文，旧会话迟到结果不重新落盘', () async {
    final store = MemoryStore();
    final diagnostics = FailureDiagnostics(store: store);
    final old = diagnostics.attempt(DiagnosticOperation.postEdit);
    final failed = StateError('old');
    diagnostics.capture(failed);
    await diagnostics.clear();
    await old.run(() async {
      diagnostics.capture(StateError('late'));
    });
    expect(diagnostics.records, isEmpty);
    diagnostics.capture(failed);
    await diagnostics.settled;
    expect(diagnostics.records, hasLength(1));
  });

  test('最多 50 条、7 天、1 MiB，损坏存储降级且不递归记录', () async {
    var now = DateTime.utc(2026, 9, 6);
    final store = MemoryStore();
    final diagnostics = FailureDiagnostics(store: store, now: () => now);
    for (var i = 0; i < 55; i++) {
      diagnostics.capture(StateError('$i'));
    }
    await diagnostics.settled;
    expect(diagnostics.records, hasLength(50));
    expect(utf8.encode(store.value!).length, lessThanOrEqualTo(1024 * 1024));
    now = now.add(const Duration(days: 8));
    store.broken = true;
    diagnostics.capture(StateError('new'));
    await diagnostics.settled;
    expect(diagnostics.records, hasLength(1));
    expect(diagnostics.storageAvailable, isFalse);
  });

  test('字符串异常也能记录；同一异常不重复发送，主动取消不记录', () async {
    final diagnostics = FailureDiagnostics();
    final error = StateError('secret');
    final id = diagnostics.capture(error);
    expect(diagnostics.capture(error), id);
    diagnostics.capture('private thrown string');
    diagnostics.capture(const ApiFailure(reason: FailureReason.cancelled));
    await diagnostics.settled;
    expect(diagnostics.records, hasLength(2));
    expect(diagnostics.export(), isNot(contains('private thrown string')));
  });

  test('成功返回后的本地校验失败保留已收到返回与请求编号', () async {
    final diagnostics = FailureDiagnostics();
    final dio = Dio()
      ..interceptors.add(
        NetworkDiagnosticInterceptor(diagnostics: diagnostics),
      );
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Request-ID'] = requestId;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              headers: Headers.fromMap({
                'x-request-id': [requestId],
              }),
              data: {'code': 0},
            ),
            true,
          );
        },
      ),
    );
    await diagnostics.attempt(DiagnosticOperation.postEdit).run(() async {
      await dio.patch<Object?>('https://private.invalid/posts/private-id');
      diagnostics.capture(
        const ApiFailure(
          source: FailureSource.content,
          reason: FailureReason.contractViolation,
        ),
        stage: DiagnosticStage.decode,
      );
    });
    await diagnostics.settled;
    expect(diagnostics.records.single.fields['responseReceived'], true);
    expect(diagnostics.records.single.fields['httpStatus'], 200);
    expect(diagnostics.records.single.fields['requestId'], requestId);
    expect(diagnostics.export(), isNot(contains('private-id')));
    dio.close();
  });
}
