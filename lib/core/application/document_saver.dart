import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentSaveException implements Exception {
  const DocumentSaveException(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}

abstract interface class DocumentSaver {
  bool get isSupported;

  /// Returns false when the user closes the system picker without saving.
  Future<bool> save({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  });
}

final documentSaverProvider = Provider<DocumentSaver>(
  (ref) => const _UnsupportedDocumentSaver(),
);

class _UnsupportedDocumentSaver implements DocumentSaver {
  const _UnsupportedDocumentSaver();

  @override
  bool get isSupported => false;

  @override
  Future<bool> save({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) => Future.error(const DocumentSaveException('当前设备暂不支持保存档案。'));
}
