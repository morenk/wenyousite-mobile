import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

const _requestId = '123e4567-e89b-42d3-a456-426614174000';

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCreateMomentDto());
    registerFallbackValue(_FakeUpdateMomentDto());
    registerFallbackValue(_FakeCreateMomentCommentDto());
    registerFallbackValue(_FakeMoveMomentBookmarkDto());
  });

  test('三个信息流、详情、评论、楼中楼与作者候选完整映射分页契约', () async {
    final api = _MockMomentsApi();
    when(
      () => api.momentsList(cursor: 'cursor-1', limit: 7, feed: 'FOLLOWING'),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments',
        MomentsList200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update(
              (meta) => meta
                ..cursor = 'cursor-2'
                ..hasMore = true,
            )
            ..data.add(_cardDto()),
        ),
      ),
    );
    when(
      () => api.momentsBookmarks(cursor: null, limit: 20, folderId: null),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/bookmarks',
        MomentsBookmarks200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update((meta) => meta.hasMore = false)
            ..data.add(_ownBookmarkDto()),
        ),
      ),
    );
    when(
      () => api.userMomentsList(id: 'user-1', cursor: null, limit: 20),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/users/user-1/moments',
        UserMomentsList200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update((meta) => meta.hasMore = false)
            ..data.add(_cardDto()),
        ),
      ),
    );
    when(() => api.momentsDetail(id: 'moment-1')).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/moment-1',
        MomentsDetail200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_detailDto()),
        ),
      ),
    );
    when(
      () => api.momentsCommentsList(
        id: 'moment-1',
        cursor: 'comments-1',
        limit: 9,
        order: 'NEWEST',
        authorId: 'user-2',
      ),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/moment-1/comments',
        MomentsCommentsList200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update(
              (meta) => meta
                ..cursor = 'comments-2'
                ..hasMore = true,
            )
            ..data.add(_rootCommentDto()),
        ),
      ),
    );
    when(
      () => api.momentsReplies(
        id: 'moment-1',
        commentId: 'comment-root',
        cursor: null,
        limit: 20,
        order: 'OLDEST',
        authorId: null,
      ),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/moment-1/comments/comment-root/replies',
        MomentsReplies200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update((meta) => meta.hasMore = false)
            ..data.add(_replyDto()),
        ),
      ),
    );
    when(() => api.momentsCommentAuthors(id: 'moment-1')).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/moment-1/comment-authors',
        MomentsCommentAuthors200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.add(_authorDto(id: 'user-2')),
        ),
      ),
    );
    final repository = ApiMomentRepository(api);

    final feed = await repository.fetchFeed(
      mode: MomentFeedMode.following,
      cursor: 'cursor-1',
      limit: 7,
    );
    final bookmarks = await repository.fetchBookmarks();
    final user = await repository.fetchUserMoments(userId: 'user-1');
    final detail = await repository.fetchDetail('moment-1');
    final comments = await repository.fetchComments(
      momentId: 'moment-1',
      order: MomentCommentOrder.newest,
      authorId: 'user-2',
      cursor: 'comments-1',
      limit: 9,
    );
    final replies = await repository.fetchReplies(
      momentId: 'moment-1',
      rootCommentId: 'comment-root',
      order: MomentCommentOrder.oldest,
    );
    final authors = await repository.fetchCommentAuthors('moment-1');

    expect(feed.cursor, 'cursor-2');
    expect(feed.items.single.coverMedia?.bestFeedUrl, contains('feed.webp'));
    expect(feed.items.single.tipTotal, '25');
    expect(bookmarks.items.single.viewerBookmarked, isTrue);
    expect(user.items.single.author.username, '温柔测试员');
    expect(detail.images.single.width, 1200);
    expect(detail.version, 3);
    expect(comments.cursor, 'comments-2');
    expect(
      comments.items.single.replies.single.parentCommentId,
      'comment-root',
    );
    expect(replies.items.single.replyToComment?.author.username, '温柔测试员');
    expect(authors.single.id, 'user-2');
  });

  test('创建编辑删除、点赞收藏与评论写操作严格透传所有幂等和版本字段', () async {
    final api = _MockMomentsApi();
    late CreateMomentDto createPayload;
    late UpdateMomentDto updatePayload;
    late CreateMomentCommentDto commentPayload;
    late MoveMomentBookmarkDto moveBookmarkPayload;
    when(
      () => api.momentsCreate(
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createMomentDto: any(named: 'createMomentDto'),
      ),
    ).thenAnswer((invocation) async {
      createPayload =
          invocation.namedArguments[#createMomentDto]! as CreateMomentDto;
      return _detailResponse<MomentsCreate201Response>(
        '/api/v1/moments',
        MomentsCreate201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_detailDto()),
        ),
      );
    });
    when(
      () => api.momentsUpdate(
        id: 'moment-1',
        updateMomentDto: any(named: 'updateMomentDto'),
      ),
    ).thenAnswer((invocation) async {
      updatePayload =
          invocation.namedArguments[#updateMomentDto]! as UpdateMomentDto;
      return _response(
        '/api/v1/moments/moment-1',
        MomentsUpdate200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_detailDto(version: 4)),
        ),
      );
    });
    when(() => api.momentsRemove(id: 'moment-1')).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/moment-1',
        MomentsRemove200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update((data) => data.message = '已删除'),
        ),
      ),
    );
    _stubActions(api);
    when(
      () => api.momentsMoveBookmark(
        id: 'moment-1',
        moveMomentBookmarkDto: any(named: 'moveMomentBookmarkDto'),
      ),
    ).thenAnswer((invocation) async {
      moveBookmarkPayload =
          invocation.namedArguments[#moveMomentBookmarkDto]!
              as MoveMomentBookmarkDto;
      return _response(
        '/api/v1/moments/moment-1/bookmark',
        MomentsMoveBookmark200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update(
              (data) => data
                ..momentId = 'moment-1'
                ..folderId = 'folder-2',
            ),
        ),
      );
    });
    when(
      () => api.momentsCreateComment(
        id: 'moment-1',
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createMomentCommentDto: any(named: 'createMomentCommentDto'),
      ),
    ).thenAnswer((invocation) async {
      commentPayload =
          invocation.namedArguments[#createMomentCommentDto]!
              as CreateMomentCommentDto;
      return _response(
        '/api/v1/moments/moment-1/comments',
        MomentsCreateComment201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_replyDto()),
        ),
      );
    });
    when(
      () =>
          api.momentsRemoveComment(id: 'moment-1', commentId: 'comment-reply'),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments/moment-1/comments/comment-reply',
        MomentsRemoveComment200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update((data) => data.message = '已删除'),
        ),
      ),
    );
    final repository = ApiMomentRepository(api);
    const input = MomentDraftInput(
      title: '  今日微光  ',
      content: '  一段纯文本  ',
      mediaIds: ['media-1'],
      coverMediaId: 'media-1',
    );

    await repository.create(input, clientRequestId: _requestId);
    final updated = await repository.update('moment-1', input, version: 3);
    await repository.remove('moment-1');
    final liked = await repository.setLike('moment-1', active: true);
    final unliked = await repository.setLike('moment-1', active: false);
    final bookmarked = await repository.setBookmark('moment-1', active: true);
    final unbookmarked = await repository.setBookmark(
      'moment-1',
      active: false,
    );
    await repository.moveBookmark('moment-1', 'folder-2');
    await repository.createComment(
      'moment-1',
      const MomentCommentInput(
        content: ' 回复 ',
        stickerAssetId: 'sticker-1',
        replyToCommentId: 'comment-root',
      ),
      clientRequestId: _requestId,
    );
    await repository.removeComment('moment-1', 'comment-reply');

    expect(createPayload.title, '今日微光');
    expect(createPayload.content, '一段纯文本');
    expect(createPayload.mediaIds.toList(), ['media-1']);
    expect(createPayload.coverMediaId, 'media-1');
    expect(createPayload.clientRequestId, _requestId);
    expect(updatePayload.version, 3);
    expect(updated.version, 4);
    expect(liked.active, isTrue);
    expect(unliked.active, isFalse);
    expect(bookmarked.count, 4);
    expect(unbookmarked.active, isFalse);
    expect(moveBookmarkPayload.folderId, 'folder-2');
    expect(commentPayload.content, '回复');
    expect(commentPayload.stickerAssetId, 'sticker-1');
    expect(commentPayload.replyToCommentId, 'comment-root');
    expect(commentPayload.clientRequestId, _requestId);
    verify(() => api.momentsRemove(id: 'moment-1')).called(1);
    verify(
      () =>
          api.momentsRemoveComment(id: 'moment-1', commentId: 'comment-reply'),
    ).called(1);
  });

  test('不安全 URL、未知封面、重复项目与互斥评论附件均拒绝进入界面', () async {
    final api = _MockMomentsApi();
    final repository = ApiMomentRepository(api);
    when(
      () => api.momentsList(cursor: null, limit: 20, feed: 'DISCOVER'),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments',
        MomentsList200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update((meta) => meta.hasMore = false)
            ..data.add(_cardDto(imageUrl: 'file:///private/image.webp')),
        ),
      ),
    );
    await expectLater(
      repository.fetchFeed(mode: MomentFeedMode.discover),
      throwsA(isA<ApiFailure>()),
    );

    when(
      () => api.momentsList(cursor: null, limit: 20, feed: 'DISCOVER'),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/moments',
        MomentsList200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update((meta) => meta.hasMore = false)
            ..data.addAll([_cardDto(), _cardDto()]),
        ),
      ),
    );
    await expectLater(
      repository.fetchFeed(mode: MomentFeedMode.discover),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      () => const MomentCommentInput(
        content: '内容',
        mediaId: 'media-1',
        stickerAssetId: 'sticker-1',
      ).normalized(),
      throwsA(isA<DomainValidationException>()),
    );
  });
}

class _MockMomentsApi extends Mock implements MomentsApi {}

class _FakeCreateMomentDto extends Fake implements CreateMomentDto {}

class _FakeUpdateMomentDto extends Fake implements UpdateMomentDto {}

class _FakeCreateMomentCommentDto extends Fake
    implements CreateMomentCommentDto {}

class _FakeMoveMomentBookmarkDto extends Fake
    implements MoveMomentBookmarkDto {}

Response<T> _response<T>(String path, T data) {
  return Response(
    requestOptions: RequestOptions(path: path),
    data: data,
  );
}

Response<T> _detailResponse<T>(String path, T data) => _response(path, data);

PostAuthorResponseDto _authorDto({String id = 'user-1'}) {
  return PostAuthorResponseDto(
    (builder) => builder
      ..id = id
      ..username = id == 'user-1' ? '温柔测试员' : '纸飞机'
      ..avatar = 'https://cdn.example.com/$id-avatar.webp'
      ..level = 4,
  );
}

MomentMediaResponseDto _mediaDto({
  String url = 'https://cdn.example.com/source.webp',
}) {
  return MomentMediaResponseDto(
    (builder) => builder
      ..id = 'media-1'
      ..url = url
      ..thumbnailUrl = 'https://cdn.example.com/thumb.webp'
      ..feedUrl = 'https://cdn.example.com/feed.webp'
      ..mediumUrl = 'https://cdn.example.com/medium.webp'
      ..width = 1200
      ..height = 800,
  );
}

MomentCardResponseDto _cardDto({
  String imageUrl = 'https://cdn.example.com/source.webp',
}) {
  final now = DateTime.utc(2026, 8, 10, 12);
  return MomentCardResponseDto(
    (builder) => builder
      ..id = 'moment-1'
      ..authorId = 'user-1'
      ..author.replace(_authorDto())
      ..title = '今日微光'
      ..contentExcerpt = '一段纯文本'
      ..coverType = MomentCardResponseDtoCoverTypeEnum.IMAGE
      ..textCoverTheme = MomentCardResponseDtoTextCoverThemeEnum.ROSE
      ..coverMedia.replace(_mediaDto(url: imageUrl))
      ..imageCount = 1
      ..likeCount = 2
      ..commentCount = 3
      ..bookmarkCount = 4
      ..tipTotal = '25'
      ..viewerLiked = false
      ..viewerBookmarked = true
      ..createdAt = now
      ..updatedAt = now,
  );
}

OwnMomentBookmarkResponseDto _ownBookmarkDto() {
  final now = DateTime.utc(2026, 8, 10, 12);
  return OwnMomentBookmarkResponseDto(
    (builder) => builder
      ..id = 'moment-1'
      ..authorId = 'user-1'
      ..author.replace(_authorDto())
      ..title = '今日微光'
      ..contentExcerpt = '一段纯文本'
      ..coverType = OwnMomentBookmarkResponseDtoCoverTypeEnum.IMAGE
      ..textCoverTheme = OwnMomentBookmarkResponseDtoTextCoverThemeEnum.ROSE
      ..coverMedia.replace(_mediaDto())
      ..imageCount = 1
      ..likeCount = 2
      ..commentCount = 3
      ..bookmarkCount = 4
      ..tipTotal = '25'
      ..viewerLiked = false
      ..viewerBookmarked = true
      ..createdAt = now
      ..updatedAt = now
      ..bookmarkFolderId = 'folder-default',
  );
}

MomentDetailResponseDto _detailDto({int version = 3}) {
  final card = _cardDto();
  return MomentDetailResponseDto(
    (builder) => builder
      ..id = card.id
      ..authorId = card.authorId
      ..author.replace(card.author)
      ..title = card.title
      ..contentExcerpt = card.contentExcerpt
      ..coverType = MomentDetailResponseDtoCoverTypeEnum.IMAGE
      ..textCoverTheme = MomentDetailResponseDtoTextCoverThemeEnum.ROSE
      ..coverMedia.replace(_mediaDto())
      ..imageCount = 1
      ..likeCount = card.likeCount
      ..commentCount = card.commentCount
      ..bookmarkCount = card.bookmarkCount
      ..tipTotal = card.tipTotal
      ..viewerLiked = card.viewerLiked
      ..viewerBookmarked = card.viewerBookmarked
      ..createdAt = card.createdAt
      ..updatedAt = card.updatedAt
      ..content = '一段纯文本'
      ..images.add(_mediaDto())
      ..version = version
      ..canEdit = true
      ..canDelete = true,
  );
}

MomentCommentResponseDto _replyDto() {
  return MomentCommentResponseDto(
    (builder) => builder
      ..id = 'comment-reply'
      ..momentId = 'moment-1'
      ..author.replace(_authorDto(id: 'user-2'))
      ..content = '楼中楼回复'
      ..parentCommentId = 'comment-root'
      ..replyToComment.update(
        (target) => target
          ..id = 'comment-root'
          ..author.replace(_authorDto()),
      )
      ..deleted = false
      ..canDelete = true
      ..createdAt = DateTime.utc(2026, 8, 10, 13),
  );
}

MomentRootCommentResponseDto _rootCommentDto() {
  return MomentRootCommentResponseDto(
    (builder) => builder
      ..id = 'comment-root'
      ..momentId = 'moment-1'
      ..author.replace(_authorDto())
      ..content = '主评论'
      ..deleted = false
      ..canDelete = true
      ..createdAt = DateTime.utc(2026, 8, 10, 12)
      ..replyCount = 1
      ..replies.add(_replyDto()),
  );
}

void _stubActions(_MockMomentsApi api) {
  when(() => api.momentsLike(id: 'moment-1')).thenAnswer(
    (_) async => _response(
      '/api/v1/moments/moment-1/like',
      MomentsLike201Response(
        (builder) => builder
          ..code = ApiSuccessEnvelopeCodeEnum.number0
          ..message = 'ok'
          ..data.update(
            (data) => data
              ..momentId = 'moment-1'
              ..count = 3
              ..active = true,
          ),
      ),
    ),
  );
  when(() => api.momentsUnlike(id: 'moment-1')).thenAnswer(
    (_) async => _response(
      '/api/v1/moments/moment-1/like',
      MomentsUnlike200Response(
        (builder) => builder
          ..code = ApiSuccessEnvelopeCodeEnum.number0
          ..message = 'ok'
          ..data.update(
            (data) => data
              ..momentId = 'moment-1'
              ..count = 2
              ..active = false,
          ),
      ),
    ),
  );
  when(() => api.momentsBookmark(id: 'moment-1')).thenAnswer(
    (_) async => _response(
      '/api/v1/moments/moment-1/bookmark',
      MomentsBookmark201Response(
        (builder) => builder
          ..code = ApiSuccessEnvelopeCodeEnum.number0
          ..message = 'ok'
          ..data.update(
            (data) => data
              ..momentId = 'moment-1'
              ..count = 4
              ..active = true,
          ),
      ),
    ),
  );
  when(() => api.momentsUnbookmark(id: 'moment-1')).thenAnswer(
    (_) async => _response(
      '/api/v1/moments/moment-1/bookmark',
      MomentsUnbookmark200Response(
        (builder) => builder
          ..code = ApiSuccessEnvelopeCodeEnum.number0
          ..message = 'ok'
          ..data.update(
            (data) => data
              ..momentId = 'moment-1'
              ..count = 3
              ..active = false,
          ),
      ),
    ),
  );
}
