import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';

final textFontServiceProvider = Provider<TextFontService>(
  (ref) => _processService ??= TextFontService(ref.read(wenyouApiProvider)),
);
TextFontService? _processService;

class TextFontService {
  TextFontService(this.api, {this.cache});
  final WenyouApi api;
  final TextFontCache? cache;
  Future<TextFontRuntime>? _loading;
  TextFontRuntime? _runtime;
  DateTime? _lastAttempt;
  Uri? _base;
  final Dio _assets = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      followRedirects: false,
    ),
  );

  Future<TextFontRuntime> load() {
    final stale =
        _lastAttempt == null ||
        DateTime.now().difference(_lastAttempt!) >= const Duration(minutes: 5);
    if (_loading == null || stale) {
      _lastAttempt = DateTime.now();
      _loading = _load();
    }
    return _loading!;
  }

  Future<TextFontRuntime> retry() {
    _loading = null;
    return load();
  }

  static Uri? trustedBase(String? source) {
    final uri = source == null ? null : Uri.tryParse(source);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !uri.path.endsWith('/')) {
      return null;
    }
    return uri;
  }

  Future<Uint8List> _download(TextFontAsset asset) async {
    final base = _base;
    if (base == null) throw const TextFontUnavailable();
    final cancel = CancelToken();
    final timer = Timer(const Duration(seconds: 15), () => cancel.cancel());
    final bytes = BytesBuilder(copy: false);
    try {
      final response = await _assets.get<ResponseBody>(
        base.resolve(asset.path).toString(),
        cancelToken: cancel,
        options: Options(
          headers: {'X-Request-ID': const Uuid().v4()},
          responseType: ResponseType.stream,
          followRedirects: false,
        ),
      );
      if (response.statusCode != 200 || response.data == null) {
        throw const TextFontUnavailable();
      }
      await for (final chunk in response.data!.stream.timeout(
        const Duration(seconds: 15),
      )) {
        if (bytes.length + chunk.length > asset.bytes) {
          throw const FormatException('字体资源超出大小');
        }
        bytes.add(chunk);
      }
      return bytes.takeBytes();
    } finally {
      timer.cancel();
      cancel.cancel();
    }
  }

  Future<TextFontRuntime> _load() async {
    final directory =
        cache?.directory ??
        _runtime?.cache.directory ??
        Directory(
          '${(await getApplicationSupportDirectory()).path}/text-fonts-v1',
        );
    final runtime = _runtime ??= TextFontRuntime(
      cache: cache ?? TextFontCache(directory),
      download: _download,
    );
    final pointer = File('${directory.path}/catalog.json');
    TextFontAsset? descriptor;
    runtime.assetsAvailable = false;
    try {
      final catalog = (await api.getMetaApi().textFontsGetCatalog(
        extra: ApiRequestPolicy.public.extra,
      )).data?.data;
      final manifest = catalog?.manifest;
      _base = trustedBase(catalog?.assetBaseUrl);
      if (manifest == null || _base == null) {
        runtime.updateManifest(runtime.manifest);
        return runtime;
      }
      descriptor = TextFontAsset(
        path: manifest.path,
        hash: manifest.sha256,
        bytes: manifest.bytes,
      );
      runtime.assetsAvailable = true;
      final data = await runtime.schedule(() => runtime.asset(descriptor!));
      runtime.updateManifest(TextFontManifest(data));
      runtime.cache.pinned.add(descriptor.hash);
      await directory.create(recursive: true);
      await pointer.writeAsString(
        jsonEncode({'base': _base.toString(), 'manifest': descriptor.toJson()}),
        flush: true,
      );
    } on Object {
      // 离线只读已验证的清单和缓存，不从持久化地址发起请求。
      runtime.assetsAvailable = false;
      try {
        if (await pointer.exists() && await pointer.length() < 4096) {
          final value =
              jsonDecode(await pointer.readAsString()) as Map<String, dynamic>;
          descriptor = TextFontAsset.fromJson(
            value['manifest'] as Map<String, dynamic>,
          );
          final data = await runtime.cache.read(descriptor);
          if (data != null) runtime.updateManifest(TextFontManifest(data));
        }
      } on Object {
        runtime.updateManifest(null);
      }
    }
    return runtime;
  }
}
