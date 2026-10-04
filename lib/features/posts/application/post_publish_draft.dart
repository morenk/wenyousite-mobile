import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

class PostPublishDraft {
  const PostPublishDraft({this.mode, this.identityToken, this.pending});
  final PostIdentityMode? mode;
  final String? identityToken;
  final PendingPostCreate? pending;

  Map<String, Object?> toJson() => {
    if (mode != null) 'identityMode': mode!.name,
    if (identityToken != null) 'identityToken': identityToken,
    if (pending case final value?)
      'pendingCreate': {
        'subthreadId': value.input.subthreadId,
        'content': value.input.content,
        'clientRequestId': value.input.clientRequestId,
        'parentPostId': value.input.parentPostId,
        'replyToPostId': value.input.replyToPostId,
        'identityMode': value.input.identityMode?.name,
        'identityToken': value.input.identityToken,
      },
  };

  static PostPublishDraft? fromJson(Object? value) {
    if (value is! Map) return null;
    PostIdentityMode? modeOf(Object? value) => switch (value) {
      'account' => PostIdentityMode.account,
      'rp' => PostIdentityMode.rp,
      _ => null,
    };
    String? optional(Object? value) => value is String ? value : null;
    PendingPostCreate? pending;
    final input = value['pendingCreate'];
    if (input is Map &&
        input['subthreadId'] is String &&
        input['content'] is String &&
        input['clientRequestId'] is String) {
      pending = PendingPostCreate(
        input: PostCreateInput(
          subthreadId: input['subthreadId'] as String,
          content: input['content'] as String,
          clientRequestId: input['clientRequestId'] as String,
          parentPostId: optional(input['parentPostId']),
          replyToPostId: optional(input['replyToPostId']),
          identityMode: modeOf(input['identityMode']),
          identityToken: optional(input['identityToken']),
        ),
      );
    }
    return PostPublishDraft(
      mode: modeOf(value['identityMode']),
      identityToken: optional(value['identityToken']),
      pending: pending,
    );
  }
}
