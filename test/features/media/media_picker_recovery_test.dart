import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/features/media/application/media_picker_recovery_ports.dart';
import 'package:wenyousite_mobile/features/media/application/recovered_media_selection.dart';
import 'package:wenyousite_mobile/features/media/data/media_picker_recovery.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  test('文件型图片输入只在准备上传时读取字节', () async {
    final directory = await Directory.systemTemp.createTemp('wenyou-media-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}picked.png');
    await file.writeAsBytes(const [137, 80, 78, 71]);
    final input = MediaUploadInput.fromPickedSource(
      PickedMediaSource.file(
        filename: 'picked.png',
        path: file.path,
        length: await file.length(),
        declaredContentType: 'image/png',
        purpose: MediaUploadPurpose.moment,
      ),
    );

    expect(input.isMaterialized, isFalse);
    expect(input.byteLength, 4);
    expect(input.sourcePath, file.path);

    final materialized = await input.materialize();
    expect(materialized.isMaterialized, isTrue);
    expect(materialized.bytes, const [137, 80, 78, 71]);
    expect(materialized.purpose, MediaUploadPurpose.moment);
  });

  test('Android 丢失的多图选择按原用途恢复且只消费一次', () async {
    final directory = await Directory.systemTemp.createTemp('wenyou-lost-');
    addTearDown(() => directory.delete(recursive: true));
    final first = File('${directory.path}${Platform.pathSeparator}first.png');
    final second = File('${directory.path}${Platform.pathSeparator}second.png');
    await first.writeAsBytes(const [1, 2, 3]);
    await second.writeAsBytes(const [4, 5, 6]);
    final contextStore = _MemoryRecoveryContextStore(MediaUploadPurpose.moment);

    final recovered = RecoveredMediaSelectionStore.fromResult(
      await recoverLostEditorMediaSelection(
        isAndroid: true,
        contextStore: contextStore,
        retrieve: () async => LostDataResponse(
          files: [XFile(first.path), XFile(second.path)],
          type: RetrieveType.image,
        ),
      ),
    );

    expect(contextStore.cleared, isTrue);
    expect(recovered.hasSelection(MediaUploadPurpose.moment), isTrue);
    final inputs = recovered.take(MediaUploadPurpose.moment);
    expect(inputs, hasLength(2));
    expect(inputs, everyElement(isA<MediaUploadInput>()));
    expect(
      inputs,
      everyElement(
        predicate<MediaUploadInput>((i) {
          return !i.isMaterialized && i.purpose == MediaUploadPurpose.moment;
        }),
      ),
    );
    expect(recovered.take(MediaUploadPurpose.moment), isEmpty);
  });

  test('恢复异常不会阻塞启动并提供安全重选提示', () async {
    final contextStore = _MemoryRecoveryContextStore(
      MediaUploadPurpose.richContent,
    );

    final recovered = RecoveredMediaSelectionStore.fromResult(
      await recoverLostEditorMediaSelection(
        isAndroid: true,
        contextStore: contextStore,
        retrieve: () => Future.error(StateError('private picker detail')),
      ),
    );

    expect(recovered.failure?.userMessage, '上次选择的图片没有恢复，请重新选择。');
    expect(
      recovered.failure?.userMessage,
      isNot(contains('private picker detail')),
    );
  });
}

class _MemoryRecoveryContextStore implements MediaPickerRecoveryContextStore {
  _MemoryRecoveryContextStore(this.purpose);

  MediaUploadPurpose? purpose;
  bool cleared = false;

  @override
  Future<void> begin(MediaUploadPurpose purpose) async {
    this.purpose = purpose;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    purpose = null;
  }

  @override
  Future<MediaUploadPurpose?> read() async => purpose;
}
