import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_policy.dart';
import 'package:wenyousite_mobile/features/media/data/image_crop_processor.dart';
import 'package:wenyousite_mobile/features/media/data/media_image_validation.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/data/profile_cover_image_policy.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

import '../../support/media_compatibility_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('头像和背景不再用声明类型覆盖真实格式冲突', () {
    final input = MediaUploadInput(
      filename: 'photo.jpg',
      declaredContentType: 'image/jpeg',
      bytes: image.encodePng(mediaQuadrants()),
    );
    expect(() => validateAvatarImageInput(input), throwsA(isA<ApiFailure>()));
    expect(
      () => validateProfileCoverImageInput(input),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('带 JPG 扩展名的未知文件不进入头像和背景准备', () {
    final input = MediaUploadInput(
      filename: 'photo.jpg',
      declaredContentType: 'image/jpeg',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    expect(() => validateAvatarImageInput(input), throwsA(isA<ApiFailure>()));
    expect(
      () => validateProfileCoverImageInput(input),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('APNG 动画控制块在引擎解码前拒绝，不静默丢帧', () {
    final pixels = mediaQuadrants();
    pixels.addFrame(mediaQuadrants());
    final bytes = image.encodePng(pixels);
    expect(ascii.decode(bytes, allowInvalid: true), contains('acTL'));
    expect(
      () => validateMediaImageHeader(
        MediaUploadInput(filename: 'animated.png', bytes: bytes),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (e) => e.userMessage,
          'message',
          contains('GIF'),
        ),
      ),
    );
  });

  test('裁剪准备复用上传工作协调器，不在已有准备任务旁并行解码', () async {
    final coordinator = MediaUploadWorkCoordinator();
    final release = Completer<void>();
    final occupied = coordinator.prepare(() => release.future);
    final processor = EngineImageCropProcessor(workCoordinator: coordinator);
    var completed = false;
    final preparation = processor
        .prepare(MediaUploadInput(filename: 'image.jpg', bytes: mediaJpeg()))
        .then((value) {
          completed = true;
          return value;
        });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(completed, isFalse);
    release.complete();
    await occupied;
    expect((await preparation).width, 80);
  });

  test('裁剪读取异常保留准备阶段诊断且不写入文件名和内容', () async {
    final previous = FailureDiagnostics.instance;
    final diagnostics = FailureDiagnostics();
    FailureDiagnostics.instance = diagnostics;
    addTearDown(() {
      FailureDiagnostics.instance = previous;
      diagnostics.dispose();
    });
    final bytes = Uint8List.sublistView(mediaJpeg(), 0, 100);
    await expectLater(
      EngineImageCropProcessor().prepare(
        MediaUploadInput(filename: 'private-photo-name.jpg', bytes: bytes),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (e) => e.recoveryAction,
          'recovery',
          FailureRecoveryAction.none,
        ),
      ),
    );
    final record = diagnostics.records.single;
    expect(record.stage, DiagnosticStage.preparing);
    expect(record.operation, DiagnosticOperation.mediaUpload);
    expect(jsonEncode(record.toJson()), isNot(contains('private-photo-name')));
  });
}
