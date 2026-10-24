import 'dart:convert';
import 'dart:io';

import 'android_probe.dart';
import 'vm_probe.dart';

/// 连接已启动的真实产品。仅接受采样命令，不接受导航/业务写入或任意VM表达式。
Future<void> main(List<String> arguments) async {
  FontVmProbe? vm;
  try {
    if (!Platform.isWindows) throw StateError('只允许在Windows开发机采样');
    final args = <String, String>{};
    for (var i = 0; i < arguments.length; i += 2) {
      if (i + 1 >= arguments.length || !arguments[i].startsWith('--')) {
        throw const FormatException('参数必须使用 --名称 值');
      }
      if (args.containsKey(arguments[i])) throw const FormatException('参数重复');
      args[arguments[i]] = arguments[i + 1];
    }
    if (args.keys.any(
      (key) => ![
        '--run-id',
        '--device',
        '--vm-uri',
        '--candidate',
        '--adb',
      ].contains(key),
    )) {
      throw const FormatException('未知参数');
    }
    final runId = args['--run-id'] ?? '';
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,95}$').hasMatch(runId)) {
      throw const FormatException('runId无效');
    }
    final device = args['--device'] ?? '';
    if (!RegExp(r'^[A-Za-z0-9._:-]+$').hasMatch(device)) {
      throw const FormatException('设备序号无效');
    }
    final candidate =
        jsonDecode(await File(args['--candidate'] ?? '').readAsString()) as Map;
    if (candidate['applicationId'] != acceptancePackage ||
        candidate['apiBaseUrl'] != acceptanceApi ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch('${candidate['apkSha256']}') ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch('${candidate['sourceDigest']}') ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch('${candidate['definesSha256']}')) {
      throw StateError('候选配置、包名或摘要不符合联验约定');
    }
    final output = Directory('build/font-acceptance/$runId');
    if (await output.exists()) throw StateError('证据目录已存在，不能覆盖或断连后续接原旅程');
    final android = AndroidFontProbe(
      args['--adb'] ?? r'D:\sdk\android\platform-tools\adb.exe',
      device,
    );
    final baseline = await android.identity();
    if (baseline['apkSha256'] != candidate['apkSha256']) {
      throw StateError('设备APK与固定候选摘要不一致');
    }
    vm = await FontVmProbe.connect(args['--vm-uri'] ?? '');
    final vmIdentity = await vm.attach();
    if (baseline['pid'] != vmIdentity['pid']) {
      throw StateError('VM Service不属于目标Android进程');
    }
    baseline.addAll(vmIdentity);
    await vm.evaluateSnapshot(const []); // 真实选择器已打开且实际API必须一致。
    await output.create(recursive: true);
    await _json(File('${output.path}/session.json'), {
      'schemaVersion': 1,
      'runId': runId,
      'startedAt': DateTime.now().toUtc().toIso8601String(),
      ...baseline,
      'candidateCommit': candidate['commit'],
      'sourceDigest': candidate['sourceDigest'],
      'definesSha256': candidate['definesSha256'],
      'api': acceptanceApi,
      'package': acceptancePackage,
      'note': '只读观察，不代表隔离已核验或治理已ack；不采集VM地址/Token/正文。',
    });
    stdout.writeln(
      '观察器已绑定真实产品。输入一行JSON：{"stage":"client-ready","fontIds":[]}；quit结束。',
    );
    await for (final line
        in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.trim() == 'quit') break;
      final command = jsonDecode(line) as Map;
      final stage = command['stage'] as String? ?? '';
      final ids = (command['fontIds'] as List? ?? []).cast<String>();
      if (command.keys.any((key) => !['stage', 'fontIds'].contains(key)) ||
          !RegExp(r'^[a-z0-9][a-z0-9-]{0,63}$').hasMatch(stage)) {
        throw const FormatException('仅允许合法阶段名和fontIds');
      }
      fontSnapshotExpression(ids);
      final directory = Directory('${output.path}/$stage');
      if (await directory.exists()) throw StateError('阶段证据已存在，不能覆盖');
      final before = await android.identity();
      final currentVm = await vm.call('getVM');
      if (before['pid'] != currentVm['pid'] ||
          !(currentVm['isolates'] as List).cast<Map>().any(
            (isolate) => isolate['id'] == vmIdentity['isolateId'],
          )) {
        throw StateError('Android与VM进程/isolate发生变化');
      }
      sameSession(baseline, {
        ...vmIdentity,
        ...before,
        'vmStartTime': currentVm['startTime'],
      });
      final fonts = await vm.evaluateSnapshot(ids);
      final memory = await vm.memory();
      final raw = await android.capture(before['pid']! as int);
      final after = await android.identity();
      sameSession(baseline, {...vmIdentity, ...after});
      if (vm.invalidations.isNotEmpty) throw StateError('采样期间发生VM重载或退出');
      final memoryMetrics = androidMemory(raw.meminfo, raw.status);
      if (memoryMetrics['pssKiB'] == null || memoryMetrics['rssKiB'] == null) {
        throw StateError('设备未返回可识别PSS/RSS，不能伪造零值');
      }
      await directory.create();
      await File(
        '${directory.path}/screen.png',
      ).writeAsBytes(raw.png, flush: true);
      await File(
        '${directory.path}/meminfo.txt',
      ).writeAsString(raw.meminfo, flush: true);
      // status原文不落盘；只保存明确的内存指标与进程身份。
      await _json(File('${directory.path}/snapshot.json'), {
        'schemaVersion': 1,
        'runId': runId,
        'stage': stage,
        'sampledAt': DateTime.now().toUtc().toIso8601String(),
        ...baseline,
        'fonts': fonts,
        'androidMemory': memoryMetrics,
        'vmMemory': memory,
        'checkpointAck': false,
        'requiresVisualReview': true,
      });
      stdout.writeln('已记录 $stage；请人工核对实际产品画面并等待治理ack。');
    }
    await _json(File('${output.path}/observer-ended.json'), {
      'endedAt': DateTime.now().toUtc().toIso8601String(),
      'invalidations': vm.invalidations,
      'acceptancePassed': false,
    });
  } on Object catch (error) {
    // 网络/VM错误可能含诊断口访问码，不能原样输出第三方异常。
    stderr.writeln(
      error is StateError || error is FormatException
          ? '采样停止：${error is StateError ? error.message : (error as FormatException).message}'
          : '采样停止：连接、设备或文件操作失败；不输出诊断口和敏感响应。',
    );
    exitCode = 1;
  } finally {
    await vm?.close();
  }
}

Future<void> _json(File file, Map<String, Object?> value) => file.writeAsString(
  const JsonEncoder.withIndent('  ').convert(value),
  flush: true,
);
