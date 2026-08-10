import 'dart:convert';
import 'dart:io';

const _httpMethods = {
  'delete',
  'get',
  'head',
  'options',
  'patch',
  'post',
  'put',
  'trace',
};

void main(List<String> arguments) {
  final root = Directory.current;
  final contract = File('${root.path}/contracts/openapi.json');
  final exclusionFile = File('${root.path}/tool/api_coverage_exclusions.json');
  final sourceRoot = Directory('${root.path}/lib');
  if (!contract.existsSync() ||
      !exclusionFile.existsSync() ||
      !sourceRoot.existsSync()) {
    stderr.writeln('请从移动端仓库根目录运行 API 覆盖审计。');
    exitCode = 2;
    return;
  }

  final operations = _loadOperations(contract)..sort(_compareOperations);
  late final _ExclusionManifest manifest;
  try {
    manifest = _loadExclusions(exclusionFile);
  } on FormatException catch (error) {
    stderr.writeln('API 排除清单无效：${error.message}');
    exitCode = 2;
    return;
  }
  final contractVersion = _loadContractVersion(contract);
  if (manifest.contractVersion != contractVersion) {
    stderr.writeln(
      'API 排除清单契约版本 ${manifest.contractVersion} 与当前契约 '
      '$contractVersion 不一致，必须重新审查。',
    );
    exitCode = 2;
    return;
  }
  final exclusions = manifest.exclusions;
  final operationIds = operations.map((operation) => operation.id).toSet();
  final unknownExclusions = exclusions.keys
      .where((id) => !operationIds.contains(id))
      .toList();
  if (unknownExclusions.isNotEmpty) {
    stderr.writeln(
      'API 排除清单包含当前契约不存在的 operationId：${unknownExclusions.join(', ')}',
    );
    exitCode = 2;
    return;
  }
  final source = sourceRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');
  final covered = <_Operation>[];
  final scopeCovered = <_Operation>[];
  final scopeMissing = <_Operation>[];
  final excluded = <_Operation>[];
  for (final operation in operations) {
    final invocation = RegExp('\\b${RegExp.escape(operation.id)}\\s*\\(');
    final isCovered = invocation.hasMatch(source);
    if (isCovered) covered.add(operation);
    if (exclusions.containsKey(operation.id)) {
      excluded.add(operation);
    } else {
      (isCovered ? scopeCovered : scopeMissing).add(operation);
    }
  }

  final excludedButInvoked = excluded
      .where((operation) => covered.any((item) => item.id == operation.id))
      .toList();
  if (excludedButInvoked.isNotEmpty) {
    stderr.writeln('以下 operationId 已在移动端调用，必须先从排除清单移除：');
    for (final operation in excludedButInvoked) {
      stderr.writeln('- ${operation.id}');
    }
    exitCode = 2;
    return;
  }

  stdout.writeln('API raw coverage: ${covered.length}/${operations.length}');
  stdout.writeln(
    'Mobile API scope: ${scopeCovered.length}/'
    '${operations.length - excluded.length} '
    '(${scopeMissing.length} missing; ${excluded.length} excluded)',
  );
  if (scopeMissing.isNotEmpty) {
    final grouped = <String, List<_Operation>>{};
    for (final operation in scopeMissing) {
      grouped.putIfAbsent(operation.tag, () => []).add(operation);
    }
    for (final entry in grouped.entries) {
      stdout.writeln('\n[${entry.key}] ${entry.value.length}');
      for (final operation in entry.value) {
        stdout.writeln(
          '- ${operation.id}  ${operation.method.toUpperCase()} '
          '${operation.path}',
        );
      }
    }
  }

  final excludedByCategory = <String, List<_Operation>>{};
  for (final operation in excluded) {
    final category = exclusions[operation.id]!.category;
    excludedByCategory.putIfAbsent(category, () => []).add(operation);
  }
  for (final entry in excludedByCategory.entries) {
    final reason = exclusions[entry.value.first.id]!.reason;
    stdout.writeln(
      '\n[Excluded: ${entry.key}] ${entry.value.length} — $reason',
    );
  }

  if (arguments.contains('--require-complete') && scopeMissing.isNotEmpty) {
    exitCode = 1;
  }
}

_ExclusionManifest _loadExclusions(File source) {
  final root = jsonDecode(source.readAsStringSync()) as Map<String, Object?>;
  if (root['schemaVersion'] != 1) {
    throw const FormatException('不支持的 API 排除清单版本。');
  }
  final contractVersion = root['contractVersion'];
  if (contractVersion is! String || contractVersion.trim().isEmpty) {
    throw const FormatException('API 排除清单缺少 contractVersion。');
  }
  final values = root['exclusions'];
  if (values is! List) throw const FormatException('API 排除清单缺少 exclusions。');
  final exclusions = <String, _Exclusion>{};
  for (final value in values) {
    if (value is! Map<String, Object?>) {
      throw const FormatException('API 排除项格式错误。');
    }
    final id = value['operationId'];
    final category = value['category'];
    final reason = value['reason'];
    if (id is! String ||
        id.trim().isEmpty ||
        category is! String ||
        category.trim().isEmpty ||
        reason is! String ||
        reason.trim().isEmpty) {
      throw const FormatException('API 排除项字段不完整。');
    }
    if (exclusions.containsKey(id)) {
      throw FormatException('API 排除项重复：$id');
    }
    exclusions[id] = _Exclusion(
      category: category.trim(),
      reason: reason.trim(),
    );
  }
  return _ExclusionManifest(
    contractVersion: contractVersion.trim(),
    exclusions: exclusions,
  );
}

String _loadContractVersion(File contract) {
  final root = jsonDecode(contract.readAsStringSync()) as Map<String, Object?>;
  final info = root['info'] as Map<String, Object?>?;
  final version = info?['version'];
  if (version is! String || version.trim().isEmpty) {
    throw const FormatException('OpenAPI 契约缺少 info.version。');
  }
  return version.trim();
}

List<_Operation> _loadOperations(File contract) {
  final root = jsonDecode(contract.readAsStringSync()) as Map<String, Object?>;
  final paths = root['paths'] as Map<String, Object?>? ?? const {};
  final operations = <_Operation>[];
  for (final pathEntry in paths.entries) {
    final pathItem = pathEntry.value as Map<String, Object?>?;
    if (pathItem == null) continue;
    for (final methodEntry in pathItem.entries) {
      if (!_httpMethods.contains(methodEntry.key)) continue;
      final operation = methodEntry.value as Map<String, Object?>?;
      final id = operation?['operationId'];
      if (id is! String || id.trim().isEmpty) continue;
      final tags = operation?['tags'];
      final tag = tags is List && tags.isNotEmpty && tags.first is String
          ? tags.first as String
          : 'Untagged';
      operations.add(
        _Operation(
          id: id,
          method: methodEntry.key,
          path: pathEntry.key,
          tag: tag,
        ),
      );
    }
  }
  return operations;
}

int _compareOperations(_Operation left, _Operation right) {
  final tag = left.tag.compareTo(right.tag);
  if (tag != 0) return tag;
  final path = left.path.compareTo(right.path);
  if (path != 0) return path;
  return left.method.compareTo(right.method);
}

class _Operation {
  const _Operation({
    required this.id,
    required this.method,
    required this.path,
    required this.tag,
  });

  final String id;
  final String method;
  final String path;
  final String tag;
}

class _Exclusion {
  const _Exclusion({required this.category, required this.reason});

  final String category;
  final String reason;
}

class _ExclusionManifest {
  const _ExclusionManifest({
    required this.contractVersion,
    required this.exclusions,
  });

  final String contractVersion;
  final Map<String, _Exclusion> exclusions;
}
