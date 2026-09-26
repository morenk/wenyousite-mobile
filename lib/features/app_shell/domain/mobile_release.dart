import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

typedef MobileReleaseTarget = ({
  MobileClientPlatform platform,
  int build,
  String version,
});

class MobileRelease {
  const MobileRelease({
    required this.target,
    required this.summary,
    required this.items,
    required this.publishedAt,
    required this.revision,
  });

  final MobileReleaseTarget target;
  final String summary;
  final List<String> items;
  final DateTime publishedAt;
  final int revision;

  bool isInstalled(InstalledAppInfo installed) =>
      target.platform == installed.platform &&
      target.build == installed.build &&
      target.version == installed.version;

  bool matchesUpdate(MobileUpdateInfo update) =>
      target.platform == update.platform &&
      target.build == update.targetBuild &&
      target.version == update.targetVersion;
}

class MobileReleasePage {
  const MobileReleasePage({required this.items, this.nextCursor});

  final List<MobileRelease> items;
  final String? nextCursor;
}
