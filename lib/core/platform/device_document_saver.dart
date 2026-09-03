import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/document_saver.dart';

final deviceDocumentSaverProvider = Provider<DocumentSaver>(
  (ref) => DeviceDocumentSaver(),
);

abstract interface class DocumentSaverPlatformBridge {
  Future<bool> saveDocument({
    required String filePath,
    required String fileName,
    required String mimeType,
  });
}

class MethodChannelDocumentSaverBridge implements DocumentSaverPlatformBridge {
  const MethodChannelDocumentSaverBridge();

  static const _channel = MethodChannel('site.wenyou.app/document_saver');

  @override
  Future<bool> saveDocument({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    return await _channel.invokeMethod<bool>('saveDocument', {
          'filePath': filePath,
          'fileName': fileName,
          'mimeType': mimeType,
        }) ??
        false;
  }
}

class DeviceDocumentSaver implements DocumentSaver {
  DeviceDocumentSaver({
    this.bridge = const MethodChannelDocumentSaverBridge(),
    Future<Directory> Function()? temporaryDirectory,
    this.uuid = const Uuid(),
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final DocumentSaverPlatformBridge bridge;
  final Future<Directory> Function() _temporaryDirectory;
  final Uuid uuid;

  @override
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<bool> save({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (!isSupported) {
      throw const DocumentSaveException('当前设备暂不支持保存档案。');
    }
    if (bytes.isEmpty || fileName.trim().isEmpty || mimeType.trim().isEmpty) {
      throw const DocumentSaveException('档案内容无效，请重新导出。');
    }
    File? temporaryFile;
    try {
      final directory = Directory(
        '${(await _temporaryDirectory()).path}${Platform.pathSeparator}wenyou_documents',
      );
      await directory.create(recursive: true);
      temporaryFile = File(
        '${directory.path}${Platform.pathSeparator}${uuid.v4()}.zip',
      );
      await temporaryFile.writeAsBytes(bytes, flush: true);
      return await bridge.saveDocument(
        filePath: temporaryFile.path,
        fileName: fileName,
        mimeType: mimeType,
      );
    } on PlatformException {
      throw const DocumentSaveException('系统文件保存器暂时不可用，请重试。');
    } on FileSystemException {
      throw const DocumentSaveException('档案暂时无法写入本机，请检查存储空间。');
    } finally {
      if (temporaryFile != null) {
        try {
          if (await temporaryFile.exists()) await temporaryFile.delete();
        } on FileSystemException {
          // 系统写入已经结束，临时文件清理失败不改变用户可见结果。
        }
      }
    }
  }
}
