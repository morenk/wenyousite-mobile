import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

final mePageTestProfile = MeProfileModel(
  id: 'user-1',
  email: 'owner@example.com',
  username: '温柔测试员',
  bio: '一起写故事。',
  level: 4,
  experience: 150,
  currentLevelExperience: 100,
  nextLevelExperience: 200,
  receivedTipTotal: '18',
  receivedTipCount: 6,
  showRecentReplies: true,
  showPlayedThreads: true,
  showBookmarks: true,
  followingCount: 7,
  followerCount: 9,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 10, 8),
);

MeProfileModel mePageTestProfileWithAvatar(String avatarUrl) {
  return MeProfileModel(
    id: mePageTestProfile.id,
    email: mePageTestProfile.email,
    username: mePageTestProfile.username,
    avatarUrl: avatarUrl,
    bio: mePageTestProfile.bio,
    level: mePageTestProfile.level,
    experience: mePageTestProfile.experience,
    currentLevelExperience: mePageTestProfile.currentLevelExperience,
    nextLevelExperience: mePageTestProfile.nextLevelExperience,
    receivedTipTotal: mePageTestProfile.receivedTipTotal,
    receivedTipCount: mePageTestProfile.receivedTipCount,
    showRecentReplies: mePageTestProfile.showRecentReplies,
    showPlayedThreads: mePageTestProfile.showPlayedThreads,
    showBookmarks: mePageTestProfile.showBookmarks,
    followingCount: mePageTestProfile.followingCount,
    followerCount: mePageTestProfile.followerCount,
    createdAt: mePageTestProfile.createdAt,
    updatedAt: mePageTestProfile.updatedAt,
  );
}

MeProfileModel mePageTestProfileWithCover() {
  return MeProfileModel(
    id: mePageTestProfile.id,
    email: mePageTestProfile.email,
    username: mePageTestProfile.username,
    bio: mePageTestProfile.bio,
    level: mePageTestProfile.level,
    experience: mePageTestProfile.experience,
    currentLevelExperience: mePageTestProfile.currentLevelExperience,
    nextLevelExperience: mePageTestProfile.nextLevelExperience,
    receivedTipTotal: mePageTestProfile.receivedTipTotal,
    receivedTipCount: mePageTestProfile.receivedTipCount,
    showRecentReplies: mePageTestProfile.showRecentReplies,
    showPlayedThreads: mePageTestProfile.showPlayedThreads,
    showBookmarks: mePageTestProfile.showBookmarks,
    followingCount: mePageTestProfile.followingCount,
    followerCount: mePageTestProfile.followerCount,
    profileCover: const ProfileCoverModel(
      web: ProfileCoverVariant(url: 'https://cdn.example.com/cover-web.webp'),
      mobile: ProfileCoverVariant(
        url: 'https://cdn.example.com/cover-mobile.webp',
      ),
    ),
    createdAt: mePageTestProfile.createdAt,
    updatedAt: mePageTestProfile.updatedAt,
  );
}

final mePageTestAvatarInput = MediaUploadInput(
  filename: 'avatar.jpg',
  declaredContentType: 'image/jpeg',
  bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 0, 1]),
);

final mePageTestPreviewBytes = image.encodePng(
  image.Image(width: 160, height: 90),
);

final mePageTestCroppedPreviewInput = MediaUploadInput(
  filename: 'cropped.png',
  declaredContentType: 'image/png',
  bytes: Uint8List.fromList(mePageTestPreviewBytes),
);

final mePageTestAvatarSetResult = AvatarUpdateResult(
  avatarUrl: 'https://cdn.example.com/avatar.webp',
  updatedAt: DateTime.utc(2026, 8, 10, 11),
);

final mePageTestAvatarRemoveResult = AvatarUpdateResult(
  avatarUrl: null,
  updatedAt: DateTime.utc(2026, 8, 10, 12),
);

const mePageTestTokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

class MePageTestMemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class MePageTestFakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async => mePageTestTokens;
}
