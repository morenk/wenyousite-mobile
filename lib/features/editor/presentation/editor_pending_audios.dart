import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_audio_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/application/audio_file_picker.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/data/audio_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/data/system_audio_file_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';

final audioFilePickerProvider = Provider<AudioFilePicker>(
  (ref) => const SystemAudioFilePicker(),
);

class EditorPendingAudio {
  EditorPendingAudio(this.id, this.input);
  final String id;
  AudioUploadInput? input;
  PendingAudioUpload? pending;
  MediaAudio? result;
  AudioUploadProgress progress = const AudioUploadProgress(
    AudioUploadStage.preparing,
  );
  CancelToken? cancel;
  Future<void>? persisting;
  String? failure;
  bool active = false;
  bool persisted = false;
  bool awaitingContinue = false;
  bool terminalFailure = false;
  int generation = 0;
}

/// 和图片共用一份编辑快照；只传递普通链接与独立可信音频投影。
class EditorPendingAudios extends ChangeNotifier {
  EditorPendingAudios({
    required this.ref,
    required this.editor,
    required this.accountId,
    required this.target,
    required this.isCurrent,
    required this.save,
  });
  final WidgetRef ref;
  final RichEditorSession editor;
  final String? accountId;
  final String target;
  final bool Function() isCurrent;
  final Future<bool> Function() save;
  final Map<String, EditorPendingAudio> items = {};
  AudioFilePickOperation? _selection;
  bool _disposed = false;
  bool _paused = false;
  int _selectionGeneration = 0;
  Completer<void>? _resumed;
  String? selectionFailure;
  bool get selecting => _selection != null;
  Set<String> get ids => editor.localAudioIds;
  bool get hasPending => ids.isNotEmpty || selecting;
  bool get hasFailure =>
      selectionFailure != null ||
      ids.any((id) => items[id]?.failure != null || items[id] == null);
  Iterable<EditorPendingAudio> get visible => ids.map(
    (id) => items.putIfAbsent(
      id,
      () => EditorPendingAudio(id, null)..failure = '本机音频缺失，请移除后重新选择。',
    ),
  );

  Future<void> pick() async {
    if (_disposed || !isCurrent() || selecting || _paused) return;
    final policy = ref.read(appCapabilitiesProvider).audioUpload;
    if (policy == null) return;
    selectionFailure = null;
    final operation = ref.read(audioFilePickerProvider).pick(policy.selection);
    final generation = ++_selectionGeneration;
    bool current() =>
        !_disposed && isCurrent() && generation == _selectionGeneration;
    _selection = operation;
    notifyListeners();
    SelectedAudioFile? file;
    String? savedId;
    PendingAudioFileStore? savedStore;
    bool adopted = false;
    try {
      file = await operation.result;
      if (_paused && current()) await _resumed?.future;
      if (!current() || file == null) return;
      final type = policy.normalizeContentType(
        file.declaredContentType,
        file.filename,
      );
      if (type == null) {
        throw const ApiFailure(userMessage: '仅支持 MP3、M4A、WAV、OGG 和 FLAC 音频。');
      }
      final owner = accountId;
      final store = ref.read(pendingMediaFileStoreProvider);
      if (owner == null || store is! PendingAudioFileStore) {
        throw const ApiFailure(userMessage: '音频未能保存到本机，请重试。');
      }
      final id = const Uuid().v4();
      savedId = id;
      savedStore = store as PendingAudioFileStore;
      final input = await savedStore.persistAudio(
        AudioUploadInput(
          filename: file.filename,
          path: file.path,
          size: file.size,
          contentType: type,
        ),
        accountId: owner,
        target: target,
        attachmentId: id,
      );
      if (_paused && current()) await _resumed?.future;
      if (!current()) return;
      final item = EditorPendingAudio(id, input)..persisted = true;
      items[id] = item;
      adopted = true;
      editor.insertLocalAudio(id, filename: input.filename);
      await editor.flush();
      _selection = null;
      if (await save() && current()) {
        unawaited(_run(item));
      } else {
        item.failure = '音频未能保存到本机，请重试或移除。';
      }
    } on AudioFileSelectionException catch (error) {
      if (current()) {
        selectionFailure = switch (error.failure) {
          AudioFileSelectionFailure.tooLarge => '音频不能超过 30 MiB。',
          AudioFileSelectionFailure.empty => '音频文件为空，请重新选择。',
          _ => '音频文件读取失败，请重新选择。',
        };
      }
    } on Object catch (error) {
      if (current()) {
        selectionFailure = error is ApiFailure
            ? error.userMessage
            : '音频选择失败，请重试。';
      }
    } finally {
      if (!adopted && savedStore != null && savedId != null) {
        await savedStore.removeAudio(
          accountId: accountId!,
          target: target,
          attachmentId: savedId,
        );
      }
      try {
        await file?.release();
      } on Object {
        /* 私有草稿已独立保存；不删除用户源文件。 */
      }
      if (identical(_selection, operation)) _selection = null;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> cancelSelection() async {
    _selectionGeneration++;
    _resumed?.complete();
    _resumed = null;
    await _selection?.cancel();
  }

  void restore(Object? value) {
    if (value is! List) return;
    for (final entry in value) {
      if (entry is! Map || entry['id'] is! String) continue;
      final input = AudioUploadInput.parse(entry['input']);
      final item = EditorPendingAudio(entry['id'] as String, input)
        ..persisted = input != null
        ..pending = PendingAudioUpload.parse(entry['pending'])
        ..awaitingContinue = true;
      if (input == null && item.pending == null) {
        item.failure = '本机音频缺失，请移除后重新选择。';
      }
      items[item.id] = item;
    }
  }

  List<Map<String, Object?>> toJson() => [
    for (final item in items.values)
      if (ids.contains(item.id))
        {
          'id': item.id,
          'input': item.input?.toJson(),
          'pending': item.pending?.toJson(),
        },
  ];

  void documentChanged() {
    if (_disposed || !isCurrent()) return;
    for (final item in items.values) {
      if (!ids.contains(item.id)) {
        _stop(item);
        continue;
      }
      if (item.result != null) {
        editor.resolveLocalAudio(
          item.id,
          item.result!,
          filename: item.input?.filename,
        );
        unawaited(editor.flush());
      } else if (!item.active &&
          !item.awaitingContinue &&
          item.failure == null &&
          !_paused) {
        unawaited(_run(item));
      }
    }
  }

  Future<void> retry(String id) async {
    final item = items[id];
    if (item == null || item.active || item.terminalFailure) return;
    item.awaitingContinue = false;
    item.failure = null;
    await _run(item);
  }

  Future<void> reselect(String id) async {
    if (ref.read(appCapabilitiesProvider).audioUpload == null) return;
    remove(id);
    await pick();
  }

  Future<void> _run(EditorPendingAudio item) async {
    final policy = ref.read(appCapabilitiesProvider).audioUpload;
    if (_disposed ||
        !isCurrent() ||
        _paused ||
        item.active ||
        !ids.contains(item.id)) {
      return;
    }
    if (policy == null && item.pending == null) {
      item.failure = '音频上传暂不可用，请稍后重试。';
      notifyListeners();
      return;
    }
    if (item.input == null && item.pending == null) {
      item.failure = '本机音频缺失，请重新选择。';
      notifyListeners();
      return;
    }
    final generation = ++item.generation;
    final cancel = CancelToken();
    item.cancel = cancel;
    item.active = true;
    item.failure = null;
    notifyListeners();
    bool current() =>
        !_disposed &&
        isCurrent() &&
        generation == item.generation &&
        ids.contains(item.id);
    try {
      if (!await editor.flush()) {
        throw const ApiFailure(userMessage: '正文保存失败，请重试或移除音频。');
      }
      if (!await save()) throw const ApiFailure(userMessage: '本机音频状态保存失败，请重试。');
      if (!current()) return;
      final result = await ref
          .read(audioUploadRepositoryProvider)
          .upload(
            item.input,
            policy,
            cancelToken: cancel,
            pending: item.pending,
            savePending: (pending) async {
              if (!current()) {
                cancel.cancel();
                throw cancel.cancelError!;
              }
              item.pending = pending;
              if (!await save()) {
                throw const ApiFailure(userMessage: '本机音频状态保存失败，请重试。');
              }
            },
            onProgress: (progress) {
              if (current()) {
                item.progress = progress;
                notifyListeners();
              }
            },
          );
      if (!current()) return;
      item.result = result;
      editor.resolveLocalAudio(item.id, result, filename: item.input?.filename);
      await editor.flush();
      await save();
    } on AudioProcessingFailed catch (error) {
      if (current()) {
        item.terminalFailure = true;
        item.failure = error.message;
      }
    } on AudioProcessingPending {
      if (current()) item.failure = '音频仍在处理中，点击重试查询。';
    } on Object catch (error) {
      if (current() && !cancel.isCancelled) {
        item.failure = error is ApiFailure ? error.userMessage : '音频上传失败，请重试。';
      }
    } finally {
      if (!_disposed && generation == item.generation) {
        item.active = false;
        notifyListeners();
      }
    }
  }

  void remove(String id) {
    final item = items[id];
    if (item != null) _stop(item);
    editor.removeLocalAudio(id);
    unawaited(editor.flush());
    notifyListeners();
  }

  void _stop(EditorPendingAudio item) {
    item.generation++;
    item.cancel?.cancel();
    item.active = false;
  }

  void pause({bool cancelSelection = true}) {
    _paused = true;
    _resumed ??= Completer<void>();
    if (cancelSelection) unawaited(this.cancelSelection());
    for (final item in items.values) {
      if (item.active) item.awaitingContinue = true;
      _stop(item);
    }
  }

  void resume() {
    _paused = false;
    _resumed?.complete();
    _resumed = null;
    documentChanged();
  }

  void clear() {
    pause();
    items.clear();
    selectionFailure = null;
  }

  @override
  void dispose() {
    _disposed = true;
    pause();
    super.dispose();
  }
}
