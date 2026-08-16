class AppEnvironment {
  const AppEnvironment({
    required this.apiBaseUrl,
    this.supportedContractMajor = 5,
    this.supportedMarkdownContractVersion = 3,
  });

  factory AppEnvironment.fromDefines() {
    return const AppEnvironment(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://wenyou.site/api/v1',
      ),
    );
  }

  final String apiBaseUrl;
  final int supportedContractMajor;
  final int supportedMarkdownContractVersion;

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
    return markdownVersion.toInt() == supportedMarkdownContractVersion;
  }
}
