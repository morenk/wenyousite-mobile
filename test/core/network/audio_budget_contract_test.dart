import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  test('5.42字体策略契约保留字体、音频、颜色与旧42900错误', () {
    final expected = {
      40016: BusinessErrorCode.TEXT_COLOR_CAPABILITY_REQUIRED,
      40017: BusinessErrorCode.TEXT_COLOR_DISABLED,
      40018: BusinessErrorCode.INVALID_TEXT_COLOR,
      40019: BusinessErrorCode.TEXT_FONT_CAPABILITY_REQUIRED,
      40020: BusinessErrorCode.TEXT_FONT_DISABLED,
      40021: BusinessErrorCode.INVALID_TEXT_FONT,
      42900: BusinessErrorCode.RATE_LIMITED,
      42901: BusinessErrorCode.AUDIO_ACTIVE_LIMIT,
      42902: BusinessErrorCode.AUDIO_DAILY_BYTES_LIMIT,
    };
    final serializers = standardSerializers;
    for (final entry in expected.entries) {
      final result = serializers.deserializeWith(ApiErrorEnvelope.serializer, {
        'code': entry.key,
        'message': 'fixture',
      })!;
      expect(result.code, entry.value);
    }
    final contract =
        jsonDecode(File('contracts/openapi.json').readAsStringSync()) as Map;
    expect((contract['info'] as Map)['version'], '5.42.0-dev.20261022.1');
    final manifest = File(
      'contracts/backend-contract.properties',
    ).readAsStringSync();
    expect(
      manifest,
      contains('backendRevision=f27898ec3b168b9e027b5d5abef43a0d3dafa242'),
    );
  });
}
