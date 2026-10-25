// 只验证外部观察器与真实Dart VM协议，不冒充Android产品验收。
import 'dart:convert';
import 'dart:io';

import 'package:wenyousite_mobile/core/text_fonts/text_font_legacy_mapping.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_ledger.dart';

final _engineLedger = TextFontNativeLedger();
_Service? _processService = _Service();

class _Service {
  final api = _Api();
  final dynamicRuntime = _Dynamic();
  final _runtime = _Runtime();
  bool get dynamicEnabled => true;
  bool canPasteFont(String id) => dynamicRuntime.catalog.canPaste(id);
}

class _Api {
  final dio = _Dio();
}

class _Dio {
  final options = _Options();
}

class _Options {
  final baseUrl = 'http://127.0.0.1:38876/api/v1';
}

class _Dynamic {
  final catalog = _Catalog();
}

class _Catalog {
  int get revision => 7;
  bool canSelect(String id) => !withdrawn(id);
  bool canPaste(String id) => !withdrawn(id);
  bool canRender(String id) => !withdrawn(id);
  bool withdrawn(String id) => id.endsWith('f');
}

class _Runtime {
  final demandQueue = _Queue();
  List<String> loadedFamilies(String id) => ['WYF2-${id.substring(4)}-core'];
}

class _Queue {
  int get requests => 2;
  int get attemptedDownloadBytes => 123;
  int get verifiedDownloadBytes => 123;
  int get pendingCount => 0;
}

Future<void> main() async {
  _engineLedger.beginNativeAttempt(
    hash: 'a' * 64,
    family: 'fixture',
    inputBytes: 123,
  );
  _engineLedger.completeNativeAttempt(hash: 'a' * 64, family: 'fixture');
  stdout.writeln(
    jsonEncode({
      'ready': _processService!._runtime.demandQueue.pendingCount == 0,
      'pid': pid,
      'mapping': dynamicTextFontVersion('great-vibes'),
    }),
  );
  await stdin.first;
}
