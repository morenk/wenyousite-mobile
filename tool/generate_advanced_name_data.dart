import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// 独立生成进阶 v2，核验全部内容与普通／历史依赖版本。
void main(List<String> args) {
  final source = Directory('contracts/toolbox');
  final manifest =
      jsonDecode(File('${source.path}/source-advanced.json').readAsStringSync())
          as Map<String, Object?>;
  final recordedFiles = manifest['files']! as Map<String, Object?>;
  final sources = <String, String>{};
  for (final entry in recordedFiles.entries) {
    final file = File('${source.path}/${entry.key}');
    final expected = entry.value! as Map<String, Object?>;
    if (sha256.convert(file.readAsBytesSync()).toString() !=
        expected['sha256']) {
      throw StateError('进阶词库摘要不符：${entry.key}，请从固定提交重新同步');
    }
    sources[entry.key] = file.readAsStringSync();
  }
  final advancedManifest =
      jsonDecode(sources['advanced-name-manifest.json']!)
          as Map<String, Object?>;
  if (advancedManifest['schemaVersion'] != 2) throw StateError('进阶词库版本不符');
  for (final entry
      in (advancedManifest['files']! as List<Object?>)
          .cast<Map<String, Object?>>()) {
    final matching = recordedFiles.values.cast<Map<String, Object?>>().where(
      (file) =>
          file['path'] == entry['path'] && file['sha256'] == entry['sha256'],
    );
    if (matching.length != 1) throw StateError('进阶契约内容未完整同步：${entry['path']}');
  }
  for (final dependency in {
    'ordinaryDataRevision': 'source.json',
    'historicalDataRevision': 'source-historical.json',
  }.entries) {
    final data =
        jsonDecode(
              File('${source.path}/${dependency.value}').readAsStringSync(),
            )
            as Map<String, Object?>;
    if (advancedManifest[dependency.key] != data['revision']) {
      throw StateError('进阶词库依赖版本不同：${dependency.key}');
    }
  }
  final advancedData =
      jsonDecode(sources['advanced-name-data.json']!) as Map<String, Object?>;
  final countries = (advancedData['styles']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .map((style) => style['country']! as String)
      .toSet();
  if (countries.any((country) => !RegExp(r'^[a-z]{2}$').hasMatch(country))) {
    throw StateError('进阶国家代码无效');
  }
  final buffer = StringBuffer(
    '// GENERATED CODE - DO NOT MODIFY BY HAND.\n'
    '// 已提交 Web 进阶词库 ${manifest['revision']}，\n'
    '// 由 tool/generate_advanced_name_data.dart 生成。\n',
  );
  buffer.writeln(
    'const advancedNameCountries = <String>{${countries.map((country) => "'$country'").join(', ')}};',
  );
  for (final entry in {
    'advancedNamesJson': 'advanced-name-data.json',
    'advancedNamesLicense': 'LICENSE.advanced-names.txt',
  }.entries) {
    final contents = sources[entry.value]!;
    if (contents.contains("'''")) throw StateError('源数据包含保留的字面量分隔符');
    buffer.writeln("const ${entry.key} = r'''$contents''';");
  }
  final output = File(
    'lib/features/toolbox/application/advanced_name_data.g.dart',
  );
  final temporary = File(
    '${Directory.systemTemp.path}/wenyou-advanced-names-$pid.dart',
  )..writeAsStringSync(buffer.toString());
  try {
    final result = Process.runSync(Platform.resolvedExecutable, [
      'format',
      temporary.path,
    ]);
    if (result.exitCode != 0) throw StateError('进阶词库格式化失败');
    final contents = temporary.readAsStringSync();
    if (args.contains('--check')) {
      if (!output.existsSync() || output.readAsStringSync() != contents) {
        throw StateError('进阶起名数据生成产物不同步');
      }
    } else {
      output.parent.createSync(recursive: true);
      output.writeAsStringSync(contents);
    }
  } finally {
    temporary.deleteSync();
  }
  stdout.writeln('进阶词库 ${manifest['revision']} 数据与摘要校验通过');
}
