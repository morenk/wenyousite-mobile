import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

void main() {
  test('真实 SDK 信封只含白名单字段，服务确认同一事件 ID 后才出队', () async {
    final outgoing = <String>[];
    final sender = DiagnosticSentrySender(
      'https://public-key@example.invalid/42',
      httpClientFactory: () => MockClient((request) async {
        final bytes = request.headers['content-encoding'] == 'gzip'
            ? gzip.decode(request.bodyBytes)
            : request.bodyBytes;
        final body = utf8.decode(bytes);
        outgoing.add(body);
        final header = jsonDecode(body.split('\n').first) as Map;
        return http.Response(jsonEncode({'id': header['event_id']}), 200);
      }),
    );
    final diagnostics = FailureDiagnostics(sender: sender);
    final id = diagnostics.capture(
      StateError('private-body'),
      stackTrace: StackTrace.fromString(
        '#0 secret (package:wenyousite_mobile/main.dart:1:2)',
      ),
    );
    await diagnostics.settled;
    expect(outgoing, hasLength(1));
    expect(outgoing.single, contains(id!.replaceAll('-', '')));
    expect(outgoing.single, isNot(contains('private-body')));
    expect(outgoing.single, isNot(contains('secret')));
    expect(outgoing.single, isNot(contains('"user":')));
    expect(outgoing.single, isNot(contains('"request":')));
    expect(outgoing.single, isNot(contains('"breadcrumbs":')));
    expect(diagnostics.records.single.pending, isFalse);
    sender.cancel();
  });

  test('Sentry 503 保留待发送记录，后续错误不会立即重复连接', () async {
    var calls = 0;
    final sender = DiagnosticSentrySender(
      'https://key@example.invalid/42',
      httpClientFactory: () => MockClient((request) async {
        calls++;
        return http.Response('{}', 503);
      }),
    );
    final diagnostics = FailureDiagnostics(sender: sender);
    diagnostics.capture(StateError('one'));
    await diagnostics.settled;
    diagnostics.capture(StateError('two'));
    await diagnostics.settled;
    expect(calls, 1);
    expect(diagnostics.records.every((record) => record.pending), isTrue);
    sender.cancel();
  });
}
