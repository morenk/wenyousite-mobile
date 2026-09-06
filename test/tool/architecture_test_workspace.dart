import 'dart:convert';
import 'dart:io';

Future<Directory> createArchitectureTestWorkspace() async {
  final root = await Directory.systemTemp.createTemp('wenyou-architecture-');
  writeArchitectureFixture(root, 'README.md', '当前版本：`1.0.0+1`。');
  writeArchitectureFixture(
    root,
    'pubspec.yaml',
    'name: fixture\nversion: 1.0.0+1\ndependencies:\n',
  );
  writeArchitectureAllowlist(root);
  return root;
}

Future<void> disposeArchitectureTestWorkspace(Directory root) async {
  final target = root.absolute;
  final prefix =
      '${Directory.systemTemp.absolute.path}${Platform.pathSeparator}wenyou-architecture-';
  if (!target.path.startsWith(prefix)) {
    throw StateError('Unexpected test fixture path.');
  }
  if (target.existsSync()) await target.delete(recursive: true);
}

void writeArchitectureAllowlist(
  Directory root, {
  List<Map<String, String>> domainBoundaryDebt = const [],
  List<String> featureDependencies = const [],
  List<String> featureCycleDebt = const [],
  List<String> layerDependencyDebt = const [],
  List<String> crossFeatureInternalImportDebt = const [],
  Map<String, int> largeFileDebt = const {},
}) {
  writeArchitectureFixture(
    root,
    'tool/architecture_allowlist.json',
    const JsonEncoder.withIndent('  ').convert({
      'domainBoundaryDebt': domainBoundaryDebt,
      'featureDependencies': featureDependencies,
      'featureCycleDebt': featureCycleDebt,
      'layerDependencyDebt': layerDependencyDebt,
      'largeFileDebt': largeFileDebt,
      'crossFeatureInternalImportDebt': crossFeatureInternalImportDebt,
    }),
  );
}

void writeArchitectureFixture(
  Directory root,
  String relativePath,
  String contents,
) {
  final file = File('${root.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
