import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';

// 只连接当前测试进程的本地VM诊断口，不访问应用API或字体服务器。
class _DiagnosticHttp extends HttpOverrides {}

Future<Map<String, Object?>> measureFontVmMemory() async {
  final uri = (await developer.Service.getInfo()).serverUri;
  if (uri == null) return {'available': false};
  if (!['127.0.0.1', 'localhost', '::1'].contains(uri.host)) {
    throw StateError('VM诊断只允许本机');
  }
  return HttpOverrides.runWithHttpOverrides(() async {
    final socket = await WebSocket.connect(
      uri.replace(scheme: 'ws', path: '${uri.path}ws').toString(),
    );
    final messages = socket
        .map((data) => jsonDecode(data as String) as Map)
        .asBroadcastStream();
    var id = 0;
    Future<Map<String, Object?>> call(
      String method, [
      Map<String, Object?> parameters = const {},
    ]) async {
      final requestId = (++id).toString();
      final response = messages.firstWhere((m) => m['id'] == requestId);
      socket.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': requestId,
          'method': method,
          'params': parameters,
        }),
      );
      final result = await response.timeout(const Duration(seconds: 10));
      if (result['error'] != null) throw StateError('VM内存诊断失败：$method');
      return Map<String, Object?>.from(result['result'] as Map);
    }

    try {
      final isolate = {
        'isolateId': developer.Service.getIsolateId(Isolate.current),
      };
      await call('getAllocationProfile', {...isolate, 'gc': true});
      return {
        'available': true,
        'afterForcedGc': true,
        'dart': await call('getMemoryUsage', isolate),
        'process': await call('getProcessMemoryUsage'),
      };
    } finally {
      await socket.close();
    }
  }, _DiagnosticHttp());
}
