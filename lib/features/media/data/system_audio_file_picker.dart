import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/features/media/application/audio_file_picker_ports.dart';

/// Android 的大文件准备由后台 SAF 端口处理；其他端沿用系统文件选择器。
class SystemAudioFilePicker implements AudioFilePicker {
  const SystemAudioFilePicker({
    this.channel = const MethodChannel('site.wenyou.app/audio_file_picker'),
    this.platform,
  });

  final MethodChannel channel;
  final TargetPlatform? platform;

  @override
  AudioFilePickOperation pick(AudioFileSelectionPolicy policy) {
    final operation = _AudioFilePickOperation(
      policy,
      channel,
      (platform ?? defaultTargetPlatform) == TargetPlatform.android,
    );
    operation.start();
    return operation;
  }
}

class _AudioFilePickOperation implements AudioFilePickOperation {
  _AudioFilePickOperation(this.policy, this.channel, this.android);

  final AudioFileSelectionPolicy policy;
  final MethodChannel channel;
  final bool android;
  final String id = const Uuid().v4();
  final _result = Completer<SelectedAudioFile?>();
  bool _cancelled = false;
  StreamIterator<List<int>>? _reader;

  @override
  Future<SelectedAudioFile?> get result => _result.future;

  void start() => unawaited(_start());

  Future<void> _start() async {
    try {
      final file = android ? await _pickAndroid() : await _pickOther();
      if (_cancelled) {
        await file?.release();
        _result.complete(null);
      } else {
        _result.complete(file);
      }
    } on Object catch (error, stack) {
      if (_cancelled) {
        _result.complete(null);
      } else {
        _result.completeError(error, stack);
      }
    }
  }

  Future<SelectedAudioFile?> _pickAndroid() async {
    try {
      final value = await channel.invokeMapMethod<String, Object?>('pick', {
        'id': id,
        'maximumBytes': policy.maximumBytes,
        'contentTypes': policy.contentTypes,
      });
      if (value == null) return null;
      final filename = value['filename'];
      final path = value['path'];
      final size = value['size'];
      final contentType = value['contentType'];
      if (value['id'] != id ||
          filename is! String ||
          path is! String ||
          path.isEmpty ||
          size is! int ||
          size <= 0 ||
          size > policy.maximumBytes ||
          (contentType != null && contentType is! String)) {
        await channel.invokeMethod<void>('release', {'id': id});
        throw const AudioFileSelectionException(
          AudioFileSelectionFailure.unreadable,
        );
      }
      return SelectedAudioFile(
        filename: filename,
        path: path,
        size: size,
        declaredContentType: contentType as String?,
        release: () => channel.invokeMethod<void>('release', {'id': id}),
      );
    } on PlatformException catch (error) {
      throw AudioFileSelectionException(switch (error.code) {
        'file_too_large' => AudioFileSelectionFailure.tooLarge,
        'file_empty' => AudioFileSelectionFailure.empty,
        'picker_unavailable' ||
        'picker_busy' => AudioFileSelectionFailure.unavailable,
        _ => AudioFileSelectionFailure.unreadable,
      });
    } on MissingPluginException {
      throw const AudioFileSelectionException(
        AudioFileSelectionFailure.unavailable,
      );
    }
  }

  Future<SelectedAudioFile?> _pickOther() async {
    final selected = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: '音频',
          mimeTypes: policy.contentTypes,
          extensions: const ['mp3', 'm4a', 'mp4', 'wav', 'ogg', 'flac'],
          uniformTypeIdentifiers: const ['public.audio'],
        ),
      ],
    );
    if (selected == null || _cancelled) return null;
    final declaredSize = await selected.length();
    if (declaredSize > policy.maximumBytes) {
      throw const AudioFileSelectionException(
        AudioFileSelectionFailure.tooLarge,
      );
    }
    final root = await getTemporaryDirectory();
    final directory = await Directory(
      p.join(root.path, 'audio-selections-v1'),
    ).create(recursive: true);
    final cutoff = DateTime.now().subtract(const Duration(days: 1));
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is File &&
          RegExp(
            r'^[a-fA-F0-9-]{36}\.[a-z0-9]{1,8}$',
          ).hasMatch(p.basename(entry.path)) &&
          (await entry.stat()).modified.isBefore(cutoff)) {
        await entry.delete();
      }
    }
    final extension = p.extension(selected.name).toLowerCase();
    final safeExtension = RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)
        ? extension
        : '.audio';
    final file = File(p.join(directory.path, '$id$safeExtension'));
    final sink = file.openWrite();
    final reader = StreamIterator<List<int>>(selected.openRead());
    _reader = reader;
    var size = 0;
    try {
      while (!_cancelled && await reader.moveNext()) {
        if (_cancelled) break;
        size += reader.current.length;
        if (size > policy.maximumBytes) {
          throw const AudioFileSelectionException(
            AudioFileSelectionFailure.tooLarge,
          );
        }
        sink.add(reader.current);
        await sink.flush();
      }
      if (size == 0 && !_cancelled) {
        throw const AudioFileSelectionException(
          AudioFileSelectionFailure.empty,
        );
      }
    } on Object {
      await sink.close();
      if (await file.exists()) await file.delete();
      rethrow;
    } finally {
      await reader.cancel();
      _reader = null;
    }
    await sink.close();
    return SelectedAudioFile(
      filename: selected.name,
      path: file.path,
      size: size,
      declaredContentType: selected.mimeType,
      release: () async {
        if (await file.exists()) await file.delete();
      },
    );
  }

  @override
  Future<void> cancel() async {
    _cancelled = true;
    if (android) {
      await channel.invokeMethod<void>('cancel', {'id': id});
    } else {
      await _reader?.cancel();
    }
  }
}
