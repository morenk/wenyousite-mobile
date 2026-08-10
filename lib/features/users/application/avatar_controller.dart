import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
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
  AvatarController(this._picker, this._mediaRepository, this._avatarRepository)
    : super(const AvatarState());

  final AvatarImagePicker _picker;
  final MediaUploadRepository _mediaRepository;
  final AvatarRepository _avatarRepository;
  CancelToken? _uploadCancelToken;
  var _cancelRequested = false;

  Future<AvatarUpdateResult?> chooseAndSet() async {
    if (state.isBusy) return null;
    state = const AvatarState(phase: AvatarPhase.picking);
    try {
      final selected = await _picker.pickAvatarFromGallery();
      if (!mounted) return null;
      if (selected == null) {
        state = const AvatarState();
        return null;
      }
      final input = validateAvatarImageInput(selected);
      final cancelToken = CancelToken();
      _uploadCancelToken = cancelToken;
      _cancelRequested = false;
      state = const AvatarState(phase: AvatarPhase.uploading);
      final image = await _mediaRepository.uploadImage(
        input,
        cancelToken: cancelToken,
        onProgress: (progress) {
          if (!mounted || _uploadCancelToken != cancelToken) return;
          state = AvatarState(phase: AvatarPhase.uploading, progress: progress);
        },
      );
      if (!mounted) return null;
      _uploadCancelToken = null;
      return _setUploadedMedia(image.mediaId);
    } on Object catch (error) {
      if (!mounted) return null;
      _uploadCancelToken = null;
      if (_cancelRequested) {
        _cancelRequested = false;
        state = const AvatarState();
        return null;
      }
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
    final cancelToken = _uploadCancelToken;
    if (cancelToken == null || cancelToken.isCancelled) return;
    _cancelRequested = true;
    cancelToken.cancel('avatar-upload-cancelled');
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

  @override
  void dispose() {
    _uploadCancelToken?.cancel('avatar-controller-disposed');
    super.dispose();
  }
}

final avatarControllerProvider =
    StateNotifierProvider.autoDispose<AvatarController, AvatarState>((ref) {
      return AvatarController(
        ref.watch(avatarImagePickerProvider),
        ref.watch(mediaUploadRepositoryProvider),
        ref.watch(avatarRepositoryProvider),
      );
    });
