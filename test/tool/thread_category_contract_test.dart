import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('主题分类 v2 契约不再暴露颜色字段', () {
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
      endsWith('thread-category-v2-fixtures.json'),
    );
    final fixture =
        jsonDecode(fixtures.single.readAsStringSync()) as Map<String, dynamic>;
    expect(fixture['version'], 2);
    for (final definition in fixture['definitions'] as List<dynamic>) {
      expect(definition as Map<String, dynamic>, isNot(contains('color')));
    }

    final openApi =
        jsonDecode(File('contracts/openapi.json').readAsStringSync())
            as Map<String, dynamic>;
    final schemas =
        (openApi['components'] as Map<String, dynamic>)['schemas']
            as Map<String, dynamic>;
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
