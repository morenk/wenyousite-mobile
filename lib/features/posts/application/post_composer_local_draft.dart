import 'package:wenyousite_mobile/features/editor/editor_persistence.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_drafts.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

/// 同主题已有未确认请求，必须回原目标处理后才能打开其他发表入口。
class PostDraftTargetBlocked implements Exception {
  const PostDraftTargetBlocked();
}

Future<({String target, bool isolated})> preparePostComposerLocalDraft({
  required PendingMediaFileStore store,
  required String accountId,
  required PostComposerTarget target,
}) async {
  final sharedKey = 'post:${postComposerDraftKey(target)}';
  if (!isSharedPostComposerTarget(target)) {
    return (target: sharedKey, isolated: false);
  }
  final legacyKey = 'post:${postComposerLegacyDraftKey(target)}';
  final legacy = await store.read(accountId: accountId, target: legacyKey);
  final legacyPending = PostPublishDraft.fromJson(legacy?['metadata'])?.pending;
  // 旧版未确认请求仍在原入口重试，不覆盖新建的主题共享草稿。
  if (legacyPending != null) {
    if (!pendingPostMatchesTarget(legacyPending, target)) {
      throw const PostDraftTargetBlocked();
    }
    return (target: legacyKey, isolated: true);
  }
  final shared = await store.read(accountId: accountId, target: sharedKey);
  final migratedFrom = shared?['migratedFrom'];
  if (migratedFrom is String &&
      (migratedFrom.startsWith('post:createFloor:${target.threadId}:') ||
          migratedFrom.startsWith('post:createReply:${target.threadId}:'))) {
    // 换到其他入口也先补齐迁移标记，避免下一次保存覆盖来源后旧稿复活。
    final source = migratedFrom == legacyKey
        ? legacy
        : await store.read(accountId: accountId, target: migratedFrom);
    if (source?['markdown'] is String) {
      await store.write(
        accountId: accountId,
        target: migratedFrom,
        payload: {'version': 1, 'completed': true, 'migratedTo': sharedKey},
      );
    }
  }
  final pending = PostPublishDraft.fromJson(shared?['metadata'])?.pending;
  if (pending != null && !pendingPostMatchesTarget(pending, target)) {
    throw const PostDraftTargetBlocked();
  }
  if (shared == null && legacy?['markdown'] is String) {
    await migrateEditorLocalDraft(
      store: store,
      accountId: accountId,
      source: legacyKey,
      target: sharedKey,
      payload: legacy!,
    );
  }
  return (target: sharedKey, isolated: false);
}
