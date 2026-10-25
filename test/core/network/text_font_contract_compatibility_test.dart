import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  for (final advertised in [false, true]) {
    test('字体能力可选字段 $advertised 不影响旧 meta 解码', () {
      final capabilities = standardSerializers.deserializeWith(
        ApiCapabilitiesResponseDto.serializer,
        {
          'stickers': true,
          'directMessages': true,
          'pushNotifications': false,
          if (advertised) ...{
            'textFontV1Supported': true,
            'textFontV1WriteEnabled': false,
            'textFontV2Supported': true,
            'textFontV2WriteEnabled': true,
          },
        },
      )!;
      expect(capabilities.stickers, isTrue);
      expect(capabilities.directMessages, isTrue);
      expect(capabilities.pushNotifications, isFalse);
      expect(capabilities.textFontV1Supported, advertised ? true : null);
      expect(capabilities.textFontV1WriteEnabled, advertised ? false : null);
      expect(capabilities.textFontV2Supported, advertised ? true : null);
      expect(capabilities.textFontV2WriteEnabled, advertised ? true : null);
    });
  }
}
