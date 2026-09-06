import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

void main() {
  test(
    '显式验收：Sentry 接收一条脱敏诊断',
    () async {
      final sender = DiagnosticSentrySender(
        const String.fromEnvironment('SENTRY_DSN'),
      );
      addTearDown(sender.cancel);
      expect(sender.available, isTrue, reason: '需通过仓库外配置文件提供独立移动端 DSN');
      final diagnostics = FailureDiagnostics(sender: sender)
        ..environment = {
          'os': 'windows',
          'appVersion': '0.7.0-dev.1',
          'build': '94',
        };
      final id = diagnostics.capture(
        StateError('Explicit diagnostic receipt verification'),
        stackTrace: StackTrace.current,
      );
      await diagnostics.settled;
      expect(
        diagnostics.records.single.pending,
        isFalse,
        reason: '尚未收到 Sentry 的同编号事件确认',
      );
      // Only the generated correlation ID is printed, never the DSN or payload.
      debugPrint('SENTRY_DIAGNOSTIC_RECEIPT=$id');
    },
    skip: !const bool.fromEnvironment('WENYOU_VALIDATE_SENTRY'),
  );
}
