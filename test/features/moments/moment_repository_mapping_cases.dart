part of 'moment_repository_test.dart';

void registerMomentMappingCases() {
  test('信息流与搜索共用作者媒体字段，入口错误诊断仍各自保留', () async {
    for (final kind in ['valid', 'unsafe', 'dimension']) {
      final card = _cardDto().rebuild((b) {
        if (kind == 'unsafe') b.coverMedia.url = 'file:///private/cover.jpg';
        if (kind == 'dimension') b.coverMedia.height = null;
      });
      final search = MomentSearchResponseDto(
        (b) => b
          ..id = card.id
          ..authorId = card.authorId
          ..author.replace(card.author)
          ..title = card.title
          ..contentExcerpt = card.contentExcerpt
          ..coverType = MomentSearchResponseDtoCoverTypeEnum.IMAGE
          ..textCoverTheme = MomentSearchResponseDtoTextCoverThemeEnum.ROSE
          ..coverMedia.replace(card.coverMedia!)
          ..imageCount = card.imageCount
          ..likeCount = card.likeCount
          ..commentCount = card.commentCount
          ..bookmarkCount = card.bookmarkCount
          ..tipTotal = card.tipTotal
          ..viewerLiked = card.viewerLiked
          ..viewerBookmarked = card.viewerBookmarked
          ..createdAt = card.createdAt
          ..updatedAt = card.updatedAt
          ..relevance = 1,
      );
      final api = _MockMomentsApi();
      when(
        () => api.momentsList(cursor: null, limit: 20, feed: 'DISCOVER'),
      ).thenAnswer(
        (_) async => _response(
          '/api/v1/moments',
          MomentsList200Response(
            (b) => b
              ..code = ApiSuccessEnvelopeCodeEnum.number0
              ..message = 'ok'
              ..meta.update((m) => m.hasMore = false)
              ..data.add(card),
          ),
        ),
      );
      final feed = ApiMomentRepository(
        api,
      ).fetchFeed(mode: MomentFeedMode.discover);
      if (kind == 'valid') {
        final actual = (await feed).items.single;
        final found = MomentSearchMapper.map(search);
        expect(
          [
            actual.author.id,
            actual.author.username,
            actual.author.avatarUrl,
            actual.author.level,
          ],
          ['user-1', '温柔测试员', 'https://cdn.example.com/user-1-avatar.webp', 4],
        );
        expect(
          [
            found.author.id,
            found.author.username,
            found.author.avatarUrl,
            found.author.level,
          ],
          [
            actual.author.id,
            actual.author.username,
            actual.author.avatarUrl,
            actual.author.level,
          ],
        );
        for (final media in [actual.coverMedia!, found.coverMedia!]) {
          expect(
            [
              media.id,
              media.url,
              media.thumbnailUrl,
              media.feedUrl,
              media.mediumUrl,
              media.width,
              media.height,
              media.animated,
              media.contentType,
            ],
            [
              'media-1',
              'https://cdn.example.com/source.webp',
              'https://cdn.example.com/thumb.webp',
              'https://cdn.example.com/feed.webp',
              'https://cdn.example.com/medium.webp',
              1200,
              800,
              false,
              'image/webp',
            ],
          );
        }
      } else {
        await expectLater(
          feed,
          throwsA(
            isA<ApiFailure>().having(
              (e) => e.diagnosticCode,
              '诊断',
              kind == 'unsafe'
                  ? 'MOMENT_UNSAFE_URL'
                  : 'MOMENT_MEDIA_DIMENSION_MISMATCH',
            ),
          ),
        );
        expect(
          () => MomentSearchMapper.map(search),
          throwsA(
            isA<ApiFailure>()
                .having(
                  (e) => e.legacyUserMessage,
                  '原搜索错误',
                  kind == 'unsafe' ? '图片地址不安全，请重新搜索。' : '图片加载失败，请重新搜索。',
                )
                .having((e) => e.diagnosticCode, '保留搜索诊断边界', isNull),
          ),
        );
      }
    }
  });
}
