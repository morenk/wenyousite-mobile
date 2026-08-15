class ProfileCoverVariant {
  const ProfileCoverVariant({required this.url, this.width, this.height});

  final String url;
  final int? width;
  final int? height;
}

class ProfileCoverModel {
  const ProfileCoverModel({required this.web, this.mobile});

  final ProfileCoverVariant web;
  final ProfileCoverVariant? mobile;

  ProfileCoverVariant get preferredForMobile => mobile ?? web;

  Iterable<String> get cachedUrls sync* {
    yield web.url;
    if (mobile case final mobile?) yield mobile.url;
  }
}

class ProfileCoverUpdateResult {
  const ProfileCoverUpdateResult({
    required this.profileCover,
    required this.updatedAt,
  });

  final ProfileCoverModel? profileCover;
  final DateTime updatedAt;
}
