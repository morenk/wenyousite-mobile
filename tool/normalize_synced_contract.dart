import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  final contractPath = arguments.isEmpty
      ? 'contracts/openapi.json'
      : arguments.single;
  final file = File(contractPath);
  final document = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  final paths = document['paths'] as Map<String, Object?>? ?? const {};
  final normalized = <String>[];

  for (final pathEntry in paths.entries) {
    final pathItem = pathEntry.value;
    if (pathItem is! Map<String, Object?>) continue;

    for (final operationEntry in pathItem.entries) {
      final operation = operationEntry.value;
      if (operation is! Map<String, Object?>) continue;
      final parameters = operation['parameters'];
      if (parameters is! List<Object?>) continue;

      final retained = <Object?>[];
      final parametersByIdentity = <String, String>{};
      for (final parameter in parameters) {
        if (parameter is! Map<String, Object?> ||
            parameter.containsKey(r'$ref')) {
          retained.add(parameter);
          continue;
        }

        final location = parameter['in'];
        final name = parameter['name'];
        if (location is! String || name is! String) {
          retained.add(parameter);
          continue;
        }

        final identity = '$location:$name';
        final encoded = jsonEncode(parameter);
        final existing = parametersByIdentity[identity];
        if (existing == null) {
          parametersByIdentity[identity] = encoded;
          retained.add(parameter);
          continue;
        }
        if (existing != encoded) {
          stderr.writeln(
            'Conflicting duplicate OpenAPI parameter at '
            '${pathEntry.key}#${operationEntry.key} ($identity).',
          );
          exitCode = 1;
          return;
        }
        normalized.add('${pathEntry.key}#${operationEntry.key} ($identity)');
      }

      operation['parameters'] = retained;
    }
  }

  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(document)}\n',
  );
  if (normalized.isEmpty) {
    stdout.writeln('No duplicate OpenAPI parameters required normalization.');
  } else {
    stdout.writeln(
      'Normalized ${normalized.length} exact duplicate OpenAPI parameter(s):',
    );
    for (final location in normalized) {
      stdout.writeln('- $location');
    }
  }
}
