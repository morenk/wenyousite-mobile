class AppEnvironment {
  const AppEnvironment({
    required this.apiBaseUrl,
    this.supportedContractMajor = 5,
    this.supportedMarkdownContractVersions = const {3, 4, 5, 6},
  });

  factory AppEnvironment.fromDefines() {
    // 旧启动配置不能悄悄改用普通账号与草稿；必须显式移除后重新启动。
    if (const bool.hasEnvironment('WENYOU_PREVIEW_SESSION') ||
        const bool.hasEnvironment('WENYOU_PREVIEW_RUN') ||
        const bool.hasEnvironment('WENYOU_PREVIEW_SNAPSHOT_AT') ||
        const bool.hasEnvironment('WENYOU_PREVIEW_SOURCE_KIND') ||
        const bool.hasEnvironment('WENYOU_PREVIEW_SNAPSHOT_SHA') ||
        const bool.hasEnvironment('WENYOU_PREVIEW_MEDIA_ORIGIN')) {
      throw StateError('隔离开发预览已退役，请移除旧配置并明确选择 API 后重新启动。');
    }
    const environment = AppEnvironment(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://wenyou.site/api/v1',
      ),
    );
    return environment;
  }

  final String apiBaseUrl;
  final int supportedContractMajor;
  final Set<int> supportedMarkdownContractVersions;
  int get supportedMarkdownContractVersion => 5;

  Uri get apiBaseUri {
    final uri = Uri.parse(apiBaseUrl);
    if (!uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('API_BASE_URL 必须是绝对 HTTP(S) 地址', apiBaseUrl);
    }
    final normalizedPath = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return uri.replace(path: normalizedPath);
  }

  String get apiOrigin =>
      apiBaseUri.replace(path: '', query: null, fragment: null).toString();

  bool supportsContract(String contractVersion) {
    final major = int.tryParse(contractVersion.split('.').first);
    return major == supportedContractMajor;
  }

  bool supportsMarkdown(num markdownVersion) {
    return markdownVersion is int &&
        supportedMarkdownContractVersions.contains(markdownVersion);
  }
}
