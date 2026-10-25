import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _vendorRoot = 'packages/flutter_quill';
const _manifestPath = 'tool/vendor/flutter-quill.json';
const _patchPath = 'tool/patches/flutter-quill-heading-spacing.patch';

/// 仅完整核验的固定第三方快照获得架构例外；失败时不返回任何豁免文件。
({List<String> failures, Set<String> verifiedFiles})
validateVendoredDependencies(Directory root) {
  final failures = <String>[];
  final verifiedFiles = <String>{};
  final directory = Directory('${root.path}/$_vendorRoot');
  final manifestFile = File('${root.path}/$_manifestPath');
  if (!directory.existsSync() && !manifestFile.existsSync()) {
    return (failures: failures, verifiedFiles: verifiedFiles);
  }
  try {
    final manifest = jsonDecode(manifestFile.readAsStringSync()) as Map;
    if (manifest['schemaVersion'] != 1 ||
        manifest['root'] != _vendorRoot ||
        manifest['repository'] !=
            'https://github.com/singerdmx/flutter-quill.git' ||
        manifest['revision'] != 'c273155025d1255335a6dd3e6ecd3700d29f103e') {
      throw const FormatException('未登记的第三方来源或版本');
    }
    final patch = manifest['patch'] as Map;
    if (patch['path'] != _patchPath) {
      throw const FormatException('未登记的第三方补丁');
    }
    _verifyHash(File('${root.path}/$_patchPath'), patch['sha256'], failures);
    final files = Map<String, dynamic>.from(manifest['files'] as Map);
    if (!files.containsKey('LICENSE') ||
        !files.containsKey('pubspec.yaml') ||
        !files.containsKey('lib/src/editor/widgets/text/text_block.dart')) {
      throw const FormatException('缺少许可证、包配置或补丁目标');
    }
    for (final entry in files.entries) {
      final path = entry.key;
      if (path.isEmpty ||
          path.startsWith('/') ||
          path.contains('\\') ||
          path.contains(':') ||
          path
              .split('/')
              .any((part) => part.isEmpty || part == '..' || part == '.')) {
        throw const FormatException('第三方文件路径越界');
      }
      _verifyHash(File('${directory.path}/$path'), entry.value, failures);
      verifiedFiles.add('$_vendorRoot/$path');
    }
    final prefix = '${directory.path.replaceAll('\\', '/')}/';
    for (final entity in directory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      final path = entity.path.replaceAll('\\', '/').substring(prefix.length);
      // 依赖自己的解析/编译缓存不属于源码清单。
      if (path == '.dart_tool' ||
          path.startsWith('.dart_tool/') ||
          path == 'build' ||
          path.startsWith('build/')) {
        continue;
      }
      if (entity is Link) {
        failures.add('第三方源码不得包含符号链接: $_vendorRoot/$path');
      } else if (entity is File && !files.containsKey(path)) {
        failures.add('未登记的第三方文件: $_vendorRoot/$path');
      }
    }
  } on Object catch (error) {
    failures.add('第三方源码清单核验失败: $error');
  }
  return (
    failures: failures,
    verifiedFiles: failures.isEmpty ? verifiedFiles : <String>{},
  );
}

void _verifyHash(File file, Object? expected, List<String> failures) {
  if (expected is! String || !RegExp(r'^[a-f0-9]{64}$').hasMatch(expected)) {
    throw const FormatException('无效的第三方 SHA-256');
  }
  if (FileSystemEntity.typeSync(file.path, followLinks: false) !=
      FileSystemEntityType.file) {
    failures.add('第三方文件缺失或不是普通文件: ${file.path}');
  } else if (sha256.convert(file.readAsBytesSync()).toString() != expected) {
    failures.add('第三方文件 SHA-256 不匹配: ${file.path}');
  }
}
