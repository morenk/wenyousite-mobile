import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum AudioUploadFailureReason {
  unavailable,
  invalidInput,
  fileChanged,
  unsupportedType,
  timeout,
  localFileSave,
  documentSave,
  draftSave,
}

/// 音频工作流只传递失败分类，具体操作提示由编辑器展示层决定。
class AudioUploadFailure extends ApiFailure {
  const AudioUploadFailure(this.audioReason)
    : super(
        source: audioReason == AudioUploadFailureReason.timeout
            ? FailureSource.network
            : FailureSource.device,
        reason: audioReason == AudioUploadFailureReason.timeout
            ? FailureReason.timeout
            : audioReason == AudioUploadFailureReason.localFileSave ||
                  audioReason == AudioUploadFailureReason.documentSave ||
                  audioReason == AudioUploadFailureReason.draftSave
            ? FailureReason.localPersistence
            : FailureReason.validation,
      );

  final AudioUploadFailureReason audioReason;
}
