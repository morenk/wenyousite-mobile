import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';

class EditorClipboardContractTestContractClipboardGateway
    implements EditorClipboardGateway {
  const EditorClipboardContractTestContractClipboardGateway({
    required this.text,
    this.html,
  });

  final String text;
  final String? html;

  @override
  Future<EditorClipboardSnapshot> read() async =>
      EditorClipboardSnapshot(text: text, html: html);

  @override
  Future<void> write({required String text, required String marker}) async {}
}

class EditorClipboardContractTestRoundTripClipboardGateway
    implements EditorClipboardGateway {
  EditorClipboardSnapshot snapshot = const EditorClipboardSnapshot(text: null);
  bool failWrites = false;
  int writeAttempts = 0;

  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;

  @override
  Future<void> write({required String text, required String marker}) async {
    writeAttempts += 1;
    snapshot = EditorClipboardSnapshot(text: text, marker: marker);
    if (failWrites) {
      throw PlatformException(code: 'clipboard-unavailable');
    }
  }
}

final contract =
    jsonDecode(
          File(
            'contracts/editor-clipboard-v2-fixtures.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

final goldenCases = (contract['goldenCases'] as List<dynamic>)
    .cast<Map<String, dynamic>>();

Map<String, dynamic> readerFixture(String id) =>
    goldenCases.singleWhere((fixture) => fixture['id'] == id);
