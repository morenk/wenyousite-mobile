import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// 历史姓名使用独立来源清单，不改变普通起名词库的版本。
void main(List<String> args) {
  final source = Directory('contracts/toolbox');
  final manifest =
      jsonDecode(
            File('${source.path}/source-historical.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  final sources = <String, String>{};
  for (final entry in (manifest['files']! as Map<String, Object?>).entries) {
    final file = File('${source.path}/${entry.key}');
    final expected = entry.value! as Map<String, Object?>;
    if (sha256.convert(file.readAsBytesSync()).toString() !=
        expected['sha256']) {
      throw StateError('历史词库摘要不符：${entry.key}，请从固定提交重新同步');
    }
    sources[entry.key] = file.readAsStringSync();
  }
  final historicalManifest =
      jsonDecode(sources['historical-name-manifest.json']!)
          as Map<String, Object?>;
  final recordedFiles = manifest['files']! as Map<String, Object?>;
  for (final entry
      in (historicalManifest['files']! as Map<String, Object?>).entries) {
    final matching = recordedFiles.values.cast<Map<String, Object?>>().where(
      (file) => file['path'] == entry.key && file['sha256'] == entry.value,
    );
    if (matching.length != 1) throw StateError('历史契约内容未完整同步：${entry.key}');
  }
  final ordinary =
      jsonDecode(File('${source.path}/source.json').readAsStringSync())
          as Map<String, Object?>;
  if (ordinary['revision'] != historicalManifest['ordinaryDataRevision']) {
    throw StateError('普通词库与历史词库声明的依赖版本不同');
  }
  final buffer = StringBuffer(
    '// GENERATED CODE - DO NOT MODIFY BY HAND.\n'
    '// 已提交 Web 历史词库 ${manifest['revision']}，\n'
    '// 由 tool/generate_historical_name_data.dart 生成。\n',
  );
  final historicalData =
      jsonDecode(sources['historical-name-data.json']!) as Map<String, Object?>;
  final countries = (historicalData['profiles']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .map((profile) => profile['country']! as String)
      .toSet();
  if (countries.any((country) => !RegExp(r'^[a-z]{2}$').hasMatch(country))) {
    throw StateError('历史国家代码无效');
  }
  buffer.writeln(
    'const historicalNameCountries = <String>{'
    '${countries.map((country) => "'$country'").join(', ')}};',
  );
  for (final entry in {
    'historicalNamesJson': 'historical-name-data.json',
    'historicalNamesLicense': 'LICENSE.historical-names.txt',
  }.entries) {
    final contents = sources[entry.value]!;
    if (contents.contains("'''")) throw StateError('源数据包含保留的字面量分隔符');
    buffer.writeln("const ${entry.key} = r'''$contents''';");
  }
  final output = File(
    'lib/features/toolbox/application/historical_name_data.g.dart',
  );
  final temporary = File(
    '${Directory.systemTemp.path}/wenyou-historical-names-$pid.dart',
  )..writeAsStringSync(buffer.toString());
  try {
    final result = Process.runSync(Platform.resolvedExecutable, [
      'format',
      temporary.path,
    ]);
    if (result.exitCode != 0) throw StateError('历史词库格式化失败');
    final contents = temporary.readAsStringSync();
    if (args.contains('--check')) {
      if (!output.existsSync() || output.readAsStringSync() != contents) {
        throw StateError('历史起名数据生成产物不同步');
      }
    } else {
      output.parent.createSync(recursive: true);
      output.writeAsStringSync(contents);
    }
  } finally {
    temporary.deleteSync();
  }
  stdout.writeln('历史词库 ${manifest['revision']} 数据与摘要校验通过');
}
