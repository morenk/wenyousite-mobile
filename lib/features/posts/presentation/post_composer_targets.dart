import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

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
    label: '回复 @${target.author.username}',
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
