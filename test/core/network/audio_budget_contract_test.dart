import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  test('5.43保留音频与颜色兼容错误，旧42900不变', () {
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
    expect((contract['info'] as Map)['version'], '5.43.0-dev.20261022.3');
    final manifest = File(
      'contracts/backend-contract.properties',
    ).readAsStringSync();
    expect(
      manifest,
      contains('backendRevision=bc1135b72557eb6025a541dbd10119cf528ff989'),
    );
  });
}
