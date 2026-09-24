import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

export 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';

Override memoryPendingMediaFileStoreOverride() =>
    pendingMediaFileStoreProvider.overrideWith((ref) {
      final store = MemoryPendingMediaFileStore();
      ref.onDispose(store.dispose);
      return store;
    });

/// 草稿元数据留在内存，图片用独立临时目录，便于页面恢复测试读取真实来源。
class MemoryPendingMediaFileStore implements PendingMediaFileStore {
  MemoryPendingMediaFileStore()
    : directory = Directory.systemTemp.createTempSync('wenyou-pending-test-');

  final Directory directory;
  final Map<String, Map<String, Object?>> drafts = {};
  bool failWrites = false;
  int persistCalls = 0;
  String key(String accountId, String target) => '$accountId::$target';

  void dispose() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }

  @override
  Future<MediaUploadInput> persist(
    MediaUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  }) async {
    persistCalls++;
    if (failWrites) throw const FileSystemException('test disk full');
    final bytes = input.isMaterialized
        ? input.bytes
        : File(input.sourcePath!).readAsBytesSync();
    final file = File('${directory.path}/$persistCalls.png')
      ..writeAsBytesSync(bytes);
    return MediaUploadInput.fromPickedSource(
      _MemorySource(
        filename: input.filename,
        path: file.path,
        length: bytes.length,
        declaredContentType: input.declaredContentType,
        purpose: input.purpose,
      ),
    );
  }

  @override
  Future<Map<String, Object?>?> read({
    required String accountId,
    required String target,
  }) async {
    final value = drafts[key(accountId, target)];
    return value == null ? null : _clone(value);
  }

  @override
  Future<void> write({
    required String accountId,
    required String target,
    required Map<String, Object?> payload,
  }) async {
    if (failWrites) throw const FileSystemException('test disk full');
    drafts[key(accountId, target)] = _clone(payload);
  }

  @override
  Future<void> delete({
    required String accountId,
    required String target,
  }) async {
    drafts.remove(key(accountId, target));
  }
}

Map<String, Object?> _clone(Map<String, Object?> value) =>
    (jsonDecode(jsonEncode(value)) as Map).cast<String, Object?>();

class _MemorySource extends PickedMediaSource {
  const _MemorySource({
    required super.filename,
    required super.path,
    required super.length,
    super.declaredContentType,
    super.purpose,
  }) : super.file();

  @override
  Future<Uint8List> readBytes() async => File(path).readAsBytesSync();
}
