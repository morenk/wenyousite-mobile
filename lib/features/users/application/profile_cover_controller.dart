import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

enum ProfileCoverPhase {
  idle,
  picking,
  uploadingWeb,
  uploadingMobile,
  setting,
  removing,
  failed,
}

enum ProfileCoverOperation { set, remove }

class ProfileCoverState {
  const ProfileCoverState({
    this.phase = ProfileCoverPhase.idle,
    this.progress,
    this.failure,
    this.failedOperation,
    this.pendingWebMediaId,
    this.pendingMobileMediaId,
    this.hasPendingSelection = false,
    this.previewBytes,
  });

  final ProfileCoverPhase phase;
  final MediaUploadProgress? progress;
  final ApiFailure? failure;
  final ProfileCoverOperation? failedOperation;
  final String? pendingWebMediaId;
  final String? pendingMobileMediaId;
  final bool hasPendingSelection;
  final Uint8List? previewBytes;

  bool get isBusy => switch (phase) {
    ProfileCoverPhase.picking ||
    ProfileCoverPhase.uploadingWeb ||
    ProfileCoverPhase.uploadingMobile ||
    ProfileCoverPhase.setting ||
    ProfileCoverPhase.removing => true,
    ProfileCoverPhase.idle || ProfileCoverPhase.failed => false,
  };
}

class ProfileCoverController extends StateNotifier<ProfileCoverState> {
  ProfileCoverController(
    this._picker,
    this._webUploadTask,
    this._mobileUploadTask,
    this._repository,
  ) : super(const ProfileCoverState());

  final ProfileCoverImagePicker _picker;
  final MediaUploadTask _webUploadTask;
  final MediaUploadTask _mobileUploadTask;
  final ProfileCoverRepository _repository;
  ProfileCoverImageSelection? _selection;

  Future<MediaUploadInput?> pickImage() async {
    if (state.isBusy) return null;
    _selection = null;
    _resetTasks();
    state = const ProfileCoverState(phase: ProfileCoverPhase.picking);
    try {
      final selected = await _picker.pickProfileCoverFromGallery();
      if (!mounted) return null;
      if (selected == null) {
        state = const ProfileCoverState();
        return null;
      }
      state = const ProfileCoverState();
      return selected;
    } on Object catch (error) {
      if (!mounted) return null;
      _resetTasks();
      state = ProfileCoverState(
        phase: ProfileCoverPhase.failed,
        failedOperation: ProfileCoverOperation.set,
        failure: _asFailure(error, '背景图没有准备成功，请稍后重试。'),
      );
      return null;
    }
  }

  Future<ProfileCoverUpdateResult?> setSelection(
    ProfileCoverImageSelection selection,
  ) {
    if (state.isBusy) return Future.value();
    _selection = selection;
    _resetTasks();
    return _continueSet();
  }

  Future<ProfileCoverUpdateResult?> remove() async {
    if (state.isBusy) return null;
    _selection = null;
    state = const ProfileCoverState(phase: ProfileCoverPhase.removing);
    try {
      final result = await _repository.removeProfileCover();
      if (!mounted) return null;
      state = const ProfileCoverState();
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = ProfileCoverState(
        phase: ProfileCoverPhase.failed,
        failedOperation: ProfileCoverOperation.remove,
        failure: _asFailure(error, '背景图没有移除成功，请稍后重试。'),
      );
      return null;
    }
  }

  Future<ProfileCoverUpdateResult?> retry() {
    if (state.isBusy) return Future.value();
    if (state.failedOperation == ProfileCoverOperation.remove) return remove();
    if (_selection == null &&
        (state.pendingWebMediaId == null ||
            state.pendingMobileMediaId == null)) {
      return Future.value();
    }
    return _continueSet(
      webMediaId: state.pendingWebMediaId,
      mobileMediaId: state.pendingMobileMediaId,
    );
  }

  void cancelUpload() {
    if (state.phase != ProfileCoverPhase.uploadingWeb &&
        state.phase != ProfileCoverPhase.uploadingMobile) {
      return;
    }
    _webUploadTask.cancel();
    _mobileUploadTask.cancel();
    _selection = null;
    state = const ProfileCoverState();
  }

  void updateUploadState(
    ProfileCoverPhase surfacePhase,
    MediaUploadTaskState uploadState,
  ) {
    if (!mounted ||
        !uploadState.isBusy ||
        (state.phase != ProfileCoverPhase.uploadingWeb &&
            state.phase != ProfileCoverPhase.uploadingMobile)) {
      return;
    }
    state = ProfileCoverState(
      phase: surfacePhase,
      progress: uploadState.progress,
      pendingWebMediaId: state.pendingWebMediaId,
      pendingMobileMediaId: state.pendingMobileMediaId,
      hasPendingSelection: _selection != null,
      previewBytes: _selection?.mobile.bytes,
    );
  }

  Future<ProfileCoverUpdateResult?> _continueSet({
    String? webMediaId,
    String? mobileMediaId,
  }) async {
    var webId = webMediaId;
    var mobileId = mobileMediaId;
    try {
      final selection = _selection;
      if (selection == null && (webId == null || mobileId == null)) return null;
      state = ProfileCoverState(
        phase: ProfileCoverPhase.uploadingWeb,
        pendingWebMediaId: webId,
        pendingMobileMediaId: mobileId,
        hasPendingSelection: selection != null,
        previewBytes: selection?.mobile.bytes,
      );
      final uploads = await Future.wait<UploadedEditorImage?>([
        webId == null
            ? _webUploadTask.uploadInput(selection!.web)
            : Future<UploadedEditorImage?>.value(),
        mobileId == null
            ? _mobileUploadTask.uploadInput(selection!.mobile)
            : Future<UploadedEditorImage?>.value(),
      ]);
      if (!mounted) return null;
      webId ??= uploads[0]?.mediaId;
      mobileId ??= uploads[1]?.mediaId;
      if (webId == null || mobileId == null) {
        final failedState = webId == null
            ? _webUploadTask.state
            : _mobileUploadTask.state;
        return _recordUploadFailure(
          failedState,
          webMediaId: webId,
          mobileMediaId: mobileId,
        );
      }
      state = ProfileCoverState(
        phase: ProfileCoverPhase.setting,
        pendingWebMediaId: webId,
        pendingMobileMediaId: mobileId,
        previewBytes: selection?.mobile.bytes,
      );
      final result = await _repository.setProfileCover(
        webMediaId: webId,
        mobileMediaId: mobileId,
      );
      if (!mounted) return null;
      _selection = null;
      _resetTasks();
      state = const ProfileCoverState();
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = ProfileCoverState(
        phase: ProfileCoverPhase.failed,
        failedOperation: ProfileCoverOperation.set,
        pendingWebMediaId: webId,
        pendingMobileMediaId: mobileId,
        hasPendingSelection: _selection != null,
        previewBytes: _selection?.mobile.bytes,
        failure: _asFailure(error, '背景图没有设置成功，请稍后重试。'),
      );
      return null;
    }
  }

  ProfileCoverUpdateResult? _recordUploadFailure(
    MediaUploadTaskState uploadState, {
    required String? webMediaId,
    required String? mobileMediaId,
  }) {
    final failure = uploadState.failure;
    state = failure == null
        ? const ProfileCoverState()
        : ProfileCoverState(
            phase: ProfileCoverPhase.failed,
            failedOperation: ProfileCoverOperation.set,
            pendingWebMediaId: webMediaId,
            pendingMobileMediaId: mobileMediaId,
            hasPendingSelection: _selection != null,
            previewBytes: _selection?.mobile.bytes,
            failure: ApiFailure(
              userMessage: failure.userMessage,
              businessCode: failure.businessCode,
              requestId: failure.requestId,
            ),
          );
    return null;
  }

  void _resetTasks() {
    _webUploadTask.reset();
    _mobileUploadTask.reset();
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }

  @override
  void dispose() {
    _webUploadTask.cancel();
    _mobileUploadTask.cancel();
    super.dispose();
  }
}

final profileCoverControllerProvider =
    StateNotifierProvider.autoDispose<
      ProfileCoverController,
      ProfileCoverState
    >(
      (ref) {
        final webUploadProvider = mediaUploadTaskControllerProvider(
          _webProfileCoverUploadTaskId,
        );
        final mobileUploadProvider = mediaUploadTaskControllerProvider(
          _mobileProfileCoverUploadTaskId,
        );
        final controller = ProfileCoverController(
          ref.watch(profileCoverImagePickerPortProvider),
          ref.read(webUploadProvider.notifier),
          ref.read(mobileUploadProvider.notifier),
          ref.watch(profileCoverRepositoryProvider),
        );
        ref.listen<MediaUploadTaskState>(webUploadProvider, (_, next) {
          controller.updateUploadState(ProfileCoverPhase.uploadingWeb, next);
        });
        ref.listen<MediaUploadTaskState>(mobileUploadProvider, (_, next) {
          controller.updateUploadState(ProfileCoverPhase.uploadingMobile, next);
        });
        return controller;
      },
      dependencies: [
        profileCoverImagePickerPortProvider,
        profileCoverRepositoryProvider,
        mediaUploadTaskControllerProvider,
      ],
    );

const _webProfileCoverUploadTaskId = 'users/profile-cover/web';
const _mobileProfileCoverUploadTaskId = 'users/profile-cover/mobile';
