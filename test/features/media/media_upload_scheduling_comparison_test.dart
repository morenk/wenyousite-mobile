import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_normalizer.dart';

void main() {
  for (final count in [1, 9]) {
    testWidgets('$count 图确定性调度：相同耗时下旧完整流程限流与新传输限流对比', (tester) async {
      final old = await _simulate(tester, count: count, legacy: true);
      final current = await _simulate(tester, count: count, legacy: false);
      if (count == 1) {
        expect(old.lastConfirmation, 120);
        expect(current.lastConfirmation, 120);
        expect(old.allReady, 1120);
        expect(current.allReady, 1120);
      } else {
        expect(old.transferStarts[2], 1140);
        expect(current.transferStarts[2], 120);
        expect(old.lastConfirmation, 4600);
        expect(current.lastConfirmation, 520);
        expect(old.allReady, 5600);
        expect(current.allReady, 1520);
      }
      expect(current.maximumTransfers, 2.clamp(1, count));
      // t=500ms 点击发布：只计算图片等待，不把正文 HTTP 发送混进模型。
      expect(old.allReady - 500, count == 1 ? 620 : 5100);
      expect(current.allReady - 500, count == 1 ? 620 : 1020);
    });
  }
}

Future<_ScheduleResult> _simulate(
  WidgetTester tester, {
  required int count,
  required bool legacy,
}) async {
  final start = tester.binding.clock.now();
  int elapsed() => tester.binding.clock.now().difference(start).inMilliseconds;
  final result = _ScheduleResult();
  final repository = _TimedRepository(result, elapsed);
  final coordinator = MediaUploadWorkCoordinator();
  const normalizer = _TimedNormalizer();
  final gateway = RepositoryMediaUploadGateway(
    repository,
    normalizer: normalizer,
    workCoordinator: coordinator,
  );
  final oldPageGate = MediaUploadWorkCoordinator();
  final futures = [
    for (var index = 0; index < count; index++)
      legacy
          // 旧动态页面只有两个完整流水线名额，处理等待占用该名额。
          ? oldPageGate.transfer(() async {
              final input = await coordinator.prepare(
                () => normalizer.normalize(_input(index)),
              );
              return coordinator.transfer(() => repository.uploadImage(input));
            })
          : gateway.startImageUpload(_input(index)).result,
  ];
  var completed = false;
  final done = Future.wait(futures).then((_) {
    result.allReady = elapsed();
    completed = true;
  });
  for (var tick = 0; tick < 700 && !completed; tick++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
  expect(completed, isTrue);
  await done;
  return result;
}

MediaUploadInput _input(int index) => MediaUploadInput(
  filename: '$index.png',
  bytes: Uint8List.fromList([1]),
  purpose: MediaUploadPurpose.moment,
);

class _ScheduleResult {
  final transferStarts = <int, int>{};
  int lastConfirmation = 0;
  int allReady = 0;
  int maximumTransfers = 0;
}

class _TimedNormalizer implements MediaUploadNormalizer {
  const _TimedNormalizer();
  @override
  Future<MediaUploadInput> normalize(MediaUploadInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return input;
  }
}

class _TimedRepository implements MediaUploadRepository {
  _TimedRepository(this.result, this.elapsed);
  final _ScheduleResult result;
  final int Function() elapsed;
  int activeTransfers = 0;

  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) async {
    final index = int.parse(input.filename.split('.').first);
    result.transferStarts[index] = elapsed();
    activeTransfers++;
    if (activeTransfers > result.maximumTransfers) {
      result.maximumTransfers = activeTransfers;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    activeTransfers--;
    result.lastConfirmation = elapsed();
    onProgress?.call(
      const MediaUploadProgress(stage: MediaUploadStage.processing),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    return UploadedEditorImage(
      mediaId: '$index',
      url: 'https://cdn.example/$index.png',
    );
  }
}
