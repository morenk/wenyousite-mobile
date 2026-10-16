import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  test('5.38音频预算错误数字可由生成客户端读取，旧42900不变', () {
    final expected = {
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
    expect((contract['info'] as Map)['version'], '5.38.0-dev.20261017.1');
    final manifest = File(
      'contracts/backend-contract.properties',
    ).readAsStringSync();
    expect(manifest, contains('9159729106cefb883726121dc9f94c0b164678c1'));
  });
}
