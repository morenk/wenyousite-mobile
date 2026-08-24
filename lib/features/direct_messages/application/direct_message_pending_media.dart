import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class PendingDirectMessageMedia {
  const PendingDirectMessageMedia({required this.input, this.progress});

  final MediaUploadInput input;
  final MediaUploadProgress? progress;
}

void validateDirectMessageParticipants(
  DirectConversation conversation,
  Iterable<DirectMessage> messages, {
  bool requireOutgoing = false,
}) {
  final otherUserId = conversation.otherUser.id;
  for (final message in messages) {
    final includesOther =
        message.senderId == otherUserId || message.recipientId == otherUserId;
    final isOutgoing = message.recipientId == otherUserId;
    if (!includesOther || (requireOutgoing && !isOutgoing)) {
      throw const ApiFailure(userMessage: '会话成员已经发生变化，请重新打开。');
    }
  }
}

class DirectMessagePendingMediaJobs {
  DirectMessagePendingMediaJobs(this._gateway);

  final MediaUploadGateway _gateway;
  final Map<String, _PendingMediaJob> _jobs = {};

  bool contains(String messageId) => _jobs.containsKey(messageId);

  PendingDirectMessageMedia register(String messageId, MediaUploadInput input) {
    final job = _PendingMediaJob(input);
    _jobs[messageId] = job;
    return job.snapshot;
  }

  Future<String> resolveMediaId(
    String messageId, {
    required void Function(PendingDirectMessageMedia media) onProgress,
  }) {
    final job = _jobs[messageId];
    if (job == null) {
      return Future.error(StateError('待发送图片已经不存在。'));
    }
    final uploadedMediaId = job.uploadedMediaId;
    if (uploadedMediaId != null) return Future.value(uploadedMediaId);
    final active = job.active;
    if (active != null) return active;

    late final Future<String> future;
    final operation = _gateway.startImageUpload(
      job.input,
      onProgress: (progress) {
        if (!identical(_jobs[messageId], job)) return;
        job.progress = progress;
        onProgress(job.snapshot);
      },
    );
    job.operation = operation;
    future = operation.result
        .then((image) {
          if (!identical(_jobs[messageId], job)) {
            throw StateError('待发送图片已经取消。');
          }
          job.uploadedMediaId = image.mediaId;
          return image.mediaId;
        })
        .whenComplete(() {
          if (identical(job.active, future)) job.active = null;
          if (identical(job.operation, operation)) job.operation = null;
        });
    job.active = future;
    return future;
  }

  void remove(String messageId) {
    _jobs.remove(messageId)?.operation?.cancel();
  }

  void dispose() {
    for (final job in _jobs.values) {
      job.operation?.cancel();
    }
    _jobs.clear();
  }
}

class _PendingMediaJob {
  _PendingMediaJob(this.input);

  final MediaUploadInput input;
  MediaUploadProgress? progress;
  String? uploadedMediaId;
  MediaUploadOperation<UploadedEditorImage>? operation;
  Future<String>? active;

  PendingDirectMessageMedia get snapshot =>
      PendingDirectMessageMedia(input: input, progress: progress);
}
