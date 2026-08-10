import 'dart:convert';
import 'dart:io';

const _idempotentOperations = <String>{
  'directConversationsCreate',
  'directConversationsSend',
  'economyTipMoment',
  'economyTipThread',
  'economyTipUser',
  'momentsCreate',
  'momentsCreateComment',
  'postsCreate',
  'stickersImportDirectMessage',
  'stickersImportMedia',
  'stickersImportPostImage',
  'subthreadsCreate',
  'threadsCreate',
};

void main() {
  final failures = <String>[];
  final allowlist = _readAllowlist();
  final dartFiles = _dartFiles(Directory('lib'));

  _checkIdempotentPolicies(dartFiles, failures);
  _checkDomainBoundaries(dartFiles, allowlist.domainBoundaryDebt, failures);
  _checkFeatureDependencies(dartFiles, allowlist.featureDependencies, failures);
  _checkVersionConsistency(failures);
  _checkDirectDependencies(dartFiles, failures);
  _checkRawRequestFlags(dartFiles, failures);
  _checkRawRouteNavigation(dartFiles, failures);

  if (failures.isNotEmpty) {
    stderr.writeln('Architecture checks failed (${failures.length}):');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Architecture checks passed: request policies, domain boundaries, '
    'feature dependencies, version and dependency hygiene.',
  );
}

void _checkIdempotentPolicies(List<File> files, List<String> failures) {
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final operation in _idempotentOperations) {
      final matcher = RegExp('\\.$operation\\s*\\(');
      for (final match in matcher.allMatches(source)) {
        final openingParenthesis = source.indexOf('(', match.start);
        final call = _balancedCall(source, openingParenthesis);
        if (!call.contains('extra: ApiRequestPolicy.idempotentCreate.extra')) {
          failures.add(
            '${_relative(file.path)} calls $operation without the '
            'idempotent-create request policy',
          );
        }
      }
    }
  }
}

void _checkDomainBoundaries(
  List<File> files,
  Set<String> allowlist,
  List<String> failures,
) {
  const forbiddenImports = <String>[
    'package:flutter/material.dart',
    'package:flutter/widgets.dart',
    'package:flutter_riverpod/flutter_riverpod.dart',
    'package:wenyousite_mobile/core/network/',
  ];
  for (final file in files.where(
    (file) => _relative(file.path).contains('/domain/'),
  )) {
    final path = _relative(file.path);
    final source = file.readAsStringSync();
    if (forbiddenImports.any(source.contains) && !allowlist.contains(path)) {
      failures.add(
        '$path introduces framework, UI state or transport errors into domain',
      );
    }
  }
}

void _checkFeatureDependencies(
  List<File> files,
  Set<String> allowlist,
  List<String> failures,
) {
  final importPattern = RegExp(r'package:wenyousite_mobile/features/([^/]+)/');
  final edges = <String>{};
  for (final file in files) {
    final path = _relative(file.path);
    if (!path.startsWith('lib/features/')) continue;
    final from = path.split('/')[2];
    for (final match in importPattern.allMatches(file.readAsStringSync())) {
      final to = match.group(1)!;
      if (to != from) edges.add('$from->$to');
    }
  }
  for (final edge in edges.difference(allowlist).toList()..sort()) {
    failures.add('new cross-feature dependency is not allowed: $edge');
  }
}

void _checkVersionConsistency(List<String> failures) {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final readme = File('README.md').readAsStringSync();
  final pubspecVersion = RegExp(
    r'^version:\s*([^\s]+)',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  final readmeVersion = RegExp(r'当前版本：`([^`]+)`').firstMatch(readme)?.group(1);
  if (pubspecVersion == null || readmeVersion == null) {
    failures.add('cannot read version from pubspec.yaml or README.md');
  } else if (pubspecVersion != readmeVersion) {
    failures.add(
      'README version $readmeVersion does not match pubspec $pubspecVersion',
    );
  }
}

void _checkDirectDependencies(List<File> files, List<String> failures) {
  final pubspec = File('pubspec.yaml').readAsLinesSync();
  final dependencies = <String>{};
  var inDependencies = false;
  for (final line in pubspec) {
    if (line == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    if (line == 'dev_dependencies:') break;
    if (!inDependencies) continue;
    final match = RegExp(r'^  ([a-zA-Z0-9_]+):').firstMatch(line);
    if (match != null) dependencies.add(match.group(1)!);
  }
  final allSource = files.map((file) => file.readAsStringSync()).join('\n');
  for (final dependency in dependencies.toList()..sort()) {
    if (!allSource.contains('package:$dependency/')) {
      failures.add('direct dependency is unused by lib/: $dependency');
    }
  }
}

void _checkRawRequestFlags(List<File> files, List<String> failures) {
  for (final file in files) {
    final path = _relative(file.path);
    if (path.endsWith('/api_request_policy.dart')) continue;
    final source = file.readAsStringSync();
    if (RegExp(r'''["'](?:skipAuth|idempotentCreate)["']''').hasMatch(source)) {
      failures.add('$path uses a raw request-policy flag');
    }
  }
}

void _checkRawRouteNavigation(List<File> files, List<String> failures) {
  final rawNavigation = RegExp(
    r'''\b(?:context|router)\.(?:go|push|replace)\(\s*["']/''',
  );
  for (final file in files) {
    final path = _relative(file.path);
    if (rawNavigation.hasMatch(file.readAsStringSync())) {
      failures.add(
        '$path navigates with a raw path; use a named route or '
        'AppRouteLocations',
      );
    }
  }
}

String _balancedCall(String source, int openingParenthesis) {
  var depth = 0;
  String? quote;
  var escaped = false;
  for (var index = openingParenthesis; index < source.length; index += 1) {
    final character = source[index];
    if (quote != null) {
      if (escaped) {
        escaped = false;
      } else if (character == r'\') {
        escaped = true;
      } else if (character == quote) {
        quote = null;
      }
      continue;
    }
    if (character == "'" || character == '"') {
      quote = character;
      continue;
    }
    if (character == '(') depth += 1;
    if (character == ')') {
      depth -= 1;
      if (depth == 0) return source.substring(openingParenthesis, index + 1);
    }
  }
  return source.substring(openingParenthesis);
}

List<File> _dartFiles(Directory directory) {
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}

String _relative(String path) {
  final root = Directory.current.absolute.path.replaceAll('\\', '/');
  return path
      .replaceAll('\\', '/')
      .replaceFirst(RegExp('^${RegExp.escape(root)}/?'), '');
}

_ArchitectureAllowlist _readAllowlist() {
  final json =
      jsonDecode(File('tool/architecture_allowlist.json').readAsStringSync())
          as Map<String, dynamic>;
  return _ArchitectureAllowlist(
    domainBoundaryDebt: (json['domainBoundaryDebt'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    featureDependencies: (json['featureDependencies'] as List<dynamic>)
        .cast<String>()
        .toSet(),
  );
}

class _ArchitectureAllowlist {
  const _ArchitectureAllowlist({
    required this.domainBoundaryDebt,
    required this.featureDependencies,
  });

  final Set<String> domainBoundaryDebt;
  final Set<String> featureDependencies;
}
