import 'dart:async';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class PostRepliesPageTestFailingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  @override
  Future<UploadedEditorImage> get result => Future<UploadedEditorImage>.error(
    const ApiFailure(userMessage: '图片处理失败', requestId: 'request-one'),
  );

  @override
  void cancel() {}
}

class PostRepliesPageTestSuccessfulMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  @override
  Future<UploadedEditorImage> get result => Future.value(
    const UploadedEditorImage(
      mediaId: 'retried-reply-image',
      url: 'https://cdn.example.com/retried-reply.png',
    ),
  );

  @override
  void cancel() {}
}

class PostRepliesPageTestLateCompletingMediaUploadGateway
    implements MediaUploadGateway {
  final operation = PostRepliesPageTestLateCompletingMediaUploadOperation();

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length ~/ 2,
        totalBytes: input.bytes.length,
      ),
    );
    return operation;
  }
}

class PostRepliesPageTestLateCompletingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final postRepliesPageTestCompleter = Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => postRepliesPageTestCompleter.future;

  @override
  void cancel() => cancelled = true;

  void complete(UploadedEditorImage image) =>
      postRepliesPageTestCompleter.complete(image);
}
