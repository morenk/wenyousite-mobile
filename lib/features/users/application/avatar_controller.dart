import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_policy.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/users/data/avatar_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

enum AvatarPhase { idle, picking, uploading, setting, removing, failed }

enum AvatarOperation { set, remove }

class AvatarState {
  const AvatarState({
    this.phase = AvatarPhase.idle,
    this.progress,
    this.failure,
    this.failedOperation,
    this.pendingMediaId,
  });

  final AvatarPhase phase;
  final MediaUploadProgress? progress;
  final ApiFailure? failure;
  final AvatarOperation? failedOperation;
  final String? pendingMediaId;

  bool get isBusy => switch (phase) {
    AvatarPhase.picking ||
    AvatarPhase.uploading ||
    AvatarPhase.setting ||
    AvatarPhase.removing => true,
    AvatarPhase.idle || AvatarPhase.failed => false,
  };
}

class AvatarController extends StateNotifier<AvatarState> {
  AvatarController(this._picker, this._uploadTask, this._avatarRepository)
    : super(const AvatarState());

  final AvatarImagePicker _picker;
  final MediaUploadTask _uploadTask;
  final AvatarRepository _avatarRepository;

  Future<AvatarUpdateResult?> chooseAndSet() async {
    if (state.isBusy) return null;
    _uploadTask.reset();
    state = const AvatarState(phase: AvatarPhase.picking);
    try {
      final selected = await _picker.pickAvatarFromGallery();
      if (!mounted) return null;
      if (selected == null) {
        state = const AvatarState();
        return null;
      }
      final input = validateAvatarImageInput(selected);
      state = const AvatarState(phase: AvatarPhase.uploading);
      final image = await _uploadTask.uploadInput(input);
      if (!mounted) return null;
      if (image == null) {
        final failure = _uploadTask.state.failure;
        _uploadTask.reset();
        if (failure == null) {
          state = const AvatarState();
          return null;
        }
        state = AvatarState(
          phase: AvatarPhase.failed,
          failedOperation: AvatarOperation.set,
          failure: ApiFailure(
            userMessage: failure.userMessage,
            businessCode: failure.businessCode,
            requestId: failure.requestId,
          ),
        );
        return null;
      }
      return _setUploadedMedia(image.mediaId);
    } on Object catch (error) {
      if (!mounted) return null;
      _uploadTask.reset();
      state = AvatarState(
        phase: AvatarPhase.failed,
        failedOperation: AvatarOperation.set,
        failure: _asFailure(error, '头像没有上传成功，请稍后重试。'),
      );
      return null;
    }
  }

  Future<AvatarUpdateResult?> remove() async {
    if (state.isBusy) return null;
    state = const AvatarState(phase: AvatarPhase.removing);
    try {
      final result = await _avatarRepository.removeAvatar();
      if (!mounted) return null;
      state = const AvatarState();
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = AvatarState(
        phase: AvatarPhase.failed,
        failedOperation: AvatarOperation.remove,
        failure: _asFailure(error, '头像没有移除成功，请稍后重试。'),
      );
      return null;
    }
  }

  Future<AvatarUpdateResult?> retry() {
    if (state.isBusy) return Future<AvatarUpdateResult?>.value();
    if (state.failedOperation == AvatarOperation.remove) return remove();
    final mediaId = state.pendingMediaId;
    if (mediaId != null) return _setUploadedMedia(mediaId);
    return chooseAndSet();
  }

  void cancelUpload() {
    if (state.phase != AvatarPhase.uploading) return;
    _uploadTask.cancel();
    state = const AvatarState();
  }

  void clearFailure() {
    if (state.phase != AvatarPhase.failed) return;
    state = const AvatarState();
  }

  Future<AvatarUpdateResult?> _setUploadedMedia(String mediaId) async {
    state = AvatarState(phase: AvatarPhase.setting, pendingMediaId: mediaId);
    try {
      final result = await _avatarRepository.setAvatar(mediaId);
      if (!mounted) return null;
      state = const AvatarState();
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = AvatarState(
        phase: AvatarPhase.failed,
        failedOperation: AvatarOperation.set,
        pendingMediaId: mediaId,
        failure: _asFailure(error, '头像没有设置成功，请稍后重试。'),
      );
      return null;
    }
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: fallback, cause: error);
  }

  void updateUploadState(MediaUploadTaskState uploadState) {
    if (!mounted || !uploadState.isBusy) return;
    state = AvatarState(
      phase: AvatarPhase.uploading,
      progress: uploadState.progress,
    );
  }

  @override
  void dispose() {
    _uploadTask.cancel();
    super.dispose();
  }
}

final avatarControllerProvider =
    StateNotifierProvider.autoDispose<AvatarController, AvatarState>(
      (ref) {
        final uploadProvider = mediaUploadTaskControllerProvider(
          _avatarUploadTaskId,
        );
        final controller = AvatarController(
          ref.watch(avatarImagePickerPortProvider),
          ref.read(uploadProvider.notifier),
          ref.watch(avatarRepositoryProvider),
        );
        ref.listen<MediaUploadTaskState>(uploadProvider, (_, next) {
          controller.updateUploadState(next);
        });
        return controller;
      },
      dependencies: [
        avatarImagePickerPortProvider,
        mediaUploadTaskControllerProvider,
      ],
    );

const _avatarUploadTaskId = 'users/avatar';
