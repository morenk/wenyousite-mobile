import 'package:dio/dio.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_routes.g.dart';

/// 返回契约内固定 operationId；未知地址不返回任何字符串。
String? diagnosticApiOperation(RequestOptions options) {
  final path = Uri.tryParse(options.path)?.pathSegments;
  if (path == null) return null;
  final prefix = '${options.method.toUpperCase()} ';
  for (final route in diagnosticApiRoutes.entries) {
    if (!route.key.startsWith(prefix)) continue;
    final template = route.key
        .substring(prefix.length)
        .split('/')
        .skip(1)
        .toList();
    if (template.length != path.length) continue;
    var matches = true;
    for (var i = 0; i < template.length; i++) {
      if (template[i].startsWith('{')) {
        if (path[i].isEmpty) matches = false;
      } else if (template[i] != path[i]) {
        matches = false;
      }
    }
    if (matches) return route.value;
  }
  return null;
}
