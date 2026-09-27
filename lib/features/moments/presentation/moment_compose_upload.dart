import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class MomentComposeUpload {
  MomentComposeUpload(this.input, {String? id}) : id = id ?? const Uuid().v4();

  final String id;
  MediaUploadInput input;
  PendingMediaUpload? pending;
  bool persisted = false;
  Future<void>? persisting;
  int generation = 0;
  final Object taskId = Object();
  bool started = false;
  bool active = false;
  bool failed = false;
  MediaUploadFailure? failure;
}
