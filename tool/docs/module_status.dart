const allowedModuleStatuses = <String>{
  'planned',
  'in_progress',
  'implemented',
  'deferred',
};

final class ModuleStatusDeclaration {
  const ModuleStatusDeclaration({required this.status, required this.line});

  final String status;
  final int line;
}

final class ModuleIndexEntry {
  const ModuleIndexEntry({
    required this.module,
    required this.status,
    required this.line,
  });

  final String module;
  final String status;
  final int line;
}

final class ModuleIndexParseResult {
  const ModuleIndexParseResult({required this.entries, required this.errors});

  final Map<String, ModuleIndexEntry> entries;
  final List<String> errors;
}

List<ModuleStatusDeclaration> parseModuleStatusDeclarations(String text) {
  final declarations = <ModuleStatusDeclaration>[];
  final lines = text.split('\n');
  final pattern = RegExp(r'^状态：`([^`]+)`\s*$');
  for (var index = 0; index < lines.length; index++) {
    final match = pattern.firstMatch(lines[index].trimRight());
    if (match != null) {
      declarations.add(
        ModuleStatusDeclaration(status: match.group(1)!, line: index + 1),
      );
    }
  }
  return declarations;
}

ModuleIndexParseResult parseModuleIndex(String text) {
  final entries = <String, ModuleIndexEntry>{};
  final errors = <String>[];
  final lines = text.split('\n');
  var foundHeader = false;
  var readingTable = false;

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index].trim();
    if (!readingTable) {
      if (RegExp(r'^\|\s*模块\s*\|\s*状态\s*\|').hasMatch(line)) {
        foundHeader = true;
        readingTable = true;
      }
      continue;
    }
    if (line.isEmpty) break;
    if (!line.startsWith('|') || !line.endsWith('|')) {
      errors.add('模块索引第 ${index + 1} 行不是合法 Markdown 表格行。');
      continue;
    }

    final cells = line
        .substring(1, line.length - 1)
        .split('|')
        .map((cell) => cell.trim())
        .toList(growable: false);
    if (cells.length < 4) {
      errors.add('模块索引第 ${index + 1} 行至少需要 4 列。');
      continue;
    }
    if (cells.every((cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell))) {
      continue;
    }

    final module = cells[0];
    final status = cells[1];
    if (module.isEmpty || status.isEmpty) {
      errors.add('模块索引第 ${index + 1} 行缺少模块名或状态。');
      continue;
    }
    if (entries.containsKey(module)) {
      errors.add('模块索引重复声明 $module（第 ${index + 1} 行）。');
      continue;
    }
    entries[module] = ModuleIndexEntry(
      module: module,
      status: status,
      line: index + 1,
    );
    if (!allowedModuleStatuses.contains(status)) {
      errors.add('模块索引 $module 使用未知状态 $status。');
    }
  }

  if (!foundHeader) {
    errors.add('模块索引缺少“模块 / 状态”表头。');
  }
  return ModuleIndexParseResult(entries: entries, errors: errors);
}

List<String> validateModuleStatusIndex({
  required Set<String> modules,
  required Map<String, List<ModuleStatusDeclaration>> documents,
  required ModuleIndexParseResult index,
}) {
  final errors = <String>[...index.errors];

  for (final indexedModule in index.entries.keys) {
    if (!modules.contains(indexedModule)) {
      errors.add('模块索引包含不存在的功能模块 $indexedModule。');
    }
  }

  final sortedModules = modules.toList()..sort();
  for (final module in sortedModules) {
    final indexEntry = index.entries[module];
    if (indexEntry == null) {
      errors.add('模块 $module 未出现在模块索引中。');
    }

    final declarations = documents[module];
    if (declarations == null) continue;
    if (declarations.isEmpty) {
      errors.add('$module.md 未声明模块状态。');
      continue;
    }
    if (declarations.length > 1) {
      errors.add('$module.md 重复声明模块状态。');
      continue;
    }

    final status = declarations.single.status;
    if (!allowedModuleStatuses.contains(status)) {
      errors.add('$module.md 使用未知状态 $status。');
    }
    if (indexEntry != null && indexEntry.status != status) {
      errors.add('$module.md 状态 $status 与模块索引状态 ${indexEntry.status} 不一致。');
    }
  }
  return errors;
}
