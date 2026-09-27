class AppEnvironment {
  const AppEnvironment({
    required this.apiBaseUrl,
    this.supportedContractMajor = 5,
    this.supportedMarkdownContractVersions = const {3, 4, 5},
    this.previewSession = '',
    this.previewSnapshotAt = '',
    this.previewRun = '',
    this.previewSnapshotSha = '',
    this.previewMediaOrigin = '',
  });

  factory AppEnvironment.fromDefines() {
    const environment = AppEnvironment(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://wenyou.site/api/v1',
      ),
      previewSession: String.fromEnvironment('WENYOU_PREVIEW_SESSION'),
      previewSnapshotAt: String.fromEnvironment('WENYOU_PREVIEW_SNAPSHOT_AT'),
      previewRun: String.fromEnvironment('WENYOU_PREVIEW_RUN'),
      previewSnapshotSha: String.fromEnvironment('WENYOU_PREVIEW_SNAPSHOT_SHA'),
      previewMediaOrigin: String.fromEnvironment('WENYOU_PREVIEW_MEDIA_ORIGIN'),
    );
    // 保持纯 Dart，可由契约校验 CLI 读取；与 Flutter kDebugMode 一致。
    environment.validatePreview(
      isDebugMode:
          !const bool.fromEnvironment('dart.vm.product') &&
          !const bool.fromEnvironment('dart.vm.profile'),
    );
    return environment;
  }

  final String apiBaseUrl;
  final int supportedContractMajor;
  final Set<int> supportedMarkdownContractVersions;
  final String previewSession;
  final String previewSnapshotAt;
  final String previewRun;
  final String previewSnapshotSha;
  final String previewMediaOrigin;

  bool get isPreview => previewSession.isNotEmpty;

  /// 旧环境仍使用原键和原目录；预览批次不读取或迁移旧数据。
  String storageName(String original) =>
      isPreview ? '$previewRun.$original' : original;

  void validatePreview({required bool isDebugMode}) {
    if (!isPreview) {
      if (previewRun.isNotEmpty ||
          previewSnapshotAt.isNotEmpty ||
          previewSnapshotSha.isNotEmpty ||
          previewMediaOrigin.isNotEmpty) {
        throw StateError('请重新启动开发预览后再试。');
      }
      return;
    }
    final uri = apiBaseUri;
    final media = Uri.tryParse(previewMediaOrigin);
    if (!isDebugMode ||
        !RegExp(r'^[a-z][a-z0-9-]{2,47}$').hasMatch(previewSession) ||
        !RegExp(r'^preview_[a-f0-9]{24}$').hasMatch(previewRun) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(previewSnapshotSha) ||
        DateTime.tryParse(previewSnapshotAt) == null ||
        media == null ||
        media.scheme != 'http' ||
        media.host != '127.0.0.1' ||
        media.port < 1024 ||
        media.port > 65535 ||
        {3000, 3001, 5432, 6379, uri.port}.contains(media.port) ||
        previewMediaOrigin != 'http://127.0.0.1:${media.port}' ||
        uri.scheme != 'http' ||
        uri.host != '127.0.0.1' ||
        uri.port < 1024 ||
        uri.port > 65535 ||
        {3000, 3001, 5432, 6379}.contains(uri.port) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.path != '/api/v1/') {
      throw StateError('开发预览仅允许 Debug 与已核验的独立 loopback API。');
    }
  }

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
