import 'dart:convert';
import 'dart:io';

import 'android_performance_metrics.dart';

void main(List<String> arguments) {
  final options = _parseOptions(arguments);
  final inputDirectory = Directory(_required(options, 'input-dir'));
  final output = File(_required(options, 'output'));
  final metadata = _readMap(File(_required(options, 'metadata')));
  final sourceRevision = _required(options, 'source-revision');
  final files =
      inputDirectory
          .listSync()
          .whereType<File>()
          .where((file) => RegExp(r'run-\d+\.json$').hasMatch(file.path))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));
  final runs = files.map(_readMap).toList(growable: false);
  final report = evaluateAndroidPerformance(
    runs: runs,
    device: metadata,
    sourceRevision: sourceRevision,
    generatedAt: DateTime.now(),
  );
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  stdout.writeln('性能报告：${output.path}');
  stdout.writeln(report['passed'] == true ? '60 Hz 性能门禁通过。' : '60 Hz 性能门禁失败。');
  if (report['passed'] != true) exitCode = 1;
}

Map<String, String> _parseOptions(List<String> arguments) {
  final result = <String, String>{};
  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (!argument.startsWith('--') || index + 1 >= arguments.length) {
      throw FormatException('无效参数：$argument');
    }
    result[argument.substring(2)] = arguments[++index];
  }
  return result;
}

String _required(Map<String, String> options, String key) {
  final value = options[key];
  if (value == null || value.isEmpty) throw FormatException('缺少 --$key');
  return value;
}

Map<String, Object?> _readMap(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map) throw FormatException('${file.path} 不是 JSON 对象');
  return Map<String, Object?>.from(decoded);
}
