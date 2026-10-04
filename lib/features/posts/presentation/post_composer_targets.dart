import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

PostComposerTarget postReplyTarget(PostItem root, PostItem target) {
  return (
    kind: PostComposerKind.createReply,
    threadId: root.threadId,
    subthreadId: root.subthreadId,
    postId: null,
    parentPostId: root.id,
    replyToPostId: target.id,
    version: null,
    initialContent: '',
    label: '回复 @${target.author.displayName}',
  );
}

PostComposerTarget postEditTarget(PostItem post, String label) {
  return (
    kind: PostComposerKind.editPost,
    threadId: post.threadId,
    subthreadId: post.subthreadId,
    postId: post.id,
    parentPostId: post.parentPostId,
    replyToPostId: post.replyToPostId,
    version: post.version,
    initialContent: post.content,
    label: label,
  );
}

PostComposerTarget threadIdentityMentionTarget(
  PostComposerTarget target,
  ThreadIdentityState identity,
) => (
  kind: target.kind,
  threadId: target.threadId,
  subthreadId: target.subthreadId,
  postId: target.postId,
  parentPostId: target.parentPostId,
  replyToPostId: target.replyToPostId,
  version: target.version,
  initialContent: '[@${identity.displayName}](/users/${identity.userId}) ',
  label: '提及 @${identity.displayName}',
);
