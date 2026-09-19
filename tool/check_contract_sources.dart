import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

void main() {
  try {
    final manifest = jsonDecode(
      File('contracts/markdown-editor-list-v1-source.json').readAsStringSync(),
    );
    if (manifest is! Map<String, dynamic> ||
        manifest['schemaVersion'] != 1 ||
        manifest['file'] != 'markdown-editor-list-v1-fixtures.json' ||
        manifest['backendRevision'] is! String ||
        !RegExp(
          r'^[0-9a-f]{40}$',
        ).hasMatch(manifest['backendRevision'] as String) ||
        manifest['sha256'] is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(manifest['sha256'] as String)) {
      throw const FormatException('固定列表契约来源清单不完整');
    }
    final actual = sha256.convert(
      File('contracts/markdown-editor-list-v1-fixtures.json').readAsBytesSync(),
    );
    if (actual.toString() != manifest['sha256']) {
      throw const FormatException('固定列表契约内容与来源SHA-256不一致');
    }
    stdout.writeln(
      '固定列表契约来源验证通过：${manifest['backendRevision']} / $actual。'
      '其余契约来源见backend-contract.properties。',
    );
    final inlineSource =
        jsonDecode(
              File(
                'contracts/markdown-inline-combinations-v1-source.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    if (inlineSource['schemaVersion'] != 1 ||
        inlineSource['backendRevision'] is! String ||
        !RegExp(
          r'^[0-9a-f]{40}$',
        ).hasMatch(inlineSource['backendRevision'] as String)) {
      throw const FormatException('固定行内组合契约来源不完整');
    }
    final files = inlineSource['files'] as Map<String, dynamic>;
    for (final name in [
      'markdown-inline-combinations-v1-fixtures.json',
      'markdown-inline-combinations-v1.schema.json',
    ]) {
      final hash = sha256
          .convert(File('contracts/$name').readAsBytesSync())
          .toString();
      if (files[name] != hash) {
        throw FormatException('固定行内组合契约SHA-256不一致：$name');
      }
    }
    stdout.writeln('固定行内组合契约来源验证通过：${inlineSource['backendRevision']}。');
  } on Object catch (error) {
    stderr.writeln('contract:source 检查失败：$error');
    exitCode = 1;
  }
}
