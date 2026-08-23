import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('主题分类 v3 契约保持纯文本并固定历史展示投影', () {
    final fixtures = Directory('contracts')
        .listSync()
        .whereType<File>()
        .where(
          (file) => RegExp(
            r'thread-category-v\d+-fixtures\.json$',
          ).hasMatch(file.path.replaceAll('\\', '/')),
        )
        .toList();

    expect(fixtures, hasLength(1));
    expect(
      fixtures.single.path.replaceAll('\\', '/'),
      endsWith('thread-category-v3-fixtures.json'),
    );
    final fixture =
        jsonDecode(fixtures.single.readAsStringSync()) as Map<String, dynamic>;
    expect(fixture['version'], 3);
    for (final definition in fixture['definitions'] as List<dynamic>) {
      final value = definition as Map<String, dynamic>;
      expect(value, isNot(contains('color')));
      expect(value, isNot(contains('icon')));
      expect(value, isNot(contains('mergedIntoId')));
    }

    final openApi =
        jsonDecode(File('contracts/openapi.json').readAsStringSync())
            as Map<String, dynamic>;
    final schemas =
        (openApi['components'] as Map<String, dynamic>)['schemas']
            as Map<String, dynamic>;
    final categoryInfo =
        schemas['ThreadCategoryInfoDto'] as Map<String, dynamic>;
    expect(
      (categoryInfo['properties'] as Map<String, dynamic>).keys,
      unorderedEquals(['slug', 'name', 'isActive']),
    );
    expect(
      categoryInfo['required'] as List<dynamic>,
      unorderedEquals(['slug', 'name', 'isActive']),
    );
    for (final name in const [
      'ThreadCategoryResponseDto',
      'CreateThreadCategoryDto',
      'UpdateThreadCategoryDto',
    ]) {
      final schema = schemas[name] as Map<String, dynamic>;
      final properties = schema['properties'] as Map<String, dynamic>;
      expect(properties, isNot(contains('color')), reason: name);
    }
  });
}
