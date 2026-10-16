import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  test('5.39兼容错误数字可由生成客户端读取，旧42900不变', () {
    final expected = {
      40016: BusinessErrorCode.TEXT_COLOR_CAPABILITY_REQUIRED,
      40017: BusinessErrorCode.TEXT_COLOR_DISABLED,
      40018: BusinessErrorCode.INVALID_TEXT_COLOR,
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
    expect((contract['info'] as Map)['version'], '5.39.0-dev.20261017.1');
    final manifest = File(
      'contracts/backend-contract.properties',
    ).readAsStringSync();
    expect(manifest, contains('78685f48f0eeabf358fb4a6f5a4b0bca6b068a12'));
  });
}
