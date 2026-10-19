import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// 从已检入的词库生成只读 Dart 常量；--check 核对来源摘要及产物一致性。
void main(List<String> args) {
  final check = args.contains('--check');
  final source = Directory('contracts/toolbox');
  final manifest =
      jsonDecode(File('${source.path}/source.json').readAsStringSync())
          as Map<String, Object?>;
  final files = manifest['files']! as Map<String, Object?>;
  final sources = <String, String>{};
  for (final entry in files.entries) {
    final file = File('${source.path}/${entry.key}');
    final expected = entry.value! as Map<String, Object?>;
    if (sha256.convert(file.readAsBytesSync()).toString() !=
        expected['sha256']) {
      throw StateError('词库摘要不符：${entry.key}，请从固定提交重新同步');
    }
    sources[entry.key] = file.readAsStringSync();
  }
  final buffer = StringBuffer(
    '// GENERATED CODE - DO NOT MODIFY BY HAND.\n'
    '// 已提交 Web 词库 ${manifest['revision']}，由 tool/generate_toolbox_data.dart 生成。\n',
  );
  for (final entry in {
    'bilingualNamesJson': 'bilingual-name-data.json',
    'chineseNamesJson': 'cn.json',
    'nameInspirationJson': 'name-inspiration.json',
    'fakerNamesLicense': 'LICENSE.faker.txt',
    'wenyouNamesLicense': 'LICENSE.wenyou.txt',
  }.entries) {
    final contents = sources[entry.value]!;
    // 原始多行字面量保留字符与许可证，不产生 Dart 字符串插值。
    if (contents.contains("'''")) throw StateError('源数据包含保留的字面量分隔符');
    buffer.writeln("const ${entry.key} = r'''$contents''';");
  }
  final output = File('lib/features/toolbox/application/toolbox_data.g.dart');
  if (check) {
    // 格式化器仅影响源码空白：通过 format 的输出做比较，不修改产物。
    final temporary = File(
      '${Directory.systemTemp.path}/wenyou-toolbox-$pid.dart',
    )..writeAsStringSync(buffer.toString());
    try {
      final result = Process.runSync(Platform.resolvedExecutable, [
        'format',
        temporary.path,
      ]);
      if (result.exitCode != 0 ||
          !output.existsSync() ||
          output.readAsStringSync() != temporary.readAsStringSync()) {
        throw StateError('工具箱数据生成产物不同步');
      }
    } finally {
      temporary.deleteSync();
    }
  } else {
    output.parent.createSync(recursive: true);
    output.writeAsStringSync(buffer.toString());
    final result = Process.runSync(Platform.resolvedExecutable, [
      'format',
      output.path,
    ]);
    if (result.exitCode != 0) throw StateError('工具箱数据格式化失败');
  }
  stdout.writeln('工具箱 ${manifest['revision']} 数据与摘要校验通过');
}
