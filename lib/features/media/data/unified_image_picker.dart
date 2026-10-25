import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/data/profile_cover_image_policy.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class UnifiedImagePicker
    implements
        EditorImagePicker,
        MultiEditorImagePicker,
        RecoveryAwareEditorImagePicker,
        AvatarImagePicker,
        ProfileCoverImagePicker {
  UnifiedImagePicker(this.coordinator);
  final PhotoSelectionCoordinator coordinator;

  @override
  Future<List<MediaUploadInput>> pickManyFromGalleryFor({
    required int limit,
    required MediaUploadPurpose purpose,
  }) async =>
      await coordinator.pick(
        PhotoSelectionRequest(limit: limit, purpose: purpose),
      ) ??
      [];

  @override
  Future<MediaUploadInput?> pickFromGalleryFor(
    MediaUploadPurpose purpose,
  ) async =>
      (await pickManyFromGalleryFor(limit: 1, purpose: purpose)).firstOrNull;

  @override
  Future<MediaUploadInput?> pickFromGallery() =>
      pickFromGalleryFor(MediaUploadPurpose.richContent);

  @override
  Future<List<MediaUploadInput>> pickManyFromGallery({required int limit}) =>
      pickManyFromGalleryFor(
        limit: limit,
        purpose: MediaUploadPurpose.richContent,
      );

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async =>
      (await pickFromGalleryFor(MediaUploadPurpose.avatar))?.materialize();

  @override
  Future<MediaUploadInput?> pickProfileCoverFromGallery() async {
    final input = await pickFromGalleryFor(MediaUploadPurpose.profileCover);
    return input == null
        ? null
        : validateProfileCoverImageInput(await input.materialize());
  }
}
