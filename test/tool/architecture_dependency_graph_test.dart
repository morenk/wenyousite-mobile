import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_architecture.dart';
import 'architecture_test_workspace.dart';

void main() {
  late Directory root;
  setUp(() async => root = await createArchitectureTestWorkspace());
  tearDown(() => disposeArchitectureTestWorkspace(root));

  test('同数量的新内部导入不能替换已冻结的精确边', () {
    const source = 'lib/features/alpha/presentation/page.dart';
    const oldTarget = 'lib/features/beta/presentation/old.dart';
    const newTarget = 'lib/features/beta/presentation/new.dart';
    writeArchitectureFixture(
      root,
      source,
      "import '../../beta/presentation/old.dart';\n",
    );
    writeArchitectureAllowlist(
      root,
      featureDependencies: ['alpha->beta'],
      crossFeatureInternalImportDebt: ['$source->$oldTarget'],
    );
    expect(collectArchitectureFailures(root), isEmpty);
    writeArchitectureFixture(
      root,
      source,
      "import '../../beta/presentation/new.dart';\n",
    );
    expect(
      collectArchitectureFailures(root),
      containsAll([
        'new cross-feature internal import: $source->$newTarget; use a feature facade',
        'stale cross-feature internal import debt: $source->$oldTarget',
      ]),
    );
  });

  test('多层 facade 和循环 export 不能隐藏 data 对状态的反向依赖', () {
    const source = 'lib/features/alpha/data/repository.dart';
    const target = 'lib/features/alpha/application/state.dart';
    writeArchitectureFixture(root, source, "import '../alpha.dart';\n");
    writeArchitectureFixture(
      root,
      'lib/features/alpha/alpha.dart',
      "export 'nested.dart';\n",
    );
    writeArchitectureFixture(
      root,
      'lib/features/alpha/nested.dart',
      "export 'alpha.dart';\nexport 'application/state.dart';\n",
    );
    writeArchitectureFixture(root, target, 'class ItemState {}\n');
    expect(
      collectArchitectureFailures(root),
      contains('new forbidden layer dependency: $source->$target'),
    );
  });

  test('domain 的条件导出链仍校验所有平台分支的框架依赖', () {
    const source = 'lib/features/alpha/domain/item.dart';
    writeArchitectureFixture(root, source, "import '../surface.dart';\n");
    writeArchitectureFixture(
      root,
      'lib/features/alpha/surface.dart',
      "export 'plain.dart' if (dart.library.io) 'framework.dart';\n",
    );
    writeArchitectureFixture(
      root,
      'lib/features/alpha/plain.dart',
      'class Value {}\n',
    );
    writeArchitectureFixture(
      root,
      'lib/features/alpha/framework.dart',
      "export 'package:flutter/material.dart';\n",
    );
    expect(
      collectArchitectureFailures(root),
      contains(
        '$source imports forbidden domain dependency package:flutter/material.dart',
      ),
    );
  });

  test('core 不能借应用 facade 间接依赖 feature', () {
    const source = 'lib/core/models/item.dart';
    const target = 'lib/features/beta/domain/item.dart';
    writeArchitectureFixture(
      root,
      source,
      "import '../../app/surface.dart';\n",
    );
    writeArchitectureFixture(
      root,
      'lib/app/surface.dart',
      "export '../features/beta/domain/item.dart';\n",
    );
    writeArchitectureFixture(root, target, 'class Item {}\n');
    expect(
      collectArchitectureFailures(root),
      contains(
        '$source depends on feature implementation $target; core must remain feature-independent',
      ),
    );
  });

  test('跨模块 facade 导出的反向边仍参与循环检查', () {
    writeArchitectureFixture(
      root,
      'lib/features/alpha/domain/item.dart',
      "import '../../beta/beta.dart';\n",
    );
    writeArchitectureFixture(
      root,
      'lib/features/beta/beta.dart',
      "export 'domain/item.dart';\n",
    );
    writeArchitectureFixture(
      root,
      'lib/features/beta/domain/item.dart',
      "import '../../alpha/domain/item.dart';\n",
    );
    writeArchitectureAllowlist(
      root,
      featureDependencies: ['alpha->beta', 'beta->alpha'],
    );
    expect(
      collectArchitectureFailures(root),
      containsAll([
        'new cyclic cross-feature dependency is not allowed: alpha->beta',
        'new cyclic cross-feature dependency is not allowed: beta->alpha',
      ]),
    );
  });

  test('伪造在字符串内的 import 不构成依赖', () {
    writeArchitectureFixture(
      root,
      'lib/features/alpha/domain/item.dart',
      "const text = \"import 'package:flutter/material.dart';\";\n",
    );
    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('测试、工具、驱动和新增未暂存 Dart 都受 900 行限制', () {
    final git = Process.runSync('git', [
      'init',
      '--quiet',
    ], workingDirectory: root.path);
    expect(git.exitCode, 0);
    const paths = [
      'test/large_test.dart',
      'tool/large.dart',
      'integration_test/large_test.dart',
      'test_driver/large.dart',
      'scripts/new_tool.dart',
    ];
    for (final path in paths) {
      writeArchitectureFixture(
        root,
        path,
        '${List.filled(901, '// line').join('\n')}\n',
      );
    }
    expect(
      collectArchitectureFailures(root),
      containsAll([
        for (final path in paths)
          '$path has 901 lines; split non-generated Dart files above 900 lines',
      ]),
    );
  });

  test('测试辅助库不能通过手写 part 逃避显式边界', () {
    const path = 'test/fixtures.dart';
    writeArchitectureFixture(root, path, "part of 'page_test.dart';\n");
    expect(
      collectArchitectureFailures(root),
      contains('$path uses handwritten part-of; use an explicit library'),
    );
  });
}
