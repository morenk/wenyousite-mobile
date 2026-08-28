import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/recovered_media_selection_models.dart';

class RecoveredMediaSelectionStore {
  RecoveredMediaSelectionStore({
    Map<MediaUploadPurpose, List<MediaUploadInput>> selections = const {},
    this.failure,
  }) : _selections = {
         for (final entry in selections.entries)
           entry.key: List<MediaUploadInput>.of(entry.value),
       };

  factory RecoveredMediaSelectionStore.fromResult(
    RecoveredMediaSelectionResult result,
  ) {
    final error = result.error;
    return RecoveredMediaSelectionStore(
      selections: result.selections,
      failure: error == null
          ? null
          : ApiFailure(
              userMessage: '上次选择的图片没有恢复，请重新选择。',
              reason: FailureReason.localPersistence,
              recoveryAction: FailureRecoveryAction.reopen,
              cause: error,
            ),
    );
  }

  final Map<MediaUploadPurpose, List<MediaUploadInput>> _selections;
  final ApiFailure? failure;

  bool hasSelection(MediaUploadPurpose purpose) =>
      _selections[purpose]?.isNotEmpty ?? false;

  List<MediaUploadInput> take(MediaUploadPurpose purpose) {
    final selection = _selections.remove(purpose);
    return selection == null
        ? const []
        : List<MediaUploadInput>.unmodifiable(selection);
  }

  void discard(MediaUploadPurpose purpose) {
    _selections.remove(purpose);
  }
}

final recoveredMediaSelectionStoreProvider =
    Provider<RecoveredMediaSelectionStore>((ref) {
      return RecoveredMediaSelectionStore();
    });
