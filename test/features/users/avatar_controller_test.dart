import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/users/application/avatar_controller.dart';
import 'package:wenyousite_mobile/features/users/data/avatar_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

void main() {
  test('取消系统选择后回到空闲且不上传', () async {
    final picker = _FakeAvatarPicker();
    final media = _FakeMediaRepository();
    final avatar = _FakeAvatarRepository();
    final controller = AvatarController(picker, media, avatar);

    expect(await controller.chooseAndSet(), isNull);

    expect(controller.state.phase, AvatarPhase.idle);
    expect(media.uploadCalls, 0);
    expect(avatar.setCalls, 0);
  });

  test('选择安全图片后复用媒体管线并以 mediaId 设置头像', () async {
    final picker = _FakeAvatarPicker(input: _jpegInput);
    final media = _FakeMediaRepository();
    final avatar = _FakeAvatarRepository();
    final controller = AvatarController(picker, media, avatar);

    final result = await controller.chooseAndSet();

    expect(result?.avatarUrl, _newAvatarUrl);
    expect(media.uploadCalls, 1);
    expect(media.lastInput?.declaredContentType, 'image/jpeg');
    expect(avatar.setCalls, 1);
    expect(avatar.lastMediaId, 'media-1');
    expect(controller.state.phase, AvatarPhase.idle);
  });

  test('设置端点失败保留 mediaId，重试不重复上传', () async {
    var failOnce = true;
    final picker = _FakeAvatarPicker(input: _jpegInput);
    final media = _FakeMediaRepository();
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
    final controller = AvatarController(picker, media, avatar);

    expect(await controller.chooseAndSet(), isNull);
    expect(controller.state.phase, AvatarPhase.failed);
    expect(controller.state.pendingMediaId, 'media-1');
    expect(controller.state.failure?.requestId, 'avatar-request-id');

    final result = await controller.retry();
    expect(result?.avatarUrl, _newAvatarUrl);
    expect(media.uploadCalls, 1);
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
      _FakeMediaRepository(),
      avatar,
    );

    expect(await controller.remove(), isNull);
    expect(controller.state.failedOperation, AvatarOperation.remove);
    expect(controller.state.failure?.requestId, 'remove-request-id');

    expect((await controller.retry())?.avatarUrl, isNull);
    expect(avatar.removeCalls, 2);
  });

  test('头像策略拒绝 GIF 且不进入上传管线', () async {
    final media = _FakeMediaRepository();
    final controller = AvatarController(
      _FakeAvatarPicker(input: _gifInput),
      media,
      _FakeAvatarRepository(),
    );

    expect(await controller.chooseAndSet(), isNull);

    expect(controller.state.phase, AvatarPhase.failed);
    expect(controller.state.failure?.userMessage, contains('JPG、PNG 和 WebP'));
    expect(media.uploadCalls, 0);
  });

  test('扩展名和声明伪装成 JPEG 的 GIF 仍被拒绝', () async {
    final media = _FakeMediaRepository();
    final controller = AvatarController(
      _FakeAvatarPicker(
        input: MediaUploadInput(
          filename: 'avatar.jpg',
          declaredContentType: 'image/jpeg',
          bytes: Uint8List.fromList('GIF89a'.codeUnits),
        ),
      ),
      media,
      _FakeAvatarRepository(),
    );

    expect(await controller.chooseAndSet(), isNull);
    expect(controller.state.failure?.userMessage, contains('JPG、PNG 和 WebP'));
    expect(media.uploadCalls, 0);
  });

  test('用户取消直传后回到空闲且不设置头像', () async {
    final media = _FakeMediaRepository(
      onUpload: (_, cancelToken, _) async {
        await cancelToken!.whenCancel;
        throw cancelToken.cancelError!;
      },
    );
    final avatar = _FakeAvatarRepository();
    final controller = AvatarController(
      _FakeAvatarPicker(input: _jpegInput),
      media,
      avatar,
    );

    final pending = controller.chooseAndSet();
    await Future<void>.delayed(Duration.zero);
    controller.cancelUpload();
    expect(await pending, isNull);

    expect(controller.state.phase, AvatarPhase.idle);
    expect(avatar.setCalls, 0);
  });
}

class _FakeAvatarPicker implements AvatarImagePicker {
  _FakeAvatarPicker({this.input});

  final MediaUploadInput? input;

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async => input;
}

class _FakeMediaRepository implements MediaUploadRepository {
  _FakeMediaRepository({this.onUpload});

  final Future<UploadedEditorImage> Function(
    MediaUploadInput input,
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  )?
  onUpload;
  int uploadCalls = 0;
  MediaUploadInput? lastInput;

  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) async {
    uploadCalls += 1;
    lastInput = input;
    if (onUpload != null) return onUpload!(input, cancelToken, onProgress);
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    return const UploadedEditorImage(mediaId: 'media-1', url: _newAvatarUrl);
  }
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
