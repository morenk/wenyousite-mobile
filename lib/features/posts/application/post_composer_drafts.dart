import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

/// 同一账号会话的主题回复由所有页面共用，退出或切号后重新创建。
final postComposerDraftsProvider = Provider((ref) {
  ref.watch(sessionScopeProvider);
  return <String, PostComposerDraft>{};
});

bool isSharedPostComposerTarget(PostComposerTarget target) =>
    target.kind == PostComposerKind.createFloor ||
    target.kind == PostComposerKind.createReply;

String postComposerDraftKey(PostComposerTarget target) =>
    isSharedPostComposerTarget(target)
    ? 'thread-reply:${target.threadId}'
    : postComposerLegacyDraftKey(target);

String postComposerLegacyDraftKey(PostComposerTarget target) => [
  target.kind.name,
  target.threadId,
  target.subthreadId,
  target.postId ?? '',
  target.parentPostId ?? '',
  target.replyToPostId ?? '',
].join(':');

bool pendingPostMatchesTarget(
  PendingPostCreate pending,
  PostComposerTarget target,
) =>
    pending.input.subthreadId == target.subthreadId &&
    pending.input.parentPostId == target.parentPostId &&
    pending.input.replyToPostId == target.replyToPostId;
