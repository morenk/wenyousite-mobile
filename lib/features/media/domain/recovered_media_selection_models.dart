import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class RecoveredMediaSelectionResult {
  const RecoveredMediaSelectionResult({this.selections = const {}, this.error});

  final Map<MediaUploadPurpose, List<MediaUploadInput>> selections;
  final Object? error;
}
