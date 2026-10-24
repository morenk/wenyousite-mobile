import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';

void main() {
  test('真实Provider重建、退出及切账号复用同一服务，失败原生预留不归零', () {
    ProviderContainer scope(String? account, int generation, bool supported) =>
        ProviderContainer(
          overrides: [
            wenyouApiProvider.overrideWithValue(WenyouApi()),
            appCapabilitiesProvider.overrideWithValue(
              AppCapabilities(textFontV2Supported: supported),
            ),
            sessionScopeProvider.overrideWithValue(
              SessionScope(accountId: account, generation: generation),
            ),
          ],
        );
    final first = scope('first', 0, false);
    final service = first.read(textFontServiceProvider);
    final hash = 'a' * 64;
    expect(
      service.ledger.beginNativeAttempt(
        hash: hash,
        family: 'engine-test',
        inputBytes: 123,
      ),
      isTrue,
    );
    // 模拟FontLoader已被调用但失败；不能调用complete或退款。
    first.dispose();
    for (final identity in <String?>[null, 'second']) {
      final next = scope(identity, 1, true);
      final recovered = next.read(textFontServiceProvider);
      expect(identical(recovered, service), isTrue);
      expect(recovered.ledger.chargedInputBytes, 123);
      expect(recovered.ledger.attemptedCount, 1);
      expect(recovered.ledger.loadedCount, 0);
      expect(
        recovered.ledger.beginNativeAttempt(
          hash: hash,
          family: 'engine-test',
          inputBytes: 123,
        ),
        isFalse,
      );
      next.dispose();
    }
  });
}
