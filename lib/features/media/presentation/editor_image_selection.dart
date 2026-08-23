import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

Future<UploadedEditorImage?> pickAndUploadEditorImage(
  BuildContext context,
  WidgetRef ref, {
  required Object uploadTaskId,
  MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
}) async {
  final inputs = await pickEditorImages(context, ref, purpose: purpose);
  if (!context.mounted || inputs == null || inputs.isEmpty) return null;
  return ref
      .read(mediaUploadTaskControllerProvider(uploadTaskId).notifier)
      .uploadInput(inputs.single);
}

Future<List<MediaUploadInput>?> pickEditorImages(
  BuildContext context,
  WidgetRef ref, {
  int maximumSelection = 1,
  MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
}) async {
  assert(maximumSelection > 0);
  final picker = ref.read(editorImagePickerPortProvider);
  while (context.mounted) {
    try {
      final List<MediaUploadInput> inputs;
      if (maximumSelection > 1 && picker is MultiEditorImagePicker) {
        inputs = await (picker as MultiEditorImagePicker).pickManyFromGallery(
          limit: maximumSelection,
        );
      } else {
        final input = await picker.pickFromGallery();
        inputs = input == null ? const [] : [input];
      }
      if (!context.mounted || inputs.isEmpty) return null;
      return inputs
          .take(maximumSelection)
          .map((input) => input.withPurpose(purpose))
          .toList(growable: false);
    } on Object catch (error) {
      if (!context.mounted) return null;
      final retry = await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('选择图片失败'),
          content: Text(_imageSelectionFailureMessage(error)),
          actions: [
            TextButton(
              key: const Key('image-picker-failure-close'),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('关闭'),
            ),
            FilledButton(
              key: const Key('image-picker-failure-retry'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('重新选择'),
            ),
          ],
        ),
      );
      if (retry != true) return null;
    }
  }
  return null;
}

String _imageSelectionFailureMessage(Object error) {
  if (error is ApiFailure) return error.userMessage;
  return '选择图片失败，请重试或更换图片。';
}
