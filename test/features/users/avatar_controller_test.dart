import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/users/application/avatar_controller.dart';
import 'package:wenyousite_mobile/features/users/data/avatar_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

void main() {
  test('取消系统选择后回到空闲且不上传', () async {
    final upload = _FakeMediaUploadTask();
    final avatar = _FakeAvatarRepository();
    final controller = AvatarController(_FakeAvatarPicker(), upload, avatar);

    expect(await _pickAndSet(controller), isNull);

    expect(controller.state.phase, AvatarPhase.idle);
    expect(upload.uploadCalls, 0);
    expect(avatar.setCalls, 0);
  });

  test('选择安全图片后通过共享任务并以 mediaId 设置头像', () async {
    final upload = _FakeMediaUploadTask();
    final avatar = _FakeAvatarRepository();
    final controller = AvatarController(
      _FakeAvatarPicker(input: _jpegInput),
      upload,
      avatar,
    );

    final result = await _pickAndSet(controller);

    expect(result?.avatarUrl, _newAvatarUrl);
    expect(upload.uploadCalls, 1);
    expect(upload.lastInput?.declaredContentType, 'image/jpeg');
    expect(upload.lastInput?.purpose, MediaUploadPurpose.avatar);
    expect(avatar.setCalls, 1);
    expect(avatar.lastMediaId, 'media-1');
    expect(controller.state.phase, AvatarPhase.idle);
  });

  test('共享任务进度映射到头像展示状态', () {
    final controller = AvatarController(
      _FakeAvatarPicker(),
      _FakeMediaUploadTask(),
      _FakeAvatarRepository(),
    );
    const progress = MediaUploadProgress(
      stage: MediaUploadStage.uploading,
      sentBytes: 5,
      totalBytes: 10,
    );

    controller.updateUploadState(
      const MediaUploadTaskState(
        phase: MediaUploadTaskPhase.uploading,
        progress: progress,
      ),
    );

    expect(controller.state.phase, AvatarPhase.uploading);
    expect(controller.state.progress?.fraction, .5);
  });

  test('上传失败保留业务码、请求 ID 与裁剪结果，重试不重新选择', () async {
    final upload = _FakeMediaUploadTask(
      onUpload: (_) async => null,
      failure: const MediaUploadTaskState(
        phase: MediaUploadTaskPhase.failed,
        failure: MediaUploadFailure(
          userMessage: '上传过于频繁，请稍后重试。',
          canRetry: true,
          businessCode: 42900,
          requestId: 'upload-request-id',
        ),
      ),
    );
    final picker = _FakeAvatarPicker(input: _jpegInput);
    final controller = AvatarController(
      picker,
      upload,
      _FakeAvatarRepository(),
    );

    expect(await _pickAndSet(controller), isNull);

    expect(controller.state.phase, AvatarPhase.failed);
    expect(controller.state.pendingMediaId, isNull);
    expect(controller.state.hasPendingInput, isTrue);
    expect(controller.state.failure?.businessCode, 42900);
    expect(controller.state.failure?.requestId, 'upload-request-id');
    await controller.retry();
    expect(picker.calls, 1);
    expect(upload.uploadCalls, 2);
  });

  test('设置端点失败保留 mediaId，重试不重复上传', () async {
    var failOnce = true;
    final upload = _FakeMediaUploadTask();
    final avatar = _FakeAvatarRepository(
      onSet: (_) async {
        if (failOnce) {
          failOnce = false;
          throw const ApiFailure(
            userMessage: '头像暂时无法设置。',
            requestId: 'avatar-request-id',
          );
        }
        return _setResult;
      },
    );
    final controller = AvatarController(
      _FakeAvatarPicker(input: _jpegInput),
      upload,
      avatar,
    );

    expect(await _pickAndSet(controller), isNull);
    expect(controller.state.phase, AvatarPhase.failed);
    expect(controller.state.pendingMediaId, 'media-1');
    expect(controller.state.failure?.requestId, 'avatar-request-id');

    final result = await controller.retry();
    expect(result?.avatarUrl, _newAvatarUrl);
    expect(upload.uploadCalls, 1);
    expect(avatar.setCalls, 2);
  });

  test('移除失败保留请求 ID 并可重试', () async {
    var failOnce = true;
    final avatar = _FakeAvatarRepository(
      onRemove: () async {
        if (failOnce) {
          failOnce = false;
          throw const ApiFailure(
            userMessage: '移除失败。',
            requestId: 'remove-request-id',
          );
        }
        return _removeResult;
      },
    );
    final controller = AvatarController(
      _FakeAvatarPicker(),
      _FakeMediaUploadTask(),
      avatar,
    );

    expect(await controller.remove(), isNull);
    expect(controller.state.failedOperation, AvatarOperation.remove);
    expect(controller.state.failure?.requestId, 'remove-request-id');

    expect((await controller.retry())?.avatarUrl, isNull);
    expect(avatar.removeCalls, 2);
  });

  test('头像策略拒绝 GIF 且不进入上传任务', () async {
    final upload = _FakeMediaUploadTask();
    final controller = AvatarController(
      _FakeAvatarPicker(input: _gifInput),
      upload,
      _FakeAvatarRepository(),
    );

    expect(await _pickAndSet(controller), isNull);

    expect(controller.state.phase, AvatarPhase.failed);
    expect(controller.state.failure?.userMessage, contains('JPG、PNG 和 WebP'));
    expect(upload.uploadCalls, 0);
  });

  test('扩展名和声明伪装成 JPEG 的 GIF 仍被拒绝', () async {
    final upload = _FakeMediaUploadTask();
    final controller = AvatarController(
      _FakeAvatarPicker(
        input: MediaUploadInput(
          filename: 'avatar.jpg',
          declaredContentType: 'image/jpeg',
          bytes: Uint8List.fromList('GIF89a'.codeUnits),
        ),
      ),
      upload,
      _FakeAvatarRepository(),
    );

    expect(await _pickAndSet(controller), isNull);
    expect(controller.state.failure?.userMessage, contains('JPG、PNG 和 WebP'));
    expect(upload.uploadCalls, 0);
  });

  test('取消共享上传后 Future 立即结束且不设置头像', () async {
    final pendingUpload = Completer<UploadedEditorImage?>();
    final upload = _FakeMediaUploadTask(
      onUpload: (_) => pendingUpload.future,
      onCancel: () => pendingUpload.complete(),
    );
    final avatar = _FakeAvatarRepository();
    final controller = AvatarController(
      _FakeAvatarPicker(input: _jpegInput),
      upload,
      avatar,
    );

    final input = await controller.pickImage();
    final pending = controller.setImage(input!);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.previewBytes, input.bytes);
    controller.cancelUpload();

    expect(await pending, isNull);
    expect(upload.cancelCalls, 1);
    expect(controller.state.phase, AvatarPhase.idle);
    expect(avatar.setCalls, 0);
  });

  testWidgets('内层应用组合可绑定头像选择与共享上传端口', (tester) async {
    final gateway = _FakeMediaUploadGateway();
    final avatar = _FakeAvatarRepository();

    await tester.pumpWidget(
      ProviderScope(
        child: ProviderScope(
          overrides: [
            avatarImagePickerPortProvider.overrideWithValue(
              _FakeAvatarPicker(input: _jpegInput),
            ),
            mediaUploadGatewayPortProvider.overrideWithValue(gateway),
            avatarRepositoryProvider.overrideWithValue(avatar),
          ],
          child: const MaterialApp(home: _AvatarProviderProbe()),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('set-avatar')));
    await tester.pumpAndSettle();

    expect(find.text('idle'), findsOneWidget);
    expect(gateway.uploadCalls, 1);
    expect(avatar.setCalls, 1);
  });
}

class _AvatarProviderProbe extends ConsumerWidget {
  const _AvatarProviderProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(avatarControllerProvider);
    return TextButton(
      key: const Key('set-avatar'),
      onPressed: () => _pickAndSet(ref.read(avatarControllerProvider.notifier)),
      child: Text(state.phase.name),
    );
  }
}

Future<AvatarUpdateResult?> _pickAndSet(AvatarController controller) async {
  final input = await controller.pickImage();
  if (input == null) return null;
  return controller.setImage(input);
}

class _FakeAvatarPicker implements AvatarImagePicker {
  _FakeAvatarPicker({this.input});

  final MediaUploadInput? input;
  int calls = 0;

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async {
    calls += 1;
    return input;
  }
}

class _FakeMediaUploadTask implements MediaUploadTask {
  _FakeMediaUploadTask({this.onUpload, this.onCancel, this.failure});

  final Future<UploadedEditorImage?> Function(MediaUploadInput input)? onUpload;
  final void Function()? onCancel;
  final MediaUploadTaskState? failure;
  int uploadCalls = 0;
  int cancelCalls = 0;
  int resetCalls = 0;
  MediaUploadInput? lastInput;

  @override
  MediaUploadTaskState state = const MediaUploadTaskState();

  @override
  Future<UploadedEditorImage?> uploadInput(MediaUploadInput input) async {
    uploadCalls += 1;
    lastInput = input;
    final result =
        await (onUpload?.call(input) ??
            Future<UploadedEditorImage?>.value(
              const UploadedEditorImage(mediaId: 'media-1', url: _newAvatarUrl),
            ));
    final failureState = failure;
    if (failureState != null) state = failureState;
    return result;
  }

  @override
  void cancel() {
    cancelCalls += 1;
    state = const MediaUploadTaskState();
    onCancel?.call();
  }

  @override
  void reset() {
    resetCalls += 1;
    state = const MediaUploadTaskState();
  }
}

class _FakeMediaUploadGateway implements MediaUploadGateway {
  int uploadCalls = 0;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    uploadCalls += 1;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    return _CompletedUploadOperation(
      const UploadedEditorImage(mediaId: 'media-1', url: _newAvatarUrl),
    );
  }
}

class _CompletedUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  _CompletedUploadOperation(UploadedEditorImage result)
    : result = Future.value(result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

class _FakeAvatarRepository implements AvatarRepository {
  _FakeAvatarRepository({this.onSet, this.onRemove});

  final Future<AvatarUpdateResult> Function(String mediaId)? onSet;
  final Future<AvatarUpdateResult> Function()? onRemove;
  int setCalls = 0;
  int removeCalls = 0;
  String? lastMediaId;

  @override
  Future<AvatarUpdateResult> setAvatar(String mediaId) async {
    setCalls += 1;
    lastMediaId = mediaId;
    return onSet?.call(mediaId) ?? _setResult;
  }

  @override
  Future<AvatarUpdateResult> removeAvatar() async {
    removeCalls += 1;
    return onRemove?.call() ?? _removeResult;
  }
}

final _jpegInput = MediaUploadInput(
  filename: 'avatar.jpg',
  declaredContentType: 'image/jpeg',
  bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 0, 1]),
);

final _gifInput = MediaUploadInput(
  filename: 'avatar.gif',
  declaredContentType: 'image/gif',
  bytes: Uint8List.fromList('GIF89a'.codeUnits),
);

const _newAvatarUrl = 'https://cdn.example.com/avatar.webp';
final _setResult = AvatarUpdateResult(
  avatarUrl: _newAvatarUrl,
  updatedAt: DateTime.utc(2026, 8, 10, 11),
);
final _removeResult = AvatarUpdateResult(
  avatarUrl: null,
  updatedAt: DateTime.utc(2026, 8, 10, 12),
);
