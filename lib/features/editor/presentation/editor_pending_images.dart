import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class EditorPendingImage {
  EditorPendingImage(this.id, this.input);
  final String id;
  MediaUploadInput? input;
  final Object taskId = Object();
  MediaUploadTaskState state = const MediaUploadTaskState();
  PendingMediaUpload? pending;
  UploadedEditorImage? result;
  ProviderSubscription<MediaUploadTaskState>? subscription;
  MediaUploadTaskController? controller;
  int generation = 0;
  bool active = false;
  bool persisted = false;
  Future<MediaUploadInput>? persisting;
  bool missing = false;
}

/// 协调一个正文编辑目标的本机附件；发布意图只在当前页面内存中存在。
class EditorPendingImages extends ChangeNotifier {
  EditorPendingImages({
    required this.ref,
    required this.editor,
    required this.target,
    this.baseline,
    this.confirmRestore,
  }) : scope = ref.read(sessionScopeProvider),
       accountId = ref.read(sessionScopeProvider).accountId {
    editor.addListener(_documentChanged);
  }

  final WidgetRef ref;
  final RichEditorSession editor;
  final String target;
  final Object scope;
  final String? accountId;
  final String? baseline;
  final Future<bool?> Function()? confirmRestore;
  final Map<String, EditorPendingImage> images = {};
  bool _disposed = false;
  bool _scheduled = false;
  bool _restoring = false;
  bool _paused = false;
  bool _cleared = false;
  bool _saveEnabled = false;
  bool get restoring => _restoring;
  Timer? _saveTimer;
  Future<void> _saveQueue = Future.value();
  String? saveFailure;
  bool _saved = false;
  String get localSaveLabel => saveFailure != null
      ? '本机保存失败'
      : _saved
      ? '已保存到本机'
      : '正在保存到本机…';
  bool waitingToPublish = false;
  int _publishGeneration = 0;
  int get publishGeneration => _publishGeneration;
  bool isPublishIntentCurrent(int generation) =>
      generation == _publishGeneration && isCurrent;
  Completer<bool>? _ready;

  Set<String> get ids => editor.localImageIds;
  bool get hasPending => ids.isNotEmpty;
  int get pendingCount => ids.length;
  bool get isCurrent => !_disposed && ref.read(sessionScopeProvider) == scope;
  String? get _accountId => accountId;

  Future<void> restore() async {
    final owner = _accountId;
    if (owner == null) return;
    _restoring = true;
    final initialDocument = editor.controller.document
        .toDelta()
        .toJson()
        .toString();
    notifyListeners();
    try {
      final payload = await ref
          .read(pendingMediaFileStoreProvider)
          .read(accountId: owner, target: target);
      if (!isCurrent || payload == null) return;
      if (editor.controller.document.toDelta().toJson().toString() !=
          initialDocument) {
        saveFailure = '本机草稿尚未恢复，请重新打开编辑器后重试。';
        return;
      }
      if (baseline != null && payload['baseline'] != baseline) {
        final decision = await confirmRestore?.call();
        if (decision != true || !isCurrent) {
          if (isCurrent && decision == false) {
            await ref
                .read(pendingMediaFileStoreProvider)
                .delete(accountId: owner, target: target);
          } else {
            saveFailure = '本机草稿尚未恢复，请重新打开编辑器。';
          }
          return;
        }
      }
      final markdown = payload['markdown'];
      if (markdown is! String) return;
      for (final entry in payload['images'] as List? ?? const []) {
        if (entry is! Map || entry['id'] is! String) continue;
        final input = entry['input'] is Map
            ? decodePendingMediaInput(
                Map<String, Object?>.from(entry['input'] as Map),
              )
            : null;
        final item = EditorPendingImage(entry['id'] as String, input)
          ..persisted = input != null
          ..missing = input == null;
        if (entry['pending'] is Map) {
          item.pending = PendingMediaUpload.fromJson(
            Map<String, Object?>.from(entry['pending'] as Map),
          );
        }
        images[item.id] = item;
      }
      editor.applyExternalMarkdown(
        markdown,
        mediaDisplays: mediaDisplaysFromJson(payload['mediaDisplays']),
      );
      if (!hasPending) editor.onMarkdownChanged(markdown);
      for (final id in ids) {
        final item = images.putIfAbsent(
          id,
          () => EditorPendingImage(id, null)..missing = true,
        );
        if (item.input != null) unawaited(_run(item));
      }
    } on Object {
      if (isCurrent) saveFailure = '本机草稿读取失败，请重试后再编辑。';
    } finally {
      _restoring = false;
      _saveEnabled = saveFailure == null;
      if (!_disposed) notifyListeners();
    }
  }

  void add(MediaUploadInput input) {
    if (!isCurrent || waitingToPublish) return;
    final item = EditorPendingImage(const Uuid().v4(), input);
    images[item.id] = item;
    editor.insertLocalImage(item.id);
    unawaited(_run(item));
    notifyListeners();
  }

  Future<void> retry(String id) async {
    final item = images[id];
    if (item == null || item.active || waitingToPublish) return;
    await _run(item);
  }

  void remove(String id) {
    if (waitingToPublish) return;
    final item = images[id];
    if (item != null) _pauseItem(item);
    editor.removeLocalImage(id);
    unawaited(editor.flush());
  }

  Future<void> _run(EditorPendingImage item) async {
    if (!isCurrent ||
        _paused ||
        item.active ||
        item.input == null ||
        !ids.contains(item.id)) {
      return;
    }
    final generation = ++item.generation;
    item.active = true;
    item.missing = false;
    item.state = const MediaUploadTaskState(
      phase: MediaUploadTaskPhase.preparing,
    );
    notifyListeners();
    try {
      final owner = _accountId;
      if (!item.persisted && owner != null) {
        item.persisting = ref
            .read(pendingMediaFileStoreProvider)
            .persist(
              item.input!,
              accountId: owner,
              target: target,
              attachmentId: item.id,
            )
            .then((input) {
              item.input = input;
              item.persisted = true;
              return input;
            });
        await item.persisting;
      }
      if (!isCurrent ||
          generation != item.generation ||
          !ids.contains(item.id)) {
        return;
      }
      if (!await save()) throw StateError('本机草稿保存失败');
      if (!isCurrent || generation != item.generation) return;
      item.subscription?.close();
      item.subscription = ref.listenManual(
        mediaUploadTaskControllerProvider(item.taskId),
        (_, state) {
          if (!isCurrent || item.generation != generation) return;
          item.state = state;
          item.pending = state.failure != null
              ? state.pendingUpload
              : state.pendingUpload ?? item.pending;
          _scheduleSave();
          _checkReady();
          notifyListeners();
        },
      );
      final controller = ref.read(
        mediaUploadTaskControllerProvider(item.taskId).notifier,
      );
      item.controller = controller;
      final result = item.pending == null
          ? await controller.uploadInput(item.input!)
          : await controller.resumeUpload(item.input!, item.pending!);
      if (!isCurrent ||
          generation != item.generation ||
          !ids.contains(item.id)) {
        return;
      }
      item.active = false;
      item.state = ref.read(mediaUploadTaskControllerProvider(item.taskId));
      item.pending = item.state.failure != null
          ? item.state.pendingUpload
          : item.state.pendingUpload ?? item.pending;
      if (result != null) {
        item.result = result;
        editor.resolveLocalImage(item.id, result);
        await editor.flush();
      }
    } on Object {
      if (isCurrent && generation == item.generation) {
        item.active = false;
        item.missing = true;
        saveFailure = '图片未能保存到本机，请重试或移除。';
      }
    } finally {
      if (isCurrent && generation == item.generation) {
        item.active = false;
        _checkReady();
        _scheduleSave();
        notifyListeners();
      }
    }
  }

  void _documentChanged() {
    if (_disposed || _scheduled || _restoring) return;
    _scheduled = true;
    scheduleMicrotask(() {
      _scheduled = false;
      if (!isCurrent) return;
      for (final item in images.values) {
        if (!ids.contains(item.id)) {
          if (item.active) _pauseItem(item);
        } else if (item.result != null) {
          editor.resolveLocalImage(item.id, item.result!);
          unawaited(editor.flush());
        } else if (!item.active &&
            item.state.failure == null &&
            !item.missing &&
            !_paused) {
          unawaited(_run(item));
        }
      }
      _checkReady();
      _scheduleSave();
      notifyListeners();
    });
  }

  Future<bool> waitForReady() async {
    if (waitingToPublish || !isCurrent) return false;
    if (!hasPending) return true;
    final generation = ++_publishGeneration;
    waitingToPublish = true;
    _ready = Completer<bool>();
    _checkReady();
    notifyListeners();
    final ready = await _ready!.future;
    return ready && isCurrent && generation == _publishGeneration;
  }

  void cancelPublish() {
    _publishGeneration++;
    waitingToPublish = false;
    if (_ready?.isCompleted == false) _ready!.complete(false);
    if (!_disposed) notifyListeners();
  }

  void finishWaiting() {
    waitingToPublish = false;
    if (!_disposed) notifyListeners();
  }

  void _checkReady() {
    if (!waitingToPublish || _ready?.isCompleted != false) return;
    if (ids.any(
      (id) => images[id]?.missing != false || images[id]?.state.failure != null,
    )) {
      cancelPublish();
    } else if (!hasPending) {
      _ready!.complete(true);
    }
  }

  void _scheduleSave() {
    if (_restoring || _disposed || _cleared || !_saveEnabled) return;
    _saved = false;
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(save()),
    );
  }

  Future<bool> save() async {
    final owner = _accountId;
    if (owner == null ||
        !isCurrent ||
        _restoring ||
        _cleared ||
        !_saveEnabled) {
      return saveFailure == null;
    }
    _saveTimer?.cancel();
    try {
      await Future.wait([
        for (final item in images.values)
          if (ids.contains(item.id) && item.persisting != null)
            item.persisting!,
      ]);
    } on Object {
      saveFailure = '图片未能保存到本机，请先不要退出。';
      return false;
    }
    if (!isCurrent || _cleared) return false;
    final payload = <String, Object?>{
      'version': 1,
      if (baseline != null) 'baseline': baseline,
      'markdown': editor.localMarkdown,
      'mediaDisplays': mediaDisplaysToJson(editor.mediaDisplays),
      'images': [
        for (final item in images.values)
          if (ids.contains(item.id))
            {
              'id': item.id,
              if (item.persisted && item.input != null)
                'input': encodePendingMediaInput(item.input!),
              if (item.pending != null) 'pending': item.pending!.toJson(),
            },
      ],
    };
    final store = ref.read(pendingMediaFileStoreProvider);
    var saved = false;
    _saveQueue = _saveQueue.then((_) async {
      try {
        await store.write(accountId: owner, target: target, payload: payload);
        saveFailure = null;
        _saved = true;
        saved = true;
      } on Object {
        saveFailure = '本机草稿保存失败，请先不要退出。';
      } finally {
        if (!_disposed) notifyListeners();
      }
    });
    await _saveQueue;
    return saved;
  }

  Future<bool> clear({bool published = true}) async {
    _cleared = true;
    _paused = true;
    _saveTimer?.cancel();
    final owner = _accountId;
    final store = owner == null
        ? null
        : ref.read(pendingMediaFileStoreProvider);
    await _saveQueue;
    if (owner != null && store != null) {
      try {
        await store.delete(accountId: owner, target: target);
      } on Object {
        if (!published) {
          _cleared = false;
          _paused = false;
          saveFailure = '本机草稿清理失败，请重试。';
          return false;
        }
        saveFailure = '内容已发布，本机草稿未能清理；请勿再次发布。';
        try {
          await store.write(
            accountId: owner,
            target: target,
            payload: {'version': 1, 'completed': true},
          );
        } on Object {
          // 结果已提交，不将清理失败转换为再次发布入口。
        }
        return false;
      }
    }
    return true;
  }

  void startNewDraft() {
    images.clear();
    _cleared = false;
    _paused = false;
    _saveEnabled = true;
  }

  void pause() {
    _paused = true;
    cancelPublish();
    for (final item in images.values) {
      _pauseItem(item);
    }
  }

  void resume() {
    if (!isCurrent || _cleared) return;
    _paused = false;
    _documentChanged();
  }

  void _pauseItem(EditorPendingImage item) {
    if (item.subscription != null && isCurrent) {
      item.pending =
          ref
              .read(mediaUploadTaskControllerProvider(item.taskId))
              .pendingUpload ??
          item.pending;
    }
    item.generation++;
    item.controller?.pause();
    item.subscription?.close();
    item.subscription = null;
    item.active = false;
  }

  @override
  void dispose() {
    _disposed = true;
    _publishGeneration++;
    if (_ready?.isCompleted == false) _ready!.complete(false);
    for (final item in images.values) {
      item.generation++;
      item.subscription?.close();
    }
    _saveTimer?.cancel();
    editor.removeListener(_documentChanged);
    super.dispose();
  }
}
