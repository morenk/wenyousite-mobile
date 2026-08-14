import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

abstract interface class AvatarRepository {
  Future<AvatarUpdateResult> setAvatar(String mediaId);

  Future<AvatarUpdateResult> removeAvatar();
}

abstract interface class MeProfileRepository {
  Future<MeProfileModel> fetchMe();

  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch);
}

abstract interface class PublicUserRepository {
  Future<PublicUserProfileModel> fetchUser(String userId);

  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  });

  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  });

  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId);

  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  });
}

final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  return const _UnboundAvatarRepository();
});

final meProfileRepositoryProvider = Provider<MeProfileRepository>((ref) {
  return const _UnboundMeProfileRepository();
});

final publicUserRepositoryProvider = Provider<PublicUserRepository>((ref) {
  return const _UnboundPublicUserRepository();
});

class _UnboundAvatarRepository implements AvatarRepository {
  const _UnboundAvatarRepository();

  @override
  Future<AvatarUpdateResult> removeAvatar() {
    return Future.error(_unboundError());
  }

  @override
  Future<AvatarUpdateResult> setAvatar(String mediaId) {
    return Future.error(_unboundError());
  }
}

class _UnboundMeProfileRepository implements MeProfileRepository {
  const _UnboundMeProfileRepository();

  @override
  Future<MeProfileModel> fetchMe() {
    return Future.error(_unboundError());
  }

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) {
    return Future.error(_unboundError());
  }
}

class _UnboundPublicUserRepository implements PublicUserRepository {
  const _UnboundPublicUserRepository();

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) {
    return Future.error(_unboundError());
  }

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() {
  return StateError('用户仓储尚未在应用组合根绑定。');
}
