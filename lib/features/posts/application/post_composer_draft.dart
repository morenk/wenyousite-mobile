import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

class PostComposerDraft {
  const PostComposerDraft({
    required this.content,
    this.mediaDisplays = const {},
    required this.baseContent,
    required this.basePostId,
    required this.baseVersion,
    this.publishDraft,
  });

  final String content;
  final Map<String, MediaDisplay> mediaDisplays;
  final String baseContent;
  final String? basePostId;
  final int? baseVersion;
  final PostPublishDraft? publishDraft;
}

class PostComposerBaseline {
  const PostComposerBaseline({
    required this.content,
    this.mediaDisplays = const {},
    this.mentionLabels = const {},
    required this.postId,
    required this.version,
  });

  final String content;
  final Map<String, MediaDisplay> mediaDisplays;
  final Map<String, String> mentionLabels;
  final String? postId;
  final int? version;

  PostComposerDraft? draftFor(
    String content, {
    Map<String, MediaDisplay>? displays,
    PostPublishDraft? publishDraft,
  }) {
    if (_sameMarkdown(content, this.content) && publishDraft == null) {
      return null;
    }
    return PostComposerDraft(
      content: content,
      mediaDisplays: displays ?? mediaDisplays,
      baseContent: this.content,
      basePostId: postId,
      baseVersion: version,
      publishDraft: publishDraft,
    );
  }
}

class PreparedPostComposer {
  const PreparedPostComposer({
    required this.target,
    required this.baseline,
    this.publishDraft,
  });

  final PostComposerTarget target;
  final PostComposerBaseline baseline;
  final PostPublishDraft? publishDraft;
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

/// 入口预填内容要在本机草稿恢复后合并；待重试的请求不能变更正文。
String mergePostComposerInsertion({
  required String content,
  required String? insertion,
  required bool pending,
}) {
  final addition = insertion?.trim();
  if (pending ||
      addition == null ||
      addition.isEmpty ||
      content.contains(addition)) {
    return content;
  }
  return content.trim().isEmpty
      ? '$addition '
      : '${content.trimRight()}\n$addition ';
}

PostComposerDraftResolution resolvePostComposerDraft({
  required PostComposerDraft? draft,
  required PostComposerBaseline baseline,
}) {
  if (draft == null) return PostComposerDraftResolution.ready;
  if (_sameMarkdown(draft.content, baseline.content) &&
      draft.publishDraft == null) {
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
