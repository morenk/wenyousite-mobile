import 'dart:io';

import 'package:flutter/services.dart';

class EditorClipboardSnapshot {
  const EditorClipboardSnapshot({required this.text, this.marker});

  final String? text;
  final String? marker;
}

abstract interface class EditorClipboardGateway {
  Future<EditorClipboardSnapshot> read();

  Future<void> write({required String text, required String marker});
}

class PlatformEditorClipboardGateway implements EditorClipboardGateway {
  const PlatformEditorClipboardGateway();

  static const _channel = MethodChannel('site.wenyou.app/editor_clipboard');

  @override
  Future<EditorClipboardSnapshot> read() async {
    if (!Platform.isAndroid) {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return EditorClipboardSnapshot(text: data?.text);
    }
    try {
      final raw = await _channel.invokeMapMethod<Object?, Object?>('readText');
      return EditorClipboardSnapshot(
        text: raw?['text'] as String?,
        marker: raw?['marker'] as String?,
      );
    } on MissingPluginException {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return EditorClipboardSnapshot(text: data?.text);
    }
  }

  @override
  Future<void> write({required String text, required String marker}) async {
    if (!Platform.isAndroid) {
      await Clipboard.setData(ClipboardData(text: text));
      return;
    }
    try {
      await _channel.invokeMethod<void>('writeText', {
        'text': text,
        'marker': marker,
      });
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }
}
