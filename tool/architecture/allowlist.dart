import 'dart:convert';
import 'dart:io';

ArchitectureAllowlist readAllowlist(Directory root) {
  final json =
      jsonDecode(
            File(
              '${root.path}/tool/architecture_allowlist.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return ArchitectureAllowlist(
    domainBoundaryDebt: (json['domainBoundaryDebt'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(DomainBoundaryDebt.fromJson)
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
    crossFeatureInternalImportDebt:
        (json['crossFeatureInternalImportDebt'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toSet(),
    largeFileDebt: (json['largeFileDebt'] as Map<String, dynamic>? ?? const {})
        .map((path, lines) => MapEntry(path, (lines as num).toInt())),
  );
}

class ArchitectureAllowlist {
  const ArchitectureAllowlist({
    required this.domainBoundaryDebt,
    required this.featureDependencies,
    required this.featureCycleDebt,
    required this.layerDependencyDebt,
    required this.largeFileDebt,
    required this.crossFeatureInternalImportDebt,
  });

  final Set<DomainBoundaryDebt> domainBoundaryDebt;
  final Set<String> featureDependencies;
  final Set<String> featureCycleDebt;
  final Set<String> layerDependencyDebt;
  final Map<String, int> largeFileDebt;
  final Set<String> crossFeatureInternalImportDebt;
}

class DomainBoundaryDebt {
  const DomainBoundaryDebt({required this.source, required this.target});

  factory DomainBoundaryDebt.fromJson(Map<String, dynamic> json) {
    return DomainBoundaryDebt(
      source: json['source'] as String,
      target: json['target'] as String,
    );
  }

  final String source;
  final String target;

  String get key => '$source->$target';

  @override
  bool operator ==(Object other) {
    return other is DomainBoundaryDebt &&
        other.source == source &&
        other.target == target;
  }

  @override
  int get hashCode => Object.hash(source, target);
}
