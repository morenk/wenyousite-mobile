import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/markdown/local_image_marker.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_controller.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_states.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

export 'package:wenyousite_mobile/features/posts/application/post_discussion_controller.dart';
export 'package:wenyousite_mobile/features/posts/application/post_states.dart';

class PostComposerController extends StateNotifier<PostComposerState> {
  PostComposerController(
    this._repository,
    this.target, {
    String Function()? createRequestId,
  }) : _createRequestId = createRequestId ?? const Uuid().v4,
       _requestId = (createRequestId ?? const Uuid().v4)(),
       super(PostComposerState(content: target.initialContent));

  final PostRepository _repository;
  final PostComposerTarget target;
  final String Function() _createRequestId;
  String _requestId;

  void updateContent(String content) {
    if (state.isSubmitting || state.pendingCreate != null) return;
    state = state.copyWith(
      content: content,
      failure: null,
      result: null,
      conflict: null,
    );
  }

  void restoreContent(String content) {
    if (state.isSubmitting || state.pendingCreate != null) return;
    state = state.copyWith(
      content: MarkdownContent.normalize(content),
      documentRevision: state.documentRevision + 1,
      failure: null,
      result: null,
      conflict: null,
    );
  }

  Future<PostItem?> submit({
    String? identityToken,
    String? identityId,
    PostIdentityMode? identityMode,
    Future<bool> Function()? persistCreateIntent,
    bool legacySingleIdentity = false,
  }) async {
    if (state.isSubmitting) return null;
    final validation = _validate(state.content);
    if (validation != null) {
      state = state.copyWith(
        failure: ApiFailure(
          userMessage: validation,
          source: FailureSource.expected,
          reason: FailureReason.validation,
        ),
      );
      return null;
    }
    return switch (target.kind) {
      PostComposerKind.createFloor ||
      PostComposerKind.createReply => _submitCreate(
        identityToken: identityToken,
        identityId: legacySingleIdentity ? null : identityId,
        identityMode: identityMode,
        persistCreateIntent: persistCreateIntent,
      ),
      PostComposerKind.editPost => _submitEdit(
        postId: target.postId!,
        version: target.version!,
      ),
      PostComposerKind.upsertBody => _submitBody(
        version: target.version,
        identityToken: identityToken,
        identityId: legacySingleIdentity ? null : identityId,
        identityMode: identityMode,
        persistCreateIntent: persistCreateIntent,
      ),
    };
  }

  Future<PostItem?> retryConflict() async {
    final conflict = state.conflict;
    if (conflict == null || state.isSubmitting) return null;
    if (target.kind == PostComposerKind.upsertBody) {
      return _submitBody(version: conflict.latest.version);
    }
    return _submitEdit(
      postId: conflict.latest.id,
      version: conflict.latest.version,
    );
  }

  Future<PostItem?> _submitCreate({
    String? identityToken,
    String? identityId,
    PostIdentityMode? identityMode,
    Future<bool> Function()? persistCreateIntent,
  }) async {
    final pending = state.pendingCreate;
    final input =
        pending?.input ??
        PostCreateInput(
          subthreadId: target.subthreadId,
          content: state.content,
          clientRequestId: _requestId,
          parentPostId: target.parentPostId,
          replyToPostId: target.replyToPostId,
          identityToken: identityToken,
          identityId: identityId,
          identityMode: identityMode,
        );
    // 请求发出前保存相同正文、身份和幂等键，异常退出后仍确认同一次发表。
    state = state.copyWith(
      isSubmitting: true,
      failure: null,
      conflict: null,
      pendingCreate: PendingPostCreate(input: input),
    );
    try {
      if (persistCreateIntent != null && !await persistCreateIntent()) {
        if (!mounted) return null;
        state = state.copyWith(
          isSubmitting: false,
          failure: const ApiFailure.localWrite(
            diagnosticCode: 'post_draft_save_failed',
          ),
        );
        return null;
      }
      if (!mounted) return null;
      final result = await _repository.create(input);
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        result: result,
        pendingCreate: null,
      );
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      final failure = _asFailure(error, '内容没有发布成功，请稍后重试。');
      final ambiguous = _isAmbiguous(failure);
      if (failure.businessCode == 40912) {
        _requestId = _createRequestId();
      }
      state = state.copyWith(
        isSubmitting: false,
        failure: failure,
        pendingCreate: ambiguous ? PendingPostCreate(input: input) : null,
      );
      return null;
    }
  }

  Future<PostItem?> _submitEdit({
    required String postId,
    required int version,
  }) async {
    state = state.copyWith(isSubmitting: true, failure: null, conflict: null);
    try {
      final result = await _repository.update(
        postId: postId,
        content: state.content,
        version: version,
      );
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        result: result,
        pendingCreate: null,
      );
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      final failure = _asFailure(error, '帖子没有更新成功，请稍后重试。');
      if (_isConflict(failure)) {
        return _resolveConflict(postId, state.content, failure);
      } else {
        state = state.copyWith(isSubmitting: false, failure: failure);
      }
      return null;
    }
  }

  Future<PostItem?> _submitBody({
    required int? version,
    String? identityToken,
    String? identityId,
    PostIdentityMode? identityMode,
    Future<bool> Function()? persistCreateIntent,
  }) async {
    final creating = target.postId == null && version == null;
    final pending = creating
        ? state.pendingCreate ??
              PendingPostCreate(
                input: PostCreateInput(
                  subthreadId: target.subthreadId,
                  content: state.content,
                  clientRequestId: _requestId,
                  identityToken: identityToken,
                  identityId: identityId,
                  identityMode: identityMode,
                ),
              )
        : null;
    state = state.copyWith(
      isSubmitting: true,
      failure: null,
      conflict: null,
      pendingCreate: pending,
    );
    try {
      if (creating &&
          persistCreateIntent != null &&
          !await persistCreateIntent()) {
        if (!mounted) return null;
        state = state.copyWith(
          isSubmitting: false,
          failure: const ApiFailure.localWrite(
            diagnosticCode: 'post_draft_save_failed',
          ),
        );
        return null;
      }
      if (!mounted) return null;
      final result = await _repository.upsertBody(
        subthreadId: target.subthreadId,
        content: pending?.input.content ?? state.content,
        version: version,
        identityId: pending != null ? pending.input.identityId : identityId,
        identityToken: pending != null
            ? pending.input.identityToken
            : identityToken,
        identityMode: pending != null
            ? pending.input.identityMode
            : identityMode,
      );
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        result: result,
        pendingCreate: null,
      );
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      final failure = _asFailure(error, '子贴正文没有更新成功，请稍后重试。');
      if (_isConflict(failure) && target.postId != null) {
        return _resolveConflict(target.postId!, state.content, failure);
      } else {
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          pendingCreate: creating && _isAmbiguous(failure) ? pending : null,
        );
      }
      return null;
    }
  }

  Future<PostItem?> _resolveConflict(
    String postId,
    String pendingContent,
    ApiFailure original,
  ) async {
    try {
      final latest = await _repository.fetchPost(postId);
      if (!mounted) return null;
      if (MarkdownContent.normalize(latest.content) ==
          MarkdownContent.normalize(pendingContent)) {
        state = state.copyWith(
          isSubmitting: false,
          failure: null,
          result: latest,
          pendingCreate: null,
          conflict: null,
        );
        return latest;
      }
      state = state.copyWith(
        isSubmitting: false,
        failure: original,
        pendingCreate: null,
        conflict: PostEditConflict(
          latest: latest,
          pendingContent: pendingContent,
        ),
      );
      return null;
    } on Object catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        failure: _asFailure(error, '读取最新版失败；当前编辑内容仍已保留。'),
      );
      return null;
    }
  }

  String? _validate(String content) {
    if (containsLocalImageMarker(content)) return '图片尚未就绪，请等待或移除。';
    if (MarkdownDiceContract.countMarkdownNodes(content) >
        MarkdownDiceContract.maximumNodesPerPost) {
      return '当前正文最多可插入 20 个骰子，请删除一个后重试。';
    }
    if (target.kind == PostComposerKind.upsertBody &&
        !MarkdownContent.hasVisibleNonDiceContent(content)) {
      return '子贴正文需要包含文字，骰子可作为补充。';
    }
    if (!MarkdownContent.hasVisibleContent(content)) {
      return '正文和骰子不能同时为空。';
    }
    if (content.runes.length > 10000) return '正文超过 10000 字符，请精简后重试。';
    return null;
  }

  /// 明确的身份冲突不曾写入；只有用户确认新身份后才建立新的发表操作。
  void confirmIdentityChange() {
    if (state.isSubmitting || state.pendingCreate != null) return;
    _requestId = _createRequestId();
    state = state.copyWith(failure: null);
  }

  void restorePendingCreate(PendingPostCreate pending) {
    if (target.kind != PostComposerKind.createFloor &&
        target.kind != PostComposerKind.createReply &&
        !(target.kind == PostComposerKind.upsertBody &&
            target.postId == null)) {
      return;
    }
    final input = pending.input;
    if (state.isSubmitting ||
        input.subthreadId != target.subthreadId ||
        input.parentPostId != target.parentPostId ||
        input.replyToPostId != target.replyToPostId) {
      return;
    }
    _requestId = input.clientRequestId;
    state = state.copyWith(
      content: input.content,
      documentRevision: state.documentRevision + 1,
      pendingCreate: pending,
    );
  }

  bool _isAmbiguous(ApiFailure failure) {
    final status = failure.httpStatus;
    return status == null || status >= 500;
  }

  bool _isConflict(ApiFailure failure) =>
      failure.businessCode == 40002 ||
      (failure.businessCode == null && failure.httpStatus == 409);

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

class PostActionController extends StateNotifier<PostActionState> {
  PostActionController(this._repository) : super(const PostActionState());

  final PostRepository _repository;

  Future<bool> remove(PostItem post) async {
    if (state.isBusy || post.isBody) return false;
    state = PostActionState(
      pendingPostId: post.id,
      pinRevision: state.pinRevision,
    );
    try {
      await _repository.remove(post.id);
      if (!mounted) return false;
      state = PostActionState(
        successMessage: '帖子已删除。',
        pinRevision: state.pinRevision,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      final failure = error is ApiFailure
          ? error
          : ApiFailure(userMessage: '帖子没有删除成功，请稍后重试。', cause: error);
      if (failure.businessCode == 40403) {
        state = PostActionState(
          successMessage: '帖子已删除。',
          pinRevision: state.pinRevision,
        );
        return true;
      }
      state = PostActionState(failure: failure, pinRevision: state.pinRevision);
      return false;
    }
  }

  Future<bool> setPinned(PostItem post, {required bool pinned}) async {
    if (state.isBusy ||
        post.isBody ||
        post.isDeleted ||
        post.parentPostId != null ||
        post.floorNumber == null) {
      return false;
    }
    final revision = state.pinRevision;
    state = PostActionState(pendingPostId: post.id, pinRevision: revision);
    try {
      await _repository.setPinned(post.id, pinned: pinned);
      if (!mounted) return false;
      state = PostActionState(
        successMessage: pinned ? '楼层已置顶。' : '已取消楼层置顶。',
        pinRevision: revision + 1,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = PostActionState(
        failure: error is ApiFailure
            ? error
            : mapApplicationFailure(error, '楼层置顶状态没有更新，请稍后重试。'),
        pinRevision: revision,
      );
      return false;
    }
  }

  void clearFeedback() {
    if (state.isBusy) return;
    state = PostActionState(pinRevision: state.pinRevision);
  }
}

final postDiscussionControllerProvider = StateNotifierProvider.autoDispose
    .family<
      PostDiscussionController,
      PostDiscussionState,
      PostDiscussionTarget
    >((ref, target) {
      ref.watch(viewerScopeProvider);

      return PostDiscussionController(
        ref.watch(postRepositoryProvider),
        target,
      );
    }, dependencies: [viewerScopeProvider, postRepositoryProvider]);

final postComposerControllerProvider = StateNotifierProvider.autoDispose
    .family<PostComposerController, PostComposerState, PostComposerTarget>((
      ref,
      target,
    ) {
      ref.watch(sessionScopeProvider);
      return PostComposerController(ref.watch(postRepositoryProvider), target);
    }, dependencies: [sessionScopeProvider, postRepositoryProvider]);

final postActionControllerProvider = StateNotifierProvider.autoDispose
    .family<PostActionController, PostActionState, String>((ref, threadId) {
      ref.watch(sessionScopeProvider);
      return PostActionController(ref.watch(postRepositoryProvider));
    }, dependencies: [sessionScopeProvider, postRepositoryProvider]);
