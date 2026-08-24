import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/users/application/profile_cover_controller.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

void main() {
  test('选择一张图片后并行上传双画幅并原子绑定', () async {
    final webTask = _FakeUploadTask([_uploaded('web-media')]);
    final mobileTask = _FakeUploadTask([_uploaded('mobile-media')]);
    final repository = _FakeProfileCoverRepository();
    final controller = ProfileCoverController(
      const _FakePicker(null),
      webTask,
      mobileTask,
      repository,
    );

    final result = await controller.setSelection(_selection);

    expect(result?.profileCover?.mobile, isNotNull);
    expect(webTask.inputs.single.filename, 'web.png');
    expect(mobileTask.inputs.single.filename, 'mobile.png');
    expect(webTask.inputs.single.purpose, MediaUploadPurpose.profileCover);
    expect(mobileTask.inputs.single.purpose, MediaUploadPurpose.profileCover);
    expect(repository.lastWebMediaId, 'web-media');
    expect(repository.lastMobileMediaId, 'mobile-media');
    expect(controller.state.phase, ProfileCoverPhase.idle);
  });

  test('双画幅上传同时启动并在等待期间保留手机端本地预览', () async {
    final webCompletion = Completer<UploadedEditorImage?>();
    final mobileCompletion = Completer<UploadedEditorImage?>();
    final webTask = _DeferredUploadTask(webCompletion);
    final mobileTask = _DeferredUploadTask(mobileCompletion);
    final repository = _FakeProfileCoverRepository();
    final controller = ProfileCoverController(
      const _FakePicker(null),
      webTask,
      mobileTask,
      repository,
    );

    final result = controller.setSelection(_selection);
    await Future<void>.delayed(Duration.zero);

    expect(webTask.inputs, hasLength(1));
    expect(mobileTask.inputs, hasLength(1));
    expect(controller.state.previewBytes, _selection.mobile.bytes);
    expect(repository.setCalls, 0);

    webCompletion.complete(_uploaded('web-media'));
    mobileCompletion.complete(_uploaded('mobile-media'));
    expect(await result, isNotNull);
    expect(repository.setCalls, 1);
  });

  test('移动画幅上传失败保留已上传 Web mediaId，重试不重复 Web 上传', () async {
    final webTask = _FakeUploadTask([_uploaded('web-media')]);
    final mobileTask = _FakeUploadTask([
      const MediaUploadFailure(userMessage: '移动背景上传失败', canRetry: true),
      _uploaded('mobile-media'),
    ]);
    final repository = _FakeProfileCoverRepository();
    final controller = ProfileCoverController(
      const _FakePicker(null),
      webTask,
      mobileTask,
      repository,
    );

    expect(await controller.setSelection(_selection), isNull);
    expect(controller.state.pendingWebMediaId, 'web-media');
    expect(controller.state.failure?.userMessage, '移动背景上传失败');

    expect(await controller.retry(), isNotNull);
    expect(webTask.inputs, hasLength(1));
    expect(mobileTask.inputs, hasLength(2));
  });

  test('绑定失败保留双 mediaId，重试只重新调用设置端点', () async {
    final webTask = _FakeUploadTask([_uploaded('web-media')]);
    final mobileTask = _FakeUploadTask([_uploaded('mobile-media')]);
    final repository = _FakeProfileCoverRepository(failSetOnce: true);
    final controller = ProfileCoverController(
      const _FakePicker(null),
      webTask,
      mobileTask,
      repository,
    );

    expect(await controller.setSelection(_selection), isNull);
    expect(controller.state.pendingMobileMediaId, 'mobile-media');

    expect(await controller.retry(), isNotNull);
    expect(repository.setCalls, 2);
    expect(webTask.inputs, hasLength(1));
    expect(mobileTask.inputs, hasLength(1));
  });

  test('移除失败后可重试并采用服务端双清理结果', () async {
    final repository = _FakeProfileCoverRepository(failRemoveOnce: true);
    final controller = ProfileCoverController(
      const _FakePicker(null),
      _FakeUploadTask(const []),
      _FakeUploadTask(const []),
      repository,
    );

    expect(await controller.remove(), isNull);
    expect(controller.state.failedOperation, ProfileCoverOperation.remove);

    final result = await controller.retry();
    expect(result?.profileCover, isNull);
    expect(repository.removeCalls, 2);
  });
}

class _FakePicker implements ProfileCoverImagePicker {
  const _FakePicker(this.selection);

  final MediaUploadInput? selection;

  @override
  Future<MediaUploadInput?> pickProfileCoverFromGallery() async => selection;
}

class _FakeUploadTask implements MediaUploadTask {
  _FakeUploadTask(this.outcomes);

  final List<Object> outcomes;
  final inputs = <MediaUploadInput>[];
  var _index = 0;
  MediaUploadTaskState _state = const MediaUploadTaskState();

  @override
  MediaUploadTaskState get state => _state;

  @override
  Future<UploadedEditorImage?> uploadInput(MediaUploadInput input) async {
    inputs.add(input);
    final outcome = outcomes[_index++];
    if (outcome is MediaUploadFailure) {
      _state = MediaUploadTaskState(
        phase: MediaUploadTaskPhase.failed,
        failure: outcome,
      );
      return null;
    }
    _state = const MediaUploadTaskState();
    return outcome as UploadedEditorImage;
  }

  @override
  void cancel() => _state = const MediaUploadTaskState();

  @override
  void reset() => _state = const MediaUploadTaskState();
}

class _DeferredUploadTask implements MediaUploadTask {
  _DeferredUploadTask(this.completion);

  final Completer<UploadedEditorImage?> completion;
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadTaskState get state =>
      const MediaUploadTaskState(phase: MediaUploadTaskPhase.uploading);

  @override
  Future<UploadedEditorImage?> uploadInput(MediaUploadInput input) {
    inputs.add(input);
    return completion.future;
  }

  @override
  void cancel() {}

  @override
  void reset() {}
}

class _FakeProfileCoverRepository implements ProfileCoverRepository {
  _FakeProfileCoverRepository({
    this.failSetOnce = false,
    this.failRemoveOnce = false,
  });

  bool failSetOnce;
  bool failRemoveOnce;
  int setCalls = 0;
  int removeCalls = 0;
  String? lastWebMediaId;
  String? lastMobileMediaId;

  @override
  Future<ProfileCoverUpdateResult> setProfileCover({
    required String webMediaId,
    required String mobileMediaId,
  }) async {
    setCalls += 1;
    lastWebMediaId = webMediaId;
    lastMobileMediaId = mobileMediaId;
    if (failSetOnce) {
      failSetOnce = false;
      throw const ApiFailure(userMessage: '设置失败', requestId: 'cover-request');
    }
    return ProfileCoverUpdateResult(
      profileCover: const ProfileCoverModel(
        web: ProfileCoverVariant(url: 'https://cdn.example.com/web.webp'),
        mobile: ProfileCoverVariant(url: 'https://cdn.example.com/mobile.webp'),
      ),
      updatedAt: DateTime.utc(2026, 8, 16),
    );
  }

  @override
  Future<ProfileCoverUpdateResult> removeProfileCover() async {
    removeCalls += 1;
    if (failRemoveOnce) {
      failRemoveOnce = false;
      throw const ApiFailure(userMessage: '移除失败');
    }
    return ProfileCoverUpdateResult(
      profileCover: null,
      updatedAt: DateTime.utc(2026, 8, 16),
    );
  }
}

final _selection = ProfileCoverImageSelection(
  web: MediaUploadInput(
    filename: 'web.png',
    bytes: Uint8List.fromList([1]),
    purpose: MediaUploadPurpose.profileCover,
  ),
  mobile: MediaUploadInput(
    filename: 'mobile.png',
    bytes: Uint8List.fromList([2]),
    purpose: MediaUploadPurpose.profileCover,
  ),
);

UploadedEditorImage _uploaded(String mediaId) {
  return UploadedEditorImage(
    mediaId: mediaId,
    url: 'https://cdn.example.com/$mediaId.webp',
  );
}
