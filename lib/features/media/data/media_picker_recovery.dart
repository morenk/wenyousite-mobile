import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/features/media/application/media_picker_recovery_ports.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/shared_preferences_media_picker_recovery_context_store.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/recovered_media_selection_models.dart';

typedef LostMediaRetriever = Future<LostDataResponse> Function();

Future<RecoveredMediaSelectionResult> recoverLostEditorMediaSelection({
  LostMediaRetriever? retrieve,
  MediaPickerRecoveryContextStore contextStore =
      const SharedPreferencesMediaPickerRecoveryContextStore(),
  bool? isAndroid,
}) async {
  if (!(isAndroid ?? Platform.isAndroid)) {
    return const RecoveredMediaSelectionResult();
  }
  final purpose = await contextStore.read();
  try {
    final response = await (retrieve ?? ImagePicker().retrieveLostData)();
    await contextStore.clear();
    if (response.isEmpty || purpose == null) {
      return const RecoveredMediaSelectionResult();
    }
    final files =
        response.files ??
        (response.file == null ? const <XFile>[] : [response.file!]);
    final inputs = <MediaUploadInput>[];
    for (final file in files) {
      inputs.add(
        await mediaUploadInputFromXFile(
          file,
          emptyMessage: '上次选择的图片已不可用，请重新选择。',
          purpose: purpose,
        ),
      );
    }
    if (inputs.isEmpty) return const RecoveredMediaSelectionResult();
    return RecoveredMediaSelectionResult(
      selections: {purpose: List.unmodifiable(inputs)},
    );
  } on Object catch (error) {
    try {
      await contextStore.clear();
    } on Object {
      // The recovery result is already unusable; the next picker launch will
      // overwrite this small context marker before opening the system UI.
    }
    return RecoveredMediaSelectionResult(error: error);
  }
}
