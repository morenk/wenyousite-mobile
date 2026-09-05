import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_bootstrap.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

void main() {
  test('真实文件替换可恢复记录和关闭设置，损坏文件不会恢复自动发送', () async {
    final directory = await Directory.systemTemp.createTemp(
      'wenyou-diagnostic-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/records.json');
    final first = FailureDiagnostics(store: FileDiagnosticStore(file));
    await first.initialize();
    first.capture(StateError('private-content'));
    await first.settled;
    await first.setAutomaticSending(false);
    final restored = FailureDiagnostics(store: FileDiagnosticStore(file));
    await restored.initialize();
    expect(restored.automaticSending, isFalse);
    expect(restored.records.single.id, first.records.single.id);
    expect(await file.readAsString(), isNot(contains('private-content')));
    expect(await File('${file.path}.tmp').exists(), isFalse);
    await file.writeAsString('broken');
    final broken = FailureDiagnostics(store: FileDiagnosticStore(file));
    await broken.initialize();
    expect(broken.automaticSending, isFalse);
    expect(broken.storageAvailable, isFalse);
    expect(broken.records, isEmpty);
    await file.writeAsString('x' * (FailureDiagnostics.maximumBytes + 1));
    final oversized = FailureDiagnostics(store: FileDiagnosticStore(file));
    await oversized.initialize();
    expect(oversized.automaticSending, isFalse);
    expect(oversized.storageAvailable, isFalse);
  });

  test('全局入口保留原 Flutter 和 Dart 错误传播，不泄漏异常文本', () async {
    final originalFlutter = FlutterError.onError;
    final originalPlatform = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = originalFlutter;
      PlatformDispatcher.instance.onError = originalPlatform;
    });
    var flutterCalls = 0;
    var platformCalls = 0;
    FlutterError.onError = (_) => flutterCalls++;
    PlatformDispatcher.instance.onError = (_, _) {
      platformCalls++;
      return false;
    };
    final diagnostics = FailureDiagnostics();
    installFailureDiagnosticHandlers(diagnostics);
    FlutterError.onError!(
      FlutterErrorDetails(exception: StateError('private-flutter')),
    );
    final handled = PlatformDispatcher.instance.onError!(
      StateError('private-dart'),
      StackTrace.current,
    );
    await diagnostics.settled;
    expect(handled, isFalse);
    expect(flutterCalls, 1);
    expect(platformCalls, 1);
    expect(diagnostics.records.map((record) => record.operation).toSet(), {
      DiagnosticOperation.flutterError,
      DiagnosticOperation.dartError,
    });
    expect(diagnostics.export(), isNot(contains('private-')));
  });
}
