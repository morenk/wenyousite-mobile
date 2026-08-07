import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';

void main() {
  test('环境规范化 API 地址并按主版本检查契约', () {
    const environment = AppEnvironment(
      apiBaseUrl: 'https://wenyou.site/api/v1',
    );

    expect(environment.apiBaseUri.toString(), 'https://wenyou.site/api/v1/');
    expect(environment.apiOrigin, 'https://wenyou.site');
    expect(environment.supportsContract('3.4.0'), isTrue);
    expect(environment.supportsContract('4.0.0'), isFalse);
    expect(environment.supportsMarkdown(2), isTrue);
  });
}
