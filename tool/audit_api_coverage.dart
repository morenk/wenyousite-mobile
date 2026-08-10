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
  final sourceRoot = Directory('${root.path}/lib');
  if (!contract.existsSync() || !sourceRoot.existsSync()) {
    stderr.writeln('请从移动端仓库根目录运行 API 覆盖审计。');
    exitCode = 2;
    return;
  }

  final operations = _loadOperations(contract)..sort(_compareOperations);
  final source = sourceRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');
  final covered = <_Operation>[];
  final missing = <_Operation>[];
  for (final operation in operations) {
    final invocation = RegExp('\\b${RegExp.escape(operation.id)}\\s*\\(');
    (invocation.hasMatch(source) ? covered : missing).add(operation);
  }

  stdout.writeln(
    'API coverage: ${covered.length}/${operations.length} '
    '(${missing.length} missing)',
  );
  if (missing.isNotEmpty) {
    final grouped = <String, List<_Operation>>{};
    for (final operation in missing) {
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

  if (arguments.contains('--require-complete') && missing.isNotEmpty) {
    exitCode = 1;
  }
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
