import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

void main() {
  test('AOT 只有行号时仍保留应用、依赖和 Dart 栈', () {
    // Windows Dart 3.12.2 AOT 实测使用只有行号的帧；线上原始栈已丢失。
    final frames = safeDiagnosticStack(
      StackTrace.fromString(
        '#0 private (package:wenyousite_mobile/main.dart:21)\n'
        '#1 private (package:flutter_quill/src/document/document.dart:88)\n'
        '#2 private (dart:isolate-patch/isolate_patch.dart:313)\n',
      ),
    );
    expect(frames, [
      'package:wenyousite_mobile/main.dart:21',
      'package:flutter_quill/src/document/document.dart:88',
      'dart:isolate-patch/isolate_patch.dart:313',
    ]);
  });

  test('只有行号的栈经落盘恢复和 Sentry 转换仍可定位', () async {
    final diagnostics = FailureDiagnostics();
    diagnostics.capture(
      StateError('private'),
      stackTrace: StackTrace.fromString(
        '#0 private (package:wenyousite_mobile/main.dart:21)\n'
        '#1 private (package:dio/src/dio_mixin.dart:55:9)',
      ),
    );
    await diagnostics.settled;
    final restored = DiagnosticRecord.fromJson(
      diagnostics.records.single.toJson(),
    )!;
    final event = diagnosticSentryEvent(restored);
    final frames = event.exceptions!.single.stackTrace!.frames;
    expect(frames, hasLength(2));
    expect(frames.last.fileName, 'package:wenyousite_mobile/main.dart');
    expect(frames.last.lineNo, 21);
    expect(frames.last.colNo, isNull);
    expect(frames.first.inApp, isFalse);
    expect(frames.last.inApp, isTrue);
  });

  test('同类异常不同应用位置分别分组', () async {
    final diagnostics = FailureDiagnostics();
    for (final line in [21, 42]) {
      diagnostics.capture(
        StateError('private'),
        stackTrace: StackTrace.fromString(
          '#0 private (package:wenyousite_mobile/main.dart:$line:1)',
        ),
      );
    }
    await diagnostics.settled;
    final groups = diagnostics.records.map(
      (r) => diagnosticSentryEvent(r).fingerprint,
    );
    expect(groups.first, isNot(equals(groups.last)));
  });
}
