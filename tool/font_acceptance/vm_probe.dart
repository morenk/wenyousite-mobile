import 'dart:async';
import 'dart:convert';
import 'dart:io';

const fontServiceLibrary =
    'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
const acceptanceApi = 'http://127.0.0.1:38876/api/v1';

Uri localVmSocket(String source) {
  final uri = Uri.parse(source);
  if (!['http', 'ws'].contains(uri.scheme) ||
      !['127.0.0.1', 'localhost', '::1'].contains(uri.host) ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw const FormatException('VM Service 必须是无用户信息的本机地址');
  }
  final path = uri.path.endsWith('/ws')
      ? uri.path
      : '${uri.path.endsWith('/') ? uri.path : '${uri.path}/'}ws';
  return uri.replace(scheme: 'ws', path: path);
}

/// 只生成固定的只读表达式；字体 ID 不能携带 Dart 代码。
String fontSnapshotExpression(List<String> ids) {
  if (ids.length > 32 ||
      ids.any(
        (id) =>
            !RegExp(r'^(tfv_[a-f0-9]{32}|[a-z][a-z0-9-]{0,63})$').hasMatch(id),
      )) {
    throw const FormatException('每阶段最多观察32个合法字体 ID');
  }
  return '''jsonEncode({
    'serviceReady': _processService != null,
    'api': _processService?.api.dio.options.baseUrl,
    'dynamicEnabled': _processService?.dynamicEnabled,
    'catalogRevision': _processService?.dynamicRuntime?.catalog.revision,
    'ledger': {
      'attemptedKeys': _engineLedger.attemptedCount,
      'loadedKeys': _engineLedger.loadedCount,
      'chargedInputBytes': _engineLedger.chargedInputBytes,
      'maximumInputBytes': _engineLedger.maximumInputBytes,
      'maximumKeys': _engineLedger.maximumKeys
    },
    'queue': {
      'requests': _processService?._runtime?.demandQueue?.requests,
      'attemptedDownloadBytes': _processService?._runtime?.demandQueue?.attemptedDownloadBytes,
      'verifiedDownloadBytes': _processService?._runtime?.demandQueue?.verifiedDownloadBytes,
      'pending': _processService?._runtime?.demandQueue?.pendingCount
    },
    'fonts': {
      for (final id in <String>${jsonEncode(ids)}) id: {
        'version': dynamicTextFontVersion(id),
        'selectable': dynamicTextFontVersion(id) == null ? false :
          _processService?.dynamicRuntime?.catalog.canSelect(dynamicTextFontVersion(id)!),
        'pasteAllowed': _processService?.canPasteFont(id),
        'renderAllowed': dynamicTextFontVersion(id) == null ? false :
          _processService?.dynamicRuntime?.catalog.canRender(dynamicTextFontVersion(id)!),
        'withdrawn': dynamicTextFontVersion(id) == null ? false :
          _processService?.dynamicRuntime?.catalog.withdrawn(dynamicTextFontVersion(id)!),
        'loadedFamilies': _processService?._runtime?.loadedFamilies(id)
      }
    }
  })''';
}

class FontVmProbe {
  FontVmProbe._(this.socket) {
    _subscription = socket.listen(
      _message,
      onError: (Object _) => _disconnect(),
      onDone: _disconnect,
    );
  }
  static Future<FontVmProbe> connect(String uri) async => FontVmProbe._(
    await WebSocket.connect(
      localVmSocket(uri).toString(),
    ).timeout(const Duration(seconds: 10)),
  );
  final WebSocket socket;
  late final StreamSubscription<Object?> _subscription;
  final _pending = <String, Completer<Map<String, Object?>>>{};
  final invalidations = <String>[];
  String? isolateId, isolateGroupId, libraryId;
  int _sequence = 0;
  bool _closed = false;

  void _message(Object? raw) {
    final message = jsonDecode(raw as String) as Map;
    if (message['method'] == 'streamNotify') {
      final parameters = message['params'] as Map;
      final event = parameters['event'] as Map;
      final eventIsolate = event['isolate'] as Map?;
      final eventGroup = event['isolateGroup'] as Map?;
      final kind = event['kind'] as String?;
      if (kind == 'IsolateReload' && eventGroup?['id'] == isolateGroupId ||
          kind == 'IsolateExit' && eventIsolate?['id'] == isolateId) {
        invalidations.add(kind!);
      }
      return;
    }
    final completer = _pending.remove(message['id']);
    if (completer == null) return;
    if (message['error'] != null) {
      completer.completeError(StateError('VM 只读采样请求失败'));
    } else {
      completer.complete(Map<String, Object?>.from(message['result'] as Map));
    }
  }

  void _disconnect() {
    if (!_closed) invalidations.add('VmDisconnected');
    for (final pending in _pending.values) {
      pending.completeError(StateError('VM 连接已关闭，停止当前核心旅程'));
    }
    _pending.clear();
  }

  Future<Map<String, Object?>> call(
    String method, [
    Map<String, Object?> parameters = const {},
  ]) async {
    final id = '${++_sequence}';
    final result = Completer<Map<String, Object?>>();
    _pending[id] = result;
    socket.add(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        'params': parameters,
      }),
    );
    try {
      return await result.future.timeout(const Duration(seconds: 10));
    } finally {
      _pending.remove(id);
    }
  }

  Future<Map<String, Object?>> attach({
    String libraryUri = fontServiceLibrary,
  }) async {
    await call('streamListen', {'streamId': 'Isolate'});
    final vm = await call('getVM');
    final isolates = (vm['isolates'] as List).cast<Map>();
    final main = isolates
        .where((isolate) => isolate['name'] == 'main')
        .toList();
    if (main.length != 1) throw StateError('无法唯一识别产品 main isolate');
    isolateId = main.single['id'] as String;
    final groups = (vm['isolateGroups'] as List).cast<Map>();
    for (final group in groups) {
      final details = await call('getIsolateGroup', {
        'isolateGroupId': group['id'],
      });
      if ((details['isolates'] as List).cast<Map>().any(
        (entry) => entry['id'] == isolateId,
      )) {
        isolateGroupId = group['id'] as String;
        break;
      }
    }
    if (isolateGroupId == null) throw StateError('无法识别产品isolate group');
    final isolate = await call('getIsolate', {'isolateId': isolateId});
    final libraries = (isolate['libraries'] as List).cast<Map>();
    final matching = libraries
        .where(
          (library) =>
              library['uri'] == libraryUri ||
              libraryUri.startsWith('file:') &&
                  Uri.decodeFull('${library['uri']}').toLowerCase() ==
                      Uri.decodeFull(libraryUri).toLowerCase(),
        )
        .toList();
    if (matching.length != 1) throw StateError('当前进程没有真实产品字体服务库');
    libraryId = matching.single['id'] as String;
    return {
      'pid': vm['pid'],
      'vmStartTime': vm['startTime'],
      'isolateId': isolateId,
      'isolateStartTime': isolate['startTime'],
    };
  }

  Future<Map<String, Object?>> evaluateSnapshot(List<String> ids) async {
    if (invalidations.isNotEmpty) throw StateError('检测到重载、重启或VM断连');
    var value = await call('evaluate', {
      'isolateId': isolateId,
      'targetId': libraryId,
      'expression': fontSnapshotExpression(ids),
    });
    if (value['type'] == 'ErrorRef') throw StateError('产品只读表达式无法求值');
    if (value['valueAsStringIsTruncated'] == true) {
      value = await call('getObject', {
        'isolateId': isolateId,
        'objectId': value['id'],
        'offset': 0,
        'count': 1024 * 1024,
      });
    }
    if (value['valueAsStringIsTruncated'] == true) {
      throw StateError('产品快照超限');
    }
    final snapshot = jsonDecode(value['valueAsString'] as String) as Map;
    if (snapshot['serviceReady'] != true) {
      throw StateError('请先在真实产品打开一次字体选择器，再记录基线');
    }
    if (snapshot['api'] != acceptanceApi) {
      throw StateError('产品实际 API 与固定联验地址不一致');
    }
    if (snapshot['dynamicEnabled'] != true ||
        snapshot['catalogRevision'] is! int ||
        (snapshot['catalogRevision'] as int) < 0) {
      throw StateError('动态字体能力或目录尚未就绪，不能记录联验基线');
    }
    return Map<String, Object?>.from(snapshot);
  }

  Future<Map<String, Object?>> memory() async => {
    'dart': await call('getMemoryUsage', {'isolateId': isolateId}),
    'process': await call('getProcessMemoryUsage'),
    'forcedGc': false,
  };

  Future<void> close() async {
    _closed = true;
    await socket.close();
    await _subscription.cancel();
    _disconnect();
  }
}
