import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/data/private_pending_media_file_store.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  late Directory directory;
  late PrivatePendingMediaFileStore store;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pending-media-test-');
    store = PrivatePendingMediaFileStore(rootDirectory: directory);
  });
  tearDown(() => directory.delete(recursive: true));

  test('私有图片和草稿按账号及编辑目标隔离，删除只影响指定草稿', () async {
    final input = MediaUploadInput(
      filename: '../photo.png',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    final first = await store.persist(
      input,
      accountId: 'one',
      target: '../thread',
      attachmentId: '../stable-id',
    );
    final second = await store.persist(
      input,
      accountId: 'two',
      target: '../thread',
      attachmentId: '../stable-id',
    );
    expect(first.sourcePath, startsWith(directory.path));
    expect(first.sourcePath, isNot(second.sourcePath));
    await store.write(
      accountId: 'one',
      target: '../thread',
      payload: {'input': encodePendingMediaInput(first)},
    );
    expect(await store.read(accountId: 'two', target: '../thread'), isNull);
    final saved = await store.read(accountId: 'one', target: '../thread');
    final restored = decodePendingMediaInput(
      saved!['input'] as Map<String, Object?>,
    )!;
    expect((await restored.materialize()).bytes, [1, 2, 3]);
    await store.delete(accountId: 'one', target: '../thread');
    expect(await File(first.sourcePath!).exists(), isFalse);
    expect(await File(second.sourcePath!).exists(), isTrue);
  });

  test('保存固定调用时快照，连续写入和删除保持顺序', () async {
    final payload = <String, Object?>{'text': 'one'};
    final first = store.write(
      accountId: 'one',
      target: 'post',
      payload: payload,
    );
    payload['text'] = 'two';
    await first;
    expect(
      (await store.read(accountId: 'one', target: 'post'))!['text'],
      'one',
    );
    await Future.wait([
      store.write(accountId: 'one', target: 'post', payload: payload),
      store.delete(accountId: 'one', target: 'post'),
    ]);
    expect(await store.read(accountId: 'one', target: 'post'), isNull);
  });

  test('丢失本地文件不丢掉图片占位和已知媒体身份', () async {
    final input = await store.persist(
      MediaUploadInput(filename: 'photo.jpg', bytes: Uint8List.fromList([1])),
      accountId: 'one',
      target: 'post',
      attachmentId: 'stable',
    );
    final metadata = encodePendingMediaInput(input);
    await File(input.sourcePath!).delete();
    final restored = decodePendingMediaInput(metadata);
    expect(restored?.sourcePath, input.sourcePath);
    await expectLater(
      restored!.materialize(),
      throwsA(isA<FileSystemException>()),
    );
    const pending = PendingMediaUpload(
      mediaId: 'known',
      purpose: MediaUploadPurpose.richContent,
      needsConfirmation: true,
    );
    final restoredPending = PendingMediaUpload.fromJson(pending.toJson());
    expect(restoredPending?.mediaId, 'known');
    expect(restoredPending?.needsConfirmation, isTrue);
  });
}
