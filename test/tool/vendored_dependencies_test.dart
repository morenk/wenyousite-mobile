import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/vendored_dependencies.dart';
import '../../tool/check_architecture.dart';
import 'architecture_test_workspace.dart';

void main() {
  late Directory root;
  late Map<String, Object> manifest;
  const target = 'lib/src/editor/widgets/text/text_block.dart';
  const package = 'packages/flutter_quill';
  const patchPath = 'tool/patches/flutter-quill-heading-spacing.patch';
  const manifestPath = 'tool/vendor/flutter-quill.json';

  void saveManifest() =>
      writeArchitectureFixture(root, manifestPath, jsonEncode(manifest));

  setUp(() async {
    root = await createArchitectureTestWorkspace();
    final git = Process.runSync('git', [
      'init',
      '--quiet',
    ], workingDirectory: root.path);
    expect(git.exitCode, 0);
    final sources = {
      'LICENSE': 'fixture license\n',
      'pubspec.yaml': 'name: flutter_quill\n',
      target: '${List.filled(1909, '// upstream line').join('\n')}\n',
    };
    for (final entry in sources.entries) {
      writeArchitectureFixture(root, '$package/${entry.key}', entry.value);
    }
    const patch = 'fixture patch\n';
    writeArchitectureFixture(root, patchPath, patch);
    manifest = {
      'schemaVersion': 1,
      'root': package,
      'repository': 'https://github.com/singerdmx/flutter-quill.git',
      'revision': 'c273155025d1255335a6dd3e6ecd3700d29f103e',
      'patch': {
        'path': patchPath,
        'sha256': sha256.convert(utf8.encode(patch)).toString(),
      },
      'files': sources.map(
        (path, value) =>
            MapEntry(path, sha256.convert(utf8.encode(value)).toString()),
      ),
    };
    saveManifest();
  });
  tearDown(() => disposeArchitectureTestWorkspace(root));

  test('完整验证固定第三方快照后才允许超业务行数上限', () {
    expect(collectArchitectureFailures(root), isEmpty);
    expect(collectArchitectureReviewNotices(root), isEmpty);
    expect(
      validateVendoredDependencies(root).verifiedFiles,
      contains('$package/$target'),
    );
  });

  test('源码变动使完整性失败并撤回行数豁免', () {
    File(
      '${root.path}/$package/$target',
    ).writeAsStringSync('// changed\n', mode: FileMode.append);
    final failures = collectArchitectureFailures(root);
    expect(failures.any((message) => message.contains('SHA-256 不匹配')), isTrue);
    expect(
      failures.any((message) => message.contains('above 1200 lines')),
      isTrue,
    );
    expect(validateVendoredDependencies(root).verifiedFiles, isEmpty);
  });

  test('新增文件、删除许可证和补丁变化均不能静默通过', () {
    writeArchitectureFixture(
      root,
      '$package/lib/local_business.dart',
      'class LocalBusiness {}\n',
    );
    File('${root.path}/$package/LICENSE').deleteSync();
    writeArchitectureFixture(root, patchPath, 'different patch\n');
    final result = validateVendoredDependencies(root);
    expect(
      result.failures.any((message) => message.contains('未登记的第三方文件')),
      isTrue,
    );
    expect(result.failures.any((message) => message.contains('文件缺失')), isTrue);
    expect(
      result.failures.any((message) => message.contains('SHA-256 不匹配')),
      isTrue,
    );
    expect(result.verifiedFiles, isEmpty);
  });

  test('清单不能扩大到业务目录或其他上游版本', () {
    manifest['root'] = 'lib';
    saveManifest();
    expect(validateVendoredDependencies(root).failures, isNotEmpty);
    manifest['root'] = package;
    manifest['revision'] = '0000000000000000000000000000000000000000';
    saveManifest();
    expect(validateVendoredDependencies(root).failures, isNotEmpty);
  });

  test('清单拒绝路径逃逸且不豁免未登记的第三方目录', () {
    (manifest['files']! as Map)['../escape.dart'] = '0' * 64;
    saveManifest();
    expect(
      validateVendoredDependencies(
        root,
      ).failures.any((message) => message.contains('路径越界')),
      isTrue,
    );
    Directory('${root.path}/tool/vendor').deleteSync(recursive: true);
    expect(validateVendoredDependencies(root).failures, isNotEmpty);
  });
}
