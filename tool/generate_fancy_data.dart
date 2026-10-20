import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// 从固定 Web 提交生成离线清单，任何手工改写都会使摘要检查失败。
void main(List<String> args) {
  const root = 'contracts/toolbox';
  final manifest =
      jsonDecode(File('$root/source-fancy.json').readAsStringSync())
          as Map<String, Object?>;
  final files = manifest['files']! as Map<String, Object?>;
  for (final entry in files.entries) {
    final expected = entry.value! as Map<String, Object?>;
    final bytes = File('$root/${entry.key}').readAsBytesSync();
    if (sha256.convert(bytes).toString() != expected['sha256']) {
      throw StateError('花体数据摘要不符：${entry.key}');
    }
  }
  final sourceManifest =
      jsonDecode(File('$root/fancy-manifest.json').readAsStringSync())
          as Map<String, Object?>;
  for (final entry
      in (sourceManifest['files']! as List<Object?>)
          .cast<Map<String, Object?>>()) {
    final matching = files.values.cast<Map<String, Object?>>().where(
      (file) =>
          file['path'] == entry['path'] && file['sha256'] == entry['sha256'],
    );
    if (matching.length != 1) {
      throw StateError('花体清单未完整同步：${entry['path']}');
    }
  }
  final source = File('$root/fancy-data.json').readAsStringSync();
  final data = jsonDecode(source) as Map<String, Object?>;
  if (data['schemaVersion'] != 2 || data['dataVersion'] != 'fancy-v2') {
    throw StateError('花体清单版本不符');
  }
  if (source.contains("'''")) throw StateError('源数据含保留字面量分隔符');
  final license = File('$root/LICENSE.fancy.txt').readAsStringSync();
  if (license.contains("'''")) throw StateError('源许可含保留字面量分隔符');
  final contents =
      '// GENERATED CODE - DO NOT MODIFY BY HAND.\n'
      '// Web 已提交花体清单 ${manifest['revision']}。\n'
      '// 由 tool/generate_fancy_data.dart 生成。\n'
      "const fancyDataJson = r'''$source''';\n"
      "const fancyDataLicense = r'''$license''';\n";
  final output = File('lib/features/toolbox/application/fancy_data.g.dart');
  if (args.contains('--check')) {
    if (!output.existsSync() || output.readAsStringSync() != contents) {
      throw StateError('花体清单生成产物不同步');
    }
  } else {
    output.writeAsStringSync(contents);
  }
  stdout.writeln('花体清单 ${manifest['revision']} 数据与摘要校验通过');
}
