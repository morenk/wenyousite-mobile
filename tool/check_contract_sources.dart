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
  } on Object catch (error) {
    stderr.writeln('contract:source 检查失败：$error');
    exitCode = 1;
  }
}
