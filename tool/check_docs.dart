import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const requiredHeadings = <String>[
  '## 1. 模块目标与非目标',
  '## 2. 用户角色与使用场景',
  '## 3. 页面、入口和导航关系',
  '## 4. 用户操作流程',
  '## 5. API operationId 与生成类型',
  '## 6. 状态模型和数据流',
  '## 7. 鉴权、权限和隐私规则',
  '## 8. 本地存储、缓存及失效规则',
  '## 9. 加载、空数据、错误、重试和冲突状态',
  '## 10. 跨模块约束',
  '## 11. 测试场景与验收条件',
  '## 12. 已知限制和后续功能',
  '## 13. 最近审查的契约版本和后端提交',
  '## 14. 相关代码与架构文档',
];

final errors = <String>[];

void main() {
  final root = Directory.current;
  if (!File(p.join(root.path, 'pubspec.yaml')).existsSync()) {
    stderr.writeln('docs:check 必须从移动端仓库根目录运行。');
    exitCode = 1;
    return;
  }

  final operationIds = _loadOperationIds(root.path);
  final metadata = _loadContractMetadata(root.path);
  final indexFile = File(p.join(root.path, 'docs', 'modules', 'README.md'));
  if (!indexFile.existsSync()) {
    errors.add('缺少 docs/modules/README.md 模块索引。');
  }
  final indexText = indexFile.existsSync() ? indexFile.readAsStringSync() : '';

  final featureRoot = Directory(p.join(root.path, 'lib', 'features'));
  final modules = featureRoot.existsSync()
      ? (featureRoot
            .listSync()
            .whereType<Directory>()
            .map((directory) => p.basename(directory.path).replaceAll('_', '-'))
            .toList()
          ..sort())
      : <String>[];

  for (final module in modules) {
    final doc = File(p.join(root.path, 'docs', 'modules', '$module.md'));
    if (!doc.existsSync()) {
      errors.add('功能模块 $module 缺少 docs/modules/$module.md。');
      continue;
    }
    if (!RegExp('\\|\\s*${RegExp.escape(module)}\\s*\\|').hasMatch(indexText)) {
      errors.add('模块 $module 未出现在 docs/modules/README.md 表格中。');
    }
    _checkModuleDoc(doc, operationIds, metadata);
  }

  if (indexFile.existsSync()) {
    _checkLinks(indexFile, root.path);
  }
  final architectureDir = Directory(p.join(root.path, 'docs', 'architecture'));
  if (architectureDir.existsSync()) {
    for (final file in architectureDir.listSync().whereType<File>()) {
      if (p.extension(file.path) == '.md') _checkLinks(file, root.path);
    }
  }

  _checkBehavioralDocSync(root.path);

  if (errors.isNotEmpty) {
    stderr.writeln('docs:check 发现 ${errors.length} 个问题：');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('docs:check 通过：${modules.length} 个功能模块文档完整。');
}

Set<String> _loadOperationIds(String root) {
  final contract = File(p.join(root, 'contracts', 'openapi.json'));
  if (!contract.existsSync()) {
    errors.add('缺少 contracts/openapi.json。');
    return const {};
  }
  final json = jsonDecode(contract.readAsStringSync()) as Map<String, dynamic>;
  final ids = <String>{};

  void visit(Object? value) {
    if (value is Map<String, dynamic>) {
      final operationId = value['operationId'];
      if (operationId is String) ids.add(operationId);
      for (final child in value.values) {
        visit(child);
      }
    } else if (value is List<dynamic>) {
      for (final child in value) {
        visit(child);
      }
    }
  }

  visit(json);
  return ids;
}

Map<String, String> _loadContractMetadata(String root) {
  final file = File(p.join(root, 'contracts', 'backend-contract.properties'));
  if (!file.existsSync()) {
    errors.add('缺少 contracts/backend-contract.properties。');
    return const {};
  }
  final values = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final separator = line.indexOf('=');
    if (separator > 0) {
      values[line.substring(0, separator)] = line.substring(separator + 1);
    }
  }
  final version = values['contractVersion'] ?? '';
  final revision = values['backendRevision'] ?? '';
  final markdownVersion = values['markdownContractVersion'] ?? '';
  if (!RegExp(r'^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$').hasMatch(version)) {
    errors.add('contractVersion 格式不正确：$version');
  }
  if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(revision)) {
    errors.add('backendRevision 必须是完整 40 位 Git SHA：$revision');
  }
  if (!RegExp(r'^\d+$').hasMatch(markdownVersion)) {
    errors.add('markdownContractVersion 格式不正确：$markdownVersion');
  }
  return values;
}

void _checkModuleDoc(
  File file,
  Set<String> operationIds,
  Map<String, String> metadata,
) {
  final text = file.readAsStringSync();
  final name = p.basename(file.path);
  for (final heading in requiredHeadings) {
    if (!text.contains(heading)) errors.add('$name 缺少标题“$heading”。');
  }

  final apiSection = _section(text, requiredHeadings[4]);
  final identifiers = RegExp(
    r'`([a-z][A-Za-z0-9]+)`',
  ).allMatches(apiSection).map((match) => match.group(1)!).toSet();
  if (identifiers.isEmpty) {
    errors.add('$name 的 API 章节未引用任何 operationId。');
  }
  for (final identifier in identifiers) {
    if (!operationIds.contains(identifier)) {
      errors.add('$name 引用了不存在的 operationId：$identifier');
    }
  }

  final contractVersion = metadata['contractVersion'];
  final backendRevision = metadata['backendRevision'];
  if (contractVersion != null && !text.contains(contractVersion)) {
    errors.add('$name 未记录当前契约版本 $contractVersion。');
  }
  if (backendRevision != null && !text.contains(backendRevision)) {
    errors.add('$name 未记录当前后端提交 $backendRevision。');
  }
  _checkLinks(file, p.dirname(p.dirname(p.dirname(file.path))));
}

String _section(String text, String heading) {
  final start = text.indexOf(heading);
  if (start < 0) return '';
  final next = text.indexOf('\n## ', start + heading.length);
  return text.substring(start, next < 0 ? text.length : next);
}

void _checkLinks(File file, String root) {
  final text = file.readAsStringSync();
  final links = RegExp(r'\[[^\]]+\]\(([^)]+)\)');
  for (final match in links.allMatches(text)) {
    final rawTarget = match.group(1)!.trim();
    if (rawTarget.startsWith('http://') ||
        rawTarget.startsWith('https://') ||
        rawTarget.startsWith('mailto:') ||
        rawTarget.startsWith('/') ||
        rawTarget.startsWith('#')) {
      continue;
    }
    final target = Uri.decodeComponent(rawTarget.split('#').first);
    final resolved = p.normalize(p.join(p.dirname(file.path), target));
    if (!p.isWithin(root, resolved) && p.normalize(root) != resolved) {
      errors.add('${p.basename(file.path)} 的链接越出仓库：$rawTarget');
      continue;
    }
    if (!File(resolved).existsSync() && !Directory(resolved).existsSync()) {
      errors.add('${p.basename(file.path)} 存在失效链接：$rawTarget');
    }
  }
}

void _checkBehavioralDocSync(String root) {
  final parentCheck = Process.runSync(
    'git',
    ['rev-parse', '--verify', 'HEAD^'],
    workingDirectory: root,
    runInShell: true,
  );
  if (parentCheck.exitCode != 0) return;

  final diff = Process.runSync(
    'git',
    ['diff', '--name-only', 'HEAD^', 'HEAD'],
    workingDirectory: root,
    runInShell: true,
  );
  if (diff.exitCode != 0) return;
  final changed = const LineSplitter().convert(diff.stdout as String).toSet();
  final changedModules = <String>{};
  for (final path in changed) {
    final match = RegExp(r'^lib/features/([^/]+)/').firstMatch(path);
    if (match != null) changedModules.add(match.group(1)!.replaceAll('_', '-'));
  }
  final missingDocs = changedModules
      .where((module) => !changed.contains('docs/modules/$module.md'))
      .toList();
  if (missingDocs.isEmpty) return;

  final message =
      Process.runSync(
            'git',
            ['log', '-1', '--pretty=%B'],
            workingDirectory: root,
            runInShell: true,
          ).stdout
          as String;
  if (!RegExp(r'^Docs-Impact: none - .+', multiLine: true).hasMatch(message)) {
    errors.add(
      '行为代码变化但模块文档未同步：${missingDocs.join(', ')}；'
      '请更新文档或在提交中说明 Docs-Impact: none - 原因。',
    );
  }
}
