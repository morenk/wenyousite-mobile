/// 只保留源码坐标。AOT 通常省略列号；依赖包也是定位错误必需的调用链。
/// 不保留函数显示文本、机器路径或源码上下文。
final _coordinate = RegExp(
  r'^(package:[a-zA-Z0-9_]+/[a-zA-Z0-9_./-]+\.dart|dart:[a-zA-Z0-9_./-]+):(\d+)(?::(\d+))?$',
);

({String file, int line, int? column})? diagnosticCoordinate(String value) {
  final match = _coordinate.firstMatch(value);
  if (match == null || value.contains('..')) return null;
  final line = int.tryParse(match[2]!);
  final column = int.tryParse(match[3] ?? '');
  if (line == null || line <= 0 || (column != null && column <= 0)) {
    return null;
  }
  return (file: match[1]!, line: line, column: column);
}

List<String> safeDiagnosticStack(StackTrace? stack) =>
    sanitizeDiagnosticStackLines(stack?.toString().split('\n') ?? const []);

List<String> sanitizeDiagnosticStackLines(Iterable<Object?> lines) {
  final result = <String>[];
  for (final value in lines.take(512)) {
    if (value is! String || value.length > 4096) continue;
    var coordinate = value.trim();
    if (coordinate.startsWith('#') && coordinate.endsWith(')')) {
      final opening = coordinate.lastIndexOf('(');
      if (opening < 0) continue;
      coordinate = coordinate.substring(opening + 1, coordinate.length - 1);
    }
    if (diagnosticCoordinate(coordinate) != null) result.add(coordinate);
    if (result.length == 100) break;
  }
  return result;
}

String diagnosticStackStatus(StackTrace? stack, List<String> frames) {
  if (frames.isNotEmpty) return 'captured';
  final raw = stack?.toString() ?? '';
  if (raw.trim().isEmpty) return 'missing';
  if (raw.contains('isolate_instructions:') ||
      RegExp(r'#\d+\s+abs\s+[0-9a-fA-F]+').hasMatch(raw)) {
    // 本仓库发布脚本未启用 split-debug-info；不能把地址误写成源码栈。
    return 'requiresSymbols';
  }
  return 'filtered';
}
