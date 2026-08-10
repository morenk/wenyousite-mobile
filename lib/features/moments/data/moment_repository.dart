import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

abstract interface class MomentRepository {
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  });

  Future<CursorPage<MomentCard>> fetchBookmarks({
    String? cursor,
    int limit = 20,
  });

  Future<CursorPage<MomentCard>> fetchUserMoments({
    required String userId,
    String? cursor,
    int limit = 20,
  });

  Future<MomentDetail> fetchDetail(String momentId);

  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  });

  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  });

  Future<void> remove(String momentId);

  Future<MomentActionResult> setLike(String momentId, {required bool active});

  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
  });

  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  });

  Future<CursorPage<MomentComment>> fetchReplies({
    required String momentId,
    required String rootCommentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  });

  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId);

  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  });

  Future<void> removeComment(String momentId, String commentId);
}

class ApiMomentRepository implements MomentRepository {
  ApiMomentRepository(this._api);

  final MomentsApi _api;

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
        throw const ApiFailure(userMessage: '动态列表响应为空，请稍后重试。');
      }
      return _cardPage(
        envelope.data,
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<MomentCard>> fetchBookmarks({
    String? cursor,
    int limit = 20,
  }) async {
    _validatePage(limit);
    try {
      final envelope = (await _api.momentsBookmarks(
        cursor: _optionalText(cursor),
        limit: limit,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '动态收藏响应为空，请稍后重试。');
      }
      return _cardPage(
        envelope.data,
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
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
        throw const ApiFailure(userMessage: '用户动态响应为空，请稍后重试。');
      }
      return _cardPage(
        envelope.data,
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<MomentDetail> fetchDetail(String momentId) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final dto = (await _api.momentsDetail(id: id)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '动态详情响应为空，请稍后重试。');
      }
      return _detail(dto, expectedId: id);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    final draft = input.normalized();
    final requestId = _requiredText(clientRequestId, '发布请求 ID');
    try {
      final dto = (await _api.momentsCreate(
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
        throw const ApiFailure(userMessage: '服务端没有确认动态发布，请使用原请求重试。');
      }
      return _detail(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    final draft = input.normalized();
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
        throw const ApiFailure(userMessage: '动态编辑响应为空，请重新加载。');
      }
      return _detail(dto, expectedId: id);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(String momentId) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final dto = (await _api.momentsRemove(id: id)).data?.data;
      if (dto == null || _requiredText(dto.message, '删除确认').isEmpty) {
        throw const ApiFailure(userMessage: '服务端没有确认动态删除，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
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
        throw const ApiFailure(userMessage: '点赞状态响应为空，请重新加载。');
      }
      return _action(dto, expectedId: id, expectedActive: active);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final dto = active
          ? (await _api.momentsBookmark(id: id)).data?.data
          : (await _api.momentsUnbookmark(id: id)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '收藏状态响应为空，请重新加载。');
      }
      return _action(dto, expectedId: id, expectedActive: active);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
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
        throw const ApiFailure(userMessage: '评论列表响应为空，请稍后重试。');
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
      throw ApiFailure.fromDio(error);
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
        throw const ApiFailure(userMessage: '楼中楼响应为空，请稍后重试。');
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
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) async {
    final id = _requiredText(momentId, '动态 ID');
    try {
      final data = (await _api.momentsCommentAuthors(id: id)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '评论作者响应为空，请稍后重试。');
      }
      final authors = data.map(_author).toList(growable: false);
      _validateUnique(authors.map((item) => item.id), '评论作者列表');
      return List.unmodifiable(authors);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  }) async {
    final id = _requiredText(momentId, '动态 ID');
    final comment = input.normalized();
    final requestId = _requiredText(clientRequestId, '评论请求 ID');
    try {
      final dto = (await _api.momentsCreateComment(
        id: id,
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
        throw const ApiFailure(userMessage: '服务端没有确认评论发布，请使用原请求重试。');
      }
      return _comment(dto, expectedMomentId: id);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
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
        throw const ApiFailure(userMessage: '服务端没有确认评论删除，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
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
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
    if (expectedId != null && card.id != expectedId) {
      throw const ApiFailure(userMessage: '动态详情与当前页面不匹配，请重新加载。');
    }
    final images = dto.images.map(_media).toList(growable: false);
    _validateUnique(images.map((item) => item.id), '动态图片');
    if (images.length != card.imageCount || images.length > 9) {
      throw const ApiFailure(userMessage: '动态图片数量与详情不一致，请重新加载。');
    }
    if (card.coverMedia != null &&
        !images.any((image) => image.id == card.coverMedia!.id)) {
      throw const ApiFailure(userMessage: '动态封面不属于当前图片，请重新加载。');
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
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final safeId = _requiredText(id, '动态 ID');
    final mappedAuthor = _author(author);
    if (_requiredText(authorId, '动态作者 ID') != mappedAuthor.id) {
      throw const ApiFailure(userMessage: '动态作者信息不一致，请重新加载。');
    }
    final mappedCoverType = switch (coverType) {
      'IMAGE' => MomentCoverType.image,
      'TEXT' => MomentCoverType.text,
      _ => throw const ApiFailure(userMessage: '当前版本不支持服务端返回的动态封面类型。'),
    };
    final mappedTheme = switch (textCoverTheme) {
      'ROSE' => MomentTextCoverTheme.rose,
      'LILAC' => MomentTextCoverTheme.lilac,
      'MINT' => MomentTextCoverTheme.mint,
      'AMBER' => MomentTextCoverTheme.amber,
      _ => throw const ApiFailure(userMessage: '当前版本不支持服务端返回的动态封面主题。'),
    };
    final safeImageCount = _nonNegativeInteger(imageCount, '动态图片数量');
    final mappedCover = coverMedia == null ? null : _media(coverMedia);
    if ((mappedCoverType == MomentCoverType.image && mappedCover == null) ||
        (mappedCoverType == MomentCoverType.text && mappedCover != null) ||
        (mappedCover != null && safeImageCount < 1) ||
        safeImageCount > 9) {
      throw const ApiFailure(userMessage: '动态封面信息不完整，请重新加载。');
    }
    if (!RegExp(r'^(?:0|[1-9]\d*)$').hasMatch(tipTotal)) {
      throw const ApiFailure(userMessage: '动态加油数值无效，请重新加载。');
    }
    final safeTitle = _requiredText(title, '动态标题');
    if (safeTitle.length < 2 || safeTitle.length > 40) {
      throw const ApiFailure(userMessage: '动态标题长度无效，请重新加载。');
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  MomentRootComment _rootComment(
    MomentRootCommentResponseDto dto, {
    required String expectedMomentId,
  }) {
    if (dto.parentCommentId != null || dto.replyToComment != null) {
      throw const ApiFailure(userMessage: '主评论层级无效，请重新加载。');
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
      throw const ApiFailure(userMessage: '评论回复数量不一致，请重新加载。');
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
      throw const ApiFailure(userMessage: '楼中楼层级与主评论不匹配，请重新加载。');
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
      throw const ApiFailure(userMessage: '评论与当前动态不匹配，请重新加载。');
    }
    final text = _optionalText(content);
    final mappedMedia = media == null ? null : _media(media);
    final mappedSticker = sticker == null ? null : _sticker(sticker);
    if (mappedMedia != null && mappedSticker != null) {
      throw const ApiFailure(userMessage: '评论图片和表情不能同时存在，请重新加载。');
    }
    if (deleted &&
        (text != null || mappedMedia != null || mappedSticker != null)) {
      throw const ApiFailure(userMessage: '已删除评论仍包含内容，请重新加载。');
    }
    if (!deleted &&
        text == null &&
        mappedMedia == null &&
        mappedSticker == null) {
      throw const ApiFailure(userMessage: '评论内容不完整，请重新加载。');
    }
    final parentId = _optionalText(parentCommentId);
    final replyTarget = replyToComment == null
        ? null
        : MomentReplyTarget(
            id: _requiredText(replyToComment.id, '被回复评论 ID'),
            author: _author(replyToComment.author),
          );
    if (parentId == null && replyTarget != null) {
      throw const ApiFailure(userMessage: '评论回复层级无效，请重新加载。');
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
      throw const ApiFailure(userMessage: '图片尺寸信息不完整，请重新加载。');
    }
    return MomentMedia(
      id: _requiredText(dto.id, '图片 ID'),
      url: _requiredHttpUri(dto.url, '图片地址'),
      thumbnailUrl: _optionalHttpUri(dto.thumbnailUrl, '图片缩略图地址'),
      feedUrl: _optionalHttpUri(dto.feedUrl, '图片列表地址'),
      mediumUrl: _optionalHttpUri(dto.mediumUrl, '图片预览地址'),
      width: width,
      height: height,
    );
  }

  MomentSticker _sticker(MomentStickerResponseDto dto) {
    final width = _optionalPositiveInteger(dto.width, '表情宽度');
    final height = _optionalPositiveInteger(dto.height, '表情高度');
    if ((width == null) != (height == null)) {
      throw const ApiFailure(userMessage: '表情尺寸信息不完整，请重新加载。');
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
      throw const ApiFailure(userMessage: '动态操作状态与当前请求不一致，请重新加载。');
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

  void _validatePage(int limit) {
    if (limit < 1 || limit > 50) {
      throw const ApiFailure(userMessage: '分页大小无效，请重新加载。');
    }
  }

  String? _pageCursor(String? cursor, bool hasMore) {
    final safe = _optionalText(cursor);
    if (hasMore && safe == null) {
      throw const ApiFailure(userMessage: '分页游标缺失，请刷新列表。');
    }
    return safe;
  }

  void _validateUnique(Iterable<String> ids, String label) {
    final list = ids.toList(growable: false);
    if (list.toSet().length != list.length) {
      throw ApiFailure(userMessage: '$label包含重复内容，请重新加载。');
    }
  }

  String _requiredText(String value, String label) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw ApiFailure(userMessage: '$label不能为空。');
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _requiredHttpUri(String value, String label) {
    return _safeHttpUri(value, label).toString();
  }

  String? _optionalHttpUri(String? value, String label) {
    final normalized = _optionalText(value);
    return normalized == null
        ? null
        : _safeHttpUri(normalized, label).toString();
  }

  Uri _safeHttpUri(String value, String label) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw ApiFailure(userMessage: '$label不安全，请重新加载。');
    }
    return uri;
  }

  int _positiveInteger(num value, String label) {
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 1) {
      throw ApiFailure(userMessage: '$label无效，请重新加载。');
    }
    return integer;
  }

  int _nonNegativeInteger(num value, String label) {
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 0) {
      throw ApiFailure(userMessage: '$label无效，请重新加载。');
    }
    return integer;
  }

  int? _optionalPositiveInteger(num? value, String label) {
    return value == null ? null : _positiveInteger(value, label);
  }
}

final momentRepositoryProvider = Provider<MomentRepository>((ref) {
  return ApiMomentRepository(ref.watch(wenyouApiProvider).getMomentsApi());
});
