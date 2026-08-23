import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_timing.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  test('完成阶段只输出固定性能字段', () async {
    final messages = <String>[];
    final timing = MediaUploadTiming(enabled: true, writer: messages.add);

    final output = await timing.measure(
      purpose: MediaUploadPurpose.directMessage,
      stage: MediaUploadTimingStage.encodeWebp,
      inputBytes: 120,
      outputBytes: (bytes) => bytes.length,
      operation: () async => Uint8List.fromList(const [1, 2, 3]),
    );

    expect(output, hasLength(3));
    expect(messages, hasLength(1));
    expect(
      messages.single,
      matches(
        r'^purpose=directMessage stage=encodeWebp outcome=completed '
        r'elapsedMs=\d+ inputBytes=120 outputBytes=3$',
      ),
    );
  });

  test('失败阶段不记录异常内容或输出大小', () async {
    final messages = <String>[];
    final timing = MediaUploadTiming(enabled: true, writer: messages.add);

    await expectLater(
      timing.measure<void>(
        purpose: MediaUploadPurpose.moment,
        stage: MediaUploadTimingStage.objectStoragePut,
        inputBytes: 456,
        operation: () => Future<void>.error(
          StateError('https://storage.example/private?token=secret'),
        ),
      ),
      throwsStateError,
    );

    expect(messages, hasLength(1));
    expect(messages.single, contains('outcome=failed'));
    expect(messages.single, contains('inputBytes=456'));
    expect(messages.single, isNot(contains('storage.example')));
    expect(messages.single, isNot(contains('secret')));
    expect(messages.single, isNot(contains('outputBytes=')));
  });
}
