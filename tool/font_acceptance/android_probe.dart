import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const acceptancePackage = 'site.wenyou.app.debug';

int processStartTicks(String stat) {
  final end = stat.lastIndexOf(')');
  if (end < 0) throw const FormatException('进程stat格式无效');
  final fields = stat.substring(end + 1).trim().split(RegExp(r'\s+'));
  // ')' 后首字段为 /proc stat 字段3，字段22为进程启动 ticks。
  if (fields.length < 20) throw const FormatException('进程stat缺少启动时间');
  return int.parse(fields[19]);
}

Map<String, int?> androidMemory(String meminfo, String status) {
  int? number(String source, String pattern) {
    final match = RegExp(pattern, multiLine: true).firstMatch(source);
    return match == null ? null : int.parse(match[1]!);
  }

  return {
    'pssKiB': number(meminfo, r'TOTAL PSS:\s*(\d+)'),
    'rssKiB':
        number(meminfo, r'TOTAL RSS:\s*(\d+)') ??
        number(status, r'^VmRSS:\s*(\d+)\s+kB'),
    'peakRssKiB': number(status, r'^VmHWM:\s*(\d+)\s+kB'),
  };
}

void sameSession(Map<String, Object?> baseline, Map<String, Object?> current) {
  for (final key in [
    'device',
    'pid',
    'processStartTicks',
    'apkSha256',
    'vmStartTime',
    'isolateId',
    'isolateStartTime',
  ]) {
    if (baseline[key] == null || baseline[key] != current[key]) {
      throw StateError('核心旅程身份变化或缺失：$key；停止推进检查点');
    }
  }
}

class AndroidFontProbe {
  AndroidFontProbe(this.adb, this.device);
  final String adb, device;

  Future<ProcessResult> _run(
    List<String> arguments, {
    bool binary = false,
  }) async {
    final process = await Process.start(
      adb,
      ['-s', device, ...arguments],
      runInShell: false,
      mode: ProcessStartMode.normal,
    );
    final stdoutBytes = process.stdout.fold<List<int>>(
      [],
      (a, b) => a..addAll(b),
    );
    final stderrBytes = process.stderr.fold<List<int>>(
      [],
      (a, b) => a..addAll(b),
    );
    try {
      final code = await process.exitCode.timeout(const Duration(seconds: 30));
      final out = await stdoutBytes;
      await stderrBytes; // 不保存设备诊断中可能出现的账户信息。
      if (code != 0) throw StateError('ADB只读采样失败：${arguments.first}');
      return ProcessResult(
        process.pid,
        code,
        binary ? Uint8List.fromList(out) : utf8.decode(out),
        '',
      );
    } on Object {
      process.kill();
      rethrow;
    }
  }

  Future<String> text(List<String> arguments) async =>
      (await _run(arguments)).stdout as String;

  Future<Map<String, Object?>> identity() async {
    final pids = (await text(['shell', 'pidof', acceptancePackage])).trim();
    if (!RegExp(r'^\d+$').hasMatch(pids)) {
      throw StateError('真实产品Debug进程未运行或PID不唯一');
    }
    final stat = await text([
      'shell',
      'run-as',
      acceptancePackage,
      'cat',
      '/proc/$pids/stat',
    ]);
    final paths = (await text([
      'shell',
      'pm',
      'path',
      acceptancePackage,
    ])).trim().split(RegExp(r'\r?\n'));
    if (paths.length != 1 || !paths.single.startsWith('package:/data/app/')) {
      throw StateError('目标包必须是单APK安装');
    }
    final apk = paths.single.substring('package:'.length);
    if (!RegExp(r'^/data/app/[A-Za-z0-9_./=+~-]+\.apk$').hasMatch(apk)) {
      throw StateError('设备APK路径不符合预期');
    }
    final hash = (await text([
      'shell',
      'sha256sum',
      apk,
    ])).trim().split(' ').first;
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash)) {
      throw StateError('设备APK摘要无效');
    }
    return {
      'device': device,
      'pid': int.parse(pids),
      'processStartTicks': processStartTicks(stat),
      'apkSha256': hash,
    };
  }

  Future<({String meminfo, String status, Uint8List png})> capture(
    int pid,
  ) async {
    final activities = await text([
      'shell',
      'dumpsys',
      'activity',
      'activities',
    ]);
    final resumed = activities
        .split('\n')
        .where(
          (line) =>
              line.contains('topResumedActivity=') ||
              line.contains('mResumedActivity:'),
        );
    if (!resumed.any((line) => line.contains('$acceptancePackage/'))) {
      throw StateError('真实产品不在前台，不采集其他应用画面');
    }
    final meminfo = await text(['shell', 'dumpsys', 'meminfo', '$pid']);
    final status = await text([
      'shell',
      'run-as',
      acceptancePackage,
      'cat',
      '/proc/$pid/status',
    ]);
    final png =
        (await _run(['exec-out', 'screencap', '-p'], binary: true)).stdout
            as Uint8List;
    const signature = [137, 80, 78, 71, 13, 10, 26, 10];
    if (png.length < 8 ||
        List.generate(8, (i) => png[i] == signature[i]).contains(false)) {
      throw StateError('截图不是PNG，停止记录');
    }
    return (meminfo: meminfo, status: status, png: png);
  }
}
