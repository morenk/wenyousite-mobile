import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_states.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

export 'package:wenyousite_mobile/features/posts/application/post_states.dart';

typedef PostDiscussionTarget = ({String rootPostId, String? focusedReplyId});

class PostDiscussionController extends StateNotifier<PostDiscussionState> {
  PostDiscussionController(
    this._repository,
    this.target, {
    bool autoStart = true,
  }) : super(const PostDiscussionState()) {
    if (autoStart) unawaited(load());
  }

  final PostRepository _repository;
  final PostDiscussionTarget target;
  var _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    state = PostDiscussionState(order: state.order, authorId: state.authorId);
    try {
      final root = await _repository.fetchPost(target.rootPostId);
      _assertRoot(root);
      final page = await _repository.fetchReplies(
        rootPostId: target.rootPostId,
        order: state.order,
        authorId: state.authorId,
      );
      final replies = await _includeFocusedReply(root, page.items);
      if (!_isCurrent(epoch)) return;
      state = PostDiscussionState(
        phase: PostDiscussionPhase.ready,
        root: root,
        replies: replies,
        cursor: page.cursor,
        hasMore: page.hasMore,
        order: state.order,
        authorId: state.authorId,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = PostDiscussionState(
        phase: PostDiscussionPhase.failed,
        order: state.order,
        authorId: state.authorId,
        failure: _asFailure(error, '楼中楼讨论没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<void> refresh() async {
    if (state.phase != PostDiscussionPhase.ready || state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true, transientFailure: null);
    final epoch = ++_epoch;
    try {
      final root = await _repository.fetchPost(target.rootPostId);
      _assertRoot(root);
      final page = await _repository.fetchReplies(
        rootPostId: target.rootPostId,
        order: state.order,
        authorId: state.authorId,
      );
      final replies = await _includeFocusedReply(root, page.items);
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        root: root,
        replies: replies,
        cursor: page.cursor,
        hasMore: page.hasMore,
        isRefreshing: false,
        failure: null,
        transientFailure: null,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        isRefreshing: false,
        transientFailure: _asFailure(error, '楼中楼讨论刷新失败，请稍后重试。'),
      );
    }
  }

  Future<void> setOrder(PostReplyOrder order) async {
    if (order == state.order || state.phase != PostDiscussionPhase.ready) {
      return;
    }
    state = state.copyWith(order: order, authorId: null);
    await load();
  }

  Future<void> setAuthor(String? authorId) async {
    final normalized = authorId?.trim();
    final next = normalized == null || normalized.isEmpty ? null : normalized;
    if (next == state.authorId || state.phase != PostDiscussionPhase.ready) {
      return;
    }
    state = state.copyWith(authorId: next);
    await load();
  }

  Future<void> loadMore() async {
    if (state.phase != PostDiscussionPhase.ready ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    final epoch = _epoch;
    state = state.copyWith(isLoadingMore: true, transientFailure: null);
    try {
      final page = await _repository.fetchReplies(
        rootPostId: target.rootPostId,
        cursor: state.cursor,
        order: state.order,
        authorId: state.authorId,
      );
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        replies: _mergeReplies(state.replies, page.items, state.order),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      final failure = _asFailure(error, '更多回复没有加载完成，请稍后重试。');
      if (failure.isInvalidCursor) {
        await load();
        return;
      }
      state = state.copyWith(isLoadingMore: false, transientFailure: failure);
    }
  }

  void _assertRoot(PostItem root) {
    if (root.isBody || root.parentPostId != null) {
      throw const ApiFailure(userMessage: '只有主楼层可以打开楼中楼讨论。');
    }
  }

  Future<List<PostItem>> _includeFocusedReply(
    PostItem root,
    List<PostItem> replies,
  ) async {
    final focusedId = target.focusedReplyId;
    if (focusedId == null || replies.any((reply) => reply.id == focusedId)) {
      return replies;
    }
    final focused = await _repository.fetchPost(focusedId);
    if (focused.parentPostId != root.id ||
        focused.threadId != root.threadId ||
        focused.subthreadId != root.subthreadId) {
      throw const ApiFailure(userMessage: '目标回复不属于当前楼中楼讨论。');
    }
    if (state.authorId != null && focused.author.id != state.authorId) {
      return replies;
    }
    return _mergeReplies(replies, [focused], state.order);
  }

  bool _isCurrent(int epoch) => mounted && epoch == _epoch;

  static List<PostItem> _mergeReplies(
    Iterable<PostItem> current,
    Iterable<PostItem> incoming,
    PostReplyOrder order,
  ) {
    final byId = <String, PostItem>{
      for (final reply in current) reply.id: reply,
      for (final reply in incoming) reply.id: reply,
    };
    final result = byId.values.toList(growable: false)
      ..sort((left, right) {
        final compared = left.createdAt.compareTo(right.createdAt);
        return order == PostReplyOrder.oldest ? compared : -compared;
      });
    return List.unmodifiable(result);
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

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
    if (state.isSubmitting) return;
    state = state.copyWith(
      content: content,
      failure: null,
      result: null,
      conflict: null,
    );
  }

  void restoreContent(String content) {
    if (state.isSubmitting) return;
    state = state.copyWith(
      content: MarkdownContent.normalize(content),
      documentRevision: state.documentRevision + 1,
      failure: null,
      result: null,
      conflict: null,
    );
  }

  Future<PostItem?> submit() async {
    if (state.isSubmitting) return null;
    final validation = _validate(state.content);
    if (validation != null) {
      state = state.copyWith(failure: ApiFailure(userMessage: validation));
      return null;
    }
    return switch (target.kind) {
      PostComposerKind.createFloor ||
      PostComposerKind.createReply => _submitCreate(),
      PostComposerKind.editPost => _submitEdit(
        postId: target.postId!,
        version: target.version!,
      ),
      PostComposerKind.upsertBody => _submitBody(version: target.version),
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

  Future<PostItem?> _submitCreate() async {
    final pending = state.pendingCreate;
    final input =
        pending?.input ??
        PostCreateInput(
          subthreadId: target.subthreadId,
          content: state.content,
          clientRequestId: _requestId,
          parentPostId: target.parentPostId,
          replyToPostId: target.replyToPostId,
        );
    state = state.copyWith(isSubmitting: true, failure: null, conflict: null);
    PostItem? created;
    try {
      created = await _repository.create(input);
      var result = created;
      if (state.content != input.content) {
        result = await _repository.update(
          postId: created.id,
          content: state.content,
          version: created.version,
        );
      }
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
      if (created != null && _isConflict(failure)) {
        await _loadConflict(created.id, state.content, failure);
        return null;
      }
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
        await _loadConflict(postId, state.content, failure);
      } else {
        state = state.copyWith(isSubmitting: false, failure: failure);
      }
      return null;
    }
  }

  Future<PostItem?> _submitBody({required int? version}) async {
    state = state.copyWith(isSubmitting: true, failure: null, conflict: null);
    try {
      final result = await _repository.upsertBody(
        subthreadId: target.subthreadId,
        content: state.content,
        version: version,
      );
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, result: result);
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      final failure = _asFailure(error, '子贴正文没有更新成功，请稍后重试。');
      if (_isConflict(failure) && target.postId != null) {
        await _loadConflict(target.postId!, state.content, failure);
      } else {
        state = state.copyWith(isSubmitting: false, failure: failure);
      }
      return null;
    }
  }

  Future<void> _loadConflict(
    String postId,
    String pendingContent,
    ApiFailure original,
  ) async {
    try {
      final latest = await _repository.fetchPost(postId);
      if (!mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        failure: original,
        pendingCreate: null,
        conflict: PostEditConflict(
          latest: latest,
          pendingContent: pendingContent,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        failure: _asFailure(error, '云端最新版没有读取完成；当前编辑内容仍已保留。'),
      );
    }
  }

  String? _validate(String content) {
    if (!MarkdownContent.hasVisibleContent(content)) {
      return '正文和骰子不能同时为空。';
    }
    if (content.length > 10000) return '正文超过 10000 字符，请精简后重试。';
    return null;
  }

  bool _isAmbiguous(ApiFailure failure) {
    final status = failure.httpStatus;
    return status == null || status >= 500;
  }

  bool _isConflict(ApiFailure failure) =>
      failure.businessCode == 40002 || failure.httpStatus == 409;

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

class PostActionController extends StateNotifier<PostActionState> {
  PostActionController(this._repository) : super(const PostActionState());

  final PostRepository _repository;

  Future<bool> remove(PostItem post) async {
    if (state.isBusy || post.isBody) return false;
    state = PostActionState(pendingPostId: post.id);
    try {
      await _repository.remove(post.id);
      if (!mounted) return false;
      state = const PostActionState(successMessage: '帖子已删除。');
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = PostActionState(
        failure: error is ApiFailure
            ? error
            : ApiFailure(userMessage: '帖子没有删除成功，请稍后重试。', cause: error),
      );
      return false;
    }
  }

  void clearFeedback() {
    if (state.isBusy) return;
    state = const PostActionState();
  }
}

final postDiscussionControllerProvider = StateNotifierProvider.autoDispose
    .family<
      PostDiscussionController,
      PostDiscussionState,
      PostDiscussionTarget
    >((ref, target) {
      ref.watch(sessionControllerProvider);
      return PostDiscussionController(
        ref.watch(postRepositoryProvider),
        target,
      );
    }, dependencies: [postRepositoryProvider]);

final postComposerControllerProvider = StateNotifierProvider.autoDispose
    .family<PostComposerController, PostComposerState, PostComposerTarget>((
      ref,
      target,
    ) {
      ref.watch(sessionControllerProvider);
      return PostComposerController(ref.watch(postRepositoryProvider), target);
    }, dependencies: [postRepositoryProvider]);

final postActionControllerProvider = StateNotifierProvider.autoDispose
    .family<PostActionController, PostActionState, String>((ref, threadId) {
      ref.watch(sessionControllerProvider);
      return PostActionController(ref.watch(postRepositoryProvider));
    }, dependencies: [postRepositoryProvider]);
