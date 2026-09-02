import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';

void main() {
  test('环境规范化 API 地址并按主版本检查契约', () {
    const environment = AppEnvironment(
      apiBaseUrl: 'https://wenyou.site/api/v1',
    );

    expect(environment.apiBaseUri.toString(), 'https://wenyou.site/api/v1/');
    expect(environment.apiOrigin, 'https://wenyou.site');
    expect(environment.supportsContract('5.0.0'), isTrue);
    expect(environment.supportsContract('4.14.0'), isFalse);
    final metadata = <String, String>{
      for (final line in File(
        'contracts/backend-contract.properties',
      ).readAsLinesSync())
        if (line.contains('='))
          line.substring(0, line.indexOf('=')): line.substring(
            line.indexOf('=') + 1,
          ),
    };
    final markdownVersion = int.parse(metadata['markdownContractVersion']!);
    expect(markdownVersion, 4);
    expect(environment.supportedMarkdownContractVersion, 5);
    expect(environment.supportedMarkdownContractVersions, {3, 4, 5});
    expect(environment.supportsMarkdown(3), isTrue);
    expect(environment.supportsMarkdown(4), isTrue);
    expect(environment.supportsMarkdown(2), isFalse);
    expect(environment.supportsMarkdown(5), isTrue);
    expect(environment.supportsMarkdown(6), isFalse);
    expect(environment.supportsMarkdown(4.5), isFalse);
  });
}
