import 'dart:io';

import 'package:flutter/services.dart';

class EditorClipboardSnapshot {
  const EditorClipboardSnapshot({required this.text, this.html, this.marker});

  final String? text;
  final String? html;
  final String? marker;
}

abstract interface class EditorClipboardGateway {
  Future<EditorClipboardSnapshot> read();

  Future<void> write({required String text, required String marker});
}

class CallbackEditorClipboardGateway implements EditorClipboardGateway {
  CallbackEditorClipboardGateway({
    required this.readCallback,
    required this.writeCallback,
  });

  final Future<String?> Function() readCallback;
  final Future<void> Function(String text) writeCallback;
  String? _lastWrittenText;
  String? _lastMarker;

  @override
  Future<EditorClipboardSnapshot> read() async {
    final text = await readCallback();
    return EditorClipboardSnapshot(
      text: text,
      marker: text == _lastWrittenText ? _lastMarker : null,
    );
  }

  @override
  Future<void> write({required String text, required String marker}) async {
    await writeCallback(text);
    _lastWrittenText = text;
    _lastMarker = marker;
  }
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
        html: raw?['html'] as String?,
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
