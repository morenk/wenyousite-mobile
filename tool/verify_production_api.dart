import 'dart:convert';
import 'dart:io';

const _defaultBaseUrl = 'https://wenyou.site/api/v1';

Future<void> main(List<String> arguments) async {
  final baseUrl = _readBaseUrl(arguments);
  final metadata = _readContractMetadata();
  final expectedRevision = metadata['backendRevision'];
  final expectedContract = metadata['contractVersion'];
  if (expectedRevision == null || expectedContract == null) {
    stderr.writeln(
      'contracts/backend-contract.properties 缺少 backendRevision 或 contractVersion。',
    );
    exitCode = 2;
    return;
  }

  final openApi = _readJsonFile('contracts/openapi.json');
  final schema = _mapAt(openApi, const [
    'components',
    'schemas',
    'HomeThreadListItemResponseDto',
  ]);
  final coverSchema = _mapAt(schema, const ['properties', 'coverImages']);
  if (coverSchema['maxItems'] != 1) {
    stderr.writeln('本地 OpenAPI 的主题封面契约不是 maxItems=1。');
    exitCode = 2;
    return;
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  client.userAgent = 'wenyousite-mobile-production-contract-check';
  try {
    final meta = await _getEnvelope(client, baseUrl.resolve('meta'));
    final metaData = _asMap(meta['data'], 'GET /meta data');
    final actualContract = metaData['contractVersion'];
    final actualRevision = metaData['buildSha'];
    if (actualContract != expectedContract ||
        actualRevision != expectedRevision) {
      throw FormatException(
        '生产 API 与本地契约来源不一致：'
        'expected contract=$expectedContract build=$expectedRevision; '
        'actual contract=$actualContract build=$actualRevision',
      );
    }

    final threads = await _getEnvelope(
      client,
      baseUrl.resolve('threads?limit=1'),
    );
    final items = _asList(threads['data'], 'GET /threads data');
    if (items.isNotEmpty) {
      final item = _asMap(items.first, 'GET /threads data[0]');
      for (final field in const [
        'id',
        'owner',
        'defaultSubthread',
        '_count',
        'coverImages',
      ]) {
        if (!item.containsKey(field)) {
          throw FormatException('生产 GET /threads 缺少必需字段 $field。');
        }
      }
      _asMap(item['owner'], 'GET /threads owner');
      _asMap(item['_count'], 'GET /threads _count');
      final covers = _asList(item['coverImages'], 'GET /threads coverImages');
      if (covers.length > 1 || covers.any((value) => value is! String)) {
        throw const FormatException(
          '生产 GET /threads coverImages 必须是最多一项的 string[]。',
        );
      }
    }

    stdout.writeln(
      'Production API verified: contract=$actualContract '
      'build=$actualRevision; GET /threads schema compatible.',
    );
  } on Object catch (error) {
    stderr.writeln('生产 API 校验失败：$error');
    exitCode = 1;
  } finally {
    client.close(force: true);
  }
}

Uri _readBaseUrl(List<String> arguments) {
  var value =
      Platform.environment['PRODUCTION_API_BASE_URL'] ?? _defaultBaseUrl;
  for (var index = 0; index < arguments.length; index++) {
    if (arguments[index] == '--base-url' && index + 1 < arguments.length) {
      value = arguments[++index];
      continue;
    }
    throw FormatException('未知参数：${arguments[index]}');
  }
  final normalized = value.endsWith('/') ? value : '$value/';
  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    throw FormatException('生产 API 地址无效：$value');
  }
  return uri;
}

Map<String, String> _readContractMetadata() {
  final file = File('contracts/backend-contract.properties');
  if (!file.existsSync()) {
    throw const FileSystemException(
      '缺少契约元数据',
      'contracts/backend-contract.properties',
    );
  }
  return {
    for (final line in file.readAsLinesSync())
      if (line.trim().isNotEmpty && !line.trimLeft().startsWith('#'))
        line.substring(0, line.indexOf('=')).trim(): line
            .substring(line.indexOf('=') + 1)
            .trim(),
  };
}

Map<String, Object?> _readJsonFile(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  return _asMap(decoded, path);
}

Future<Map<String, Object?>> _getEnvelope(HttpClient client, Uri uri) async {
  final request = await client.getUrl(uri);
  request.headers
    ..set(HttpHeaders.acceptHeader, 'application/json')
    ..set(HttpHeaders.cacheControlHeader, 'no-cache');
  final response = await request.close().timeout(const Duration(seconds: 15));
  final body = await utf8.decoder.bind(response).join();
  if (response.statusCode != HttpStatus.ok) {
    throw HttpException(
      'GET $uri returned ${response.statusCode}: $body',
      uri: uri,
    );
  }
  final envelope = _asMap(jsonDecode(body), uri.toString());
  if (envelope['code'] != 0) {
    throw FormatException('GET $uri 返回非成功业务码：${envelope['code']}');
  }
  return envelope;
}

Map<String, Object?> _mapAt(Map<String, Object?> source, List<String> path) {
  Object? current = source;
  for (final segment in path) {
    current = _asMap(current, path.join('/'))[segment];
  }
  return _asMap(current, path.join('/'));
}

Map<String, Object?> _asMap(Object? value, String label) {
  if (value is! Map) throw FormatException('$label 不是 object。');
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<Object?> _asList(Object? value, String label) {
  if (value is! List) throw FormatException('$label 不是 array。');
  return value.cast<Object?>();
}
