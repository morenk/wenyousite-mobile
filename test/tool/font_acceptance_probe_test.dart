import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/font_acceptance/android_probe.dart';
import '../../tool/font_acceptance/vm_probe.dart';

void main() {
  test('只接受本机VM地址，不允许远程与用户信息', () {
    expect(
      localVmSocket('http://127.0.0.1:1234/token=/').toString(),
      'ws://127.0.0.1:1234/token=/ws',
    );
    expect(localVmSocket('ws://localhost:1234/token=/ws').path, '/token=/ws');
    for (final uri in [
      'http://example.test:1234/',
      'http://u:p@localhost/',
      'http://127.0.0.1/?secret=x',
      'file:///tmp/vm',
    ]) {
      expect(() => localVmSocket(uri), throwsFormatException);
    }
  });
  test('字体观察参数不能注入Dart表达式，且数量有界', () {
    expect(
      fontSnapshotExpression(['tfv_${'a' * 32}', 'great-vibes']),
      contains("'chargedInputBytes': _engineLedger.chargedInputBytes"),
    );
    for (final ids in [
      <String>['a"}); evil()'],
      List.filled(33, 'great-vibes'),
    ]) {
      expect(() => fontSnapshotExpression(ids), throwsFormatException);
    }
  });
  test('进程名含空格和括号时仍读取正确启动ticks', () {
    final tail = ['S', ...List.filled(18, '0'), '876543', '0'];
    expect(
      processStartTicks('42 (name (with) spaces) ${tail.join(' ')}'),
      876543,
    );
    expect(() => processStartTicks('42 (x) S 0'), throwsFormatException);
  });
  test('PSS和RSS独立采样，缺失指标不伪造零值', () {
    expect(
      androidMemory('TOTAL PSS: 12000 TOTAL RSS: 33000', 'VmHWM: 40000 kB'),
      {'pssKiB': 12000, 'rssKiB': 33000, 'peakRssKiB': 40000},
    );
    expect(
      androidMemory('TOTAL PSS: 12000', 'VmRSS: 25000 kB')['rssKiB'],
      25000,
    );
    expect(androidMemory('', '')['pssKiB'], isNull);
  });
  test('PID复用、APK更换、VM重启及isolate变化均拒绝原旅程', () {
    const baseline = <String, Object?>{
      'device': 'phone',
      'pid': 42,
      'processStartTicks': 99,
      'apkSha256': 'hash',
      'vmStartTime': 101,
      'isolateId': 'isolates/1',
      'isolateStartTime': 102,
    };
    sameSession(baseline, baseline);
    for (final key in baseline.keys) {
      expect(
        () => sameSession(baseline, {...baseline, key: 'changed'}),
        throwsStateError,
      );
      expect(
        () => sameSession(baseline, {...baseline, key: null}),
        throwsStateError,
      );
    }
  });
  test(
    '真实Dart VM可读取库私有账本和长JSON，不需要改产品或注册扩展',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'font-observer-vm-',
      );
      final serviceFile = File('${directory.path}/service.json');
      final fixture = File(
        'test/tool/fixtures/font_observer_vm_fixture.dart',
      ).absolute;
      final process = await Process.start(
        r'D:\sdk\flutter\bin\cache\dart-sdk\bin\dart.exe',
        [
          '--enable-vm-service=0/127.0.0.1',
          '--write-service-info=${serviceFile.path}',
          fixture.path,
        ],
        workingDirectory: Directory.current.path,
      );
      final ready = Completer<int>();
      final output = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.startsWith('{"ready":true') && !ready.isCompleted) {
              ready.complete((jsonDecode(line) as Map)['pid'] as int);
            }
          });
      unawaited(process.stderr.drain<void>());
      FontVmProbe? probe;
      try {
        Map? service;
        for (var i = 0; i < 400; i++) {
          if (await serviceFile.exists()) {
            try {
              service = jsonDecode(await serviceFile.readAsString()) as Map;
            } on FormatException {
              /* 文件写入尚未结束。 */
            }
            if (service?['uri'] != null) break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        expect(service?['uri'], isA<String>());
        final runtimePid = await ready.future.timeout(
          const Duration(seconds: 20),
        );
        probe = await FontVmProbe.connect(service!['uri'] as String);
        final identity = await probe.attach(libraryUri: fixture.uri.toString());
        expect(identity['pid'], runtimePid);
        final ids = List.generate(
          32,
          (i) => 'tfv_${i.toRadixString(16).padLeft(32, '0')}',
        );
        final snapshot = await probe.evaluateSnapshot(ids);
        expect((snapshot['ledger'] as Map)['chargedInputBytes'], 123);
        expect((snapshot['ledger'] as Map)['attemptedKeys'], 1);
        expect((snapshot['fonts'] as Map), hasLength(32));
        expect((await probe.memory())['forcedGc'], isFalse);
        final reload = await probe.call('reloadSources', {
          'isolateId': probe.isolateId,
          'force': true,
        });
        expect(reload['success'], isTrue, reason: jsonEncode(reload));
        for (var i = 0; i < 50 && probe.invalidations.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        expect(probe.invalidations, contains('IsolateReload'));
        await expectLater(probe.evaluateSnapshot(ids), throwsStateError);
      } finally {
        await probe?.close();
        process.stdin.writeln('quit');
        await process.stdin.close();
        try {
          await process.exitCode.timeout(const Duration(seconds: 5));
        } on TimeoutException {
          if (ready.isCompleted) Process.killPid(await ready.future);
          process.kill();
          await process.exitCode;
        }
        await output.cancel();
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(seconds: 45)),
    skip: !Platform.isWindows,
  );
}
