import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/local_image_marker.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_pending_images.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

const _pending = PendingMediaUpload(
  mediaId: 'known-id',
  purpose: MediaUploadPurpose.richContent,
);
const _ready = UploadedEditorImage(
  mediaId: 'known-id',
  url: 'https://cdn.example.com/ready.webp',
);

void main() {
  testWidgets('取消发布后离开重进仅续查原图片，不恢复发布意图', (tester) async {
    final store = _MemoryStore();
    final firstGateway = _Gateway();
    var state = await _mount(tester, store, firstGateway);
    state.images.add(_input());
    await tester.pump();
    expect(firstGateway.uploads, hasLength(1));
    firstGateway.uploads.single.progress(
      const MediaUploadProgress(
        stage: MediaUploadStage.processing,
        pendingUpload: _pending,
      ),
    );
    await tester.pump();
    final publish = state.images.waitForReady();
    expect(state.images.waitingToPublish, isTrue);
    state.images.cancelPublish();
    expect(await publish, isFalse);
    state.images.pause();
    expect(await state.images.save(), isTrue);
    final saved = jsonEncode(store.payload);
    expect(saved, contains('known-id'));
    expect(saved, isNot(contains('waitingToPublish')));
    await tester.pumpWidget(const SizedBox());

    final secondGateway = _Gateway();
    state = await _mount(tester, store, secondGateway);
    expect(secondGateway.uploads, isEmpty);
    expect(secondGateway.resumedIds, ['known-id']);
    expect(state.images.waitingToPublish, isFalse);
    secondGateway.resumes.single.complete(_ready);
    await tester.pump(const Duration(milliseconds: 300));
    expect(state.images.hasPending, isFalse);
    expect(state.emitted.last, contains(_ready.url));
    expect(state.images.waitingToPublish, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('服务端终态失败清空旧身份，重试重新上传且新进度有效', (tester) async {
    final gateway = _Gateway();
    final state = await _mount(tester, _MemoryStore(), gateway);
    state.images.add(_input());
    await tester.pump();
    final id = state.images.images.keys.single;
    gateway.uploads.single.progress(
      const MediaUploadProgress(
        stage: MediaUploadStage.processing,
        pendingUpload: _pending,
      ),
    );
    gateway.uploads.single.fail(
      const ApiFailure(userMessage: '图片处理失败，请重新选择后上传。'),
    );
    await tester.pump();
    expect(state.images.images[id]!.state.failure, isNotNull);
    expect(state.images.images[id]!.pending, isNull);
    final retry = state.images.retry(id);
    await tester.pump();
    expect(gateway.uploads, hasLength(2));
    expect(gateway.resumes, isEmpty);
    gateway.uploads.last.progress(
      const MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: 50,
        totalBytes: 100,
      ),
    );
    expect(state.images.images[id]!.state.progress!.fraction, .5);
    gateway.uploads.last.complete(_ready);
    await retry;
    await tester.pump();
    expect(state.images.hasPending, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('清除成功发布的本机草稿后，迟到文档通知不能重建草稿', (tester) async {
    final store = _MemoryStore();
    final state = await _mount(tester, store, _Gateway());
    state.editor.controller.replaceText(
      0,
      0,
      '待保存',
      const TextSelection.collapsed(offset: 3),
    );
    await state.editor.flush();
    expect(await state.images.save(), isTrue);
    expect(store.payload, isNotNull);
    await state.images.clear();
    final writes = store.writes;
    state.editor.controller.replaceText(
      3,
      0,
      '迟到',
      const TextSelection.collapsed(offset: 5),
    );
    await state.editor.flush();
    await tester.pump(const Duration(seconds: 1));
    expect(store.payload, isNull);
    expect(store.writes, writes);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('慢读取的恢复结果不能覆盖用户刚输入的正文', (tester) async {
    final store = _MemoryStore()
      ..payload = {'version': 1, 'markdown': '旧草稿', 'images': <Object>[]};
    store.readGate = Completer<void>();
    final state = await _mount(tester, store, _Gateway(), restore: false);
    final restoring = state.images.restore();
    state.editor.controller.replaceText(
      0,
      0,
      '新输入',
      const TextSelection.collapsed(offset: 3),
    );
    await state.editor.flush();
    store.readGate!.complete();
    await restoring;
    expect(state.editor.localMarkdown, '新输入');
    expect(state.images.saveFailure, isNotNull);
    await tester.pump(const Duration(seconds: 1));
    expect(store.payload!['markdown'], '旧草稿');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('恢复缺失文件记录保留可移除占位，不能自动发布', (tester) async {
    final store = _MemoryStore()
      ..payload = {
        'version': 1,
        'markdown': '![图片](${localImageMarkerPrefix}missing)',
        'images': <Object>[],
      };
    final gateway = _Gateway();
    final state = await _mount(tester, store, gateway);
    expect(state.images.pendingCount, 1);
    expect(state.images.images['missing']!.missing, isTrue);
    expect(await state.images.waitForReady(), isFalse);
    expect(gateway.uploads, isEmpty);
    state.images.remove('missing');
    await tester.pump();
    expect(state.images.hasPending, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('旧基线草稿恢复取消后不覆盖当前正文，也不覆盖持久记录', (tester) async {
    final store = _MemoryStore()
      ..payload = {
        'version': 1,
        'baseline': 'old-version',
        'markdown': '旧编辑内容',
        'images': <Object>[],
      };
    var confirms = 0;
    final state = await _mount(
      tester,
      store,
      _Gateway(),
      baseline: 'new-version',
      confirm: () async {
        confirms++;
        return null;
      },
    );
    expect(confirms, 1);
    expect(state.editor.localMarkdown, isEmpty);
    expect(store.payload!['markdown'], '旧编辑内容');
    expect(state.images.saveFailure, isNotNull);
    await tester.pumpWidget(const SizedBox());
  });
}

MediaUploadInput _input() => MediaUploadInput(
  filename: 'test.png',
  bytes: Uint8List.fromList([1, 2, 3]),
);

Future<_HarnessState> _mount(
  WidgetTester tester,
  _MemoryStore store,
  _Gateway gateway, {
  bool restore = true,
  String? baseline,
  Future<bool?> Function()? confirm,
}) async {
  final key = GlobalKey<_HarnessState>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionScopeProvider.overrideWithValue(
          const SessionScope(accountId: 'owner', generation: 1),
        ),
        pendingMediaFileStoreProvider.overrideWithValue(store),
        mediaUploadGatewayPortProvider.overrideWithValue(gateway),
      ],
      child: _Harness(key: key, baseline: baseline, confirm: confirm),
    ),
  );
  final state = key.currentState!;
  if (restore) await state.images.restore();
  await tester.pump();
  return state;
}

class _Harness extends ConsumerStatefulWidget {
  const _Harness({super.key, this.baseline, this.confirm});
  final String? baseline;
  final Future<bool?> Function()? confirm;
  @override
  ConsumerState<_Harness> createState() => _HarnessState();
}

class _HarnessState extends ConsumerState<_Harness> {
  final emitted = <String>[];
  late final RichEditorSession editor;
  late final EditorPendingImages images;
  @override
  void initState() {
    super.initState();
    editor = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
    );
    images = EditorPendingImages(
      ref: ref,
      editor: editor,
      target: 'post:target',
      baseline: widget.baseline,
      confirmRestore: widget.confirm,
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
  @override
  void dispose() {
    images.dispose();
    editor.dispose();
    super.dispose();
  }
}

class _MemoryStore implements PendingMediaFileStore {
  Map<String, Object?>? payload;
  Completer<void>? readGate;
  int writes = 0;
  @override
  Future<MediaUploadInput> persist(
    MediaUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  }) async => _PersistedInput(input);
  @override
  Future<Map<String, Object?>?> read({
    required String accountId,
    required String target,
  }) async {
    await readGate?.future;
    return payload;
  }

  @override
  Future<void> write({
    required String accountId,
    required String target,
    required Map<String, Object?> payload,
  }) async {
    writes++;
    this.payload = Map<String, Object?>.from(
      jsonDecode(jsonEncode(payload)) as Map,
    );
  }

  @override
  Future<void> delete({
    required String accountId,
    required String target,
  }) async {
    payload = null;
  }
}

/// 文件 IO 由独立 store 测试覆盖；这里保持真实 controller 的 materialize 契约。
class _PersistedInput implements MediaUploadInput {
  _PersistedInput(this.input);
  final MediaUploadInput input;
  @override
  String get filename => input.filename;
  @override
  String? get declaredContentType => input.declaredContentType;
  @override
  MediaUploadPurpose get purpose => input.purpose;
  @override
  Uint8List get bytes => input.bytes;
  @override
  Uint8List get requiredBytes => input.requiredBytes;
  @override
  int get byteLength => input.byteLength;
  @override
  bool get isMaterialized => true;
  @override
  String get sourcePath => '/private-test/test.png';
  @override
  PickedMediaSource get source => PickedMediaSource.file(
    filename: filename,
    path: sourcePath,
    length: byteLength,
  );
  @override
  Future<MediaUploadInput> materialize() async => this;
  @override
  MediaUploadInput withPurpose(MediaUploadPurpose purpose) =>
      _PersistedInput(input.withPurpose(purpose));
}

class _Gateway implements MediaUploadGateway, ResumableMediaUploadGateway {
  final uploads = <_Operation>[];
  final resumes = <_Operation>[];
  final resumedIds = <String>[];
  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress)? onProgress,
  }) {
    final operation = _Operation(onProgress);
    uploads.add(operation);
    return operation;
  }

  @override
  MediaUploadOperation<UploadedEditorImage> resumeImageProcessing(
    PendingMediaUpload upload, {
    void Function(MediaUploadProgress)? onProgress,
  }) {
    resumedIds.add(upload.mediaId);
    final operation = _Operation(onProgress);
    resumes.add(operation);
    return operation;
  }
}

class _Operation implements MediaUploadOperation<UploadedEditorImage> {
  _Operation(this.onProgress);
  final void Function(MediaUploadProgress)? onProgress;
  final completer = Completer<UploadedEditorImage>();
  bool cancelled = false;
  void progress(MediaUploadProgress value) => onProgress?.call(value);
  void complete(UploadedEditorImage result) => completer.complete(result);
  void fail(Object error) => completer.completeError(error);
  @override
  Future<UploadedEditorImage> get result => completer.future;
  @override
  void cancel() {
    cancelled = true;
  }
}
