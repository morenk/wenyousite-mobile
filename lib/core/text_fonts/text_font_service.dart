import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/platform/device_network_availability.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_legacy_mapping.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime_policy.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';

final textFontServiceProvider = Provider<TextFontService>((ref) {
  final service = _processService ??= TextFontService(
    ref.read(wenyouApiProvider),
    ledger: _engineLedger,
  );
  service.dynamicEnabled = ref
      .watch(appCapabilitiesProvider)
      .textFontV2Supported;
  return service;
});
TextFontService? _processService;
final _engineLedger = TextFontNativeLedger();

/// 冷启动元数据和字体需求共用引擎级窗口；事件不能重置退避/隔离。
class TextFontService with WidgetsBindingObserver {
  TextFontService(
    this.api, {
    this.cache,
    TextFontFetch? fetch,
    Duration Function()? elapsed,
    TextFontRetryLedger? retries,
    this.register,
    this.observePlatform = true,
    TextFontNativeLedger? ledger,
    TextFontRequest? dynamicRequest,
  }) : _fetch = fetch ?? TextFontTransport().fetch,
       ledger = ledger ?? TextFontNativeLedger(),
       _dynamicRequest = dynamicRequest ?? TextFontTransport().request,
       _elapsed = elapsed ?? (Stopwatch()..start()).readElapsed,
       retries = retries ?? TextFontRetryLedger();
  final WenyouApi api;
  final TextFontCache? cache;
  final TextFontFetch _fetch;
  final Duration Function() _elapsed;
  final TextFontRetryLedger retries;
  final TextFontRegister? register;
  final bool observePlatform;
  final TextFontNativeLedger ledger;
  final TextFontRequest _dynamicRequest;
  bool _dynamicActivated = false;
  bool get dynamicEnabled => _dynamicActivated;
  set dynamicEnabled(bool value) {
    if (!value || _dynamicActivated) return;
    _dynamicActivated = true;
    _dynamicDirty = true;
    _forceDynamic = true;
    // 切换状态来源立即停止旧清单呈现；原生注册账本不释放、不重置。
    _runtime?.updateManifest(null);
  }

  bool _dynamicDirty = false, _forceDynamic = false;
  DynamicFontRuntime? dynamicRuntime;
  final Object _pickerOwner = Object();
  Future<void> _operationTail = Future.value();

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _operationTail = _operationTail.then((_) async {
      try {
        result.complete(await action());
      } on Object catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  final window = TextFontDownloadWindow(
    period: const Duration(seconds: 60),
    maximumBytes: 24 * 1024 * 1024,
    maximumRequests: 64,
  );
  final _owners = <Object, Map<String, String>>{};
  final _cancels = <String, CancelToken>{};
  TextFontRuntime? _runtime;
  Future<TextFontRuntime>? _loading;
  StreamSubscription<bool>? _network;
  Timer? _timer;
  Uri? _base;
  TextFontAsset? _descriptor;
  Map<String, dynamic>? _policyJson;
  Duration _catalogDue = Duration.zero;
  Duration? _next;
  bool _foreground = true,
      _online = true,
      _observing = false,
      _disposed = false;
  bool _pointerRead = false, _withdrawn = false;
  bool _cancelledMetadata = false;
  int _epoch = 0;

  Future<TextFontRuntime> retain(Object owner, Map<String, String> texts) {
    _owners[owner] = Map.of(texts);
    if (dynamicEnabled && texts.isNotEmpty) _dynamicDirty = true;
    _runtime?.setDemand(owner, texts);
    if (!_observing && observePlatform) {
      _observing = true;
      WidgetsBinding.instance.addObserver(this);
      _network = deviceNetworkAvailability().listen(
        setOnline,
        onError: (Object _) {},
      );
    }
    return load();
  }

  void release(Object owner) {
    _owners.remove(owner);
    _runtime?.release(owner);
    if (_owners.isEmpty) {
      _timer?.cancel();
      for (final cancel in _cancels.values) {
        cancel.cancel('invisible');
      }
      if (_observing) WidgetsBinding.instance.removeObserver(this);
      _observing = false;
      unawaited(_network?.cancel());
      _network = null;
    }
  }

  void setOnline(bool online) {
    _online = online;
    _runtime?.demandQueue?.setOnline(online);
    if (online) {
      wake();
    } else {
      _timer?.cancel();
      for (final cancel in _cancels.values) {
        cancel.cancel('offline');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _runtime?.demandQueue?.setForeground(_foreground);
    if (_foreground) {
      _forceDynamic = true;
      _dynamicDirty = true;
      // 前台可重新探测可达性，覆盖系统未发送online事件的冷启动。
      setOnline(true);
    } else {
      _timer?.cancel();
      for (final cancel in _cancels.values) {
        cancel.cancel('background');
      }
    }
  }

  void wake() {
    if (!_disposed && _foreground && _online && _owners.isNotEmpty) {
      if (dynamicEnabled) _dynamicDirty = true;
      unawaited(load());
      _runtime?.demandQueue?.wake();
    }
  }

  Future<TextFontRuntime> load() {
    if (_loading case final loading?) return loading;
    final runtime = _runtime;
    if (runtime != null &&
        !(dynamicEnabled && _dynamicDirty) &&
        runtime.manifest != null &&
        _policyJson != null &&
        _elapsed() < _catalogDue) {
      // 新增可见片段不暂停仍有效的字体下载，也不重新占网络额度。
      _next = _catalogDue;
      _schedule();
      return Future.value(runtime);
    }
    return _loading = _serialize(_load).whenComplete(() {
      _loading = null;
      if (_cancelledMetadata) {
        _cancelledMetadata = false;
        _defer(_elapsed());
      }
      _schedule();
    });
  }

  Future<TextFontRuntime> retry() {
    _catalogDue = Duration.zero;
    return load();
  }

  Future<TextFontRuntime> openPicker() {
    _forceDynamic = true;
    _dynamicDirty = true;
    return retain(_pickerOwner, const {});
  }

  void closePicker() => release(_pickerOwner);

  bool canPasteFont(String id) {
    if (dynamicEnabled || MarkdownTextFont.isVersionId(id)) {
      final version = dynamicTextFontVersion(id);
      return version != null &&
          dynamicRuntime?.catalog.canPaste(version) == true;
    }
    return legacyTextFontVersions.containsKey(id);
  }

  Future<void> checkPasteVersions(Set<String> ids) async {
    final runtime = await load();
    if (!dynamicEnabled) return;
    await _serialize(() async {
      await runtime.demandQueue?.pauseForMetadata();
      try {
        for (final id
            in ids.map(dynamicTextFontVersion).nonNulls.toSet().take(256)) {
          try {
            await dynamicRuntime?.catalog.ensureVersion(id, force: true);
          } on Object {
            // 单个版本失败不阻断其他片段，仅允许该版本已有的可信状态。
          }
        }
      } finally {
        runtime.demandQueue?.setForeground(_foreground && !_disposed);
        runtime.demandQueue?.resumeAfterMetadata();
      }
    });
  }

  final _specimenOwners = <Object, String>{};
  void cancelSpecimen(Object owner) {
    final path = _specimenOwners.remove(owner);
    if (path != null) _cancels[path]?.cancel('invisible');
  }

  Future<Uint8List?> specimen(
    FontCatalogEntryDto entry, {
    Object? owner,
    bool Function()? isActive,
  }) async {
    if (isActive?.call() == false) return null;
    final runtime = await load();
    return _serialize(() async {
      if (isActive?.call() == false) return null;
      await runtime.demandQueue?.pauseForMetadata();
      try {
        if (isActive?.call() == false) return null;
        if (owner != null) {
          _specimenOwners[owner] =
              '${entry.assetBasePath}${entry.specimen.sha256}.${entry.specimen.format.name}';
        }
        return await dynamicRuntime?.specimen(entry);
      } finally {
        _specimenOwners.remove(owner);
        runtime.demandQueue?.setForeground(_foreground && !_disposed);
        runtime.demandQueue?.resumeAfterMetadata();
      }
    });
  }

  static Uri? trustedBase(String? source) {
    final uri = source == null ? null : Uri.tryParse(source);
    return uri != null &&
            uri.scheme == 'https' &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty &&
            !uri.hasQuery &&
            !uri.hasFragment &&
            uri.path.endsWith('/')
        ? uri
        : null;
  }

  void _defer(Duration at) {
    if (_next == null || at < _next!) _next = at;
  }

  void _schedule() {
    _timer?.cancel();
    if (_disposed || !_foreground || !_online || _owners.isEmpty) return;
    final at = _next;
    if (at != null) {
      final delay = at - _elapsed();
      _timer = Timer(
        delay > Duration.zero ? delay : const Duration(milliseconds: 1),
        wake,
      );
    }
  }

  Future<Uint8List?> _request(
    String key,
    Uri uri,
    int bytes,
    String mime,
  ) async {
    if (dynamicEnabled ||
        _disposed ||
        !_online ||
        !_foreground ||
        retries.isTerminal(key)) {
      return null;
    }
    final due = retries.availableAt(key);
    if (due > _elapsed()) {
      _defer(due);
      return null;
    }
    if (!window.reserve(bytes, _elapsed())) {
      _defer(window.availableAt(bytes, _elapsed()));
      return null;
    }
    final token = _cancels[key] = CancelToken();
    try {
      final result = await _fetch(uri, bytes, mime, token);
      if (dynamicEnabled) return null;
      if (token.isCancelled) {
        throw const TextFontTransferFailure(
          TextFontTransferFailureKind.cancelled,
        );
      }
      if (result.length > bytes) throw const FormatException('字体元数据超出大小');
      retries.success(key);
      return result;
    } on Object catch (error) {
      if (error is FormatException ||
          error is TextFontTransferFailure &&
              error.kind == TextFontTransferFailureKind.quarantined) {
        retries.quarantine(key);
      } else if (error is TextFontTransferFailure &&
          error.kind == TextFontTransferFailureKind.cancelled) {
        _cancelledMetadata = true;
      } else if (error is! TextFontTransferFailure ||
          error.kind != TextFontTransferFailureKind.cancelled) {
        retries.transientFailure(
          key,
          _elapsed(),
          retryAfter: error is TextFontTransferFailure
              ? error.retryAfter
              : null,
        );
        _defer(retries.availableAt(key));
      }
      return null;
    } finally {
      _cancels.remove(key);
      token.cancel();
    }
  }

  Map<String, dynamic> _data(Uint8List bytes) {
    final envelope = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (envelope['code'] != 0 || envelope['data'] is! Map<String, dynamic>) {
      throw const FormatException('无效字体元数据');
    }
    return envelope['data'] as Map<String, dynamic>;
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
      register: register,
      ledger: ledger,
    );
    runtime.requiresRuntimePolicy = true;
    _next = null;
    // 元数据事务与字体下载串行，等待已开始的下载结束/取消再预占。
    await runtime.demandQueue?.pauseForMetadata();
    try {
      final dynamic = dynamicRuntime ??= DynamicFontRuntime(
        runtime: runtime,
        window: window,
        read: _readDynamic,
        elapsed: _elapsed,
        cancel: (asset) => _cancels[asset.path]?.cancel('invisible'),
        retryLater: () => _defer(_elapsed() + const Duration(seconds: 30)),
      );
      await dynamic.catalog.restore();
      // 持久化撤回优先于新会话缺失/降级的能力响应。
      if (dynamic.catalog.hasWithdrawals) dynamicEnabled = true;
      if (dynamicEnabled) return runtime;
      if (!_pointerRead) {
        _pointerRead = true;
        await _restore(runtime, directory);
      }
      if (_elapsed() >= _catalogDue) {
        final data = await _request(
          'catalog',
          Uri.parse(api.dio.options.baseUrl).resolve('/api/v1/meta/text-fonts'),
          65536,
          'application/json',
        );
        if (dynamicEnabled) return runtime;
        if (data != null) {
          try {
            final dto = standardSerializers.deserializeWith(
              TextFontCatalogDto.serializer,
              _data(data),
            );
            if (dto == null) throw const FormatException('无效字体目录');
            final base = trustedBase(dto.assetBaseUrl);
            final descriptor = dto.manifest;
            _catalogDue = _elapsed() + const Duration(minutes: 5);
            _epoch++;
            if (base == null || descriptor == null) {
              _withdrawn = true;
              _base = null;
              _descriptor = null;
              _policyJson = null;
              runtime.assetsAvailable = false;
              runtime.updateManifest(null);
              await _writePointer(directory, {'withdrawn': true});
            } else {
              _withdrawn = false;
              _base = base;
              final next = TextFontAsset(
                path: descriptor.path,
                hash: descriptor.sha256,
                bytes: descriptor.bytes,
              );
              if (_descriptor?.hash != next.hash) {
                runtime.cache.pinned.remove(_descriptor?.hash);
                _policyJson = null;
                runtime.updateManifest(null);
              }
              _descriptor = next;
            }
          } on Object {
            retries.quarantine('catalog');
          }
        }
      }
      if (_catalogDue > _elapsed()) _defer(_catalogDue);
      final descriptor = _descriptor;
      if (_withdrawn || descriptor == null) return runtime;
      if (runtime.manifest == null) {
        final data =
            await _cached(runtime.cache, descriptor) ??
            (_base == null
                ? null
                : await _request(
                    descriptor.hash,
                    _base!.resolve(descriptor.path),
                    descriptor.bytes,
                    'application/json',
                  ));
        if (dynamicEnabled) return runtime;
        if (data != null) {
          try {
            if (!descriptor.verifies(data)) {
              throw const FormatException('字体清单校验失败');
            }
            runtime.updateManifest(TextFontManifest(data));
            runtime.cache.pinned.add(descriptor.hash);
            await runtime.cache.write(descriptor, data);
          } on FileSystemException {
            /* 已验证内存清单继续使用。 */
          } on Object {
            retries.quarantine(descriptor.hash);
            runtime.updateManifest(null);
          }
        }
      }
      if (runtime.manifest == null) return runtime;
      final policyKey = 'policy:${descriptor.hash}';
      if (_policyJson == null) {
        final bytes = await _request(
          policyKey,
          Uri.parse(
            api.dio.options.baseUrl,
          ).resolve('/api/v1/meta/text-fonts/runtime-policy'),
          65536,
          'application/json',
        );
        if (dynamicEnabled) return runtime;
        if (bytes != null) {
          try {
            final data = _data(bytes);
            final policy = TextFontRuntimePolicy(data, descriptor.hash);
            policy.freeze(runtime.manifest!);
            _policyJson = data;
          } on Object {
            retries.quarantine(policyKey);
          }
        }
      }
      runtime.assetsAvailable = _base != null;
      if (_policyJson case final policy?) {
        runtime.enableContinuous(
          TextFontRuntimePolicy(policy, descriptor.hash),
          window,
          _elapsed,
          (asset) => (_cancels[asset.path] ?? _cancels[asset.hash])?.cancel(
            'invisible',
          ),
        );
      }
      runtime.updateManifest(runtime.manifest);
      await _writePointer(directory, {
        'manifest': descriptor.toJson(),
        if (_policyJson != null) 'policy': _policyJson,
      });
      for (final entry in _owners.entries) {
        runtime.setDemand(entry.key, entry.value);
      }
      return runtime;
    } finally {
      if (dynamicEnabled && !_disposed) {
        final dynamic = dynamicRuntime!;
        final force = _forceDynamic;
        _forceDynamic = false;
        _dynamicDirty = false;
        try {
          await dynamic.refresh(
            _owners.values.expand((texts) => texts.keys),
            force: force,
          );
          runtime.assetsAvailable = true;
          dynamic.rebuild();
        } on Object {
          _defer(_elapsed() + const Duration(seconds: 30));
        }
        _defer(_elapsed() + const Duration(minutes: 5));
        for (final entry in _owners.entries) {
          runtime.setDemand(entry.key, entry.value);
        }
      }
      runtime.demandQueue?.setOnline(_online);
      runtime.demandQueue?.setForeground(_foreground && !_disposed);
      runtime.demandQueue?.resumeAfterMetadata();
    }
  }

  Future<Uint8List> _download(TextFontAsset asset) async {
    if (asset.path.startsWith('/api/v1/meta/text-fonts/v2/')) {
      final dynamic = dynamicRuntime;
      if (dynamic == null || !dynamic.allowsAsset(asset)) {
        throw const TextFontTransferFailure(
          TextFontTransferFailureKind.cancelled,
        );
      }
      final token = _cancels[asset.path] = CancelToken();
      try {
        final result = await _dynamicRequest(
          Uri.parse(api.dio.options.baseUrl).resolve(asset.path),
          asset.bytes,
          asset.path.endsWith('.json')
              ? 'application/json'
              : asset.path.endsWith('.otf')
              ? 'font/otf'
              : 'font/ttf',
          token,
        );
        if (result.status == 410) {
          dynamic.assetWithdrawn(asset);
          await dynamic.catalog.persist();
        }
        if (result.status != 200 || !dynamic.allowsAsset(asset)) {
          throw const TextFontTransferFailure(
            TextFontTransferFailureKind.cancelled,
          );
        }
        return result.bytes;
      } finally {
        _cancels.remove(asset.path);
        token.cancel();
      }
    }
    final base = _base, epoch = _epoch;
    if (dynamicEnabled || base == null || _withdrawn) {
      throw const TextFontTransferFailure(
        TextFontTransferFailureKind.cancelled,
      );
    }
    final cancel = _cancels[asset.hash] = CancelToken();
    try {
      final result = await _fetch(
        base.resolve(asset.path),
        asset.bytes,
        asset.path.endsWith('.json')
            ? 'application/json'
            : asset.path.endsWith('.txt')
            ? 'text/plain'
            : asset.path.endsWith('.otf')
            ? 'font/otf'
            : 'font/ttf',
        cancel,
      );
      if (dynamicEnabled || epoch != _epoch || _withdrawn) {
        throw const TextFontTransferFailure(
          TextFontTransferFailureKind.cancelled,
        );
      }
      return result;
    } finally {
      _cancels.remove(asset.hash);
      cancel.cancel();
    }
  }

  Future<TextFontResponse?> _readDynamic(
    String path,
    int bytes,
    String mime, {
    String? etag,
  }) async {
    if (_disposed || !_foreground || !_online || bytes > window.maximumBytes) {
      return null;
    }
    final key = 'v2:$path';
    if (retries.isTerminal(key)) return null;
    if (retries.availableAt(key) > _elapsed()) {
      _defer(retries.availableAt(key));
      return null;
    }
    if (!window.reserve(bytes, _elapsed())) {
      _defer(window.availableAt(bytes, _elapsed()));
      return null;
    }
    final token = _cancels[path] = CancelToken();
    try {
      final result = await _dynamicRequest(
        Uri.parse(api.dio.options.baseUrl).resolve(path),
        bytes,
        mime,
        token,
        etag: etag,
      );
      if (token.isCancelled) return null;
      if (result.bytes.length > bytes) throw const FormatException('动态字体响应超限');
      retries.success(key);
      return result;
    } on Object catch (error) {
      if (error is TextFontTransferFailure &&
          error.kind == TextFontTransferFailureKind.cancelled) {
        return null;
      }
      if (path.contains('/assets/') &&
          (error is FormatException ||
              error is TextFontTransferFailure &&
                  error.kind == TextFontTransferFailureKind.quarantined)) {
        retries.quarantine(key);
      } else {
        retries.transientFailure(
          key,
          _elapsed(),
          retryAfter: error is TextFontTransferFailure
              ? error.retryAfter
              : null,
        );
        _defer(retries.availableAt(key));
      }
      return null;
    } finally {
      _cancels.remove(path);
      token.cancel();
    }
  }

  Future<Uint8List?> _cached(TextFontCache cache, TextFontAsset asset) async {
    try {
      return await cache.read(asset);
    } on FileSystemException {
      return null;
    }
  }

  Future<void> _writePointer(
    Directory directory,
    Map<String, Object?> value,
  ) async {
    try {
      await directory.create(recursive: true);
      await File(
        '${directory.path}/catalog.json',
      ).writeAsString(jsonEncode(value), flush: true);
    } on FileSystemException {
      /* 缓存故障不撤销已验证结果，也不重下载。 */
    }
  }

  Future<void> _restore(TextFontRuntime runtime, Directory directory) async {
    try {
      final pointer = File('${directory.path}/catalog.json');
      if (!await pointer.exists() || await pointer.length() > 65536) return;
      final value =
          jsonDecode(await pointer.readAsString()) as Map<String, dynamic>;
      if (value['withdrawn'] == true) return;
      final descriptor = TextFontAsset.fromJson(
        value['manifest'] as Map<String, dynamic>,
      );
      final data = await runtime.cache.read(descriptor);
      if (data == null || dynamicEnabled) return;
      final manifest = TextFontManifest(data);
      _descriptor = descriptor;
      runtime.updateManifest(manifest);
      if (value['policy'] case final Map<String, dynamic> policy) {
        TextFontRuntimePolicy(policy, descriptor.hash).freeze(manifest);
        _policyJson = policy;
      }
    } on Object {
      /* 离线仅读校验缓存，不使用持久化来源发请求。 */
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    for (final cancel in _cancels.values) {
      cancel.cancel('disposed');
    }
    unawaited(_network?.cancel());
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    _runtime?.demandQueue?.dispose();
  }
}

extension on Stopwatch {
  Duration readElapsed() => elapsed;
}
