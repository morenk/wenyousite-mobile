import 'dart:convert';
import 'dart:io';

/// 只从固定契约生成静态端点与 operationId，运行时不打包或读取契约正文。
void main() {
  final schema =
      jsonDecode(File('contracts/openapi.json').readAsStringSync())
          as Map<String, Object?>;
  final paths = schema['paths']! as Map<String, Object?>;
  final routes = <String, String>{};
  for (final path in paths.entries) {
    for (final method in (path.value! as Map<String, Object?>).entries) {
      if (!const {
        'get',
        'post',
        'put',
        'patch',
        'delete',
        'head',
        'options',
      }.contains(method.key)) {
        continue;
      }
      final id =
          (method.value! as Map<String, Object?>)['operationId']! as String;
      routes['${method.key.toUpperCase()} ${path.key}'] = id;
    }
  }
  final keys = routes.keys.toList()
    ..sort((a, b) {
      final dynamicOrder = '{'
          .allMatches(a)
          .length
          .compareTo('{'.allMatches(b).length);
      return dynamicOrder == 0 ? a.compareTo(b) : dynamicOrder;
    });
  File('lib/core/diagnostics/diagnostic_routes.g.dart').writeAsStringSync(
    '// GENERATED CODE - DO NOT MODIFY BY HAND.\n'
    '// 运行 dart run tool/generate_diagnostic_routes.dart 从固定 OpenAPI 更新。\n'
    'const diagnosticApiRoutes = <String, String>{\n'
    '${keys.map((key) => "  '$key': '${routes[key]}',").join('\n')}\n'
    '};\n',
  );
}
