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
  final failures = collectArchitectureFailures(Directory.current);

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
    'layering, feature dependencies, cycles, version and dependency hygiene.',
  );
}

List<String> collectArchitectureFailures(Directory root) {
  final failures = <String>[];
  final allowlist = _readAllowlist(root);
  final dartFiles = _dartFiles(Directory('${root.path}/lib'));

  _checkIdempotentPolicies(dartFiles, failures, root);
  _checkDomainBoundaries(
    dartFiles,
    allowlist.domainBoundaryDebt,
    failures,
    root,
  );
  _checkLayerDependencies(
    dartFiles,
    allowlist.layerDependencyDebt,
    failures,
    root,
  );
  _checkFeatureDependencies(
    dartFiles,
    allowlist.featureDependencies,
    allowlist.featureCycleDebt,
    failures,
    root,
  );
  _checkEditorPublicSurface(dartFiles, failures, root);
  _checkFoundationIconBoundary(dartFiles, failures, root);
  _checkVersionConsistency(failures, root);
  _checkDirectDependencies(dartFiles, failures, root);
  _checkRawRequestFlags(dartFiles, failures, root);
  _checkRawRouteNavigation(dartFiles, failures, root);

  failures.sort();
  return failures;
}

void _checkFoundationIconBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const forbiddenPatterns = <String, String>{
    r'\bIcons\.': 'Material Icons.*',
    r'\bIconData\b': 'Material IconData',
    r'\bIcon\s*\(': 'Material Icon(...)',
  };
  for (final file in files) {
    final source = file.readAsStringSync();
    final path = _relative(file.path, root);
    for (final entry in forbiddenPatterns.entries) {
      if (RegExp(entry.key).hasMatch(source)) {
        failures.add(
          '$path uses ${entry.value}; use Foundation semantic icons',
        );
      }
    }
  }
}

void _checkEditorPublicSurface(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const publicEditorSurfaces = <String>{
    'lib/features/editor/editor.dart',
    'lib/features/editor/editor_persistence.dart',
  };
  for (final file in files) {
    final path = _relative(file.path, root);
    if (!path.startsWith('lib/features/') ||
        path.startsWith('lib/features/editor/')) {
      continue;
    }
    for (final target in _dependencyTargets(file, root)) {
      if (target.startsWith('lib/features/editor/') &&
          !publicEditorSurfaces.contains(target)) {
        failures.add(
          '$path imports editor internals $target; use an editor root facade',
        );
      }
    }
  }
}

void _checkIdempotentPolicies(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final operation in _idempotentOperations) {
      final matcher = RegExp('\\.$operation\\s*\\(');
      for (final match in matcher.allMatches(source)) {
        final openingParenthesis = source.indexOf('(', match.start);
        final call = _balancedCall(source, openingParenthesis);
        if (!call.contains('extra: ApiRequestPolicy.idempotentCreate.extra')) {
          failures.add(
            '${_relative(file.path, root)} calls $operation without the '
            'idempotent-create request policy',
          );
        }
      }
    }
  }
}

void _checkDomainBoundaries(
  List<File> files,
  Set<_DomainBoundaryDebt> allowlist,
  List<String> failures,
  Directory root,
) {
  const forbiddenImports = <String>[
    'package:flutter/',
    'package:flutter_riverpod/',
    'package:riverpod/',
    'package:dio/',
    'package:wenyou_api/',
    'lib/core/network/',
  ];
  final actualDebt = <_DomainBoundaryDebt>{};
  for (final file in files.where(
    (file) => _relative(file.path, root).contains('/domain/'),
  )) {
    final path = _relative(file.path, root);
    final dependencies = _dependencyTargets(file, root);
    for (final dependency in dependencies.where(
      (target) => forbiddenImports.any(target.startsWith),
    )) {
      final debt = _DomainBoundaryDebt(source: path, target: dependency);
      actualDebt.add(debt);
      if (!allowlist.contains(debt)) {
        failures.add('$path imports forbidden domain dependency $dependency');
      }
    }
  }
  for (final debt
      in allowlist.difference(actualDebt).toList()
        ..sort((left, right) => left.key.compareTo(right.key))) {
    failures.add('stale domain boundary debt: ${debt.key}');
  }
}

Set<String> _dependencyTargets(File file, Directory root) {
  final source = file
      .readAsStringSync()
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');
  final directivePattern = RegExp(
    r'^\s*(?:import|export)\s+([\s\S]*?);',
    multiLine: true,
  );
  final uriPattern = RegExp(r'''['"]([^'"]+)['"]''');
  final sourcePath = _relative(file.path, root);
  return {
    for (final directive in directivePattern.allMatches(source))
      for (final uri in uriPattern.allMatches(directive.group(1)!))
        _normalizeDependency(uri.group(1)!, sourcePath),
  };
}

String _normalizeDependency(String uri, String sourcePath) {
  const packagePrefix = 'package:wenyousite_mobile/';
  if (uri.startsWith(packagePrefix)) {
    return 'lib/${uri.substring(packagePrefix.length)}';
  }
  if (uri.contains(':')) return uri;
  final segments = <String>[
    ...sourcePath.split('/')..removeLast(),
    ...uri.replaceAll('\\', '/').split('/'),
  ];
  final normalized = <String>[];
  for (final segment in segments) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (normalized.isNotEmpty) normalized.removeLast();
      continue;
    }
    normalized.add(segment);
  }
  return normalized.join('/');
}

void _checkLayerDependencies(
  List<File> files,
  Set<String> allowlist,
  List<String> failures,
  Directory root,
) {
  final actualDebt = <String>{};
  for (final file in files) {
    final path = _relative(file.path, root);
    final parts = path.split('/');
    if (parts.length < 5 || !path.startsWith('lib/features/')) continue;
    final fromLayer = parts[3];
    for (final target in _dependencyTargets(file, root)) {
      final targetParts = target.split('/');
      if (targetParts.length < 5 || !target.startsWith('lib/features/')) {
        continue;
      }
      final toLayer = targetParts[3];
      if (fromLayer == 'data' &&
          toLayer == 'application' &&
          !target.endsWith('_ports.dart')) {
        final dependency = '$path->$target';
        actualDebt.add(dependency);
        if (!allowlist.contains(dependency)) {
          failures.add('new forbidden layer dependency: $dependency');
        }
        continue;
      }
      if (!_isForbiddenLayerDependency(fromLayer, toLayer)) continue;
      final dependency = '$path->$target';
      actualDebt.add(dependency);
      if (!allowlist.contains(dependency)) {
        failures.add('new forbidden layer dependency: $dependency');
      }
    }
  }
  for (final dependency in allowlist.difference(actualDebt).toList()..sort()) {
    failures.add('stale forbidden layer dependency debt: $dependency');
  }
}

bool _isForbiddenLayerDependency(String from, String to) {
  return switch (from) {
    'presentation' => to == 'data',
    'application' => to == 'data' || to == 'presentation',
    'domain' => to == 'data' || to == 'application' || to == 'presentation',
    'data' => to == 'presentation',
    _ => false,
  };
}

void _checkFeatureDependencies(
  List<File> files,
  Set<String> allowlist,
  Set<String> cycleDebt,
  List<String> failures,
  Directory root,
) {
  final edges = <String>{};
  for (final file in files) {
    final path = _relative(file.path, root);
    if (!path.startsWith('lib/features/')) continue;
    final from = path.split('/')[2];
    for (final target in _dependencyTargets(file, root)) {
      final parts = target.split('/');
      if (parts.length < 4 || !target.startsWith('lib/features/')) continue;
      final to = parts[2];
      if (to != from) edges.add('$from->$to');
    }
  }
  for (final edge in edges.difference(allowlist).toList()..sort()) {
    failures.add('new cross-feature dependency is not allowed: $edge');
  }
  for (final edge in allowlist.difference(edges).toList()..sort()) {
    failures.add('stale cross-feature dependency debt: $edge');
  }
  final cyclicEdges = _cyclicFeatureEdges(edges);
  for (final edge in cyclicEdges.difference(cycleDebt).toList()..sort()) {
    failures.add('new cyclic cross-feature dependency is not allowed: $edge');
  }
  for (final edge in cycleDebt.difference(cyclicEdges).toList()..sort()) {
    failures.add('stale cyclic cross-feature dependency debt: $edge');
  }
}

Set<String> _cyclicFeatureEdges(Set<String> edges) {
  final graph = <String, Set<String>>{};
  for (final edge in edges) {
    final parts = edge.split('->');
    graph.putIfAbsent(parts[0], () => <String>{}).add(parts[1]);
    graph.putIfAbsent(parts[1], () => <String>{});
  }
  final result = <String>{};
  for (final edge in edges) {
    final parts = edge.split('->');
    if (_reachableFeatures(parts[1], graph).contains(parts[0])) {
      result.add(edge);
    }
  }
  return result;
}

Set<String> _reachableFeatures(String start, Map<String, Set<String>> graph) {
  final visited = <String>{};
  final pending = <String>[start];
  while (pending.isNotEmpty) {
    final current = pending.removeLast();
    for (final next in graph[current] ?? const <String>{}) {
      if (visited.add(next)) pending.add(next);
    }
  }
  return visited;
}

void _checkVersionConsistency(List<String> failures, Directory root) {
  final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
  final readme = File('${root.path}/README.md').readAsStringSync();
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

void _checkDirectDependencies(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final pubspec = File('${root.path}/pubspec.yaml').readAsLinesSync();
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

void _checkRawRequestFlags(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  for (final file in files) {
    final path = _relative(file.path, root);
    if (path.endsWith('/api_request_policy.dart')) continue;
    final source = file.readAsStringSync();
    if (RegExp(r'''["'](?:skipAuth|idempotentCreate)["']''').hasMatch(source)) {
      failures.add('$path uses a raw request-policy flag');
    }
  }
}

void _checkRawRouteNavigation(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final rawNavigation = RegExp(
    r'''\b(?:context|router)\.(?:go|push|replace)\(\s*["']/''',
  );
  for (final file in files) {
    final path = _relative(file.path, root);
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

String _relative(String path, Directory rootDirectory) {
  final root = rootDirectory.absolute.path.replaceAll('\\', '/');
  return path
      .replaceAll('\\', '/')
      .replaceFirst(RegExp('^${RegExp.escape(root)}/?'), '');
}

_ArchitectureAllowlist _readAllowlist(Directory root) {
  final json =
      jsonDecode(
            File(
              '${root.path}/tool/architecture_allowlist.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return _ArchitectureAllowlist(
    domainBoundaryDebt: (json['domainBoundaryDebt'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_DomainBoundaryDebt.fromJson)
        .toSet(),
    featureDependencies: (json['featureDependencies'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    featureCycleDebt: (json['featureCycleDebt'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    layerDependencyDebt: (json['layerDependencyDebt'] as List<dynamic>)
        .cast<String>()
        .toSet(),
  );
}

class _ArchitectureAllowlist {
  const _ArchitectureAllowlist({
    required this.domainBoundaryDebt,
    required this.featureDependencies,
    required this.featureCycleDebt,
    required this.layerDependencyDebt,
  });

  final Set<_DomainBoundaryDebt> domainBoundaryDebt;
  final Set<String> featureDependencies;
  final Set<String> featureCycleDebt;
  final Set<String> layerDependencyDebt;
}

class _DomainBoundaryDebt {
  const _DomainBoundaryDebt({required this.source, required this.target});

  factory _DomainBoundaryDebt.fromJson(Map<String, dynamic> json) {
    return _DomainBoundaryDebt(
      source: json['source'] as String,
      target: json['target'] as String,
    );
  }

  final String source;
  final String target;

  String get key => '$source->$target';

  @override
  bool operator ==(Object other) {
    return other is _DomainBoundaryDebt &&
        other.source == source &&
        other.target == target;
  }

  @override
  int get hashCode => Object.hash(source, target);
}
