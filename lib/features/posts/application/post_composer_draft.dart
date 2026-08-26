import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

class PostComposerDraft {
  const PostComposerDraft({
    required this.content,
    required this.baseContent,
    required this.basePostId,
    required this.baseVersion,
  });

  final String content;
  final String baseContent;
  final String? basePostId;
  final int? baseVersion;
}

class PostComposerBaseline {
  const PostComposerBaseline({
    required this.content,
    required this.postId,
    required this.version,
  });

  final String content;
  final String? postId;
  final int? version;

  PostComposerDraft? draftFor(String content) {
    if (_sameMarkdown(content, this.content)) return null;
    return PostComposerDraft(
      content: content,
      baseContent: this.content,
      basePostId: postId,
      baseVersion: version,
    );
  }
}

class PreparedPostComposer {
  const PreparedPostComposer({required this.target, required this.baseline});

  final PostComposerTarget target;
  final PostComposerBaseline baseline;
}

void setPostComposerDraft(
  Map<String, PostComposerDraft> drafts,
  String key,
  PostComposerDraft? draft,
) {
  if (draft == null) {
    drafts.remove(key);
  } else {
    drafts[key] = draft;
  }
}

enum PostComposerDraftResolution { ready, saved, restore, diverged }

PostComposerDraftResolution resolvePostComposerDraft({
  required PostComposerDraft? draft,
  required PostComposerBaseline baseline,
}) {
  if (draft == null) return PostComposerDraftResolution.ready;
  if (_sameMarkdown(draft.content, baseline.content)) {
    return PostComposerDraftResolution.saved;
  }
  if (baseline.postId == null) return PostComposerDraftResolution.restore;
  if (draft.basePostId == baseline.postId &&
      (draft.baseVersion == baseline.version ||
          _sameMarkdown(draft.baseContent, baseline.content))) {
    return PostComposerDraftResolution.restore;
  }
  return PostComposerDraftResolution.diverged;
}

PostComposerTarget postComposerTargetWithBaseline({
  required PostComposerTarget target,
  required String content,
  required int? version,
  String? postId,
}) => (
  kind: target.kind,
  threadId: target.threadId,
  subthreadId: target.subthreadId,
  postId: postId ?? target.postId,
  parentPostId: target.parentPostId,
  replyToPostId: target.replyToPostId,
  version: version,
  initialContent: content,
  label: target.label,
);

bool _sameMarkdown(String left, String right) =>
    MarkdownContent.normalize(left) == MarkdownContent.normalize(right);
