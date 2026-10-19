import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

/// 账号与编辑目标隔离；相册临时文件不能作为跨页面草稿的持久来源。
class PrivatePendingMediaFileStore
    implements PendingMediaFileStore, PendingAudioFileStore {
  PrivatePendingMediaFileStore({this.rootDirectory});

  final Directory? rootDirectory;
  Future<void> _queue = Future.value();

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  Future<void> removeAudio({
    required String accountId,
    required String target,
    required String attachmentId,
  }) => _serialized(() async {
    final directory = await _directory(accountId, target);
    final file = File(p.join(directory.path, '${_hash(attachmentId)}.audio'));
    if (await file.exists()) await file.delete();
  });

  @override
  Future<AudioUploadInput> persistAudio(
    AudioUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  }) => _serialized(() async {
    if (attachmentId.isEmpty || input.size < 1 || input.size > 31457280) {
      throw ArgumentError.value(attachmentId);
    }
    final directory = await _directory(accountId, target);
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, '${_hash(attachmentId)}.audio'));
    if (input.path != file.path) {
      final temporary = File('${file.path}.tmp');
      final sink = temporary.openWrite();
      var length = 0;
      try {
        await for (final chunk in File(
          input.path,
        ).openRead(0, input.size + 1)) {
          length += chunk.length;
          if (length > input.size) throw const FormatException('音频文件大小已变化');
          sink.add(chunk);
          await sink.flush();
        }
        await sink.close();
        if (length != input.size) throw const FormatException('音频文件大小已变化');
        await temporary.rename(file.path);
      } on Object {
        try {
          await sink.close();
        } on Object {
          /* 保留原始失败并继续清理。 */
        }
        if (await temporary.exists()) await temporary.delete();
        rethrow;
      }
    }
    return AudioUploadInput(
      filename: input.filename,
      path: file.path,
      size: input.size,
      contentType: input.contentType,
    );
  });

  Future<Directory> _directory(String accountId, String target) async {
    if (accountId.isEmpty || target.isEmpty) {
      throw ArgumentError(
        'A local image draft requires an account and target.',
      );
    }
    final root = rootDirectory ?? await getApplicationSupportDirectory();
    return Directory(
      p.join(root.path, 'pending-media-v1', _hash(accountId), _hash(target)),
    );
  }

  @override
  Future<MediaUploadInput> persist(
    MediaUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  }) => _serialized(() async {
    if (attachmentId.isEmpty) throw ArgumentError.value(attachmentId);
    final directory = await _directory(accountId, target);
    await directory.create(recursive: true);
    final extension = p.extension(input.filename).toLowerCase();
    final safeExtension =
        {'.jpg', '.jpeg', '.png', '.webp', '.gif'}.contains(extension)
        ? extension
        : '.image';
    final file = File(
      p.join(directory.path, '${_hash(attachmentId)}$safeExtension'),
    );
    if (input.sourcePath != file.path) {
      final temporary = File('${file.path}.tmp');
      if (input.isMaterialized) {
        await temporary.writeAsBytes(input.requiredBytes, flush: true);
      } else {
        await File(input.sourcePath!).copy(temporary.path);
      }
      await temporary.rename(file.path);
    }
    return MediaUploadInput.fromPickedSource(
      PickedMediaSource.file(
        filename: input.filename,
        path: file.path,
        length: await file.length(),
        declaredContentType: input.declaredContentType,
        purpose: input.purpose,
      ),
    );
  });

  @override
  Future<Map<String, Object?>?> read({
    required String accountId,
    required String target,
  }) => _serialized(() async {
    final directory = await _directory(accountId, target);
    final file = File(p.join(directory.path, 'draft.json'));
    if (!await file.exists()) return null;
    final payload = jsonDecode(await file.readAsString());
    if (payload is! Map<String, Object?>) {
      throw const FormatException('Invalid local image draft.');
    }
    return payload;
  });

  @override
  Future<void> write({
    required String accountId,
    required String target,
    required Map<String, Object?> payload,
  }) {
    // 在排队前固定快照，调用者继续编辑不会悄悄改变这次保存。
    final encoded = jsonEncode(payload);
    return _serialized(() async {
      final directory = await _directory(accountId, target);
      await directory.create(recursive: true);
      final file = File(p.join(directory.path, 'draft.json'));
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsString(encoded, flush: true);
      await temporary.rename(file.path);
    });
  }

  @override
  Future<void> delete({required String accountId, required String target}) =>
      _serialized(() async {
        final directory = await _directory(accountId, target);
        if (await directory.exists()) await directory.delete(recursive: true);
      });
}

String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
