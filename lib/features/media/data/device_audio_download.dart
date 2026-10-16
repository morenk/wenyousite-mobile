import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/audio_download.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/media/data/audio_transfer_timing.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_download_filename.dart';

final deviceAudioDownloadProvider = Provider<AudioDownload>((ref) {
  // 公开媒体请求不携带业务客户端的身份、Cookie 或重试拦截器。
  final dio = Dio(
    BaseOptions(
      connectTimeout: AudioTransferTiming.connect,
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return DeviceAudioDownload(dio: dio);
});

class DeviceAudioDownload implements AudioDownload {
  DeviceAudioDownload({
    required this.dio,
    this.platform,
    this.timing = const AudioTransferTiming(),
    this.channel = const MethodChannel('site.wenyou.app/document_saver'),
    Future<Directory> Function()? temporaryDirectory,
  }) : temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;
  final Dio dio;
  final TargetPlatform? platform;
  final AudioTransferTiming timing;
  final MethodChannel channel;
  final Future<Directory> Function() temporaryDirectory;
  @override
  bool get isSupported => !kIsWeb;
  @override
  AudioSaveOperation save(MediaAudio audio, String label) =>
      _Save(this, audio, label)..start();
}

class _Save implements AudioSaveOperation {
  _Save(this.service, this.audio, this.label);
  static const maximumBytes = 30 * 1024 * 1024;
  final DeviceAudioDownload service;
  final MediaAudio audio;
  final String label;
  final id = const Uuid().v4();
  final token = CancelToken();
  final completer = Completer<bool>();
  bool nativeSaving = false;
  bool cancelled = false;
  @override
  Future<bool> get result => completer.future;
  void start() => unawaited(_run());
  @override
  Future<void> cancel() async {
    cancelled = true;
    token.cancel('audio_save_cancelled');
    if (nativeSaving) {
      try {
        await service.channel.invokeMethod<void>('cancelAudio', {'id': id});
      } on Object {
        /* 引擎销毁时仍由 _run 回收私有源文件。 */
      }
    }
  }

  Future<void> _run() async {
    Directory? directory;
    var saved = false;
    var failed = false;
    try {
      if (!service.isSupported || audio.size > maximumBytes) {
        throw const AudioSaveException();
      }
      final root = await service.temporaryDirectory();
      directory = await Directory(
        p.join(root.path, 'audio-downloads-v1', id),
      ).create(recursive: true);
      final fileName = audioDownloadFilename(label);
      final file = File(p.join(directory.path, fileName));
      final transfer = AudioTransferGuard(token, service.timing);
      try {
        await _download(file, transfer);
      } finally {
        transfer.dispose();
      }
      if (cancelled) return;
      final platform = service.platform ?? defaultTargetPlatform;
      if (platform == TargetPlatform.android ||
          platform == TargetPlatform.iOS) {
        nativeSaving = true;
        saved =
            await service.channel.invokeMethod<bool>('saveAudio', {
              'id': id,
              'filePath': file.path,
              'fileName': fileName,
              'mimeType': 'audio/mpeg',
            }) ??
            false;
      } else {
        final target = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: const [
            XTypeGroup(label: 'MP3', extensions: ['mp3']),
          ],
        );
        saved = target != null && !cancelled;
        if (saved) await _copyToDestination(file, target.path);
      }
    } on Object {
      failed = !cancelled;
    } finally {
      nativeSaving = false;
      try {
        if (directory != null && await directory.exists()) {
          await directory.delete(recursive: true);
        }
      } on FileSystemException {
        failed = true;
      }
      if (failed) {
        completer.completeError(const AudioSaveException());
      } else {
        completer.complete(saved && !cancelled);
      }
    }
  }

  Future<void> _copyToDestination(File source, String path) async {
    final staging = File('$path.$id.partial');
    final backup = File('$path.$id.backup');
    final destination = File(path);
    var backedUp = false;
    var installed = false;
    try {
      final sink = staging.openWrite();
      try {
        await for (final chunk in source.openRead()) {
          if (cancelled) throw const AudioSaveException();
          sink.add(chunk);
          await sink.flush();
        }
      } finally {
        await sink.close();
      }
      if (cancelled) throw const AudioSaveException();
      if (await destination.exists()) {
        await destination.rename(backup.path);
        backedUp = true;
      }
      await staging.rename(path);
      installed = true;
    } finally {
      if (await staging.exists()) await staging.delete();
      if (backedUp) {
        if (installed) {
          await backup.delete();
        } else {
          await backup.rename(path);
        }
      }
    }
  }

  Future<void> _download(File file, AudioTransferGuard transfer) async {
    var uri = Uri.parse(audio.sourceUrl);
    for (var redirects = 0; redirects <= 5; redirects++) {
      if (!isSafeAudioUrl(uri.toString())) throw const AudioSaveException();
      final response = await transfer.wait(
        service.dio.getUri<ResponseBody>(
          uri,
          cancelToken: transfer.token,
          options: Options(
            responseType: ResponseType.stream,
            followRedirects: false,
            validateStatus: (value) =>
                value != null && value >= 200 && value < 400,
          ),
        ),
      );
      final body = response.data!;
      if ((response.statusCode ?? 0) >= 300) {
        final target = response.headers.value(HttpHeaders.locationHeader);
        await body.stream.listen((_) {}).cancel();
        if (target == null || redirects == 5) throw const AudioSaveException();
        uri = uri.resolve(target);
        continue;
      }
      final mime = response.headers
          .value(Headers.contentTypeHeader)
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      final length = int.tryParse(
        response.headers.value(Headers.contentLengthHeader) ?? '',
      );
      if (response.statusCode != 200 ||
          (mime != null &&
              mime != 'audio/mpeg' &&
              mime != 'application/octet-stream') ||
          (length != null && (length > maximumBytes || length != audio.size))) {
        await body.stream.listen((_) {}).cancel();
        throw const AudioSaveException();
      }
      final sink = file.openWrite();
      final chunks = StreamIterator(body.stream);
      var size = 0;
      try {
        while (await transfer.wait(chunks.moveNext())) {
          final chunk = chunks.current;
          if (token.isCancelled) throw const AudioSaveException();
          size += chunk.length;
          transfer.progress(size);
          if (size > maximumBytes || size > audio.size) {
            throw const AudioSaveException();
          }
          sink.add(chunk);
          await sink.flush();
        }
      } finally {
        try {
          await chunks.cancel();
        } finally {
          await sink.close();
        }
      }
      if (size != audio.size || size == 0) throw const AudioSaveException();
      return;
    }
    throw const AudioSaveException();
  }
}
