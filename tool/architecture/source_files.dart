import 'dart:io';

List<File> dartFiles(Directory directory) {
  if (!directory.existsSync()) return const <File>[];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}

String relativePath(String path, Directory rootDirectory) {
  final root = rootDirectory.absolute.path.replaceAll('\\', '/');
  return path
      .replaceAll('\\', '/')
      .replaceFirst(RegExp('^${RegExp.escape(root)}/?'), '');
}

int lineCount(String source) {
  if (source.isEmpty) return 0;
  final newlineCount = '\n'.allMatches(source).length;
  return source.endsWith('\n') ? newlineCount : newlineCount + 1;
}

/// Include tracked files and new, non-ignored worktree files before staging.
List<File> repositoryDartFiles(Directory root) {
  final tracked = Process.runSync('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '-z',
    '--',
    '*.dart',
  ], workingDirectory: root.path);
  if (tracked.exitCode == 0) {
    return (tracked.stdout as String)
        .split('\u0000')
        .where(
          (path) => path.isNotEmpty && !path.startsWith('packages/wenyou_api/'),
        )
        .toSet()
        .map((path) => File('${root.path}/$path'))
        .where((file) => file.existsSync())
        .toList();
  }
  // Unit fixtures intentionally have no Git repository or generated package.
  return [
    ...root.listSync().whereType<File>().where(
      (file) => file.path.endsWith('.dart'),
    ),
    for (final folder in [
      'lib',
      'test',
      'tool',
      'integration_test',
      'test_driver',
    ])
      ...dartFiles(Directory('${root.path}/$folder')),
  ];
}
