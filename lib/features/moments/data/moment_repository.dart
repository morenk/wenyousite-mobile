import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_comment_context_mapper.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_failure_messages.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_response_contract_validator.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

export 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart'
    show MomentRepository, momentRepositoryProvider;

class ApiMomentRepository implements MomentRepository {
  ApiMomentRepository(this._api);

  final MomentsApi _api;
  static const _contract = MomentResponseContractValidator();

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    _validatePage(limit);
    try {
      final envelope = (await _api.momentsList(
        cursor: _optionalText(cursor),
        limit: limit,
        feed: mode == MomentFeedMode.discover ? 'DISCOVER' : 'FOLLOWING',
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '动态列表加载失败，请稍后重试。');
      }
      return _cardPage(
        envelope.data,
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<CursorPage<MomentCard>> fetchBookmarks({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) async {
    _validatePage(limit);
    try {
      final envelope = (await _api.momentsBookmarks(
        cursor: _optionalText(cursor),
        limit: limit,
        folderId: _optionalText(folderId),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '动态收藏加载失败，请稍后重试。');
      }
      final items = envelope.data.map(_ownBookmarkCard).toList(growable: false);
      _validateUnique(items.map((item) => item.id), '动态收藏列表');
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: _pageCursor(envelope.meta.cursor, envelope.meta.hasMore),
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<CursorPage<MomentCard>> fetchUserMoments({
    required String userId,
    String? cursor,
    int limit = 20,
  }) async {
    final id = _requiredText(userId, '用户 ID');
    _validatePage(limit);
    try {
      final envelope = (await _api.userMomentsList(
        id: id,
        cursor: _optionalText(cursor),
        limit: limit,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '用户动态加载失败，请稍后重试。');
      }
      return _cardPage(
        envelope.data,
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<MomentDetail> fetchDetail(String momentId) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final dto = (await _api.momentsDetail(id: id)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '动态加载失败，请稍后重试。');
      }
      return _detail(dto, expectedId: id);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    final draft = _validated(input.normalized);
    final requestId = _requiredText(clientRequestId, '发布信息');
    try {
      final dto = (await _api.momentsCreate(
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createMomentDto: CreateMomentDto(
          (builder) => builder
            ..title = draft.title
            ..content = draft.content
            ..mediaIds.replace(draft.mediaIds)
            ..coverMediaId = draft.coverMediaId
            ..clientRequestId = requestId,
        ),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '发布失败，请重试。');
      }
      return _detail(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    final draft = _validated(input.normalized);
    if (version < 1) {
      throw const ApiFailure(userMessage: '动态版本无效，请重新加载后编辑。');
    }
    try {
      final dto = (await _api.momentsUpdate(
        id: id,
        updateMomentDto: UpdateMomentDto(
          (builder) => builder
            ..title = draft.title
            ..content = draft.content
            ..mediaIds.replace(draft.mediaIds)
            ..coverMediaId = draft.coverMediaId
            ..version = version,
        ),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '修改失败，请重新加载。');
      }
      return _detail(dto, expectedId: id);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<void> remove(String momentId) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final dto = (await _api.momentsRemove(id: id)).data?.data;
      if (dto == null || _requiredText(dto.message, '删除确认').isEmpty) {
        throw const ApiFailure(userMessage: '删除失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<MomentActionResult> setLike(
    String momentId, {
    required bool active,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final dto = active
          ? (await _api.momentsLike(id: id)).data?.data
          : (await _api.momentsUnlike(id: id)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '点赞失败，请重新加载。');
      }
      return _action(dto, expectedId: id, expectedActive: active);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    final targetFolderId = _optionalText(folderId);
    try {
      final dto = active
          ? (await _api.momentsBookmark(
              id: id,
              createMomentBookmarkDto: CreateMomentBookmarkDto(
                (builder) => builder.folderId = targetFolderId,
              ),
            )).data?.data
          : (await _api.momentsUnbookmark(id: id)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '收藏失败，请重新加载。');
      }
      return _action(dto, expectedId: id, expectedActive: active);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<void> moveBookmark(String momentId, String folderId) async {
    final id = _requiredText(momentId, '动态 ID');
    final targetFolderId = _requiredText(folderId, '收藏夹 ID');
    try {
      final placement = (await _api.momentsMoveBookmark(
        id: id,
        moveMomentBookmarkDto: MoveMomentBookmarkDto(
          (builder) => builder.folderId = targetFolderId,
        ),
      )).data?.data;
      if (placement == null ||
          placement.momentId != id ||
          placement.folderId != targetFolderId) {
        throw const ApiFailure(userMessage: '移动收藏失败，请重试。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: const {40400: '动态收藏或目标收藏夹已不存在，请刷新后重试。'},
      );
    }
  }

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    _validatePage(limit);
    try {
      final envelope = (await _api.momentsCommentsList(
        id: id,
        cursor: _optionalText(cursor),
        limit: limit,
        order: _orderValue(order),
        authorId: _optionalText(authorId),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '评论加载失败，请稍后重试。');
      }
      final items = envelope.data
          .map((dto) => _rootComment(dto, expectedMomentId: id))
          .toList(growable: false);
      _validateUnique(items.map((item) => item.id), '评论列表');
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: _pageCursor(envelope.meta.cursor, envelope.meta.hasMore),
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<CursorPage<MomentComment>> fetchReplies({
    required String momentId,
    required String rootCommentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    final rootId = _requiredText(rootCommentId, '主评论 ID');
    _validatePage(limit);
    try {
      final envelope = (await _api.momentsReplies(
        id: id,
        commentId: rootId,
        cursor: _optionalText(cursor),
        limit: limit,
        order: _orderValue(order),
        authorId: _optionalText(authorId),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '回复加载失败，请稍后重试。');
      }
      final items = envelope.data
          .map(
            (dto) =>
                _comment(dto, expectedMomentId: id, expectedRootId: rootId),
          )
          .toList(growable: false);
      _validateUnique(items.map((item) => item.id), '楼中楼列表');
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: _pageCursor(envelope.meta.cursor, envelope.meta.hasMore),
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<MomentCommentContext> fetchCommentContext({
    required String momentId,
    required String commentId,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    final targetId = _requiredText(commentId, '评论 ID');
    try {
      final dto = (await _api.momentsCommentContext(
        id: id,
        commentId: targetId,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '目标评论定位失败，请稍后重试。');
      }
      return MomentCommentContextMapper(
        mapComment: _comment,
        nonNegativeInteger: _nonNegativeInteger,
      ).map(dto, momentId: id, commentId: targetId);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final data = (await _api.momentsCommentAuthors(id: id)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '评论作者加载失败，请稍后重试。');
      }
      final authors = data.map(_author).toList(growable: false);
      _validateUnique(authors.map((item) => item.id), '评论作者列表');
      return List.unmodifiable(authors);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    final comment = _validated(input.normalized);
    final requestId = _requiredText(clientRequestId, '评论信息');
    try {
      final dto = (await _api.momentsCreateComment(
        id: id,
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createMomentCommentDto: CreateMomentCommentDto(
          (builder) => builder
            ..content = comment.content
            ..mediaId = comment.mediaId
            ..stickerAssetId = comment.stickerAssetId
            ..replyToCommentId = comment.replyToCommentId
            ..clientRequestId = requestId,
        ),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '评论失败，请重试。');
      }
      return _comment(dto, expectedMomentId: id);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  @override
  Future<void> removeComment(String momentId, String commentId) async {
    final id = _requiredText(momentId, '动态 ID');
    final safeCommentId = _requiredText(commentId, '评论 ID');
    try {
      final dto = (await _api.momentsRemoveComment(
        id: id,
        commentId: safeCommentId,
      )).data?.data;
      if (dto == null || _requiredText(dto.message, '删除确认').isEmpty) {
        throw const ApiFailure(userMessage: '删除失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: momentFailureMessages);
    }
  }

  CursorPage<MomentCard> _cardPage(
    Iterable<MomentCardResponseDto> data, {
    required String? cursor,
    required bool hasMore,
  }) {
    final items = data.map(_card).toList(growable: false);
    _validateUnique(items.map((item) => item.id), '动态列表');
    return CursorPage(
      items: List.unmodifiable(items),
      cursor: _pageCursor(cursor, hasMore),
      hasMore: hasMore,
    );
  }

  MomentCard _card(MomentCardResponseDto dto) {
    return _cardFields(
      id: dto.id,
      authorId: dto.authorId,
      author: dto.author,
      title: dto.title,
      contentExcerpt: dto.contentExcerpt,
      coverType: dto.coverType.name,
      textCoverTheme: dto.textCoverTheme.name,
      coverMedia: dto.coverMedia,
      imageCount: dto.imageCount,
      likeCount: dto.likeCount,
      commentCount: dto.commentCount,
      bookmarkCount: dto.bookmarkCount,
      tipTotal: dto.tipTotal,
      viewerLiked: dto.viewerLiked,
      viewerBookmarked: dto.viewerBookmarked,
      canInteract: dto.canInteract ?? true,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MomentCard _ownBookmarkCard(OwnMomentBookmarkResponseDto dto) {
    final bookmarkFolderId = _requiredText(dto.bookmarkFolderId, '动态收藏夹 ID');
    return _cardFields(
      id: dto.id,
      authorId: dto.authorId,
      author: dto.author,
      title: dto.title,
      contentExcerpt: dto.contentExcerpt,
      coverType: dto.coverType.name,
      textCoverTheme: dto.textCoverTheme.name,
      coverMedia: dto.coverMedia,
      imageCount: dto.imageCount,
      likeCount: dto.likeCount,
      commentCount: dto.commentCount,
      bookmarkCount: dto.bookmarkCount,
      tipTotal: dto.tipTotal,
      viewerLiked: dto.viewerLiked,
      viewerBookmarked: dto.viewerBookmarked,
      canInteract: dto.canInteract ?? true,
      bookmarkFolderId: bookmarkFolderId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MomentDetail _detail(MomentDetailResponseDto dto, {String? expectedId}) {
    final card = _cardFields(
      id: dto.id,
      authorId: dto.authorId,
      author: dto.author,
      title: dto.title,
      contentExcerpt: dto.contentExcerpt,
      coverType: dto.coverType.name,
      textCoverTheme: dto.textCoverTheme.name,
      coverMedia: dto.coverMedia,
      imageCount: dto.imageCount,
      likeCount: dto.likeCount,
      commentCount: dto.commentCount,
      bookmarkCount: dto.bookmarkCount,
      tipTotal: dto.tipTotal,
      viewerLiked: dto.viewerLiked,
      viewerBookmarked: dto.viewerBookmarked,
      canInteract: dto.canInteract ?? true,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
    if (expectedId != null && card.id != expectedId) {
      _contractViolation('MOMENT_ID_MISMATCH');
    }
    final images = dto.images.map(_media).toList(growable: false);
    _validateUnique(images.map((item) => item.id), '动态图片');
    if (images.length != card.imageCount || images.length > 9) {
      _contractViolation('MOMENT_IMAGE_COUNT_MISMATCH');
    }
    if (card.coverMedia != null &&
        !images.any((image) => image.id == card.coverMedia!.id)) {
      _contractViolation('MOMENT_COVER_NOT_IN_IMAGES');
    }
    return MomentDetail(
      card: card,
      content: dto.content,
      images: List.unmodifiable(images),
      version: _positiveInteger(dto.version, '动态版本'),
      canEdit: dto.canEdit,
      canDelete: dto.canDelete,
    );
  }

  MomentCard _cardFields({
    required String id,
    required String authorId,
    required PostAuthorResponseDto author,
    required String title,
    required String contentExcerpt,
    required String coverType,
    required String textCoverTheme,
    required MomentMediaResponseDto? coverMedia,
    required num imageCount,
    required num likeCount,
    required num commentCount,
    required num bookmarkCount,
    required String tipTotal,
    required bool viewerLiked,
    required bool viewerBookmarked,
    required bool canInteract,
    String? bookmarkFolderId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final safeId = _requiredText(id, '动态 ID');
    final mappedAuthor = _author(author);
    if (_requiredText(authorId, '动态作者 ID') != mappedAuthor.id) {
      _contractViolation('MOMENT_AUTHOR_MISMATCH');
    }
    final mappedCoverType = switch (coverType) {
      'IMAGE' => MomentCoverType.image,
      'TEXT' => MomentCoverType.text,
      _ => _contractViolation('MOMENT_COVER_TYPE_UNKNOWN'),
    };
    final mappedTheme = switch (textCoverTheme) {
      'ROSE' => MomentTextCoverTheme.rose,
      'LILAC' => MomentTextCoverTheme.lilac,
      'MINT' => MomentTextCoverTheme.mint,
      'AMBER' => MomentTextCoverTheme.amber,
      _ => _contractViolation('MOMENT_TEXT_COVER_THEME_UNKNOWN'),
    };
    final safeImageCount = _nonNegativeInteger(imageCount, '动态图片数量');
    final mappedCover = coverMedia == null ? null : _media(coverMedia);
    if ((mappedCoverType == MomentCoverType.image && mappedCover == null) ||
        (mappedCoverType == MomentCoverType.text && mappedCover != null) ||
        (mappedCover != null && safeImageCount < 1) ||
        safeImageCount > 9) {
      _contractViolation('MOMENT_COVER_STATE_MISMATCH');
    }
    if (!RegExp(r'^(?:0|[1-9]\d*)$').hasMatch(tipTotal)) {
      _contractViolation('MOMENT_TIP_TOTAL_INVALID');
    }
    final safeTitle = _requiredText(title, '动态标题');
    if (safeTitle.length < 2 || safeTitle.length > 40) {
      _contractViolation('MOMENT_TITLE_LENGTH_INVALID');
    }
    return MomentCard(
      id: safeId,
      author: mappedAuthor,
      title: safeTitle,
      contentExcerpt: contentExcerpt.trim(),
      coverType: mappedCoverType,
      textCoverTheme: mappedTheme,
      coverMedia: mappedCover,
      imageCount: safeImageCount,
      likeCount: _nonNegativeInteger(likeCount, '动态点赞数'),
      commentCount: _nonNegativeInteger(commentCount, '动态评论数'),
      bookmarkCount: _nonNegativeInteger(bookmarkCount, '动态收藏数'),
      tipTotal: tipTotal,
      viewerLiked: viewerLiked,
      viewerBookmarked: viewerBookmarked,
      canInteract: canInteract,
      bookmarkFolderId: bookmarkFolderId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  MomentRootComment _rootComment(
    MomentRootCommentResponseDto dto, {
    required String expectedMomentId,
  }) {
    if (dto.parentCommentId != null || dto.replyToComment != null) {
      _contractViolation(
        'MOMENT_ROOT_COMMENT_LEVEL_INVALID',
        userMessage: '评论加载失败，请重新加载。',
      );
    }
    final replies = dto.replies
        .map(
          (reply) => _comment(
            reply,
            expectedMomentId: expectedMomentId,
            expectedRootId: dto.id,
          ),
        )
        .toList(growable: false);
    _validateUnique(replies.map((item) => item.id), '评论回复');
    final replyCount = _nonNegativeInteger(dto.replyCount, '评论回复数');
    if (replies.length > replyCount) {
      _contractViolation(
        'MOMENT_REPLY_COUNT_MISMATCH',
        userMessage: '评论加载失败，请重新加载。',
      );
    }
    final base = _commentFields(
      id: dto.id,
      momentId: dto.momentId,
      author: dto.author,
      content: dto.content,
      media: dto.media,
      sticker: dto.sticker,
      parentCommentId: dto.parentCommentId,
      replyToComment: dto.replyToComment,
      deleted: dto.deleted,
      canDelete: dto.canDelete,
      createdAt: dto.createdAt,
      expectedMomentId: expectedMomentId,
    );
    return MomentRootComment(
      id: base.id,
      momentId: base.momentId,
      author: base.author,
      content: base.content,
      media: base.media,
      sticker: base.sticker,
      deleted: base.deleted,
      canDelete: base.canDelete,
      createdAt: base.createdAt,
      replyCount: replyCount,
      replies: List.unmodifiable(replies),
    );
  }

  MomentComment _comment(
    MomentCommentResponseDto dto, {
    required String expectedMomentId,
    String? expectedRootId,
  }) {
    final comment = _commentFields(
      id: dto.id,
      momentId: dto.momentId,
      author: dto.author,
      content: dto.content,
      media: dto.media,
      sticker: dto.sticker,
      parentCommentId: dto.parentCommentId,
      replyToComment: dto.replyToComment,
      deleted: dto.deleted,
      canDelete: dto.canDelete,
      createdAt: dto.createdAt,
      expectedMomentId: expectedMomentId,
    );
    if (expectedRootId != null && comment.parentCommentId != expectedRootId) {
      _contractViolation(
        'MOMENT_REPLY_ROOT_MISMATCH',
        userMessage: '回复加载失败，请重新加载。',
      );
    }
    return comment;
  }

  MomentComment _commentFields({
    required String id,
    required String momentId,
    required PostAuthorResponseDto author,
    required String? content,
    required MomentMediaResponseDto? media,
    required MomentStickerResponseDto? sticker,
    required String? parentCommentId,
    required MomentReplyTargetResponseDto? replyToComment,
    required bool deleted,
    required bool canDelete,
    required DateTime createdAt,
    required String expectedMomentId,
  }) {
    final safeMomentId = _requiredText(momentId, '评论动态 ID');
    if (safeMomentId != expectedMomentId) {
      _contractViolation(
        'MOMENT_COMMENT_TARGET_MISMATCH',
        userMessage: '评论加载失败，请重新加载。',
      );
    }
    final text = _optionalText(content);
    final mappedMedia = media == null ? null : _media(media);
    final mappedSticker = sticker == null ? null : _sticker(sticker);
    if (mappedMedia != null && mappedSticker != null) {
      _contractViolation(
        'MOMENT_COMMENT_MEDIA_STICKER_MISMATCH',
        userMessage: '评论加载失败，请重新加载。',
      );
    }
    if (deleted &&
        (text != null || mappedMedia != null || mappedSticker != null)) {
      _contractViolation(
        'MOMENT_DELETED_COMMENT_CONTENT_PRESENT',
        userMessage: '评论加载失败，请重新加载。',
      );
    }
    if (!deleted &&
        text == null &&
        mappedMedia == null &&
        mappedSticker == null) {
      throw const ApiFailure(userMessage: '评论加载失败，请重试。');
    }
    final parentId = _optionalText(parentCommentId);
    final replyTarget = replyToComment == null
        ? null
        : MomentReplyTarget(
            id: _requiredText(replyToComment.id, '被回复评论 ID'),
            author: _author(replyToComment.author),
          );
    if (parentId == null && replyTarget != null) {
      _contractViolation(
        'MOMENT_REPLY_LEVEL_INVALID',
        userMessage: '评论加载失败，请重新加载。',
      );
    }
    return MomentComment(
      id: _requiredText(id, '评论 ID'),
      momentId: safeMomentId,
      author: _author(author),
      content: text,
      media: mappedMedia,
      sticker: mappedSticker,
      parentCommentId: parentId,
      replyToComment: replyTarget,
      deleted: deleted,
      canDelete: canDelete,
      createdAt: createdAt,
    );
  }

  MomentAuthor _author(PostAuthorResponseDto dto) {
    return MomentAuthor(
      id: _requiredText(dto.id, '作者 ID'),
      username: _requiredText(dto.username, '作者用户名'),
      avatarUrl: _optionalHttpUri(dto.avatar, '作者头像'),
      level: _nonNegativeInteger(dto.level, '作者等级'),
    );
  }

  MomentMedia _media(MomentMediaResponseDto dto) {
    final width = _optionalPositiveInteger(dto.width, '图片宽度');
    final height = _optionalPositiveInteger(dto.height, '图片高度');
    if ((width == null) != (height == null)) {
      _contractViolation(
        'MOMENT_MEDIA_DIMENSION_MISMATCH',
        userMessage: '图片加载失败，请重新加载。',
      );
    }
    return MomentMedia(
      id: _requiredText(dto.id, '图片 ID'),
      url: _requiredHttpUri(dto.url, '图片地址'),
      thumbnailUrl: _optionalHttpUri(dto.thumbnailUrl, '图片缩略图地址'),
      feedUrl: _optionalHttpUri(dto.feedUrl, '图片列表地址'),
      mediumUrl: _optionalHttpUri(dto.mediumUrl, '图片预览地址'),
      contentType: dto.contentType?.trim(),
      animated: dto.animated,
      width: width,
      height: height,
    );
  }

  MomentSticker _sticker(MomentStickerResponseDto dto) {
    final width = _optionalPositiveInteger(dto.width, '表情宽度');
    final height = _optionalPositiveInteger(dto.height, '表情高度');
    if ((width == null) != (height == null)) {
      _contractViolation(
        'MOMENT_STICKER_DIMENSION_MISMATCH',
        userMessage: '表情加载失败，请重新加载。',
      );
    }
    return MomentSticker(
      id: _requiredText(dto.id, '表情 ID'),
      url: _requiredHttpUri(dto.url, '表情地址'),
      thumbnailUrl: _requiredHttpUri(dto.thumbnailUrl, '表情缩略图地址'),
      mediumUrl: _requiredHttpUri(dto.mediumUrl, '表情预览地址'),
      width: width,
      height: height,
      animated: dto.animated,
      frameCount: _positiveInteger(dto.frameCount, '表情帧数'),
      durationMs: _nonNegativeInteger(dto.durationMs, '表情时长'),
    );
  }

  MomentActionResult _action(
    MomentActionResponseDto dto, {
    required String expectedId,
    required bool expectedActive,
  }) {
    final id = _requiredText(dto.momentId, '动态操作 ID');
    if (id != expectedId || dto.active != expectedActive) {
      _contractViolation(
        'MOMENT_ACTION_RESULT_MISMATCH',
        userMessage: '操作失败，请重新加载后重试。',
      );
    }
    return MomentActionResult(
      momentId: id,
      count: _nonNegativeInteger(dto.count, '动态操作计数'),
      active: dto.active,
    );
  }

  String _orderValue(MomentCommentOrder order) {
    return order == MomentCommentOrder.newest ? 'NEWEST' : 'OLDEST';
  }

  void _validatePage(int limit) => _contract.validatePage(limit);

  String? _pageCursor(String? cursor, bool hasMore) =>
      _contract.pageCursor(cursor, hasMore);

  void _validateUnique(Iterable<String> ids, String label) =>
      _contract.validateUnique(ids, label);

  String _requiredText(String value, String label) =>
      _contract.requiredText(value, label);

  String? _optionalText(String? value) => _contract.optionalText(value);

  String _requiredHttpUri(String value, String label) =>
      _contract.requiredHttpUri(value, label);

  String? _optionalHttpUri(String? value, String label) =>
      _contract.optionalHttpUri(value, label);

  int _positiveInteger(num value, String label) =>
      _contract.positiveInteger(value, label);

  int _nonNegativeInteger(num value, String label) =>
      _contract.nonNegativeInteger(value, label);

  int? _optionalPositiveInteger(num? value, String label) =>
      _contract.optionalPositiveInteger(value, label);

  Never _contractViolation(
    String diagnosticCode, {
    String userMessage = '动态加载失败，请重新加载。',
  }) => _contract.violation(diagnosticCode, userMessage: userMessage);
}

final apiMomentRepositoryProvider = Provider<MomentRepository>((ref) {
  return ApiMomentRepository(ref.watch(wenyouApiProvider).getMomentsApi());
});

T _validated<T>(T Function() validation) {
  try {
    return validation();
  } on Object catch (error) {
    throw mapApplicationFailure(error, '提交内容格式无效，请检查后重试。');
  }
}
