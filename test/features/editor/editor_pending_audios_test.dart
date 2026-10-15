import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_pending_audios.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_audio_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/application/audio_file_picker.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/data/audio_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_policy.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

final _policy = AudioUploadPolicy.parse({
  'version': 1,
  'maxBytes': 31457280,
  'maxDurationMs': 600000,
  'contentTypes': ['audio/mpeg'],
  'outputContentType': 'audio/mpeg',
})!;
const _input = AudioUploadInput(
  filename: 'a.mp3',
  path: '/private/a.mp3',
  size: 100,
  contentType: 'audio/mpeg',
);
final _ready = MediaAudio.parse({
  'sourceUrl': 'https://storage.example/a.mp3',
  'mediaId': 'server-id',
  'contentType': 'audio/mpeg',
  'size': 100,
  'durationMs': 1000,
})!;

void main() {
  testWidgets('恢复与回前台不自动上传，用户继续后已完成音频不依赖新上传能力', (tester) async {
    final harness = await _mount(tester, capability: false);
    harness.editor.insertLocalAudio('restored');
    await harness.editor.flush();
    harness.audios.restore([
      {
        'id': 'restored',
        'input': null,
        'pending': {'mediaId': 'server-id', 'stage': 'processing'},
      },
    ]);
    harness.audios.documentChanged();
    harness.audios.pause();
    harness.audios.resume();
    await tester.pump();
    expect(harness.repository.calls, 0);
    expect(harness.audios.items['restored']!.awaitingContinue, isTrue);
    await harness.audios.retry('restored');
    expect(harness.repository.calls, 1);
    expect(harness.repository.lastPolicy, isNull);
    expect(harness.editor.localAudioIds, isEmpty);
    expect(harness.editor.mediaAudios[_ready.sourceUrl], _ready);
    await harness.close(tester);
  });

  testWidgets('系统选择器暂停期间保留选择，恢复后才插入与上传', (tester) async {
    final harness = await _mount(tester);
    final pick = harness.audios.pick();
    harness.audios.pause(cancelSelection: false);
    harness.picker.complete();
    await tester.pump();
    expect(harness.picker.cancelled, isFalse);
    expect(harness.repository.calls, 0);
    harness.audios.resume();
    await pick;
    await tester.pump();
    expect(harness.repository.calls, 1);
    expect(harness.picker.released, isTrue);
    expect(harness.editor.localAudioIds, isEmpty);
    await harness.close(tester);
  });

  testWidgets('离开目标时取消在途私有复制，迟到结果清理且不插入', (tester) async {
    final harness = await _mount(tester);
    harness.store.copyGate = Completer<void>();
    final pick = harness.audios.pick();
    harness.picker.complete();
    await tester.pump();
    harness.audios.pause();
    harness.store.copyGate!.complete();
    await pick;
    expect(harness.store.removed, hasLength(1));
    expect(harness.repository.calls, 0);
    expect(harness.editor.localAudioIds, isEmpty);
    expect(harness.picker.released, isTrue);
    await harness.close(tester);
  });

  testWidgets('FAILED 不再提供同身份无效重试，显式重新选择才创建新附件', (tester) async {
    final harness = await _mount(tester);
    harness.repository.failure = const AudioProcessingFailed('音频无法解码，请重新选择文件。');
    harness.editor.insertLocalAudio('failed');
    await harness.editor.flush();
    harness.audios.restore([
      {
        'id': 'failed',
        'input': _input.toJson(),
        'pending': {'mediaId': 'server-id', 'stage': 'processing'},
      },
    ]);
    await harness.audios.retry('failed');
    expect(harness.audios.items['failed']!.terminalFailure, isTrue);
    await harness.audios.retry('failed');
    expect(harness.repository.calls, 1);
    harness.repository.failure = null;
    final selection = harness.audios.reselect('failed');
    harness.picker.complete();
    await selection;
    await tester.pump();
    expect(harness.repository.calls, 2);
    expect(harness.repository.lastPending, isNull);
    await harness.close(tester);
  });
}

Future<_Harness> _mount(WidgetTester tester, {bool capability = true}) async {
  final harness = _Harness();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appCapabilitiesProvider.overrideWithValue(
          AppCapabilities(audioUpload: capability ? _policy : null),
        ),
        audioFilePickerProvider.overrideWithValue(harness.picker),
        pendingMediaFileStoreProvider.overrideWithValue(harness.store),
        audioUploadRepositoryProvider.overrideWithValue(harness.repository),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          harness.audios = EditorPendingAudios(
            ref: ref,
            editor: harness.editor,
            accountId: 'user',
            target: 'post:one',
            isCurrent: () => true,
            save: () async => true,
          );
          return const SizedBox();
        },
      ),
    ),
  );
  return harness;
}

class _Harness {
  final editor = RichEditorSession(
    initialMarkdown: '',
    onMarkdownChanged: (_) {},
  );
  final picker = _Picker();
  final store = _Store();
  final repository = _Repository();
  late EditorPendingAudios audios;
  Future<void> close(WidgetTester tester) async {
    audios.dispose();
    editor.dispose();
    await tester.pumpWidget(const SizedBox());
  }
}

class _Repository implements AudioUploadRepository {
  int calls = 0;
  Object? failure;
  AudioUploadPolicy? lastPolicy;
  PendingAudioUpload? lastPending;
  @override
  Future<MediaAudio> upload(
    AudioUploadInput? input,
    AudioUploadPolicy? policy, {
    required CancelToken cancelToken,
    required Future<void> Function(PendingAudioUpload) savePending,
    PendingAudioUpload? pending,
    void Function(AudioUploadProgress)? onProgress,
  }) async {
    calls++;
    lastPolicy = policy;
    lastPending = pending;
    if (failure != null) throw failure!;
    return _ready;
  }
}

class _Picker implements AudioFilePicker, AudioFilePickOperation {
  final completion = Completer<SelectedAudioFile?>();
  bool cancelled = false;
  bool released = false;
  void complete() => completion.complete(
    SelectedAudioFile(
      filename: 'a.mp3',
      path: '/cache/a.mp3',
      size: 100,
      declaredContentType: 'audio/mpeg',
      release: () async {
        released = true;
      },
    ),
  );
  @override
  Future<SelectedAudioFile?> get result => completion.future;
  @override
  AudioFilePickOperation pick(AudioFileSelectionPolicy policy) => this;
  @override
  Future<void> cancel() async {
    cancelled = true;
  }
}

class _Store implements PendingMediaFileStore, PendingAudioFileStore {
  Completer<void>? copyGate;
  final removed = <String>[];
  @override
  Future<AudioUploadInput> persistAudio(
    AudioUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  }) async {
    await copyGate?.future;
    return _input;
  }

  @override
  Future<void> removeAudio({
    required String accountId,
    required String target,
    required String attachmentId,
  }) async {
    removed.add(attachmentId);
  }

  @override
  Future<void> delete({
    required String accountId,
    required String target,
  }) async {}
  @override
  Future<Map<String, Object?>?> read({
    required String accountId,
    required String target,
  }) async => null;
  @override
  Future<void> write({
    required String accountId,
    required String target,
    required Map<String, Object?> payload,
  }) async {}
  @override
  Future<MediaUploadInput> persist(
    MediaUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  }) async => input;
}
