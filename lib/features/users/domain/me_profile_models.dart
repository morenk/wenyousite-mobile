class MeProfileModel {
  const MeProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.level,
    required this.experience,
    required this.currentLevelExperience,
    required this.receivedTipTotal,
    required this.receivedTipCount,
    required this.showRecentReplies,
    required this.showPlayedThreads,
    required this.showBookmarks,
    required this.emailVerified,
    required this.followingCount,
    required this.followerCount,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    this.bio,
    this.nextLevelExperience,
  });

  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int level;
  final int experience;
  final int currentLevelExperience;
  final int? nextLevelExperience;
  final String receivedTipTotal;
  final int receivedTipCount;
  final bool showRecentReplies;
  final bool showPlayedThreads;
  final bool showBookmarks;
  final bool emailVerified;
  final int followingCount;
  final int followerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get levelProgress {
    final next = nextLevelExperience;
    if (next == null) return 1;
    final span = next - currentLevelExperience;
    if (span <= 0) return 1;
    return ((experience - currentLevelExperience) / span).clamp(0, 1);
  }

  MeProfileModel apply(MeProfileUpdateResult update) {
    return MeProfileModel(
      id: id,
      email: update.email,
      username: update.username,
      avatarUrl: update.avatarUrl,
      bio: update.bio,
      level: update.level,
      experience: update.experience,
      currentLevelExperience: update.currentLevelExperience,
      nextLevelExperience: update.nextLevelExperience,
      receivedTipTotal: update.receivedTipTotal,
      receivedTipCount: update.receivedTipCount,
      showRecentReplies: update.showRecentReplies,
      showPlayedThreads: update.showPlayedThreads,
      showBookmarks: update.showBookmarks,
      emailVerified: update.emailVerified,
      followingCount: followingCount,
      followerCount: followerCount,
      createdAt: createdAt,
      updatedAt: update.updatedAt,
    );
  }
}

class MeProfilePatch {
  const MeProfilePatch({
    this.username,
    this.bio,
    this.showRecentReplies,
    this.showPlayedThreads,
    this.showBookmarks,
  });

  final String? username;
  final String? bio;
  final bool? showRecentReplies;
  final bool? showPlayedThreads;
  final bool? showBookmarks;

  bool get isEmpty =>
      username == null &&
      bio == null &&
      showRecentReplies == null &&
      showPlayedThreads == null &&
      showBookmarks == null;
}

class MeProfileUpdateResult {
  const MeProfileUpdateResult({
    required this.email,
    required this.username,
    required this.level,
    required this.experience,
    required this.currentLevelExperience,
    required this.receivedTipTotal,
    required this.receivedTipCount,
    required this.showRecentReplies,
    required this.showPlayedThreads,
    required this.showBookmarks,
    required this.emailVerified,
    required this.updatedAt,
    this.avatarUrl,
    this.bio,
    this.nextLevelExperience,
  });

  final String email;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int level;
  final int experience;
  final int currentLevelExperience;
  final int? nextLevelExperience;
  final String receivedTipTotal;
  final int receivedTipCount;
  final bool showRecentReplies;
  final bool showPlayedThreads;
  final bool showBookmarks;
  final bool emailVerified;
  final DateTime updatedAt;
}
