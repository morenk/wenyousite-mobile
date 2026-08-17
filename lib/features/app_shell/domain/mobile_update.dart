enum MobileClientPlatform { android, ios, unsupported }

class MobilePlatformPolicy {
  const MobilePlatformPolicy({
    this.minimumSupportedBuild,
    this.recommendedBuild,
    this.updateUrl,
  });

  final int? minimumSupportedBuild;
  final int? recommendedBuild;
  final String? updateUrl;

  bool get isConfigured =>
      minimumSupportedBuild != null || recommendedBuild != null;
}

class InstalledAppInfo {
  const InstalledAppInfo({
    required this.platform,
    required this.version,
    required this.build,
  });

  final MobileClientPlatform platform;
  final String version;
  final int build;
}

enum MobileUpdateKind { required, recommended }

class MobileUpdateInfo {
  const MobileUpdateInfo({
    required this.kind,
    required this.platform,
    required this.currentVersion,
    required this.currentBuild,
    required this.targetBuild,
    this.updateUri,
  });

  final MobileUpdateKind kind;
  final MobileClientPlatform platform;
  final String currentVersion;
  final int currentBuild;
  final int targetBuild;
  final Uri? updateUri;

  bool get isRequired => kind == MobileUpdateKind.required;
  bool get canStartUpdate => updateUri != null;
}

MobileUpdateInfo? evaluateMobileUpdate({
  required InstalledAppInfo installed,
  required MobilePlatformPolicy policy,
}) {
  final minimum = policy.minimumSupportedBuild;
  final recommended = policy.recommendedBuild;
  final uri = _safeUpdateUri(policy.updateUrl);

  if (minimum != null && installed.build < minimum) {
    final target = recommended != null && recommended >= minimum
        ? recommended
        : minimum;
    return MobileUpdateInfo(
      kind: MobileUpdateKind.required,
      platform: installed.platform,
      currentVersion: installed.version,
      currentBuild: installed.build,
      targetBuild: target,
      updateUri: uri,
    );
  }

  // 推荐更新必须有安全地址；缺少配置时不打断用户正常使用。
  if (recommended != null && installed.build < recommended && uri != null) {
    return MobileUpdateInfo(
      kind: MobileUpdateKind.recommended,
      platform: installed.platform,
      currentVersion: installed.version,
      currentBuild: installed.build,
      targetBuild: recommended,
      updateUri: uri,
    );
  }
  return null;
}

Uri? _safeUpdateUri(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  return uri;
}
