import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'moment_pages_content_media_fixtures.dart';

MomentCard momentPagesTestCard({
  String id = 'moment-1',
  String title = '今日微光',
  MomentTextCoverTheme theme = MomentTextCoverTheme.mint,
  MomentMedia? coverMedia,
  int imageCount = 0,
  bool canInteract = true,
}) {
  final now = DateTime.utc(2026, 8, 10, 12);
  return MomentCard(
    id: id,
    author: momentPagesTestAuthor(),
    title: title,
    contentExcerpt: '动态正文是纯文本',
    coverType: coverMedia == null
        ? MomentCoverType.text
        : MomentCoverType.image,
    textCoverTheme: theme,
    coverMedia: coverMedia,
    imageCount: imageCount,
    likeCount: 2,
    commentCount: 1,
    bookmarkCount: 0,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: false,
    canInteract: canInteract,
    createdAt: now,
    updatedAt: now,
  );
}

class MomentPagesTestMomentPageWalletRepository extends Fake
    implements WalletRepository {}

MomentDetail momentPagesTestDetail() => MomentDetail(
  card: momentPagesTestCard(),
  content: '动态正文是纯文本',
  images: const [],
  version: 3,
  canEdit: false,
  canDelete: false,
);

MomentDetail momentPagesTestDetailWithImages() {
  const images = [
    MomentMedia(
      id: 'image-1',
      url: 'https://cdn.example.com/1.webp',
      mediumUrl: 'https://cdn.example.com/1-md.webp',
      width: 1200,
      height: 1600,
    ),
    MomentMedia(
      id: 'image-2',
      url: 'https://cdn.example.com/2.webp',
      mediumUrl: 'https://cdn.example.com/2-md.webp',
      width: 1600,
      height: 1000,
    ),
    MomentMedia(
      id: 'image-3',
      url: 'https://cdn.example.com/3.webp',
      mediumUrl: 'https://cdn.example.com/3-md.webp',
      width: 1000,
      height: 1000,
    ),
  ];
  return MomentDetail(
    card: momentPagesTestCard(coverMedia: images[2], imageCount: images.length),
    content: '动态正文是纯文本',
    images: images,
    version: 3,
    canEdit: false,
    canDelete: false,
  );
}

MomentDetail momentPagesTestEditableDetail({
  required String title,
  required int version,
}) => MomentDetail(
  card: momentPagesTestCard(title: title),
  content: '这是可以继续编辑的正文',
  images: const [],
  version: version,
  canEdit: true,
  canDelete: true,
);

MomentDetail momentPagesTestEditableDetailWithImages() {
  final detail = momentPagesTestDetailWithImages();
  return MomentDetail(
    card: detail.card,
    content: '带着图片继续分享此刻。',
    images: detail.images,
    version: detail.version,
    canEdit: true,
    canDelete: true,
  );
}

MomentRootComment momentPagesTestRootComment() => MomentRootComment(
  id: 'comment-root',
  momentId: 'moment-1',
  author: momentPagesTestAuthor(),
  content: '主评论',
  deleted: false,
  canDelete: false,
  createdAt: DateTime.utc(2026, 8, 10, 13),
  replyCount: 0,
  replies: const [],
);

SessionTokens momentPagesTestTokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'e30.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class MomentPagesTestMemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class MomentPagesTestFakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      momentPagesTestTokensFor('user-1');
}
