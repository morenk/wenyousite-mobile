import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

void main() {
  test('生成 API 客户端的 Dio 基地址只保留 origin', () {
    final container = ProviderContainer(
      overrides: [
        appEnvironmentProvider.overrideWithValue(
          const AppEnvironment(apiBaseUrl: 'https://wenyou.site/api/v1'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(refreshDioProvider).options.baseUrl,
      'https://wenyou.site',
    );
    expect(container.read(dioProvider).options.baseUrl, 'https://wenyou.site');
  });
}
