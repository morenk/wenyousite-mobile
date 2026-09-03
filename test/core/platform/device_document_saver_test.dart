import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/platform/device_document_saver.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'wenyou_document_saver_test_',
    );
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('系统选择保存或取消后都清理临时档案', () async {
    final bridge = _DocumentBridge();
    final saver = DeviceDocumentSaver(
      bridge: bridge,
      temporaryDirectory: () async => temporaryDirectory,
    );
    final bytes = Uint8List.fromList([0x50, 0x4b, 0x03, 0x04, 1, 2, 3]);

    expect(
      await saver.save(
        bytes: bytes,
        fileName: '星海.zip',
        mimeType: 'application/zip',
      ),
      isTrue,
    );
    expect(bridge.savedBytes, bytes);
    expect(bridge.fileName, '星海.zip');
    expect(
      Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}wenyou_documents',
      ).listSync(),
      isEmpty,
    );

    bridge.shouldSave = false;
    expect(
      await saver.save(
        bytes: bytes,
        fileName: '星海.zip',
        mimeType: 'application/zip',
      ),
      isFalse,
    );
    expect(
      Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}wenyou_documents',
      ).listSync(),
      isEmpty,
    );
  });
}

class _DocumentBridge implements DocumentSaverPlatformBridge {
  bool shouldSave = true;
  Uint8List? savedBytes;
  String? fileName;

  @override
  Future<bool> saveDocument({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    savedBytes = await File(filePath).readAsBytes();
    this.fileName = fileName;
    return shouldSave;
  }
}
